#!/usr/bin/env python3
"""
dds_model.py - cycle-accurate Python model of the DDS (same registers as the RTL).

Used to cross-check the HDL simulation sample by sample (tb/run_sim.sh writes
build/sim/<impl>/trace.csv) and as the reference for the interactive simulator
on the project web site (docs/js/dds.js is a line-by-line port of this class).

    python3 tools/dds_model.py --compare build/sim/rtl/trace.csv
"""
import argparse
import csv
import math
import sys


class DDS:
    def __init__(self, ftw_width=32, phase_width=10, ampl_width=10):
        self.N, self.M, self.A = ftw_width, phase_width, ampl_width
        self.QW = phase_width - 2
        amp = 2 ** (ampl_width - 1) - 1
        self.lut = [round(amp * math.sin(2 * math.pi * i / 2 ** phase_width)) for i in range(2 ** self.QW)]
        self.reset()

    def reset(self):
        self.ftw_accu = 0
        self.phase = 0
        self.lut_out = 0
        self.lut_out_delay = 0
        self.lut_out_inv_delay = 0
        self.q34_d = 0
        self.q34_2d = 0

    def outputs(self):
        ampl = self.lut_out_inv_delay if self.q34_2d else self.lut_out_delay
        return self.phase, ampl

    def clock(self, ftw, phase_i):
        N, M, QW = self.N, self.M, self.QW
        q2or4 = (self.phase >> (M - 2)) & 1
        q3or4 = (self.phase >> (M - 1)) & 1
        low = self.phase & (2 ** QW - 1)
        lut_in = low if not q2or4 else (2 ** QW - low) & (2 ** QW - 1)
        if q2or4 and low == 0:
            lut_next = 2 ** (self.A - 1) - 1
        else:
            lut_next = self.lut[lut_in]
        # all registers update simultaneously
        self.ftw_accu, self.phase, self.lut_out, self.lut_out_delay, self.lut_out_inv_delay, \
            self.q34_d, self.q34_2d = (
                (self.ftw_accu + ftw) % 2 ** N,
                ((self.ftw_accu >> (N - M)) + phase_i) % 2 ** M,
                lut_next,
                self.lut_out,
                -self.lut_out,
                q3or4,
                self.q34_d)


def compare(path):
    """Replay the stimulus of a testbench trace and compare every sample."""
    rows = list(csv.DictReader(open(path)))
    tunings = [0x028F5C29, 0x00A7C5AC, 0x10000000, 0x7FFFFFFF, 0x00000001, 0xDEADBEEF, 0x12345679]
    d = DDS()
    bad = 0
    for r in rows:
        ftw_hi = int(r["ftw"])
        ftw = next(t for t in tunings if t >> 16 == ftw_hi)
        d.clock(ftw, int(r["phase_i"]))
        ph, am = d.outputs()
        if (ph, am) != (int(r["phase_o"]), int(r["ampl_o"])):
            bad += 1
            if bad <= 5:
                print(f"cycle {r['cycle']}: model ({ph},{am}) hdl ({r['phase_o']},{r['ampl_o']})")
    print(f"{path}: {len(rows)} samples compared, {bad} mismatches")
    return bad


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--compare")
    a = ap.parse_args()
    if a.compare:
        sys.exit(1 if compare(a.compare) else 0)
    d = DDS()
    for _ in range(8):
        d.clock(0x10000000, 0)
        print(d.outputs())
