"""
induction.py - bounded model checking and k-induction on the sequential AIG.

Two uses:

 * Property proving ("does the design always satisfy P?")
       P is a 1-bit output of a monitor wrapped around the design
       (formal/props/dds_props.vhd). We prove P by k-induction:
         base : starting from reset, P holds in cycles 0 .. k-1       (BMC)
         step : from ANY state, if P held for k consecutive cycles,
                it also holds in the next one
       If the base case fails we have a real bug and a counter-example trace.
       If only the step fails the proof needs a larger k or a strengthening
       invariant (the classic limitation of induction).

 * Sequential equivalence with register correspondence (van Eijk, 2000)
       for two designs whose state encodings differ only partly: registers
       with matching names are assumed equal, everything else is left to
       k-induction. This is what proves the 62-flop "lean" DDS equivalent to
       the 74-flop original even though 12 of their flip-flops have no partner.
"""
from __future__ import annotations

import time

from .sat import CNF


class Unroller:
    """Time-frame expansion of one or more AIGs inside one SAT instance."""

    def __init__(self, cnf: CNF, designs: dict, shared_regs=(), free_init=True):
        self.cnf = cnf
        self.designs = designs              # tag -> AIG
        self.shared = set(shared_regs)      # register names equal in all designs at frame 0
        self.free_init = free_init
        self.reg_lit = {}                   # (tag, reg, t) -> literal

    def input_lit(self, name, t):
        return self.cnf.leaf_var(f"in:{name}@{t}")

    def reg(self, tag, name, t):
        key = (tag, name, t)
        if key in self.reg_lit:
            return self.reg_lit[key]
        aig = self.designs[tag]
        if t == 0:
            if not self.free_init:
                lit = self.cnf.true if aig.regs[name].init else -self.cnf.true
            elif name in self.shared:
                lit = self.cnf.leaf_var(f"reg:{name}@0")
            else:
                lit = self.cnf.leaf_var(f"reg:{tag}:{name}@0")
        else:
            lit = self.node(tag, aig.regs[name].d, t - 1)
        self.reg_lit[key] = lit
        return lit

    def node(self, tag, n, t):
        aig = self.designs[tag]

        def leaf(name):
            if name in aig.inputs:
                return self.input_lit(name, t)
            return self.reg(tag, name, t)
        return self.cnf.encode(aig, n, did=(tag, t, self.free_init), leaf_lit=leaf)

    def output(self, tag, name, t):
        return self.node(tag, self.designs[tag].outputs[name], t)


def _trace(cnf, unr, tag, k, names_in, names_out):
    m = set(l for l in cnf.solver.get_model() if l > 0)
    val = lambda lit: int((lit in m) if lit > 0 else (-lit not in m))
    rows = []
    for t in range(k):
        rows.append({"t": t,
                     "in": {n: val(unr.input_lit(n, t)) for n in names_in},
                     "out": {n: val(unr.output(tag, n, t)) for n in names_out}})
    return rows


def bmc(aig, prop: str, depth: int, assume: str | None = None):
    """Bounded model checking from reset: shortest counter-example up to `depth` cycles."""
    for k in range(1, depth + 1):
        cnf = CNF()
        unr = Unroller(cnf, {"d": aig}, free_init=False)
        for t in range(k):
            if assume:
                cnf.solver.add_clause([unr.output("d", assume, t)])
        cnf.solver.add_clause([-unr.output("d", prop, k - 1)])
        if cnf.solve():
            tr = _trace(cnf, unr, "d", k, sorted(aig.inputs), sorted(aig.outputs))
            cnf.close()
            return {"property": prop, "status": "FAILS", "depth": k, "trace": tr}
        cnf.close()
    return {"property": prop, "status": f"holds up to {depth} cycles", "depth": depth}


def prove_property(aig, prop: str, k: int, assume: str | None = None, max_k=None):
    """k-induction on the 1-bit output `prop` of `aig` (1 = property holds).
    Optional `assume` output constrains every cycle (environment assumption)."""
    t0 = time.time()
    res = {"property": prop, "k": k}
    # base case: from reset, cycles 0..k-1
    cnf = CNF()
    unr = Unroller(cnf, {"d": aig}, free_init=False)
    bad = []
    for t in range(k):
        if assume:
            cnf.solver.add_clause([unr.output("d", assume, t)])
        bad.append(-unr.output("d", prop, t))
    cnf.solver.add_clause(bad)
    if cnf.solve():
        res.update(status="FAILS", phase="base",
                   trace=_trace(cnf, unr, "d", k, sorted(aig.inputs), sorted(aig.outputs)))
        cnf.close()
        res["seconds"] = round(time.time() - t0, 2)
        return res
    cnf.close()
    # inductive step: arbitrary state, P held for k cycles -> holds at cycle k
    cnf = CNF()
    unr = Unroller(cnf, {"d": aig}, free_init=True)
    for t in range(k):
        cnf.solver.add_clause([unr.output("d", prop, t)])
        if assume:
            cnf.solver.add_clause([unr.output("d", assume, t)])
    if assume:
        cnf.solver.add_clause([unr.output("d", assume, k)])
    cnf.solver.add_clause([-unr.output("d", prop, k)])
    step_fails = cnf.solve()
    cnf.close()
    res.update(status="PROVEN" if not step_fails else "UNDECIDED",
               phase="step", seconds=round(time.time() - t0, 2))
    return res


def seq_equiv(ref, impl, k: int = 2):
    """Sequential equivalence of two designs with (partial) register correspondence."""
    t0 = time.time()
    matched = sorted(set(ref.regs) & set(impl.regs))
    outs = sorted(set(ref.outputs) & set(impl.outputs))
    D = {"r": ref, "i": impl}
    res = {"matched_registers": len(matched), "ref_only": sorted(set(ref.regs) - set(impl.regs)),
           "impl_only": sorted(set(impl.regs) - set(ref.regs)), "k": k, "outputs": len(outs)}

    def diffs(cnf, unr, t, with_regs):
        xs = [cnf.xor(unr.output("r", o, t), unr.output("i", o, t)) for o in outs]
        if with_regs:
            xs += [cnf.xor(unr.reg("r", r, t + 1), unr.reg("i", r, t + 1)) for r in matched]
        return xs

    # base: from reset, outputs agree for k cycles
    cnf = CNF()
    unr = Unroller(cnf, D, free_init=False)
    x = [d for t in range(k + 1) for d in diffs(cnf, unr, t, False)]
    cnf.solver.add_clause(x)
    if cnf.solve():
        res.update(status="NOT EQUIVALENT", phase="base")
        cnf.close()
        return res
    cnf.close()
    # step: matched registers start equal; outputs and matched next-states agree
    # for k frames -> they agree in frame k as well
    cnf = CNF()
    unr = Unroller(cnf, D, shared_regs=matched, free_init=True)
    for t in range(k):
        for d in diffs(cnf, unr, t, True):
            cnf.solver.add_clause([-d])
    cnf.solver.add_clause(diffs(cnf, unr, k, True))
    fails = cnf.solve()
    cnf.close()
    res.update(status="EQUIVALENT" if not fails else "UNDECIDED (increase k)", phase="step",
               seconds=round(time.time() - t0, 2))
    return res
