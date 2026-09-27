# common.tcl - shared setup for the Formality scripts (Synopsys Formality H-2013.03 and later)
set ROOT [file normalize ../..]
set synopsys_auto_setup true            ;# match DC's default assumptions (constant regs, etc.)
read_db $ROOT/lib/class.db
