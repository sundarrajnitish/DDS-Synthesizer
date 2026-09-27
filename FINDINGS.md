# Findings

Every statement here is checked by `make formal` (reports in `build/reports/`).

## F1. The buggy netlist contains exactly 14 bugs

Found by `formal/fv/repair.py` in about 5 seconds and proven: after these 14 edits, and nothing else,
the netlist is equivalent to the golden netlist (92/92) and to the original RTL (92/92). No cell is added.

| # | cell | kind | buggy | correct | fails on its own | random sim detects* |
|---|---|---|---|---|---|---|
| 1 | `add_98/u180` | wrong-gate | `ND2I` | `OR2` | ftw_accu[3], ftw_accu[5], ftw_accu[7] | 7% |
| 2 | `add_98/u181` | wrong-gate | `ND2I` | `OR2` | ftw_accu[9], ftw_accu[10], ftw_accu[11], ftw_accu[12] +19 more | 47% |
| 3 | `add_98/u32` | wrong-gate | `AN2I` | `NR2` | ftw_accu[30] | 47% |
| 4 | `add_99/u34` | wrong-gate | `NR2I` | `AN2` | phase[3], phase[5], phase[7], phase[9] | 19% |
| 5 | `lut_out_inv_delay_reg_1_inst` | wrong-connection | D = `n661` | D = `n371` (was dangling) | lut_out_inv_delay[1] | 100% |
| 6 | `lut_out_inv_delay_reg_5_inst` | wrong-connection | D = `n1360` | D = `n375` (was dangling) | lut_out_inv_delay[5] | 100% |
| 7 | `lut_out_inv_delay_reg_6_inst` | wrong-connection | D = `n374` | D = `n376` (was dangling) | lut_out_inv_delay[6] | 100% |
| 8 | `u705` | wrong-gate | `NR2` | `ND2` | lut_out_inv_delay[7], lut_out_inv_delay[8], lut_out_inv_delay[9] | 100% |
| 9 | `u707` | wrong-gate | `NR2` | `AN2` | lut_out_inv_delay[6], lut_out_inv_delay[7], lut_out_inv_delay[8], lut_out_inv_delay[9] | 100% |
| 10 | `u713` | wrong-gate | `OR3` | `AN3` | lut_out_inv_delay[3], lut_out_inv_delay[4], lut_out_inv_delay[5], lut_out_inv_delay[6] +3 more | 100% |
| 11 | `u757` | wrong-gate | `ND2` | `NR2` | lut_out[5] | 100% |
| 12 | `u758` | wrong-gate | `ND2` | `NR2` | lut_out[5], lut_out[6] | 100% |
| 13 | `u851` | wrong-gate | `OR3` | `NR3` | lut_out[2] | 100% |
| 14 | `u998` | wrong-gate | `OR3` | `NR3` | lut_out[0], lut_out[2] | 100% |

\* share of 256 random tests (2048 clocks each, random tuning word and phase offset) whose outputs
differed from the golden netlist, with only that one bug present (`formal/fv/sim_vs_formal.py`).

Where two corrections are functionally interchangeable (for example `OR2` or `EO` at `add_98/u180`,
which differ only when both inputs are 1, a combination the surrounding logic masks), the simplest gate
is reported.

## F2. The three misrouted flip-flops left their real drivers dangling

Three `EO` cells in the buggy netlist (`U716`, `U708`, `U706`, driving `N371`, `N375`, `N376`) have no
load. They are the intended D inputs of `lut_out_inv_delay` bits 1, 5 and 6. Their Design Compiler names
continue the sequence of the neighbouring D nets (`N372`, `N374`, `N377`, `N378`, `N379`). One flip-flop
was connected to `N374`, the D net of bit 4, and one to the inverted reset (constant 1 in operation).

## F3. The 2024 manual repair reached 88 of 92

| attempt | failing points | cells |
|---|---|---|
| buggy hand-out | 42 | 651 |
| 01_delay_reg_4_fixed | 40 | 651 |
| 02_bug_2 | 39 | 655 |
| 03_bug_3 | 37 | 657 |
| 04_bug_12_ftw_accu_reg_9_inst | 35 | 661 |
| 05_bug_20_lut_out_inv_delay_reg_8_inst | 4 | 699 |
| automatic repair (2026) | 0 | 651 |

The adders and the negation chain were repaired by adding logic around the faulty cells. The four points
left (`lut_out` bits 0, 2, 5, 6) come from four wrong gates in the table decoder (bugs 11 to 14).

## F4. Random simulation misses the accumulator bugs

Only 7% of random tests expose bug 1 within 2048 clocks, 47% bugs 2 and 3, 19% bug 4. Every table and
negation bug was exposed by more than 99% of tests within 100 clocks. The equivalence check finds all 14
with exact counter-examples and proves there are no others.

## F5. The datasheet formula has its exponents swapped

Correct: `f_out = FTW / 2^N * f_clk` (N = accumulator width) and `phi = PTW / 2^M * 2*pi`
(M = phase width). Proven as theorems T6a/T6b (closed form of the accumulator, by induction).

## F6. The original RTL is not portable VHDL

Mixing `std_logic_arith` and `std_logic_unsigned` makes the comparison in the LUT branch ambiguous; GHDL
rejects it unless `-fexplicit` is given. `rtl/dds_synthesizer.vhd` uses `numeric_std` only, analyses as
VHDL-93 and VHDL-2008, and is proven cycle-exact with the original (94/94 compare points).

## F7. Three flip-flops in the RTL are redundant

`lut_out[9]` and `lut_out_delay[9]` are constant 0 (all sine samples are non-negative), which Design
Compiler removes. `lut_out_inv_delay[0]` always equals `lut_out_delay[0]` (bit 0 of -x equals bit 0 of x),
which Yosys merges. `rtl/dds_synthesizer_lean.vhd` removes 12 flip-flops in total (74 to 62) and
registers the amplitude output; proven sequentially equivalent by k-induction with k = 2 (k = 1 is not
enough).

## F8. `phase_o` leads `ampl_o` by two clocks

`phase_o` is the stage-1 register; the sample computed from it reaches `ampl_o` two clocks later. The
RTL header now documents this and the latencies (`phase_i` to `ampl_o`: 3 clocks, `ftw_i`: 4 clocks).

## F9. The special case in the LUT branch is necessary and sufficient

Theorem T2b is false with counter-example phase = 256: the mirrored index 2^8 - 0 does not fit in 8 bits
and would read sin = 0 instead of the peak. T2 proves that 90 and 270 degrees are the only such phases.
Removing the branch is one of the seven mutants that property `p_sine` catches.

## F10. Open-source synthesis is smaller than the course flow

Yosys + ABC onto the same `class.lib`: 652 cells, area 1635, proven equivalent to the RTL. Design
Compiler with `compile -exact_map` and no constraints produced 621 cells, area 1696.
