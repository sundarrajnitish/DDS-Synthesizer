"""
theorems.py - the mathematical facts the DDS relies on, proven with the Z3
SMT solver (automated theorem proving over bit-vectors).

Equivalence checking shows two implementations agree; property checking shows
one implementation meets a specification. These lemmas go one level deeper and
justify the *design itself*: why folding a quarter-wave table is enough, why
the negation never overflows, why the output frequency is what the formula
says. Each is stated for all inputs (universally quantified) and proven by
showing its negation is unsatisfiable. Where a lemma is false we get a
counter-example - T2b shows exactly why the RTL needs its "peak" special case.

    python3 -m fv.theorems
"""
from __future__ import annotations

import json
import os
import sys
import time

import z3

from . import frontend

N, M, A = 32, 10, 10        # ftw width, phase width, amplitude width
QW = M - 2


def prove(name, claim, variables, statement, note=""):
    s = z3.Solver()
    s.set("timeout", 120000)
    s.add(z3.Not(claim))
    t0 = time.time()
    r = s.check()
    rec = {"id": name, "statement": statement, "note": note, "seconds": round(time.time() - t0, 2)}
    if r == z3.unsat:
        rec["status"] = "PROVEN"
    elif r == z3.sat:
        m = s.model()
        rec["status"] = "FALSE"
        rec["counterexample"] = {str(v): m.eval(v, model_completion=True).as_long() for v in variables}
    else:
        rec["status"] = "UNKNOWN"
    return rec


def fold(p):
    """The RTL's quadrant folding, written with Z3 bit-vector operations.
    Returns (index as QW+1 bits, negate flag, peak flag)."""
    low = z3.Extract(QW - 1, 0, p)
    q2or4 = z3.Extract(M - 2, M - 2, p) == 1
    q3or4 = z3.Extract(M - 1, M - 1, p) == 1
    low_w = z3.ZeroExt(1, low)
    mirrored = z3.BitVecVal(2 ** QW, QW + 1) - low_w
    idx_hw = z3.If(q2or4, z3.ZeroExt(1, z3.Extract(QW - 1, 0, mirrored)), low_w)   # what the hardware indexes
    idx_math = z3.If(q2or4, mirrored, low_w)                                        # the true index (0..2**QW)
    peak = z3.And(q2or4, low == 0)
    return idx_hw, idx_math, q3or4, peak


def lemmas():
    out = []
    p = z3.BitVec("phase", M)
    idx_hw, idx_math, neg, peak = fold(p)
    W = M + 4                                  # wide enough for p + 2^M offsets
    P = z3.ZeroExt(4, p)
    I = z3.ZeroExt(W - (QW + 1), idx_math)
    K = z3.BitVecVal(2 ** M, W)
    half = z3.BitVecVal(2 ** (M - 1), W)
    congr = lambda x, y: z3.URem(x + 4 * K - y, K) == 0          # x == y (mod 2^M)
    claim = z3.And(
        z3.ULE(idx_math, 2 ** QW),
        z3.If(neg,
              z3.Or(congr(I, K - P), congr(I + half, P)),        # sin(p) = -sin(i)
              z3.Or(congr(I, P), congr(I, half - P))))          # sin(p) = +sin(i)
    out.append(prove(
        "T1", claim, [p],
        "For every phase p, the folded index i and sign s satisfy sin(2*pi*p/2^M) = s*sin(2*pi*i/2^M) "
        "with 0 <= i <= 2^(M-2), using only sin(pi - x) = sin(x) and sin(x + pi) = -sin(x).",
        "Justifies storing only a quarter period: 256 words instead of 1024."))

    # T2: the hardware index equals the true index except at the two peaks
    out.append(prove(
        "T2", z3.Implies(z3.Not(peak), idx_hw == idx_math), [p],
        "Outside phase = 2^(M-2) and 3*2^(M-2), the (M-2)-bit truncated index equals the true index.",
        "So the peak branch in the RTL is the only special case needed."))
    out.append(prove(
        "T2b", idx_hw == idx_math, [p],
        "Without the special case the truncated index would always be right (expected FALSE).",
        "The counter-example is the reason for the `peak` branch: 2^(M-2) - 0 = 256 wraps to 0 in 8 bits, "
        "giving sin = 0 instead of +/-1 at 90 and 270 degrees."))

    # T3: negation never overflows
    v = z3.BitVec("lut_value", A)
    maxv = 2 ** (A - 1) - 1
    out.append(prove(
        "T3", z3.Implies(z3.And(v >= 0, v <= maxv),
                         z3.And(-v <= 0, -v != z3.BitVecVal(-(2 ** (A - 1)), A), -(-v) == v)), [v],
        "For 0 <= v <= 2^(A-1)-1, the A-bit two's complement -v is exact, never equals -2^(A-1), and -(-v) = v.",
        "The output range is symmetric [-511, +511]; the asymmetric value -512 is unreachable."))

    # T4: phase step per clock is floor(F/2^(N-M)) or that + 1
    a, F = z3.BitVec("accu", N), z3.BitVec("ftw", N)
    top = lambda x: z3.Extract(N - 1, N - M, x)
    d = top(a + F) - top(a)
    out.append(prove(
        "T4", z3.Or(d == top(F), d == top(F) + 1), [a, F],
        "For every accumulator value a and tuning word F: top_M(a+F) - top_M(a) is top_M(F) or top_M(F)+1 (mod 2^M).",
        "Phase truncation makes the step jitter by one LSB - the source of DDS spurs; the average step is F/2^(N-M)."))

    # T5: an odd tuning word visits every accumulator state (maximal period 2^N)
    n = z3.BitVec("n", N)
    out.append(prove(
        "T5", z3.Implies(z3.And(z3.Extract(0, 0, F) == 1, n * F == 0), n == 0), [n, F],
        "If F is odd then n*F = 0 (mod 2^N) implies n = 0 (mod 2^N).",
        "An odd FTW has period exactly 2^N clocks: the accumulator visits all 2^N states before repeating."))

    # T6: closed form of the accumulator, by induction on the clock count n
    #     a(0) = 0, a(n+1) = a(n) + F   ==>   a(n) = n*F  (mod 2^N)
    out.append(prove(
        "T6a", z3.BitVecVal(0, N) * F == 0, [F],
        "Induction base: a(0) = 0 = 0*F.", "Part 1 of a proof by induction."))
    out.append(prove(
        "T6b", z3.Implies(a == n * F, a + F == (n + 1) * F), [a, n, F],
        "Induction step: if a(n) = n*F then a(n+1) = a(n) + F = (n+1)*F (mod 2^N).",
        "With T6a this proves a(n) = n*F for every n. The phase therefore turns F times every 2^N "
        "clocks: f_out = F / 2^N * f_clk - the corrected formula (the original PDF divides by 2^M)."))
    return out


def main():
    res = lemmas()
    for r in res:
        print(f"  {r['id']:4s} {r['status']:7s} ({r['seconds']} s)  {r['statement']}")
        if "counterexample" in r:
            print(f"        counter-example: {r['counterexample']}")
    os.makedirs(os.path.join(frontend.BUILD, "reports"), exist_ok=True)
    json.dump(res, open(os.path.join(frontend.BUILD, "reports", "theorems.json"), "w"), indent=1)
    ok = all(r["status"] == ("FALSE" if r["id"] == "T2b" else "PROVEN") for r in res)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
