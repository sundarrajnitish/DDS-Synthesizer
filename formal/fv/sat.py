"""
sat.py - Tseitin encoding of AIG cones into CNF and a thin SAT wrapper.

Leaves (primary inputs and register outputs) are *shared by name* between
the designs being compared - that is exactly the "matched key point"
abstraction used by commercial equivalence checkers: once registers are
matched, sequential equivalence reduces to many small combinational checks.
"""
from __future__ import annotations

from pysat.solvers import Solver


class CNF:
    def __init__(self, solver_name: str = "cadical153"):
        self.solver = Solver(name=solver_name)
        self.nvars = 1
        self.true = self.new()
        self.solver.add_clause([self.true])
        self.leaf = {}                     # name -> var  (shared between designs)
        self.lit = {}                      # (design_id, node) -> literal

    def new(self):
        v = self.nvars
        self.nvars += 1
        return v

    def leaf_var(self, name):
        if name not in self.leaf:
            self.leaf[name] = self.new()
        return self.leaf[name]

    def encode(self, aig, root, did=None, overrides=None, leaf_lit=None):
        """Return a literal equal to AIG node `root`. Leaves are shared by name.
        overrides: node -> literal, to cut the graph at arbitrary points.
        leaf_lit:  name -> literal, to place leaves in a given time frame (unrolling)."""
        did = id(aig) if did is None else did
        overrides = overrides or {}
        if root == 0:
            return -self.true
        if root == 1:
            return self.true
        key = (did, root)
        if key in self.lit:
            return self.lit[key]
        leaf_names = getattr(aig, "_leafname", None)
        if leaf_names is None:
            leaf_names = {n: k for k, n in aig.inputs.items()}
            leaf_names.update({r.q: k for k, r in aig.regs.items()})
            aig._leafname = leaf_names
        # iterative post-order to avoid recursion limits on long carry chains
        stack = [root]
        while stack:
            n = stack[-1]
            k = (did, n)
            if k in self.lit:
                stack.pop()
                continue
            if n in overrides:
                self.lit[k] = overrides[n]
                stack.pop()
                continue
            g = aig.gates.get(n)
            if g is None and n in getattr(aig, "rst_bits", ()):
                self.lit[k] = -self.true            # functional mode: reset inactive
                stack.pop()
                continue
            if g is None:
                nm = leaf_names.get(n, f"{did}:{n}")
                self.lit[k] = leaf_lit(nm) if (leaf_lit and n in leaf_names) else self.leaf_var(nm)
                stack.pop()
                continue
            kids = [x for x in g[1:] if isinstance(x, int) and x not in (0, 1) and (did, x) not in self.lit]
            if kids:
                stack.extend(kids)
                continue
            stack.pop()

            def L(x):
                return -self.true if x == 0 else self.true if x == 1 else self.lit[(did, x)]
            if g[0] == "not":
                self.lit[k] = -L(g[1])
            else:
                a, b = L(g[1]), L(g[2])
                y = self.new()
                self.solver.add_clause([-y, a])
                self.solver.add_clause([-y, b])
                self.solver.add_clause([y, -a, -b])
                self.lit[k] = y
        return self.lit[key]

    def xor(self, a, b):
        y = self.new()
        for c in ([-y, a, b], [-y, -a, -b], [y, -a, b], [y, a, -b]):
            self.solver.add_clause(c)
        return y

    def solve(self, assumptions=()):
        return self.solver.solve(assumptions=list(assumptions))

    def model_leaves(self):
        m = set(l for l in self.solver.get_model() if l > 0)
        return {k: int(v in m) for k, v in self.leaf.items()}

    def value(self, lit):
        m = self.solver.get_model()
        v = abs(lit)
        pos = m[v - 1] > 0 if v - 1 < len(m) else False
        return int(pos if lit > 0 else not pos)

    def close(self):
        self.solver.delete()
