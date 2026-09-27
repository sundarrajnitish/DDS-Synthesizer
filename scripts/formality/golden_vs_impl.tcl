# golden_vs_impl.tcl - golden netlist (reference) against another netlist (implementation)
#   fm_shell -x "set IMPL buggy/dds_synthesizer_32_syn_BUGGY.vhd" -f golden_vs_impl.tcl
#     -> Verification FAILED: 50 passing, 42 failing compare points (as in 2024)
#   fm_shell -x "set IMPL fixed/dds_synthesizer_32_syn_FIXED.vhd" -f golden_vs_impl.tcl
#     -> Verification SUCCEEDED: 92 passing compare points
source common.tcl
if {![info exists IMPL]} { set IMPL buggy/dds_synthesizer_32_syn_BUGGY.vhd }
read_vhdl -container r -libname WORK -93 $ROOT/netlists/golden/dds_synthesized_ftw_32.vhd
set_top r:/WORK/dds_synthesizer_ftw_width32
read_vhdl -container i -libname WORK -93 $ROOT/netlists/$IMPL
set_top i:/WORK/dds_synthesizer_ftw_width32
match
if {![verify]} {
    report_failing_points
    analyze_points -failing           ;# Formality's own suggestion of likely error locations
}
exit
