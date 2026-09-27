"""
frontend.py - turn VHDL (RTL or gate-level netlist) into a flat And-Inverter
Graph that the checkers in this package can reason about.

    VHDL --GHDL--> Verilog --Yosys (flatten, proc, aigmap)--> JSON --> AIG

Both the reference RTL and the Design Compiler netlists go through exactly
the same path, so neither side gets a "free pass" from a different parser.
The standard cells of class.lib are compiled from the Liberty file itself
(tools/liberty.py), never hand-written.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BUILD = os.path.join(ROOT, "build")
LIB = os.path.join(ROOT, "lib", "class.lib")

# Known designs of this project -------------------------------------------------
DESIGNS = {
    # key: (description, [vhdl files], top entity, ghdl flags)
    "rtl_orig": ("Original RTL (Kumm 2009, std_logic_arith)",
                 ["rtl/original/sine_lut_10_x_10.vhd", "rtl/original/dds_synthesizer.vhd"],
                 "dds_synthesizer", ["-fsynopsys", "-fexplicit"]),
    "rtl": ("Refactored RTL (numeric_std)",
            ["rtl/sine_lut_pkg.vhd", "rtl/dds_synthesizer.vhd"],
            "dds_synthesizer", []),
    "lean": ("Lean RTL (62 flip-flops, registered output)",
             ["rtl/sine_lut_pkg.vhd", "rtl/dds_synthesizer_lean.vhd"],
             "dds_synthesizer_lean", []),
    "props": ("Property monitor around the refactored RTL",
              ["rtl/sine_lut_pkg.vhd", "rtl/dds_synthesizer.vhd", "formal/props/sine_full_pkg.vhd",
               "formal/props/dds_props.vhd"],
              "dds_props", []),
    "yosys": ("Open-source synthesis (Yosys + ABC onto class.lib)",
              ["@cells", "netlists/yosys/dds_synthesizer_yosys.v"], "dds_synthesizer", []),
    "golden": ("Golden gate-level netlist (Design Compiler, class.lib)",
               ["@cells", "netlists/golden/dds_synthesized_ftw_32.vhd"],
               "dds_synthesizer_ftw_width32", []),
    "buggy": ("Buggy gate-level netlist (course hand-out)",
              ["@cells", "netlists/buggy/dds_synthesizer_32_syn_BUGGY.vhd"],
              "dds_synthesizer_ftw_width32", []),
    "fixed": ("Repaired gate-level netlist (this work)",
              ["@cells", "netlists/fixed/dds_synthesizer_32_syn_FIXED.vhd"],
              "dds_synthesizer_ftw_width32", []),
}
for _i, _f in enumerate(sorted(os.listdir(os.path.join(ROOT, "netlists", "manual_attempts")))
                        if os.path.isdir(os.path.join(ROOT, "netlists", "manual_attempts")) else []):
    if _f.endswith(".vhd"):
        DESIGNS["manual_" + _f.split("_")[0]] = (f"Manual repair attempt {_f}",
                                                 ["@cells", f"netlists/manual_attempts/{_f}"],
                                                 "dds_synthesizer_ftw_width32", [])


def _run(cmd, cwd):
    r = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if r.returncode:
        sys.stderr.write(r.stdout + r.stderr)
        raise RuntimeError(f"command failed: {' '.join(cmd)}")
    return r.stdout


def cells_vhdl() -> str:
    path = os.path.join(BUILD, "cells", "class_cells.vhd")
    if not os.path.exists(path) or os.path.getmtime(path) < os.path.getmtime(LIB):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        sys.path.insert(0, os.path.join(ROOT, "tools"))
        import liberty  # noqa: E402
        cells = liberty.read_liberty(LIB)
        open(path, "w").write(liberty.emit_vhdl(cells))
        open(os.path.join(BUILD, "cells", "class_cells.v"), "w").write(liberty.emit_verilog(cells))
        json.dump(liberty.to_json(cells), open(os.path.join(BUILD, "cells", "class_cells.json"), "w"))
    return path


def _rename_ghdl_regs(verilog: str) -> str:
    """GHDL names registers nNN_q and then does `assign sig = nNN_q; // (signal)`.
    Rename the register to the VHDL signal name so the flop keeps its RTL name."""
    pairs = dict(re.findall(r"assign\s+(\w+)\s*=\s*(n\d+_q)\s*;\s*//\s*\(signal\)", verilog))
    inv = {}
    for sig, reg in pairs.items():
        inv.setdefault(reg, sig)
    for reg, sig in inv.items():
        verilog = re.sub(rf"assign\s+{sig}\s*=\s*{reg}\s*;\s*//\s*\(signal\)\n", "", verilog)
        verilog = re.sub(rf"\bwire\s+(\[[^\]]*\]\s*)?{sig}\s*;\n", "", verilog)
        verilog = re.sub(rf"\b{reg}\b", sig, verilog)
    return verilog


def build(key: str, files=None, top=None, flags=None, force=False) -> dict:
    """Return the Yosys JSON (flattened, AIG-mapped) of a design, building it if needed."""
    if files is None:
        _, files, top, flags = DESIGNS[key]
    files = [cells_vhdl() if f == "@cells" else os.path.join(ROOT, f) for f in files]
    h = hashlib.sha1()
    for f in files:
        h.update(open(f, "rb").read())
    h.update(repr((top, flags)).encode())
    h.update(open(__file__, "rb").read())
    wd = os.path.join(BUILD, "fe", key)
    out_json = os.path.join(wd, "aig.json")
    stamp = os.path.join(wd, "hash")
    if not force and os.path.exists(out_json) and open(stamp).read() == h.hexdigest():
        return json.load(open(out_json))
    shutil.rmtree(wd, ignore_errors=True)
    os.makedirs(wd)
    if all(f.endswith(".v") for f in files if not f.endswith("class_cells.vhd")):
        # Verilog netlist (e.g. from Yosys): use the Verilog cell models, no GHDL
        cells_v = os.path.join(BUILD, "cells", "class_cells.v")
        v = open(cells_v).read() + "\n" + "\n".join(open(f).read() for f in files if f.endswith(".v"))
        open(os.path.join(wd, "design.v"), "w").write(v)
        return _yosys(wd, top, out_json, stamp, h)
    std = ["--std=93c"] if "-fsynopsys" in flags else ["--std=08"]
    if files and files[0].endswith("class_cells.vhd"):
        std = ["--std=93c"]
    _run(["ghdl", "-a", *std, *flags, *files], wd)
    v = _run(["ghdl", "--synth", *std, *flags, "--out=verilog", top], wd)
    v = _rename_ghdl_regs(v)
    open(os.path.join(wd, "design.v"), "w").write(v)
    return _yosys(wd, top, out_json, stamp, h)


def _yosys(wd, top, out_json, stamp, h):
    # No opt_merge / opt_dff: every flip-flop must survive so it can be matched.
    ys = (f"read_verilog design.v; hierarchy -top {top}; proc; flatten; memory; opt_clean; "
          f"techmap; opt_expr; opt_clean; "
          f"dfflegalize -cell $_DFF_PP0_ 01 -cell $_DFF_PN0_ 01 -cell $_DFF_PP1_ 01 -cell $_DFF_PN1_ 01; "
          f"aigmap; opt_expr; opt_clean; stat; write_json aig.json")
    log = _run(["yosys", "-q", "-l", "yosys.log", "-p", ys], wd)
    open(stamp, "w").write(h.hexdigest())
    return json.load(open(out_json))
