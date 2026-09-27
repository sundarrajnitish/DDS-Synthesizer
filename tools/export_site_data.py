#!/usr/bin/env python3
"""
export_site_data.py - package the verification results and the gate-level
netlists as JSON for the web site in docs/ (which runs its own BDD-based
equivalence checker in the browser on exactly these netlists).

    python3 tools/export_site_data.py        (after `make formal`)
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import gen_sine_lut  # noqa: E402
import liberty  # noqa: E402
from netlist import Circuit  # noqa: E402

REP = os.path.join(ROOT, "build", "reports")
OUT = os.path.join(ROOT, "docs", "data")
LIB = os.path.join(ROOT, "lib", "class.lib")

NETLISTS = {
    "golden": "netlists/golden/dds_synthesized_ftw_32.vhd",
    "buggy": "netlists/buggy/dds_synthesizer_32_syn_BUGGY.vhd",
    "manual": "netlists/manual_attempts/05_bug_20_lut_out_inv_delay_reg_8_inst.vhd",
    "yosys_src": None,
}


def export_circuit(c: Circuit):
    nets = ["0", "1"]
    idx = {"0": 0, "1": 1}

    def n(x):
        if x is None:
            return 0
        if x not in idx:
            idx[x] = len(nets)
            nets.append(x)
        return idx[x]
    for b in c.inputs:
        n(b)
    cells = []
    for cell in c.order:
        cells.append([cell.name, cell.type, [n(cell.ins[p]) for p in c.libu[cell.type].inputs],
                      [n(cell.outs.get(p)) for p in c.libu[cell.type].outputs]])
    flops = []
    for name, f in sorted(c.flops.items()):
        flops.append([c.flop_name[name], name, n(f.ins["D"]),
                      n(f.outs.get("Q")) if f.outs.get("Q") else -1,
                      n(f.outs.get("QN")) if f.outs.get("QN") else -1])
    return {"nets": nets, "inputs": {b: idx[b] for b in c.inputs},
            "outputs": {b: n(x) for b, x in c.outputs.items()}, "cells": cells, "flops": flops,
            "area": sum(c.libu[x.type].area for x in c.cells.values()), "ncells": len(c.cells)}


def main():
    os.makedirs(OUT, exist_ok=True)
    lib = liberty.read_liberty(LIB)
    libu = {k.upper(): v for k, v in lib.items()}
    circuits = {k: Circuit(os.path.join(ROOT, p), LIB) for k, p in NETLISTS.items() if p}
    used = sorted({x.type for c in circuits.values() for x in c.cells.values()} |
                  {"AN2", "OR2", "NR2", "ND2", "AN3", "NR3", "OR3", "ND3", "EO", "EN", "IV", "IBUF1"})
    cells = {t: {"in": libu[t].inputs, "out": {p: liberty.parse_expr(f) for p, f in libu[t].outputs.items()},
                 "area": libu[t].area} for t in used if t in libu}
    rep = json.load(open(os.path.join(REP, "repair.json")))
    data = {"lib": cells, "designs": {k: export_circuit(c) for k, c in circuits.items()},
            "fixes": rep["fixes"]}
    json.dump(data, open(os.path.join(OUT, "netlists.json"), "w"), separators=(",", ":"))

    def load(name, default=None):
        p = os.path.join(REP, name)
        return json.load(open(p)) if os.path.exists(p) else default

    eq = load("equivalence.json", [])
    import glob
    cells_of = {"golden": len(circuits["golden"].cells), "buggy": len(circuits["buggy"].cells)}
    for i, f in enumerate(sorted(glob.glob(os.path.join(ROOT, "netlists", "manual_attempts", "*.vhd"))), 1):
        c = Circuit(f, LIB)
        cells_of[f"manual_{i:02d}"] = len(c.cells)
        cells_of[f"manual_{i:02d}_file"] = os.path.basename(f)
        cells_of[f"manual_{i:02d}_area"] = sum(c.libu[x.type].area for x in c.cells.values())
    for m in eq:                      # keep the page light: points only where useful
        if m["implementation"] not in ("buggy", "manual_05"):
            m["points"] = [p for p in m["points"] if p["status"] == "fail"]
    results = {
        "equivalence": eq,
        "repair": {k: rep[k] for k in ("before", "fixes", "after_vs_golden", "after_vs_rtl",
                                        "cells", "area", "dangling_in_buggy", "log", "seconds")},
        "seq_equiv": load("seq_equiv.json"),
        "properties": load("properties.json"),
        "mutants": load("mutants.json"),
        "theorems": load("theorems.json"),
        "sim_vs_formal": load("sim_vs_formal.json"),
        "cells_of": cells_of,
        "yosys_equiv": load("yosys_equiv.json"),
        "yosys_stat": open(os.path.join(REP, "yosys_synth_stat.txt")).read()
        if os.path.exists(os.path.join(REP, "yosys_synth_stat.txt")) else "",
    }
    json.dump(results, open(os.path.join(OUT, "results.json"), "w"), separators=(",", ":"))
    json.dump({"quarter": gen_sine_lut.table(10, 10), "full": gen_sine_lut.full_wave(10, 10)},
              open(os.path.join(OUT, "lut.json"), "w"), separators=(",", ":"))
    for f in sorted(os.listdir(OUT)):
        print(f"docs/data/{f}: {os.path.getsize(os.path.join(OUT, f)) // 1024} KB")


if __name__ == "__main__":
    main()
