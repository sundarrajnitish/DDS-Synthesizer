#!/usr/bin/env python3
"""
liberty.py - a small, dependency-free reader for the combinational and
flip-flop cells of a Liberty (.lib) technology library.

It extracts, for every cell:
  * input / output pins
  * the Boolean function of each output pin      (e.g. "((A B)+C)'")
  * for sequential cells: next_state / clear / preset of the ff() group

and can turn the library into
  * Verilog behavioural cell models   (for Yosys / Icarus)          -> emit_verilog()
  * VHDL behavioural cell models      (for GHDL gate-level sim)     -> emit_vhdl()
  * a JSON description                (for the in-browser checker)  -> to_json()

Liberty Boolean syntax handled:
  A'  !A        negation (postfix ' and prefix !)
  A B  A*B  A&B conjunction (juxtaposition = AND)
  A+B  A|B      disjunction
  A^B           exclusive or
  1  0          constants
  ( )           grouping

Usage:
  python3 tools/liberty.py lib/class.lib --verilog out.v --vhdl out.vhd --json out.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field

# --------------------------------------------------------------------------
# Boolean expression parser  ->  AST of tuples
#   ('var', name) | ('const', 0/1) | ('not', e) | ('and', [e..]) | ('or', [e..]) | ('xor', [e..])
# --------------------------------------------------------------------------

_TOKEN = re.compile(r"\s*(?:(?P<id>[A-Za-z_][A-Za-z0-9_]*)|(?P<num>[01])|(?P<op>[()'!+|*&^]))")


def _tokenize(s: str):
    s = s.strip()
    pos, out = 0, []
    while pos < len(s):
        if s[pos].isspace():
            # whitespace is significant: juxtaposition means AND
            out.append(("ws", " "))
            while pos < len(s) and s[pos].isspace():
                pos += 1
            continue
        m = _TOKEN.match(s, pos)
        if not m or m.end() == pos:
            raise ValueError(f"cannot tokenize {s!r} at {pos}")
        if m.group("id"):
            out.append(("id", m.group("id")))
        elif m.group("num"):
            out.append(("num", int(m.group("num"))))
        else:
            out.append(("op", m.group("op")))
        pos = m.end()
    # drop whitespace tokens that are not between two operands
    cleaned = []
    for i, t in enumerate(out):
        if t[0] != "ws":
            cleaned.append(t)
            continue
        prev = cleaned[-1] if cleaned else None
        nxt = next((u for u in out[i + 1:] if u[0] != "ws"), None)
        ends_operand = prev and (prev[0] in ("id", "num") or prev[1] in (")", "'"))
        starts_operand = nxt and (nxt[0] in ("id", "num") or nxt[1] in ("(", "!"))
        if ends_operand and starts_operand:
            cleaned.append(("op", "*"))
    # implicit AND also without whitespace, e.g. "A'B" or ")("
    final = []
    for t in cleaned:
        if final:
            p = final[-1]
            ends_operand = p[0] in ("id", "num") or p[1] in (")", "'")
            starts_operand = t[0] in ("id", "num") or t[1] in ("(", "!")
            if ends_operand and starts_operand:
                final.append(("op", "*"))
        final.append(t)
    return final


class _Parser:
    # precedence:  +,|  <  ^  <  *,&  <  unary
    def __init__(self, toks):
        self.t, self.i = toks, 0

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else (None, None)

    def eat(self, v=None):
        tok = self.peek()
        if v is not None and tok[1] != v:
            raise ValueError(f"expected {v!r}, got {tok}")
        self.i += 1
        return tok

    def parse(self):
        e = self.p_or()
        if self.i != len(self.t):
            raise ValueError(f"trailing tokens {self.t[self.i:]}")
        return e

    def p_or(self):
        xs = [self.p_xor()]
        while self.peek()[1] in ("+", "|"):
            self.eat()
            xs.append(self.p_xor())
        return xs[0] if len(xs) == 1 else ("or", xs)

    def p_xor(self):
        xs = [self.p_and()]
        while self.peek()[1] == "^":
            self.eat()
            xs.append(self.p_and())
        return xs[0] if len(xs) == 1 else ("xor", xs)

    def p_and(self):
        xs = [self.p_un()]
        while self.peek()[1] in ("*", "&"):
            self.eat()
            xs.append(self.p_un())
        return xs[0] if len(xs) == 1 else ("and", xs)

    def p_un(self):
        if self.peek()[1] == "!":
            self.eat()
            return ("not", self.p_un())
        e = self.p_atom()
        while self.peek()[1] == "'":
            self.eat()
            e = ("not", e)
        return e

    def p_atom(self):
        k, v = self.peek()
        if k == "id":
            self.eat()
            return ("var", v)
        if k == "num":
            self.eat()
            return ("const", v)
        if v == "(":
            self.eat("(")
            e = self.p_or()
            self.eat(")")
            return e
        raise ValueError(f"unexpected token {k, v}")


def parse_expr(s: str):
    return _Parser(_tokenize(s)).parse()


def eval_expr(e, env: dict) -> int:
    k = e[0]
    if k == "var":
        return env[e[1]] & 1
    if k == "const":
        return e[1]
    if k == "not":
        return 1 - eval_expr(e[1], env)
    vals = [eval_expr(x, env) for x in e[1]]
    if k == "and":
        return int(all(vals))
    if k == "or":
        return int(any(vals))
    if k == "xor":
        r = 0
        for v in vals:
            r ^= v
        return r
    raise ValueError(k)


def expr_to(e, lang: str) -> str:
    """Render an AST as a Verilog or VHDL expression."""
    k = e[0]
    if k == "var":
        return e[1]
    if k == "const":
        return (("1'b1" if e[1] else "1'b0") if lang == "verilog" else ("'1'" if e[1] else "'0'"))
    if k == "not":
        inner = expr_to(e[1], lang)
        return f"~({inner})" if lang == "verilog" else f"(not {inner})"
    op = {"verilog": {"and": " & ", "or": " | ", "xor": " ^ "},
          "vhdl": {"and": " and ", "or": " or ", "xor": " xor "}}[lang][k]
    return "(" + op.join(expr_to(x, lang) for x in e[1]) + ")"


def expr_to_json(e):
    return e  # tuples serialise as lists


# --------------------------------------------------------------------------
# Liberty reader (only what we need: cells, pins, functions, ff groups)
# --------------------------------------------------------------------------

@dataclass
class Cell:
    name: str
    inputs: list = field(default_factory=list)
    outputs: dict = field(default_factory=dict)  # pin -> expression string
    ff: dict | None = None                       # {'iq','iqn','next_state','clocked_on','clear','preset'}
    latch: bool = False
    tristate: bool = False
    area: float = 0.0

    @property
    def sequential(self):
        return self.ff is not None


def _blocks(text: str, keyword: str):
    """Yield (arg, body) for every `keyword(arg) { body }` at the top of text."""
    for m in re.finditer(keyword + r"\s*\(\s*([^)]*?)\s*\)\s*\{", text):
        i, depth = m.end(), 1
        while depth:
            c = text[i]
            depth += (c == "{") - (c == "}")
            i += 1
        yield m.group(1).strip('"'), text[m.end():i - 1]


def _attr(body: str, name: str):
    m = re.search(r"\b" + name + r"\s*:\s*(\"[^\"]*\"|[^;\s]+)\s*;", body)
    return m.group(1).strip('"').strip() if m else None


def read_liberty(path: str) -> dict:
    text = open(path, encoding="latin-1").read()
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = text.replace("\\\n", " ")
    cells = {}
    for name, body in _blocks(text, r"\bcell"):
        c = Cell(name)
        a = _attr(body, "area")
        c.area = float(a) if a else 0.0
        c.tristate = "three_state" in body
        for (grp, args, gbody) in re.findall(r"\b(ff|latch)\s*\(([^)]*)\)\s*\{([^}]*)\}", body):
            if grp == "latch":
                c.latch = True
                continue
            iq, iqn = [x.strip().strip('"') for x in args.split(",")]
            c.ff = {"iq": iq, "iqn": iqn,
                    "next_state": _attr(gbody, "next_state"),
                    "clocked_on": _attr(gbody, "clocked_on"),
                    "clear": _attr(gbody, "clear"),
                    "preset": _attr(gbody, "preset")}
        for pin, pbody in _blocks(body, r"\bpin"):
            d = _attr(pbody, "direction")
            if d == "input" and pin not in c.inputs:
                c.inputs.append(pin)
            elif d == "output":
                f = _attr(pbody, "function")
                if f is not None:
                    c.outputs[pin] = f
        cells[name] = c
    return cells


def usable(c: Cell) -> bool:
    """Cells we can model exactly: pure combinational, or a D flip-flop
    (optionally with async clear / preset). Latches, tristates, scan flops skipped."""
    if c.latch or c.tristate or not c.outputs:
        return False
    if c.ff:
        return c.ff["next_state"].strip() == "D"
    return True


# --------------------------------------------------------------------------
# Emitters
# --------------------------------------------------------------------------

def _ff_parts(c: Cell):
    clr = parse_expr(c.ff["clear"]) if c.ff["clear"] else None
    pre = parse_expr(c.ff["preset"]) if c.ff["preset"] else None
    return clr, pre


def emit_verilog(cells: dict) -> str:
    out = ["// Auto-generated by tools/liberty.py from the Liberty library. Do not edit.",
           "// Behavioural models of the standard cells used by the gate-level netlists.",
           "`timescale 1ns/1ps", ""]
    for c in cells.values():
        if not usable(c):
            continue
        ports = c.inputs + list(c.outputs)
        out.append(f"module {c.name} ({', '.join(ports)});")
        out.append(f"  input {', '.join(c.inputs)};")
        out.append(f"  output {', '.join(c.outputs)};")
        if c.ff:
            iq, iqn = c.ff["iq"], c.ff["iqn"]
            clr, pre = _ff_parts(c)
            out.append(f"  reg {iq};")
            out.append(f"  wire {iqn} = ~{iq};")
            sens = ["posedge CP"]
            # clear is active when its expression is 1, e.g. CD' -> active-low CD
            if clr:
                sens.append(("negedge " if clr[0] == "not" else "posedge ") + (clr[1][1] if clr[0] == "not" else clr[1]))
            if pre:
                sens.append(("negedge " if pre[0] == "not" else "posedge ") + (pre[1][1] if pre[0] == "not" else pre[1]))
            out.append(f"  always @({' or '.join(sens)})")
            if clr:
                out.append(f"    if ({expr_to(clr, 'verilog')}) {iq} <= 1'b0; else")
            if pre:
                out.append(f"    if ({expr_to(pre, 'verilog')}) {iq} <= 1'b1; else")
            out.append(f"    {iq} <= D;")
        for pin, f in c.outputs.items():
            out.append(f"  assign {pin} = {expr_to(parse_expr(f), 'verilog')};")
        out.append("endmodule\n")
    return "\n".join(out)


def emit_vhdl(cells: dict, lib_name: str = "class_lib") -> str:
    out = ["-- Auto-generated by tools/liberty.py from the Liberty library. Do not edit.",
           "-- Behavioural VHDL models of the standard cells (for GHDL gate-level simulation).",
           ""]
    for c in cells.values():
        if not usable(c):
            continue
        out += ["library ieee;", "use ieee.std_logic_1164.all;", "",
                f"entity {c.name} is",
                "  port( " + ";\n        ".join(
                    [f"{p} : in std_logic" for p in c.inputs] +
                    [f"{p} : out std_logic" for p in c.outputs]) + ");",
                f"end {c.name};", "",
                f"architecture behav of {c.name} is"]
        if c.ff:
            iq, iqn = c.ff["iq"], c.ff["iqn"]
            clr, pre = _ff_parts(c)
            out += [f"  signal {iq} : std_logic;", f"  signal {iqn} : std_logic;", "begin"]
            sens = ["CP"] + ([clr[1][1] if clr[0] == "not" else clr[1]] if clr else []) + \
                   ([pre[1][1] if pre[0] == "not" else pre[1]] if pre else [])
            out.append(f"  process({', '.join(sens)})")
            out.append("  begin")
            first = True
            if clr:
                out.append(f"    if {expr_to(clr, 'vhdl')} = '1' then {iq} <= '0';")
                first = False
            if pre:
                out.append(f"    {'if' if first else 'elsif'} {expr_to(pre, 'vhdl')} = '1' then {iq} <= '1';")
                first = False
            out.append(f"    {'if' if first else 'elsif'} rising_edge(CP) then {iq} <= D;")
            out.append("    end if;")
            out.append("  end process;")
            out.append(f"  {iqn} <= not {iq};")
        else:
            out.append("begin")
        for pin, f in c.outputs.items():
            out.append(f"  {pin} <= {expr_to(parse_expr(f), 'vhdl')};")
        out += [f"end behav;", ""]
    return "\n".join(out)


def emit_liberty_min(cells: dict, name="class_min") -> str:
    """A minimal, strictly-formatted Liberty file (combinational cells + FD2) that
    ABC's parser accepts - the original class.lib trips it up (statetables,
    malformed scan-flop pins)."""
    out = [f"library({name}) {{", "  delay_model : table_lookup;", "  time_unit : \"1ns\";",
           "  capacitive_load_unit (1, pf);"]
    for c in cells.values():
        if not usable(c) or (c.ff and c.name != "FD2"):
            continue
        out.append(f"  cell({c.name}) {{")
        out.append(f"    area : {c.area:g};")
        for p in c.inputs:
            out.append(f"    pin({p}) {{ direction : input; capacitance : 1; }}")
        if c.ff:
            out.append('    ff("IQ","IQN") { next_state : "D"; clocked_on : "CP"; clear : "CD\'"; }')
            out.append('    pin(Q) { direction : output; function : "IQ"; }')
            out.append('    pin(QN) { direction : output; function : "IQN"; }')
        else:
            for p, f in c.outputs.items():
                out.append(f'    pin({p}) {{ direction : output; function : "{f}"; }}')
        out.append("  }")
    out.append("}")
    return "\n".join(out) + "\n"


def to_json(cells: dict) -> dict:
    res = {}
    for c in cells.values():
        if not usable(c):
            continue
        d = {"inputs": c.inputs, "outputs": {p: parse_expr(f) for p, f in c.outputs.items()}, "area": c.area}
        if c.ff:
            d["ff"] = {"q": c.ff["iq"], "qn": c.ff["iqn"], "clear": c.ff["clear"], "preset": c.ff["preset"]}
        res[c.name] = d
    return res


def self_test(cells: dict):
    """Exhaustively check the parser against a few hand-written truth tables."""
    ref = {
        "ND2": lambda A, B: 1 - (A & B),
        "AO2": lambda A, B, C, D: 1 - ((A & B) | (C & D)),
        "AO4": lambda A, B, C, D: 1 - ((A | B) & (C | D)),
        "AO5": lambda A, B, C: 1 - ((A & B) | (A & C) | (B & C)),
        "EO1": lambda A, B, C, D: 1 - ((A & B) | (1 - (C | D))),
        "EON1": lambda A, B, C, D: 1 - ((A | B) & (1 - (C & D))),
        "MUX21L": lambda A, B, S: 1 - (B if S else A),
        "MUX31L": lambda D0, D1, D2, A, B: 1 - (D2 if B else (D1 if A else D0)),
        "EO3": lambda A, B, C: A ^ B ^ C,
        "EN": lambda A, B: 1 - (A ^ B),
    }
    import itertools
    for name, f in ref.items():
        c = cells[name]
        e = parse_expr(c.outputs["Z"])
        for bits in itertools.product((0, 1), repeat=len(c.inputs)):
            env = dict(zip(c.inputs, bits))
            assert eval_expr(e, env) == f(**env), (name, env)
    return len(ref)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("lib")
    ap.add_argument("--verilog")
    ap.add_argument("--vhdl")
    ap.add_argument("--json")
    ap.add_argument("--liberty-min", help="write a minimal Liberty file that ABC can read")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args(argv)
    cells = read_liberty(a.lib)
    if a.self_test:
        print(f"liberty self-test: {self_test(cells)} cells verified exhaustively")
    if a.verilog:
        open(a.verilog, "w").write(emit_verilog(cells))
    if a.vhdl:
        open(a.vhdl, "w").write(emit_vhdl(cells))
    if a.json:
        json.dump(to_json(cells), open(a.json, "w"), indent=1)
    if a.liberty_min:
        open(a.liberty_min, "w").write(emit_liberty_min(cells))
    n = sum(usable(c) for c in cells.values())
    print(f"{a.lib}: {len(cells)} cells, {n} modelled", file=sys.stderr)


if __name__ == "__main__":
    main()
