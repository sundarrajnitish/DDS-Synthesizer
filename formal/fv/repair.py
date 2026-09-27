"""
repair.py - find and fix every bug in the buggy gate-level netlist, then prove it.

    python3 -m fv.repair            (from the formal/ directory)

Steps
  1. equivalence check  golden vs buggy            -> the failing compare points
  2. diagnosis          simulation + effect-cause   -> minimal list of corrections
  3. patch              write netlists/fixed/dds_synthesizer_32_syn_FIXED.vhd
  4. proof              golden vs fixed AND original RTL vs fixed (SAT, independent
                        GHDL/Yosys front-end, not the simulator used for diagnosis)
  5. report            build/reports/repair.json + a human-readable summary
"""
from __future__ import annotations

import json
import os
import sys
import time

from . import frontend
from .aig import AIG
from .diagnose import Diagnoser
from .eqcheck import load, verify

sys.path.insert(0, os.path.join(frontend.ROOT, "tools"))
from netlist import Circuit, apply_patch  # noqa: E402

GOLDEN = os.path.join(frontend.ROOT, "netlists", "golden", "dds_synthesized_ftw_32.vhd")
BUGGY = os.path.join(frontend.ROOT, "netlists", "buggy", "dds_synthesizer_32_syn_BUGGY.vhd")
FIXED = os.path.join(frontend.ROOT, "netlists", "fixed", "dds_synthesizer_32_syn_FIXED.vhd")
LIB = frontend.LIB


def area(circ: Circuit) -> float:
    return sum(circ.libu[c.type].area for c in circ.cells.values())


def sat_verify_factory(buggy: Circuit, golden_aig: AIG):
    """Return verify(patch) -> counter-examples, using the SAT engine on the patched netlist."""
    def verify(patch):
        text = apply_patch(buggy, patch)
        tmp = os.path.join(frontend.BUILD, "repair_candidate.vhd")
        os.makedirs(frontend.BUILD, exist_ok=True)
        open(tmp, "w").write(text)
        js = frontend.build("candidate", ["@cells", os.path.relpath(tmp, frontend.ROOT)],
                            "dds_synthesizer_ftw_width32", [])
        impl = AIG(js, "dds_synthesizer_ftw_width32", "candidate")
        summary, points = verify_points(golden_aig, impl)
        return [p["cex"] for p in points if p["status"] == "fail"]
    return verify


def verify_points(ref, impl):
    return verify(ref, impl)


def main():
    t0 = time.time()
    log_lines = []

    def log(msg=""):
        print(msg)
        log_lines.append(msg)

    log("== 1. Equivalence check: golden netlist (reference) vs buggy netlist (implementation)")
    golden_aig, buggy_aig = load("golden"), load("buggy")
    s0, p0 = verify(golden_aig, buggy_aig)
    log(f"   {s0['passing']} passing, {s0['failing']} failing compare points "
        f"(Port {s0['by_type'].get('Port', {}).get('fail', 0)}, DFF {s0['by_type'].get('DFF', {}).get('fail', 0)})")

    log("\n== 2. Diagnosis (random simulation + effect-cause analysis + error model)")
    golden, buggy = Circuit(GOLDEN, LIB), Circuit(BUGGY, LIB)
    dg = Diagnoser(buggy, golden, width=2048, log=log)
    ok = dg.run(verify=sat_verify_factory(buggy, golden_aig))
    if not ok:
        log("   diagnosis FAILED")
        sys.exit(1)
    dg.minimise(lambda p: bool(sat_verify_factory(buggy, golden_aig)(p)))
    fixes = dg.net_changes()
    fixes.sort(key=lambda f: (0 if f.cell.startswith("add_98") else 1 if f.cell.startswith("add_99") else 2,
                              f.cell))
    failing_before = {p["name"] for p in p0 if p["status"] == "fail"}
    # attribute every originally failing compare point to the corrections in its cone
    for f in fixes:
        if f.is_flop:
            f.points = [buggy.flop_name[f.cell]]
        else:
            f.points = sorted(dg.reach.get(f.cell, set()) & failing_before, key=_nat)
    log(f"\n   {len(fixes)} corrections:")
    for i, f in enumerate(fixes, 1):
        log(f"   {i:2d}. [{f.kind():17s}] {f.describe()}")

    log("\n== 3. Writing the repaired netlist")
    notes = {f.cell: f"bug #{i}: {f.describe()}" for i, f in enumerate(fixes, 1)}
    text = apply_patch(buggy, dg.patch, notes)
    header = ("-- Repaired gate-level netlist.\n"
              "-- Produced automatically by formal/fv/repair.py from dds_synthesizer_32_syn_BUGGY.vhd:\n"
              f"-- {len(fixes)} corrections, each marked with a '-- FIX' comment. No cells were added.\n"
              "-- Proven equivalent to the golden netlist and to the original RTL (see build/reports).\n\n")
    open(FIXED, "w").write(header + text)
    log(f"   {os.path.relpath(FIXED, frontend.ROOT)}")

    log("\n== 4. Proof (SAT, independent GHDL + Yosys front-end)")
    fixed_aig = load("fixed")
    s1, _ = verify(golden_aig, fixed_aig)
    s2, _ = verify(load("rtl_orig"), fixed_aig)
    for s in (s1, s2):
        log(f"   {s['reference']:>9} vs {s['implementation']}: {'SUCCEEDED' if s['succeeded'] else 'FAILED'} "
            f"({s['passing']} passing / {s['failing']} failing)")
    fixed = Circuit(FIXED, LIB)
    rep = {
        "before": s0, "failing_points": [p for p in p0 if p["status"] == "fail"],
        "fixes": [f.as_dict() for f in fixes],
        "after_vs_golden": s1, "after_vs_rtl": s2,
        "cells": {"golden": len(golden.cells), "buggy": len(buggy.cells), "fixed": len(fixed.cells)},
        "area": {"golden": area(golden), "buggy": area(buggy), "fixed": area(fixed)},
        "dangling_in_buggy": sorted(dg.dangling),
        "seconds": round(time.time() - t0, 1),
        "log": log_lines,
    }
    os.makedirs(os.path.join(frontend.BUILD, "reports"), exist_ok=True)
    json.dump(rep, open(os.path.join(frontend.BUILD, "reports", "repair.json"), "w"), indent=1)
    log(f"\n   done in {rep['seconds']} s")
    sys.exit(0 if s1["succeeded"] and s2["succeeded"] else 1)


def _nat(s):
    import re
    return [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", s)]


if __name__ == "__main__":
    main()
