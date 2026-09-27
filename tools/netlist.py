#!/usr/bin/env python3
"""
netlist.py - reader / writer for the structural VHDL netlists written by
Synopsys Design Compiler (`write -hierarchy -format vhdl`).

Parses entities, component instances (`label : CELL port map( A => n1, ... )`)
and concurrent signal assignments, flattens the hierarchy and gives a
cell-level Circuit that can be simulated bit-parallel using the Boolean
functions taken from the Liberty library.  It is used by the bug
diagnosis engine (formal/fv/diagnose.py) and by the netlist patcher that
writes the repaired netlist.

VHDL is case-insensitive, so all identifiers are folded to lower case.
"""
from __future__ import annotations

import re
import sys
import os
from dataclasses import dataclass, field

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import liberty  # noqa: E402


def strip_comments(text: str) -> str:
    """Blank out VHDL comments, keeping every character offset unchanged."""
    return re.sub(r"--[^\n]*", lambda m: " " * len(m.group(0)), text)


@dataclass
class Instance:
    label: str
    cell: str                      # cell / entity name (lower case)
    conns: dict                    # formal bit ('a', 'a[3]') -> actual bit ('n12', 'ftw_i[3]', '0', '1', None)
    span: tuple = (0, 0)           # character span in the original text


@dataclass
class Module:
    name: str
    ports: list = field(default_factory=list)       # (name, dir, width|None)
    signals: dict = field(default_factory=dict)     # name -> width|None
    instances: list = field(default_factory=list)
    assigns: list = field(default_factory=list)     # (lhs_bit, rhs_bit)

    def port_bits(self, direction):
        out = []
        for n, d, w in self.ports:
            if d == direction:
                out += [n] if w is None else [f"{n}[{i}]" for i in range(w)]
        return out


def _bit(s: str) -> str | None:
    s = s.strip().lower()
    if s in ("'0'", "'1'"):
        return s[1]
    if s == "open":
        return None
    m = re.fullmatch(r"(\w+)\s*\(\s*(\d+)\s*\)", s)
    if m:
        return f"{m.group(1)}[{m.group(2)}]"
    if re.fullmatch(r"\w+", s):
        return s
    raise ValueError(f"unsupported actual {s!r}")


def _split_top(s: str, sep=","):
    out, depth, cur = [], 0, ""
    for ch in s:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == sep and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return out


def parse(text: str) -> dict:
    """Return {entity_name: Module}."""
    src = strip_comments(text)
    low = src.lower()
    mods = {}
    for m in re.finditer(r"\bentity\s+(\w+)\s+is\s+port\s*\((.*?)\)\s*;\s*end\s+\1\s*;", low, re.S):
        mod = Module(m.group(1))
        for decl in m.group(2).split(";"):
            if not decl.strip():
                continue
            names, rest = decl.split(":")
            d, *typ = rest.split(None, 1)
            typ = typ[0] if typ else ""
            r = re.search(r"\(\s*(\d+)\s+downto\s+(\d+)\s*\)", typ)
            w = int(r.group(1)) + 1 if r else None
            for n in names.split(","):
                mod.ports.append((n.strip(), d, w))
        mods[mod.name] = mod
    for a in re.finditer(r"\barchitecture\s+(\w+)\s+of\s+(\w+)\s+is(.*?)\bbegin\b(.*?)\bend\s+\1\s*;", low, re.S):
        mod = mods[a.group(2)]
        decl, body = a.group(3), a.group(4)
        body_off = a.start(4)
        decl = re.sub(r"\bcomponent\b.*?\bend\s+component\s*;", "", decl, flags=re.S)
        for s in re.finditer(r"\bsignal\s+(.*?)\s*:\s*(std_logic_vector\s*\(\s*(\d+)\s+downto\s+\d+\s*\)|std_logic)\s*;", decl, re.S):
            w = int(s.group(3)) + 1 if s.group(3) else None
            for n in s.group(1).split(","):
                mod.signals[n.strip()] = w
        for st in re.finditer(r"\s*([^;]+);", body):
            stmt = st.group(1).strip()
            if not stmt:
                continue
            im = re.fullmatch(r"(\w+)\s*:\s*(\w+)\s+port\s+map\s*\((.*)\)", stmt, re.S)
            if im:
                conns = {}
                for assoc in _split_top(im.group(3)):
                    f, act = assoc.split("=>")
                    conns[_bit(f)] = _bit(act)
                mod.instances.append(Instance(im.group(1), im.group(2), conns,
                                              (body_off + st.start(1), body_off + st.end())))
                continue
            am = re.fullmatch(r"(\w+(?:\s*\(\s*\d+\s*\))?)\s*<=\s*(.*)", stmt, re.S)
            if am:
                lhs, rhs = am.group(1), am.group(2).strip()
                if rhs.startswith("("):
                    items = [_bit(x) for x in _split_top(rhs[1:-1])]
                    w = len(items)
                    for i, it in enumerate(items):
                        mod.assigns.append((f"{lhs.strip()}[{w - 1 - i}]", it))
                else:
                    mod.assigns.append((_bit(lhs), _bit(rhs)))
                continue
            raise ValueError(f"unsupported statement: {stmt[:80]}")
    return mods


# ---------------------------------------------------------------------------
# Flattened, cell-level circuit
# ---------------------------------------------------------------------------

@dataclass
class Cell:
    name: str          # hierarchical instance name, e.g. 'add_98/u147'
    type: str          # liberty cell name (upper case)
    ins: dict          # pin -> net
    outs: dict         # pin -> net


class Circuit:
    FLOP = "FD2"

    def __init__(self, path: str, lib_path: str, top: str | None = None):
        self.path = path
        self.text = open(path).read()
        self.lib = liberty.read_liberty(lib_path)
        self.libu = {k.upper(): v for k, v in self.lib.items()}
        self.exprs = {k: {p: liberty.parse_expr(f) for p, f in c.outputs.items()} for k, c in self.libu.items()}
        self.mods = parse(self.text)
        self.top = top or [m for m in self.mods if not any(
            i.cell == m for mm in self.mods.values() for i in mm.instances)][0]
        self.cells: dict = {}
        self.alias: dict = {}          # net -> net it is connected to
        self._flatten(self.mods[self.top], "", {})
        self._resolve()

    # -- flattening ---------------------------------------------------------
    def _flatten(self, mod: Module, prefix: str, portmap: dict):
        def net(b):
            if b is None or b in ("0", "1"):
                return b
            base = b.split("[")[0]
            if any(base == p for p, _, _ in mod.ports) and portmap:
                return portmap.get(b)
            return prefix + b
        for lhs, rhs in mod.assigns:
            self.alias[net(lhs)] = net(rhs)
        for inst in mod.instances:
            if inst.cell in self.mods:                     # hierarchical instance
                sub = self.mods[inst.cell]
                pm = {f: net(a) for f, a in inst.conns.items()}
                self._flatten(sub, prefix + inst.label + "/", pm)
                continue
            lc = self.libu[inst.cell.upper()]
            ins = {p.upper(): net(inst.conns.get(p.lower())) for p in lc.inputs}
            outs = {p.upper(): net(inst.conns.get(p.lower())) for p in lc.outputs if inst.conns.get(p.lower())}
            self.cells[prefix + inst.label] = Cell(prefix + inst.label, inst.cell.upper(), ins, outs)

    def _resolve(self):
        def root(n):
            seen = set()
            while n in self.alias and n not in seen:
                seen.add(n)
                n = self.alias[n]
            return n
        for c in self.cells.values():
            c.ins = {p: root(n) for p, n in c.ins.items()}
        self.driver = {}
        for c in self.cells.values():
            for p, n in c.outs.items():
                self.driver[n] = (c.name, p)
        # outputs of the top
        top = self.mods[self.top]
        self.inputs = [b for b in top.port_bits("in") if b not in ("clk_i", "rst_i")]
        self.outputs = {b: root(b) for b in top.port_bits("out")}
        self.flops = {n: c for n, c in self.cells.items() if c.type.startswith("FD")}
        self.flop_name = {}
        for n, c in self.flops.items():
            m = re.match(r"^(\w+?)_reg(?:_(\d+))?(?:_inst)?$", n)
            self.flop_name[n] = f"{m.group(1)}[{m.group(2)}]" if m and m.group(2) else (m.group(1) if m else n)
        self.comb = [c for c in self.cells.values() if not c.type.startswith("FD")]
        self._order()

    def _order(self):
        ready = set(self.inputs) | {"0", "1", None}
        for c in self.flops.values():
            ready |= set(c.outs.values())
        pending = list(self.comb)
        order = []
        drivers = {n for c in self.comb for n in c.outs.values()}
        while pending:
            nxt = []
            for c in pending:
                if all(n in ready or n not in drivers for n in c.ins.values()):
                    order.append(c)
                    ready |= set(c.outs.values())
                else:
                    nxt.append(c)
            if len(nxt) == len(pending):
                raise ValueError("combinational loop or undriven net: " + ", ".join(c.name for c in nxt[:5]))
            pending = nxt
        self.order = order

    # -- simulation ---------------------------------------------------------
    def leaves(self):
        """Names of the free variables of the combinational check: inputs + register outputs."""
        return list(self.inputs) + sorted(set(self.flop_name.values()))

    def eval_cell(self, c: Cell, v: dict, mask: int, override_type=None, override_ins=None):
        t = override_type or c.type
        ins = override_ins or c.ins
        env = {p: v.get(n, 0) if n not in ("0", "1") else (mask if n == "1" else 0) for p, n in ins.items()}
        res = {}
        for p, e in self.exprs[t].items():
            res[p] = _eval_word(e, env, mask)
        return res

    def simulate(self, leaf_values: dict, width: int, patch=None):
        """leaf_values: leaf name -> int. Returns net -> int.
        patch: {cell_name: (type, ins)} to evaluate a modified circuit."""
        mask = (1 << width) - 1
        v = {"0": 0, "1": mask}
        for b in self.inputs:
            v[b] = leaf_values.get(b, 0)
        for n, c in self.flops.items():
            q = leaf_values.get(self.flop_name[n], 0)
            if "Q" in c.outs:
                v[c.outs["Q"]] = q
            if "QN" in c.outs:
                v[c.outs["QN"]] = ~q & mask
        for c in self.order:
            if patch and c.name in patch:
                t, ins, inv = patch[c.name]
                r = self.eval_cell(c, v, mask, t, ins)
                if inv:
                    r = {p: ~x & mask for p, x in r.items()}
            else:
                r = self.eval_cell(c, v, mask)
            for p, n in c.outs.items():
                v[n] = r[p]
        return v

    def compare_values(self, v: dict):
        """Values of every compare point (flop D inputs and outputs) from a simulation."""
        out = {}
        for n, c in self.flops.items():
            d = c.ins["D"]
            out[self.flop_name[n]] = v.get(d, 0) if d not in ("0", "1") else (v["1"] if d == "1" else 0)
        for b, n in self.outputs.items():
            out[b] = v.get(n, 0)
        return out

    def fanout(self):
        fo = {}
        for c in self.comb + list(self.flops.values()):
            for n in c.ins.values():
                fo.setdefault(n, []).append(c)
        return fo


def _eval_word(e, env, mask):
    k = e[0]
    if k == "var":
        return env[e[1]]
    if k == "const":
        return mask if e[1] else 0
    if k == "not":
        return ~_eval_word(e[1], env, mask) & mask
    vals = [_eval_word(x, env, mask) for x in e[1]]
    r = vals[0]
    for x in vals[1:]:
        r = (r & x) if k == "and" else (r | x) if k == "or" else (r ^ x)
    return r


if __name__ == "__main__":
    c = Circuit(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "lib/class.lib")
    from collections import Counter
    print(c.top, len(c.cells), "cells,", len(c.flops), "flops")
    print(Counter(x.type for x in c.cells.values()).most_common())


# ---------------------------------------------------------------------------
# Writing a corrected netlist
# ---------------------------------------------------------------------------

def apply_patch(circuit: "Circuit", patch: dict, notes: dict | None = None) -> str:
    """Return the netlist text with the given cell corrections applied.

    patch: {hier_cell_name: (new_type, {pin: hier_net}, invert_out)}
    Only cell-type changes and re-connections are supported (that is all the
    error model produces); every edited instance gets a comment explaining why.
    """
    text = circuit.text
    edits = []                                  # (start, end, replacement)
    low = strip_comments(text).lower()
    notes = notes or {}
    needed = {}
    for hname, (new_type, new_ins, inv) in patch.items():
        if inv:
            raise NotImplementedError("output inversion requires a new cell")
        parts = hname.split("/")
        label = parts[-1]
        prefix = "/".join(parts[:-1]) + "/" if len(parts) > 1 else ""
        # find which module instantiates this label
        if prefix:
            parent_inst = parts[-2]
            mod_name = next(i.cell for m in circuit.mods.values() for i in m.instances if i.label == parent_inst)
        else:
            mod_name = circuit.top
        mod = circuit.mods[mod_name]
        inst = next(i for i in mod.instances if i.label == label)
        start, end = inst.span
        old_stmt = text[start:end]
        cell = circuit.cells[hname]
        lib_cell = circuit.libu[new_type.upper()]
        # resolved (flattened) net -> the actual as written in this instance
        local_of = {}
        for p, n in cell.ins.items():
            a = inst.conns.get(p.lower())
            if a is not None:
                local_of[n] = a
        def local(net):
            if net in local_of:
                return _vhdl_net(local_of[net], text)
            return _vhdl_net(net[len(prefix):] if prefix and net.startswith(prefix) else net, text)
        assoc = [f"{p} => {local(new_ins[p])}" for p in lib_cell.inputs]
        for p in lib_cell.outputs:
            old = inst.conns.get(p.lower())
            if old is not None:
                assoc.append(f"{p} => {_vhdl_net(old, text)}")
        extra = [f"{p.upper()} => {_vhdl_net(a, text)}" for p, a in inst.conns.items()
                 if p.upper() not in lib_cell.inputs and p.upper() not in lib_cell.outputs and a is not None]
        assoc += extra
        m = re.match(r"(\s*)", old_stmt)
        indent = "   "
        note = notes.get(hname, "")
        was = f"was: {cell.type} port map( " + ", ".join(f"{p} => {local(n)}" for p, n in cell.ins.items()) + " )"
        label_src = re.match(r"\s*(\w+)", old_stmt).group(1)      # original spelling
        new_stmt = (f"-- FIX: {note}\n{indent}-- {was}\n{indent}" if note else f"-- FIX: {was}\n{indent}") + \
            f"{label_src} : {new_type.upper()} port map( " + ", ".join(assoc) + ");"
        edits.append((start, end, new_stmt))
        needed.setdefault(mod_name, set()).add(new_type.upper())
    # declare any cell type an architecture did not use before
    for mod_name, types in needed.items():
        am = re.search(rf"\barchitecture\s+\w+\s+of\s+{mod_name}\s+is\b", low)
        body_end = low.index("begin", am.end())
        declared = set(t.upper() for t in re.findall(r"\bcomponent\s+(\w+)", low[am.end():body_end]))
        decls = ""
        for t in sorted(types - declared):
            c = circuit.libu[t]
            decls += (f"\n   component {t}\n      port( {', '.join(c.inputs)} : in std_logic;  "
                      f"{', '.join(c.outputs)} : out std_logic);\n   end component;\n   ")
        if decls:
            edits.append((am.end(), am.end(), "\n   -- cell types introduced by the netlist repair" + decls))
    for start, end, rep in sorted(edits, reverse=True):
        text = text[:start] + rep + text[end:]
    return text


def _vhdl_net(n: str, text: str = "") -> str:
    m = re.fullmatch(r"(\w+)\[(\d+)\]", n)
    base, idx = (m.group(1), m.group(2)) if m else (n, None)
    if text:                                   # keep the original spelling (VHDL is case-insensitive)
        mm = re.search(rf"\b{re.escape(base)}\b", text, re.I)
        if mm:
            base = mm.group(0)
    return f"{base}({idx})" if idx is not None else base
