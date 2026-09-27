"""
mutants.py - "who verifies the verifier?"

A proof is only as good as its specification. To show that the four DDS
properties are strong enough, we inject realistic design mistakes into a copy
of the RTL (mutation testing) and check that at least one property FAILS,
with a concrete counter-example trace, for every mutant.
"""
from __future__ import annotations

import json
import os
import sys

from . import frontend
from .aig import AIG, word
from .induction import bmc

RTL = os.path.join(frontend.ROOT, "rtl", "dds_synthesizer.vhd")

MUTANTS = [
    ("no-peak-case",
     "Forget the 90/270 degree special case (index 2**QW wraps to 0)",
     "      if peak then", "      if false then"),
    ("mirror-off-by-one",
     "Mirror the table index as 2**QW-1-x instead of 2**QW-x",
     "to_unsigned(2**QW, QW+1)", "to_unsigned(2**QW-1, QW+1)"),
    ("ones-complement",
     "Negate with a bit-wise NOT (one's complement) instead of two's complement",
     "lut_out_inv_delay      <= -lut_out;", "lut_out_inv_delay      <= not lut_out;"),
    ("sign-one-cycle-early",
     "Use the 1-cycle delayed quadrant bit to select the sign (pipeline mismatch)",
     "when quadrant_3_or_4_2delay = '0' else", "when quadrant_3_or_4_delay = '0' else"),
    ("wrong-mirror-bit",
     "Mirror on the phase MSB instead of MSB-1",
     "quadrant_2_or_4 <= phase(PHASE_WIDTH-2);", "quadrant_2_or_4 <= phase(PHASE_WIDTH-1);"),
    ("truncate-wrong-bits",
     "Take the phase from the wrong accumulator bits",
     "phase <= ftw_accu(ftw_width-1 downto ftw_width-PHASE_WIDTH) + unsigned(phase_i);",
     "phase <= ftw_accu(ftw_width-2 downto ftw_width-PHASE_WIDTH-1) + unsigned(phase_i);"),
    ("accumulator-no-wrap-bit",
     "Accumulate with one bit less of precision (ftw_i MSB ignored)",
     "ftw_accu <= ftw_accu + unsigned(ftw_i);",
     "ftw_accu <= ftw_accu + unsigned('0' & ftw_i(ftw_width-2 downto 0));"),
]

PROPS = ["p_sine", "p_range", "p_step", "p_offset"]


def run(depth=8, log=print):
    src = open(RTL).read()
    out = []
    for key, desc, old, new in MUTANTS:
        assert old in src, key
        mdir = os.path.join(frontend.BUILD, "mutants")
        os.makedirs(mdir, exist_ok=True)
        path = os.path.join(mdir, f"{key}.vhd")
        open(path, "w").write(src.replace(old, new))
        files = ["rtl/sine_lut_pkg.vhd", os.path.relpath(path, frontend.ROOT),
                 "formal/props/sine_full_pkg.vhd", "formal/props/dds_props.vhd"]
        aig = AIG(frontend.build("mut_" + key, files, "dds_props", []), "dds_props", key)
        rec = {"mutant": key, "description": desc, "change": {"from": old.strip(), "to": new.strip()},
               "results": {}}
        for p in PROPS:
            r = bmc(aig, p, depth)
            rec["results"][p] = {"status": r["status"], "depth": r["depth"]}
            if r["status"] == "FAILS":
                tr = r["trace"]
                rec["results"][p]["trace"] = [{
                    "t": row["t"],
                    "ftw_i": word(row["in"], "ftw_i", 32),
                    "phase_i": word(row["in"], "phase_i", 10)} for row in tr]
        killed = [p for p in PROPS if rec["results"][p]["status"] == "FAILS"]
        rec["killed_by"] = killed
        log(f"  {key:26s} {'KILLED by ' + ', '.join(killed) if killed else 'SURVIVED'}")
        out.append(rec)
    return out


def main():
    res = run()
    os.makedirs(os.path.join(frontend.BUILD, "reports"), exist_ok=True)
    json.dump(res, open(os.path.join(frontend.BUILD, "reports", "mutants.json"), "w"), indent=1)
    sys.exit(0 if all(r["killed_by"] for r in res) else 1)


if __name__ == "__main__":
    main()
