"""
sim_vs_formal.py - how long would *simulation* take to find each bug?

For every one of the diagnosed bugs we build a netlist that contains only that
bug (the repaired netlist with one correction undone) and compare two ways of
finding it:

  formal     : one SAT-based equivalence check (eqcheck) - milliseconds,
               exhaustive, with a counter-example.
  simulation : cycle-based random simulation from reset, LANES independent
               random tests in parallel (one per bit of a Python int), each with
               its own random tuning word and phase offset, comparing the
               outputs against the golden netlist every clock.

Reported per bug: the fraction of random tests that saw a wrong output within
1, 10, 100, 1000 ... cycles, and the median detection time.
"""
from __future__ import annotations

import json
import os
import random
import sys
import time

from . import frontend
from .aig import AIG
from .eqcheck import load, verify

sys.path.insert(0, os.path.join(frontend.ROOT, "tools"))
from netlist import Circuit, apply_patch  # noqa: E402


def seq_sim(circ: Circuit, patch, stim, lanes, cycles, watch):
    """Simulate from reset; returns per-cycle list of output words (dict name->int)."""
    mask = (1 << lanes) - 1
    state = {name: 0 for name in set(circ.flop_name.values())}
    outs = []
    for t in range(cycles):
        leaves = dict(state)
        leaves.update(stim)
        v = circ.simulate(leaves, lanes, patch=patch)
        cp = circ.compare_values(v)
        for cname, (tp, ins, inv) in (patch or {}).items():
            if cname in circ.flops:
                cp[circ.flop_name[cname]] = v.get(ins["D"], 0)
        outs.append({o: v.get(circ.outputs[o], 0) for o in watch})
        state = {name: cp[name] for name in state}
    return outs


def run(lanes=512, cycles=4096, seed=7, log=print):
    rep = json.load(open(os.path.join(frontend.BUILD, "reports", "repair.json")))
    golden = Circuit(os.path.join(frontend.ROOT, "netlists", "golden", "dds_synthesized_ftw_32.vhd"), frontend.LIB)
    fixed = Circuit(os.path.join(frontend.ROOT, "netlists", "buggy", "dds_synthesizer_32_syn_BUGGY.vhd"), frontend.LIB)
    rng = random.Random(seed)
    stim = {}
    for i in range(32):
        stim[f"ftw_i[{i}]"] = rng.getrandbits(lanes)
    for i in range(10):
        stim[f"phase_i[{i}]"] = rng.getrandbits(lanes)
    watch = [f"ampl_o[{i}]" for i in range(10)] + [f"phase_o[{i}]" for i in range(10)]
    t0 = time.time()
    ref = seq_sim(golden, None, stim, lanes, cycles, watch)
    log(f"  golden reference simulated: {lanes} random tests x {cycles} cycles ({time.time() - t0:.1f} s)")
    full = {f["cell"]: (f["new_type"], f["new_ins"], f["invert_out"]) for f in rep["fixes"]}
    golden_aig = load("golden")
    results = []
    for i, f in enumerate(rep["fixes"], 1):
        patch = {c: s for c, s in full.items() if c != f["cell"]}      # every fix except this one
        # simulation
        t0 = time.time()
        got = seq_sim(fixed, patch, stim, lanes, cycles, watch)
        first = [None] * lanes
        seen = 0
        for t in range(cycles):
            diff = 0
            for o in watch:
                diff |= ref[t][o] ^ got[t][o]
            new = diff & ~seen
            if new:
                for b in range(lanes):
                    if new >> b & 1:
                        first[b] = t
                seen |= new
        sim_s = time.time() - t0
        det = sorted(x for x in first if x is not None)
        buckets = {n: sum(1 for x in det if x < n) / lanes for n in (1, 10, 100, 1000, cycles)}
        median = det[len(det) // 2] if len(det) * 2 > lanes else None
        # formal: one equivalence check on the single-bug netlist
        tmp = os.path.join(frontend.BUILD, "single_bug.vhd")
        open(tmp, "w").write(apply_patch(fixed, patch))
        t1 = time.time()
        impl = AIG(frontend.build(f"single_{i}", ["@cells", os.path.relpath(tmp, frontend.ROOT)],
                                  "dds_synthesizer_ftw_width32", []), "dds_synthesizer_ftw_width32")
        summ, pts = verify(golden_aig, impl)
        formal_s = time.time() - t1
        failing = [p["name"] for p in pts if p["status"] == "fail"]
        rec = {"bug": i, "cell": f["cell"], "description": f["description"],
               "sim": {"lanes": lanes, "cycles": cycles, "detected": len(det) / lanes,
                       "median_cycles": median, "within": buckets, "seconds": round(sim_s, 2)},
               "formal": {"failing_points": failing, "seconds": round(formal_s, 2)}}
        log(f"  bug {i:2d} {f['cell']:32s} sim: {100 * len(det) / lanes:5.1f}% of tests detect it "
            f"(median {median if median is not None else '>' + str(cycles)} cycles) | "
            f"formal: {len(failing)} failing points")
        results.append(rec)
    return results


def main():
    res = run()
    json.dump(res, open(os.path.join(frontend.BUILD, "reports", "sim_vs_formal.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
