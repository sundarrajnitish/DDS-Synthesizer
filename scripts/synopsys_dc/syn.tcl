# syn.tcl - Synopsys Design Compiler synthesis of the DDS onto class.lib
# Reconstructed from the 2024 session log (logs/dc_shell_command.log) and cleaned up.
#   cd scripts/synopsys_dc && dc_shell -f syn.tcl
# Produces the golden netlist netlists/golden/dds_synthesized_ftw_32.vhd
# (the course used the original RTL in rtl/original/; the refactored rtl/ works the same way).

set ROOT [file normalize ../..]
set search_path [list . $ROOT/lib]
set target_library class.db
set link_library   [list * class.db]
define_design_lib WORK -path ./work

analyze   -library WORK -format vhdl [list $ROOT/rtl/original/sine_lut_10_x_10.vhd \
                                          $ROOT/rtl/original/dds_synthesizer.vhd]
elaborate dds_synthesizer -architecture dds_synthesizer_arch -library WORK -parameters "ftw_width = 32"
current_design dds_synthesizer_ftw_width32
link
check_design

# The course flow used an unconstrained exact-map compile. Add a clock if you
# want timing-driven results: create_clock -period 10 [get_ports clk_i]
compile -exact_map

report_area  > area.rpt
report_cell  > cells.rpt
change_names -rules vhdl -hierarchy
write -hierarchy -format vhdl -output $ROOT/netlists/golden/dds_synthesized_ftw_32.vhd
write -hierarchy -format ddc  -output dds_synthesized_ftw_32.ddc
exit
