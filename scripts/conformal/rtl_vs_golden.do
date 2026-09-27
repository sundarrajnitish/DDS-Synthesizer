// rtl_vs_golden.do - Cadence Conformal LEC: original RTL (golden) vs synthesized netlist (revised)
set log file rtl_vs_golden.log -replace
read library -both -replace -sensitive -statetable -liberty ../../lib/class.lib -nooptimize
read design ../../rtl/original/sine_lut_10_x_10.vhd ../../rtl/original/dds_synthesizer.vhd -vhdl -golden
read design ../../netlists/golden/dds_synthesized_ftw_32.vhd -vhdl -revised
set system mode lec
add compared points -all
compare
report statistics
exit -force
