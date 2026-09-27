// golden_vs_impl.do - Cadence Conformal LEC dofile
//   lec -nogui -dofile golden_vs_impl.do
// Change the -revised file to netlists/fixed/dds_synthesizer_32_syn_FIXED.vhd for the repaired netlist.
set log file golden_vs_impl.log -replace
read library -both -replace -sensitive -statetable -liberty ../../lib/class.lib -nooptimize
read design ../../netlists/golden/dds_synthesized_ftw_32.vhd -vhdl -golden -continuousassignment bidirectional -nokeep_unreach
read design ../../netlists/buggy/dds_synthesizer_32_syn_BUGGY.vhd -vhdl -revised -continuousassignment bidirectional -nokeep_unreach
set system mode lec
add compared points -all
compare
report compare data -class nonequivalent
report statistics
// localise: diagnose the first non-equivalent point, or prove two internal nets:
//   diagnose -summary
//   prove U622/U$1 U962/U$1 -invert
exit -force
