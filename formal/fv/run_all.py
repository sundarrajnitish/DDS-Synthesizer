"""
run_all.py - the complete open-source verification flow, one command.

    cd formal && python3 -m fv.run_all            (or: make formal)

  1. liberty self-test                 cell functions parsed from class.lib
  2. equivalence matrix                RTL <-> RTL, RTL <-> netlists, golden <-> buggy/fixed/attempts
  3. automatic bug diagnosis + repair  (fv.repair)
  4. sequential equivalence            original RTL <-> lean 62-flop RTL (k-induction)
  5. property proofs                   4 properties by k-induction + 7 mutants killed
  6. theorems                          Z3 lemmas behind the design
  7. simulation vs formal              (skipped with --quick)
Writes build/reports/*.json and build/reports/summary.txt; exits non-zero on any
unexpected result, so it doubles as the CI regression.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time

from . import frontend
from .eqcheck import load, verify
from .induction import prove_property, seq_equiv

REPORTS = os.path.join(frontend.BUILD, "reports")

MATRIX = [
    # reference, implementation, expected outcome, what it shows
    ("rtl_orig", "rtl", True, "refactored RTL is cycle-exact with the original"),
    ("rtl_orig", "golden", True, "synthesis (Design Compiler) preserved the function"),
    ("rtl", "golden", True, "refactored RTL also matches the synthesized netlist"),
    ("rtl", "yosys", True, "open-source synthesis (Yosys + ABC) is correct too"),
    ("golden", "buggy", False, "the hand-out netlist is broken (42 failing points)"),
    ("golden", "fixed", True, "the automatically repaired netlist is correct"),
    ("rtl_orig", "fixed", True, "... and matches the original RTL too"),
    ("golden", "manual_01", False, "2024 manual repair attempt 1"),
    ("golden", "manual_02", False, "2024 manual repair attempt 2"),
    ("golden", "manual_03", False, "2024 manual repair attempt 3"),
    ("golden", "manual_04", False, "2024 manual repair attempt 4"),
    ("golden", "manual_05", False, "2024 manual repair attempt 5 (latest)"),
]


def yosys_equiv(ref, imp):
    """Yosys' own equivalence engine: match flip-flops and ports by name
    (everything else hidden), then equiv_simple + equiv_induct."""
    frontend.build(ref)
    frontend.build(imp)
    top = frontend.DESIGNS[ref][2]
    script = []
    for key, name in ((ref, "gold"), (imp, "gate")):
        script += [f"read_verilog {os.path.join(frontend.BUILD, 'fe', key, 'design.v')}",
                   f"hierarchy -top {top}", "proc", "flatten", "opt_clean",
                   "rename -hide w:* w:*.iq %d", f"rename {top} {name}", f"design -stash {name}"]
    script += ["design -copy-from gold -as gold gold", "design -copy-from gate -as gate gate", "async2sync",
               "equiv_make gold gate equiv", "hierarchy -top equiv", "equiv_simple", "equiv_induct",
               "tee -o equiv_status.txt equiv_status"]
    wd = os.path.join(frontend.BUILD, "yosys_equiv", imp)
    os.makedirs(wd, exist_ok=True)
    open(os.path.join(wd, "check.ys"), "w").write("\n".join(script) + "\n")
    subprocess.run(["yosys", "-q", "-s", "check.ys"], cwd=wd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    txt = open(os.path.join(wd, "equiv_status.txt")).read()
    import re as _re
    m = _re.search(r"Of those cells (\d+) are proven and (\d+) are unproven", txt)
    return {"proven": int(m.group(1)), "unproven": int(m.group(2))} if m else {"proven": 0, "unproven": -1}


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true", help="skip the slow simulation-vs-formal experiment")
    a = ap.parse_args(argv)
    os.makedirs(REPORTS, exist_ok=True)
    t0 = time.time()
    ok = True
    lines = []

    def say(s=""):
        print(s, flush=True)
        lines.append(s)

    def expect(cond, what):
        nonlocal ok
        if not cond:
            ok = False
            say(f"  !! UNEXPECTED: {what}")

    say("== 1. Liberty cell library")
    sys.path.insert(0, os.path.join(frontend.ROOT, "tools"))
    import liberty
    cells = liberty.read_liberty(frontend.LIB)
    say(f"  {len(cells)} cells in class.lib, {sum(liberty.usable(c) for c in cells.values())} modelled; "
        f"{liberty.self_test(cells)} checked exhaustively against hand-written truth tables")

    say("\n== 2. Automatic diagnosis and repair of the buggy netlist")
    r = subprocess.run([sys.executable, "-m", "fv.repair"], cwd=os.path.join(frontend.ROOT, "formal"),
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for l in r.stdout.splitlines():
        if l.startswith("   ") and ("[" in l[:8] or "vs" in l or "corrections" in l):
            say(l)
    expect(r.returncode == 0, "repair did not prove the fixed netlist")

    say("\n== 3. Open-source synthesis of the refactored RTL (Yosys + ABC onto class.lib)")
    frontend.build("rtl")
    subprocess.run([sys.executable, os.path.join(frontend.ROOT, "tools", "liberty.py"), frontend.LIB,
                    "--liberty-min", os.path.join(frontend.BUILD, "class_min.lib")], check=True,
                   stderr=subprocess.DEVNULL)
    subprocess.run(["yosys", "-q", "-s", "scripts/yosys/synth_class.ys"], cwd=frontend.ROOT, check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    stat = open(os.path.join(REPORTS, "yosys_synth_stat.txt")).read()
    import re as _re
    ncell = _re.search(r"Number of cells:\s+(\d+)", stat).group(1)
    area = _re.search(r"Chip area[^:]*:\s+([\d.]+)", stat).group(1)
    say(f"  {ncell} cells, area {float(area):.0f} -> netlists/yosys/dds_synthesizer_yosys.v")

    say("\n== 4. Equivalence matrix (combinational, register matching, SAT)")
    matrix = []
    for ref, imp, want, why in MATRIX:
        s, pts = verify(load(ref), load(imp))
        rec = {"reference": ref, "implementation": imp, "expected_equivalent": want, "meaning": why,
               "summary": s, "points": pts}
        matrix.append(rec)
        verdict = "EQUIVALENT" if s["succeeded"] else "NOT EQUIVALENT"
        say(f"  {ref:>9} vs {imp:<10} {verdict:15s} {s['passing']:3d} pass {s['failing']:3d} fail  - {why}")
        expect(s["succeeded"] == want, f"{ref} vs {imp}")
    json.dump(matrix, open(os.path.join(REPORTS, "equivalence.json"), "w"))

    say("\n   independent cross-check with Yosys equiv_make / equiv_induct (netlist vs netlist)")
    ycheck = []
    for imp, want in (("buggy", False), ("fixed", True), ("manual_05", False)):
        res = yosys_equiv("golden", imp)
        ycheck.append({"reference": "golden", "implementation": imp, **res})
        say(f"     golden vs {imp:<10} yosys: {res['proven']} proven, {res['unproven']} unproven $equiv cells")
        expect((res["unproven"] == 0) == want, f"yosys cross-check golden vs {imp}")
    json.dump(ycheck, open(os.path.join(REPORTS, "yosys_equiv.json"), "w"), indent=1)

    say("\n== 5. Sequential equivalence: original RTL vs lean RTL (register correspondence + k-induction)")
    seq = []
    ro, le = load("rtl_orig"), load("lean")
    for k in (1, 2):
        res = seq_equiv(ro, le, k)
        seq.append(res)
        say(f"  k={k}: {res['status']}  ({res['matched_registers']} matched registers, "
            f"{len(res['ref_only'])} only in original, {len(res['impl_only'])} only in lean)")
    expect(seq[-1]["status"] == "EQUIVALENT", "lean design not proven")
    json.dump({"flops": {"rtl_orig": len(ro.regs), "lean": len(le.regs)}, "runs": seq},
              open(os.path.join(REPORTS, "seq_equiv.json"), "w"), indent=1)

    say("\n== 6. Property proofs (k-induction on the refactored RTL)")
    pa = load("props")
    props = []
    for p in ["p_sine", "p_range", "p_step", "p_offset"]:
        tries = []
        for k in (1, 2, 3):
            res = prove_property(pa, p, k)
            tries.append({"k": k, "status": res["status"], "seconds": res["seconds"]})
            if res["status"] != "UNDECIDED":
                break
        props.append({"property": p, "tries": tries, "status": tries[-1]["status"], "k": tries[-1]["k"]})
        say(f"  {p:9s} " + ", ".join(f"k={t['k']}: {t['status']}" for t in tries))
        expect(tries[-1]["status"] == "PROVEN", p)
    json.dump(props, open(os.path.join(REPORTS, "properties.json"), "w"), indent=1)

    say("\n   mutation testing of the properties")
    from . import mutants
    muts = mutants.run(log=say)
    json.dump(muts, open(os.path.join(REPORTS, "mutants.json"), "w"), indent=1)
    expect(all(m["killed_by"] for m in muts), "a mutant survived")

    say("\n== 7. Theorems (Z3)")
    from . import theorems
    th = theorems.lemmas()
    for t in th:
        say(f"  {t['id']:4s} {t['status']:7s} {t['statement'][:90]}")
        expect(t["status"] == ("FALSE" if t["id"] == "T2b" else "PROVEN"), t["id"])
    json.dump(th, open(os.path.join(REPORTS, "theorems.json"), "w"), indent=1)

    if not a.quick:
        say("\n== 8. Simulation vs formal: random simulation against each single bug")
        from . import sim_vs_formal
        svf = sim_vs_formal.run(lanes=256, cycles=2048, log=say)
        json.dump(svf, open(os.path.join(REPORTS, "sim_vs_formal.json"), "w"), indent=1)

    say(f"\n{'ALL CHECKS PASSED' if ok else 'SOME CHECKS FAILED'} in {time.time() - t0:.0f} s")
    open(os.path.join(REPORTS, "summary.txt"), "w").write("\n".join(lines) + "\n")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
