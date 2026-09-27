"""
aig.py - a tiny sequential And-Inverter Graph built from Yosys JSON.

A design is:
    inputs   : {'ftw_i[3]': node, ...}         primary input bits (clk/rst removed)
    regs     : {'ftw_accu[3]': Reg(q, d, init)}  every flip-flop, by canonical name
    outputs  : {'ampl_o[4]': node, ...}
    gates    : node -> ('and', a, b) | ('not', a)
Nodes are ints (Yosys bit ids) or the constants 0 / 1.

Canonical register names make RTL and netlist registers comparable:
    RTL      : signal 'ftw_accu' bit 3            -> 'ftw_accu[3]'
    netlist  : instance 'ftw_accu_reg_3_inst'     -> 'ftw_accu[3]'
               instance 'quadrant_3_or_4_delay_reg' -> 'quadrant_3_or_4_delay'
This mirrors the name-based matching step of Formality / Conformal.
"""
from __future__ import annotations

import random
import re
from dataclasses import dataclass

CLOCKS = {"clk_i"}
RESETS = {"rst_i"}

_INST = re.compile(r"^(?P<base>\w+?)_reg(?:_(?P<idx>\d+))?(?:_inst)?\.iq$")


@dataclass
class Reg:
    q: int
    d: object
    init: int          # value after (asynchronous) reset
    names: tuple = ()


class AIG:
    def __init__(self, yosys_json: dict, top: str | None = None, label: str = ""):
        mods = yosys_json["modules"]
        top = top or next(iter(mods))
        m = mods[top]
        self.label = label or top
        self.top = top
        self.gates: dict = {}
        self.inputs: dict = {}
        self.outputs: dict = {}
        self.regs: dict = {}
        self.port_bits: dict = {}

        def node(b):
            if b == "0":
                return 0
            if b == "1":
                return 1
            if isinstance(b, str):   # 'x' / 'z' -> treat as 0
                return 0
            return b

        for pname, p in m["ports"].items():
            bits = [node(b) for b in p["bits"]]
            self.port_bits[pname] = (p["direction"], bits)
            for i, b in enumerate(bits):
                nm = f"{pname}[{i}]" if len(bits) > 1 else pname
                if p["direction"] == "input":
                    if pname not in CLOCKS | RESETS:
                        self.inputs[nm] = b
                else:
                    self.outputs[nm] = b

        # names of every bit, used for register naming and for diagnosis reports
        self.bitnames: dict = {}
        for n, v in m["netnames"].items():
            for i, b in enumerate(v["bits"]):
                if isinstance(b, int):
                    self.bitnames.setdefault(b, []).append(f"{n}[{i}]" if len(v["bits"]) > 1 else n)
        self.rst_bits = {b for n in RESETS if n in self.port_bits for b in self.port_bits[n][1]}

        # map of reset net -> is it rst_i or its inversion
        for cname, c in m["cells"].items():
            t, con = c["type"], c["connections"]
            if t == "$_AND_":
                self.gates[con["Y"][0]] = ("and", node(con["A"][0]), node(con["B"][0]))
            elif t == "$_NOT_":
                self.gates[con["Y"][0]] = ("not", node(con["A"][0]))
            elif t.startswith("$_DFF_"):
                pol_clk, pol_rst, val = t[6], t[7], int(t[8])
                q = con["Q"][0]
                self.regs[q] = Reg(q=q, d=node(con["D"][0]), init=val)
                self._rst_of = getattr(self, "_rst_of", {})
                self._rst_of[q] = (node(con["R"][0]), pol_rst)
            else:
                raise ValueError(f"unexpected cell {t} ({cname}) - run aigmap first")

        # give every register a canonical name
        named = {}
        for q, r in self.regs.items():
            names = self.bitnames.get(q, [])
            r.names = tuple(names)
            named[self.canonical([n for n in names if n.split("[")[0] not in self.port_bits] or names, q)] = r
        self.regs = dict(sorted(named.items(), key=lambda kv: _natural(kv[0])))
        self._check_resets()

    # ------------------------------------------------------------------
    @staticmethod
    def canonical(names, q):
        for n in names:
            m = _INST.match(n)
            if m:
                return f"{m['base']}[{m['idx']}]" if m["idx"] is not None else m["base"]
        for n in sorted(names, key=lambda s: (("." in s), bool(re.match(r"n\d+_o", s)), len(s))):
            if "." not in n and not re.match(r"n\d+_[oq]", n):
                return n
        return f"reg_{q}"

    def _check_resets(self):
        """Every flop must be asynchronously reset by rst_i (directly or through inverters)."""
        def root(n, inv=0):
            while n in self.gates and self.gates[n][0] == "not":
                n, inv = self.gates[n][1], inv ^ 1
            return n, inv
        self.reset_ok = True
        for q, (rnet, pol) in getattr(self, "_rst_of", {}).items():
            n, inv = root(rnet)
            active_high = (pol == "P") ^ inv
            if n not in self.rst_bits or not active_high:
                self.reset_ok = False

    # ------------------------------------------------------------------
    def cone(self, roots):
        """All gate nodes in the transitive fan-in of roots (stops at inputs / reg outputs)."""
        seen, stack = set(), [r for r in roots if isinstance(r, int)]
        while stack:
            n = stack.pop()
            if n in seen or n not in self.gates:
                continue
            seen.add(n)
            g = self.gates[n]
            stack.extend(x for x in g[1:] if isinstance(x, int))
        return seen

    def support(self, root):
        """Primary inputs and register outputs that root depends on (by name)."""
        inv = {v: k for k, v in self.inputs.items()}
        rinv = {r.q: k for k, r in self.regs.items()}
        sup, seen, stack = set(), set(), [root]
        while stack:
            n = stack.pop()
            if not isinstance(n, int) or n in seen:
                continue
            seen.add(n)
            if n in self.gates:
                stack.extend(self.gates[n][1:])
            elif n in inv:
                sup.add(inv[n])
            elif n in rinv:
                sup.add(rinv[n])
        return sup

    def topo(self, nodes=None):
        nodes = set(self.gates) if nodes is None else set(nodes)
        order, state = [], {}
        for s in nodes:
            if s in state:
                continue
            stack = [(s, 0)]
            while stack:
                n, i = stack.pop()
                if i == 0:
                    if state.get(n):
                        continue
                    state[n] = 1
                g = self.gates.get(n)
                kids = [x for x in (g[1:] if g else ()) if isinstance(x, int) and x in nodes]
                if i < len(kids):
                    stack.append((n, i + 1))
                    if not state.get(kids[i]):
                        stack.append((kids[i], 0))
                else:
                    if state[n] == 1:
                        state[n] = 2
                        order.append(n)
        return order

    # ------------------------------------------------------------------
    def simulate(self, values: dict, width: int, order=None):
        """Bit-parallel simulation. values: node -> int (width bits). Returns node -> int."""
        mask = (1 << width) - 1
        v = dict(values)
        v[0], v[1] = 0, mask
        for b in self.rst_bits:          # functional mode: reset inactive
            v.setdefault(b, 0)
        for n in order or self.topo():
            g = self.gates[n]
            if g[0] == "and":
                v[n] = v[g[1]] & v[g[2]]
            else:
                v[n] = ~v[g[1]] & mask
        return v

    def random_leaf_values(self, width, rng: random.Random, fixed=None):
        vals = {}
        for k, n in self.inputs.items():
            vals[n] = (fixed or {}).get(k, rng.getrandbits(width))
        for k, r in self.regs.items():
            vals[r.q] = (fixed or {}).get(k, rng.getrandbits(width))
        return vals

    def step(self, state: dict, inputs: dict):
        """One clock cycle, scalar. state/inputs by canonical name -> 0/1. Returns (outputs, next_state)."""
        vals = {}
        for k, n in self.inputs.items():
            vals[n] = inputs.get(k, 0)
        for k, r in self.regs.items():
            vals[r.q] = state.get(k, r.init)
        v = self.simulate(vals, 1)
        outs = {k: v[n] if isinstance(n, int) else n for k, n in self.outputs.items()}
        nxt = {k: (v[r.d] if isinstance(r.d, int) else r.d) for k, r in self.regs.items()}
        return outs, nxt

    def reset_state(self):
        return {k: r.init for k, r in self.regs.items()}

    def stats(self):
        ands = sum(1 for g in self.gates.values() if g[0] == "and")
        return {"and": ands, "not": len(self.gates) - ands, "regs": len(self.regs),
                "inputs": len(self.inputs), "outputs": len(self.outputs)}


def _natural(s):
    return [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", s)]


def word(d: dict, base: str, width: int, signed=False) -> int:
    v = sum((d.get(f"{base}[{i}]", 0) & 1) << i for i in range(width))
    if signed and v >= 1 << (width - 1):
        v -= 1 << width
    return v


def bits(base: str, value: int, width: int) -> dict:
    return {f"{base}[{i}]": (value >> i) & 1 for i in range(width)}
