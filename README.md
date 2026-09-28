# Formal Verification of a DDS Synthesizer

[![formal verification](https://github.com/sundarrajnitish/DDS-Synthesizer/actions/workflows/verify.yml/badge.svg)](https://github.com/sundarrajnitish/DDS-Synthesizer/actions/workflows/verify.yml)

**Interactive site:** https://sundarrajnitish.github.io/DDS-Synthesizer/ (runs a real equivalence checker on these netlists in your browser)

A direct digital synthesizer (DDS) was synthesized to gates, and a second netlist of the same design was
handed out with bugs planted in it. This repository verifies the design formally: RTL against
netlist, golden netlist against buggy netlist, finds and repairs every bug automatically, and proves
properties and theorems about the design.

The project started in 2024 in COEN 6551 (Formal Hardware Verification, Concordia University) with
Synopsys Formality and Cadence Conformal. In 2026 it was rebuilt so that every result can be
reproduced with open-source tools in one command.

![DDS block diagram](images/BlockDiagram.png)

## Results at a glance

| check | result |
|---|---|
| Original RTL vs Design Compiler netlist | **equivalent**, 92/92 compare points (2 constant registers removed by synthesis) |
| Golden netlist vs buggy netlist | **42 failing** compare points (50 passing), exactly as Formality and Conformal reported in 2024 |
| Automatic diagnosis | **14 bugs**: 11 wrong cell types, 3 flip-flops wired to the wrong net; found and repaired in about 5 s |
| Golden netlist vs repaired netlist | **equivalent**, 92/92, no cells added (also proven against the original RTL) |
| 2024 manual repair (last attempt) | 88/92, 4 lookup-table bits still wrong, 48 cells added |
| Refactored RTL (`numeric_std`) vs original RTL | **equivalent**, 94/94 |
| Yosys + ABC synthesis vs RTL | **equivalent**, 92/92 (one register merged, matched by function) |
| Lean pipeline (62 flip-flops) vs original (74) | **sequentially equivalent** by k-induction (k = 2) |
| 4 functional properties | **proven** by k-induction (k = 2); 7 of 7 planted mutants caught |
| 8 Z3 theorems | 7 proven, 1 deliberately false (its counter-example explains the RTL's special case) |

Full list of findings: [FINDINGS.md](FINDINGS.md).

## The design

`dds_synthesizer` (Martin Kumm, 2009, GPL-3.0) is a numerically controlled oscillator:

| parameter | value |
|---|---|
| accumulator width N (`ftw_width`) | 32 bits |
| phase width M (`PHASE_WIDTH`) | 10 bits |
| amplitude width A (`AMPL_WIDTH`) | 10 bits, signed, range -511 .. +511 |
| sine table | quarter wave, 256 words |
| latency | `phase_i` to `ampl_o`: 3 clocks; `ftw_i` to `ampl_o`: 4 clocks |

Output frequency and phase:

    f_out   = FTW / 2^N * f_clk        (N = accumulator width)
    phi_out = PTW / 2^M * 2*pi         (M = phase width)

The 2008 datasheet has these two exponents swapped; the earlier README copied the error.
At 100 MHz the frequency resolution is 100 MHz / 2^32 = 0.023 Hz.

## Repository layout

```
rtl/                     refactored RTL (numeric_std), lean variant, generated sine package
rtl/original/            the RTL used in the course (std_logic_arith), unchanged
netlists/golden/         Design Compiler netlist (reference)
netlists/buggy/          the hand-out netlist with planted bugs
netlists/fixed/          automatically repaired netlist (every change marked "-- FIX")
netlists/yosys/          open-source synthesis result
netlists/manual_attempts 2024 hand repairs, kept for comparison
lib/                     class.lib / class.db teaching library
formal/fv/               open-source verification engine (Python)
  frontend.py              VHDL -> GHDL -> Verilog -> Yosys -> And-Inverter Graph
  eqcheck.py               combinational equivalence with register matching (SAT)
  diagnose.py              automatic bug localisation and correction
  repair.py                diagnose + patch + prove
  induction.py             BMC, k-induction, sequential equivalence
  mutants.py               mutation testing of the properties
  theorems.py              Z3 lemmas
  sim_vs_formal.py         random simulation vs formal, per bug
  run_all.py               the whole flow (CI entry point)
formal/props/            property monitor (VHDL) and full-wave specification
tb/                      self-checking GHDL testbench and runner
tools/                   Liberty reader, netlist reader/patcher, LUT generator, Python model, site export
scripts/                 Design Compiler, Formality, Conformal and Yosys scripts
logs/                    the 2024 tool logs (Formality, Design Compiler)
docs/                    GitHub Pages site (static; BDD checker in docs/js)
images/                  2024 screenshots
```

## Reproducing

Requirements: Python 3.10+, GHDL 3 or newer, Yosys 0.30 or newer.

```sh
sudo apt install ghdl yosys            # Ubuntu 24.04
pip install -r requirements.txt        # python-sat, z3-solver

make lint     # VHDL-93 and VHDL-2008 analysis, Liberty self-test, LUT check
make quick    # formal flow without the slow experiment (~30 s)
make formal   # full formal flow incl. simulation vs formal (~2 min)
make sim      # GHDL testbench: rtl, orig, lean, golden, fixed must pass; buggy must fail
make site     # regenerate docs/data/*.json
make serve    # preview the site at http://localhost:8000
```

Reports are written to `build/reports/` (`summary.txt` plus one JSON file per step).
GitHub Actions runs `make lint quick sim` on every push.

With the commercial tools the same checks are in `scripts/`:

```sh
cd scripts/formality && fm_shell -f rtl_vs_golden.tcl
cd scripts/formality && fm_shell -x "set IMPL fixed/dds_synthesizer_32_syn_FIXED.vhd" -f golden_vs_impl.tcl
cd scripts/conformal && lec -nogui -dofile golden_vs_impl.do
cd scripts/synopsys_dc && dc_shell -f syn.tcl
```

## Methodology

### 1. Front end
All designs, RTL and netlists, take the same path: GHDL converts VHDL to Verilog, Yosys flattens it
and maps it to an And-Inverter Graph. The behaviour of every standard cell is taken from the
`function` attributes in `class.lib` (`tools/liberty.py`), never hand-written. A second, independent
netlist reader (`tools/netlist.py`) simulates the netlists directly; the two agree on every compare
point.

### 2. Equivalence checking (`formal/fv/eqcheck.py`)
The same algorithm as Formality and Conformal:

1. **Match** compare points: 20 output bits by name, flip-flops by instance name
   (`ftw_accu_reg_3_inst` becomes `ftw_accu[3]`).
2. **Function matching** for registers whose names differ or that synthesis merged: random-simulation
   signatures of their next-state functions, confirmed by SAT.
3. **Constant registers** without a partner are proven constant by a fixed-point induction
   (`lut_out[9]` is always 0 because every sine sample is non-negative).
4. **Verify**: one SAT query per compare point on the miter of the two logic cones, with matched
   register outputs as shared free variables. Failing points come with a counter-example.

### 3. Diagnosis and repair (`formal/fv/diagnose.py`, `repair.py`)
Effect-cause analysis on 2048 random states simulated in parallel ranks every gate by how many failing
(point, vector) pairs flipping it would correct. The top suspects are tried against the classic design
error model (wrong cell type, swapped pins, extra or missing inversion, flip-flop wired to the wrong net;
Abadir, Ferguson and Kirkland, 1988). Interacting errors are handled by a dangling-driver look-ahead and a
two-gate search with back-tracking. The patched netlist is then proven by SAT; counter-examples feed back
into the vector set. The result is written as a minimal edit of the original netlist.

### 4. Properties, induction and theorems
`formal/props/dds_props.vhd` checks the RTL against a full 1024-entry sine table computed from `sin()`.
`formal/fv/induction.py` proves each property by k-induction (base: bounded model checking from reset;
step: from any state). The same engine proves the lean 62-flop pipeline sequentially equivalent to the
original with register correspondence. `formal/fv/mutants.py` plants seven realistic mistakes and checks
that a property catches each. `formal/fv/theorems.py` proves the mathematical facts behind the design with
Z3 (quarter-wave symmetry, the peak special case, overflow-free negation, phase-step jitter, full-period
coverage for odd tuning words, and the frequency formula by induction).

### 5. Cross-checks
Every equivalence verdict is confirmed by at least two engines: the SAT checker above, Yosys's own
`equiv_make`/`equiv_induct` (netlist pairs), and the BDD checker in `docs/js/checker.js`. The GHDL
testbench compares every implementation cycle by cycle against the full-wave reference, and the Python
model in `tools/dds_model.py` is compared with the HDL simulation sample by sample.

## Credits

DDS core: Martin Kumm, 2009, GPL-3.0 (see the file headers). `class.lib` is the Synopsys teaching library
distributed with the course. Verification: Nitish Sundarraj, Concordia University, 2024; revisited 2026.
