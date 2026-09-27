"""
eqcheck.py - combinational equivalence checking with register matching,
the core algorithm behind Synopsys Formality and Cadence Conformal LEC.

Flow (identical in spirit to the commercial tools):
  1. read  : reference and implementation -> AIG               (frontend.py)
  2. match : pair up compare points - primary outputs by port name,
             flip-flops by (canonical) instance name
  3. verify: for every matched compare point, prove with SAT that
                 f_ref(inputs, registers) XOR f_impl(inputs, registers)
             is unsatisfiable. Matched register outputs are shared free
             variables ("cut points"), so each check is small.
  4. unmatched registers are checked for being constant (Design Compiler
     removes flops that can never leave their reset value).
  5. report: passing / failing / aborted counts, per type, plus a
     counter-example for each failing point.

Usage:
  python3 -m fv.eqcheck golden buggy        (run from the formal/ directory)
"""
from __future__ import annotations

import argparse
import json
import sys
import time

from . import frontend
from .aig import AIG
from .sat import CNF


def load(key: str) -> AIG:
    desc, files, top, flags = frontend.DESIGNS[key]
    return AIG(frontend.build(key), top, label=key)


def compare_points(ref: AIG, impl: AIG):
    pts, unmatched_ref, unmatched_impl = [], [], []
    for k in ref.outputs:
        if k in impl.outputs:
            pts.append(("Port", k, ref.outputs[k], impl.outputs[k]))
    for k, r in ref.regs.items():
        if k in impl.regs:
            pts.append(("DFF", k, r.d, impl.regs[k].d))
        else:
            unmatched_ref.append(k)
    unmatched_impl = [k for k in impl.regs if k not in ref.regs]
    return pts, unmatched_ref, unmatched_impl


def match_by_function(ref: AIG, impl: AIG, ur, ui, cnf, seed=1, width=256):
    """Second matching pass for registers whose names differ (renamed, or merged
    by the synthesis tool): compare random-simulation signatures of their
    next-state functions, then confirm each candidate pair with SAT. This is the
    'signature analysis' step of commercial equivalence checkers."""
    import random
    rng = random.Random(seed)
    alias = {}
    ur = [r for r in ur]
    rand = {}

    def val(name):
        if name not in rand:
            rand[name] = rng.getrandbits(width)
        return rand[name]
    changed = True
    while changed and ur:
        changed = False
        vi = {n: val(k) for k, n in impl.inputs.items()}
        vi.update({r.q: val(k) for k, r in impl.regs.items()})
        vr = {n: val(k) for k, n in ref.inputs.items()}
        vr.update({r.q: val(alias.get(k, k) if (k in alias or k in impl.regs) else "ref:" + k)
                   for k, r in ref.regs.items()})
        si, sr = impl.simulate(vi, width), ref.simulate(vr, width)
        sig = lambda v, d: v[d] if isinstance(d, int) and d not in (0, 1) else ((1 << width) - 1 if d == 1 else 0)
        by_sig = {}
        for k in list(ui) + [k for k in impl.regs if k not in ui]:
            by_sig.setdefault((sig(si, impl.regs[k].d), impl.regs[k].init), []).append(k)
        for r in list(ur):
            cands = by_sig.get((sig(sr, ref.regs[r].d), ref.regs[r].init), [])
            for i in cands:
                la = cnf.encode(ref, ref.regs[r].d, did=("fm", r, i),
                                leaf_lit=lambda n: cnf.leaf_var(alias.get(n, n)))
                lb = cnf.encode(impl, impl.regs[i].d, did="i")
                x = cnf.xor(la, lb)
                if not cnf.solve([x]):
                    alias[r] = i
                    ur.remove(r)
                    if i in ui:
                        ui.remove(i)
                    changed = True
                    break
    return alias, ur, ui


def verify(ref: AIG, impl: AIG, want_cex=True, quiet=False):
    t0 = time.time()
    pts, ur, ui = compare_points(ref, impl)
    cnf = CNF()
    alias, ur, ui = match_by_function(ref, impl, ur, ui, cnf) if (ur and ui) or ur else ({}, ur, ui)
    for r, i in alias.items():
        pts.append(("DFF", r, ref.regs[r].d, impl.regs[i].d))
    ref_leaf = (lambda n: cnf.leaf_var(alias.get(n, n))) if alias else None

    # 1) constant-register detection (fix-point) for flops without a partner.
    #    A flop is constant if, assuming the flops already known to be constant,
    #    its next-state function always equals its reset value (an inductive proof).
    constants, unmatched = {}, []
    todo = [("reference", ref, k, "r") for k in ur] + [("implementation", impl, k, "i") for k in ui]
    changed = True
    while changed:
        changed = False
        assume = [cnf.leaf_var(k) if v else -cnf.leaf_var(k) for k, v in constants.items()]
        for side, aig, k, did in todo:
            if k in constants:
                continue
            r = aig.regs[k]
            lit = cnf.encode(aig, r.d, did=did, leaf_lit=ref_leaf if did == "r" else None)
            if not cnf.solve(assume + [lit if r.init == 0 else -lit]):
                constants[k] = r.init
                changed = True
    for side, aig, k, did in todo:
        unmatched.append({"side": side, "name": k, "constant": k in constants,
                          "value": aig.regs[k].init})
    for k, v in constants.items():
        cnf.solver.add_clause([cnf.leaf_var(k) if v else -cnf.leaf_var(k)])

    # 2) one SAT query per matched compare point
    results = []
    for typ, name, a, b in pts:
        la = cnf.encode(ref, a, did="r", leaf_lit=ref_leaf)
        lb = cnf.encode(impl, b, did="i")
        rec = {"type": typ, "name": name}
        if name in alias:
            rec["matched_to"] = alias[name]
        if la == lb:
            rec["status"] = "pass"
        else:
            x = cnf.xor(la, lb)
            if cnf.solve([x]):
                rec["status"] = "fail"
                if want_cex:
                    sup = sorted((ref.support(a) | impl.support(b)) - set(constants), key=_nat)
                    leaves = cnf.model_leaves()
                    rec["cex"] = {s: leaves.get(s, 0) for s in sup}
                    rec["ref_value"] = cnf.value(la)
                    rec["impl_value"] = cnf.value(lb)
            else:
                rec["status"] = "pass"
                cnf.solver.add_clause([-x])     # learnt equivalence helps later points
        if typ == "DFF" and ref.regs[name].init != impl.regs[alias.get(name, name)].init:
            rec["status"] = "fail"
            rec["note"] = "different reset value"
        results.append(rec)
    cnf.close()
    summary = summarize(results)
    summary.update({"reference": ref.label, "implementation": impl.label,
                    "unmatched": unmatched, "seconds": round(time.time() - t0, 2),
                    "matched_by_function": alias,
                    "succeeded": summary["failing"] == 0 and
                    all(u["constant"] for u in unmatched)})
    return summary, results


def summarize(results):
    s = {"passing": 0, "failing": 0, "by_type": {}}
    for r in results:
        t = s["by_type"].setdefault(r["type"], {"pass": 0, "fail": 0})
        t[r["status"]] += 1
        s["passing" if r["status"] == "pass" else "failing"] += 1
    return s


def report(summary, results, out=sys.stdout, show_fail=50):
    w = out.write
    w("*" * 30 + " Verification Results " + "*" * 30 + "\n")
    w(f"Verification {'SUCCEEDED' if summary['succeeded'] else 'FAILED'}\n")
    w("-" * 60 + "\n")
    w(f" Reference design:      {summary['reference']}\n")
    w(f" Implementation design: {summary['implementation']}\n")
    w(f" {summary['passing']} Passing compare points\n")
    w(f" {summary['failing']} Failing compare points\n")
    w(f" 0 Aborted compare points\n 0 Unverified compare points\n")
    w("-" * 60 + "\n")
    types = ["Port", "DFF"]
    w(f"{'Matched Compare Points':<26}" + "".join(f"{t:>8}" for t in types) + f"{'TOTAL':>8}\n")
    w("-" * 60 + "\n")
    for st, lab in (("pass", "Passing (equivalent)"), ("fail", "Failing (not equivalent)")):
        vals = [summary["by_type"].get(t, {}).get(st, 0) for t in types]
        w(f"{lab:<26}" + "".join(f"{v:>8}" for v in vals) + f"{sum(vals):>8}\n")
    w("*" * 82 + "\n")
    if summary.get("matched_by_function"):
        w("\nRegisters matched by function (names differ or merged by synthesis):\n")
        for r, i in summary["matched_by_function"].items():
            w(f"  {r:<28} == {i}\n")
    if summary["unmatched"]:
        w("\nUnmatched registers:\n")
        for u in summary["unmatched"]:
            what = f"constant {u['value']} (removed by synthesis - OK)" if u["constant"] else "NOT constant - unmatched!"
            w(f"  {u['side']:<15} {u['name']:<28} {what}\n")
    fails = [r for r in results if r["status"] == "fail"]
    if fails:
        w(f"\nFailing compare points ({len(fails)}):\n")
        for r in fails[:show_fail]:
            ce = r.get("cex", {})
            w(f"  {r['type']:<5} {r['name']:<26} ref={r.get('ref_value')} impl={r.get('impl_value')}  "
              f"support={len(ce)}\n")
        if len(fails) > show_fail:
            w(f"  ... {len(fails) - show_fail} more\n")
    w(f"\n({summary['seconds']} s)\n")


def _nat(s):
    import re
    return [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", s)]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("reference", choices=sorted(frontend.DESIGNS))
    ap.add_argument("implementation", choices=sorted(frontend.DESIGNS))
    ap.add_argument("--json", help="write machine-readable results here")
    ap.add_argument("--expect", choices=["pass", "fail"], help="exit non-zero unless the outcome matches")
    a = ap.parse_args(argv)
    ref, impl = load(a.reference), load(a.implementation)
    summary, results = verify(ref, impl)
    report(summary, results)
    if a.json:
        json.dump({"summary": summary, "points": results}, open(a.json, "w"), indent=1)
    if a.expect:
        ok = summary["succeeded"] == (a.expect == "pass")
        sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
