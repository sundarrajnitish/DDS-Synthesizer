#!/usr/bin/env bash
# Run the self-checking testbench against every implementation with GHDL.
#   tb/run_sim.sh            -> rtl, orig, lean, golden, fixed (must pass), buggy (must fail)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
B="$ROOT/build/sim"
mkdir -p "$B"
python3 "$ROOT/tools/liberty.py" "$ROOT/lib/class.lib" --vhdl "$B/class_cells.vhd" 2>/dev/null
GHDL_FLAGS="--std=08 -frelaxed -Wno-binding -Wno-hide -Wno-shared"
run() {  # name impl expect_fail files...
  local name=$1 impl=$2 xfail=$3; shift 3
  local w="$B/$name"; rm -rf "$w"; mkdir -p "$w"; cd "$w"
  local std="--std=08"
  if [ "$impl" = "orig" ]; then
    ghdl -a --std=08 -fsynopsys -frelaxed -Wno-binding "$@" "$ROOT/formal/props/sine_full_pkg.vhd" "$ROOT/tb/dds_synthesizer_tb.vhd"
    ghdl -e --std=08 -fsynopsys -frelaxed -Wno-binding dds_synthesizer_tb
    ghdl -r --std=08 -fsynopsys dds_synthesizer_tb -gIMPL=$impl -gEXPECT_FAIL=$xfail -gTRACE_FILE=trace.csv 2>&1 | grep -E "report|error" | sed "s#.*(report note): #  [$name] #"
  else
    ghdl -a $GHDL_FLAGS "$@" "$ROOT/formal/props/sine_full_pkg.vhd" "$ROOT/tb/dds_synthesizer_tb.vhd"
    ghdl -e $GHDL_FLAGS dds_synthesizer_tb
    ghdl -r $GHDL_FLAGS dds_synthesizer_tb -gIMPL=$impl -gEXPECT_FAIL=$xfail -gTRACE_FILE=trace.csv 2>&1 | grep -E "report|error" | sed "s#.*(report note): #  [$name] #"
  fi
  cd "$ROOT"
}
R="$ROOT/rtl"; N="$ROOT/netlists"; C="$B/class_cells.vhd"
run rtl    rtl  false "$R/sine_lut_pkg.vhd" "$R/dds_synthesizer.vhd"
run orig   orig false "$R/original/sine_lut_10_x_10.vhd" "$R/original/dds_synthesizer.vhd"
run lean   lean false "$R/sine_lut_pkg.vhd" "$R/dds_synthesizer_lean.vhd"
run golden gate false "$C" "$N/golden/dds_synthesized_ftw_32.vhd"
run fixed  gate false "$C" "$N/fixed/dds_synthesizer_32_syn_FIXED.vhd"
run buggy  gate true  "$C" "$N/buggy/dds_synthesizer_32_syn_BUGGY.vhd"
echo "all simulations behaved as expected"
