# rtl_vs_golden.tcl - does synthesis preserve the RTL?  (expected: SUCCEEDED, 92 passing points)
#   fm_shell -f rtl_vs_golden.tcl
source common.tcl
read_vhdl -container r -libname WORK -93 [list $ROOT/rtl/original/dds_synthesizer.vhd \
                                               $ROOT/rtl/original/sine_lut_10_x_10.vhd]
set_top r:/WORK/dds_synthesizer
read_vhdl -container i -libname WORK -93 $ROOT/netlists/golden/dds_synthesized_ftw_32.vhd
set_top i:/WORK/dds_synthesizer_ftw_width32
match
verify
report_failing_points
exit
