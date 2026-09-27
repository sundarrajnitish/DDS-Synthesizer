"""
diagnose.py - automatic design-error diagnosis and correction (DEDC) for a
gate-level netlist that fails equivalence against a golden reference.

What an engineer does by hand in the Formality / Conformal schematic viewer
("which gate makes this compare point fail?") is automated here.

 1. SIMULATE   both designs on thousands of random register/input states
               (bit-parallel: one bit of a Python int per vector) and record,
               per compare point, the vectors on which they disagree.
 2. LOCALISE   every gate g is a suspect. Flipping g's output and
               re-simulating its fan-out tells us on which failing vectors g
               *could* be the culprit (effect-cause analysis). Suspects are
               ranked by the number of failing (point, vector) pairs explained.
 3. CORRECT    for each top suspect, try the classic design-error model
               (Abadir, Ferguson & Kirkland, 1988):
                 - wrong cell type        (OR3 where AN3 was intended, ...)
                 - swapped input pins, extra / missing inversion
                 - spurious inverter (should be a wire)
                 - flip-flop D pin wired to the wrong net - the intended driver
                   is then usually left *dangling*, a strong hint
               A correction is accepted only if it completely repairs at least
               one compare point and breaks nothing that was passing.
 4. ESCALATE   interacting errors are handled by (a) a dangling-driver
               look-ahead and (b) a two-gate search that may also undo
               earlier corrections in the same logic cone (back-tracking).
 5. PROVE      when random simulation is clean, the patched netlist is proven
               equivalent with SAT (eqcheck.py). Counter-examples are added to
               the vector set and the loop resumes.
 6. MINIMISE   every correction that is not needed for the proof is dropped.

Because the end result is proven by SAT, the heuristic search can never
produce a wrong netlist: at worst it fails to find a repair.
"""
from __future__ import annotations

import itertools
import os
import random
import sys
from dataclasses import dataclass, field

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tools"))
from netlist import Circuit, _eval_word  # noqa: E402

POP = int.bit_count


@dataclass
class Fix:
    cell: str
    old_type: str
    new_type: str
    old_ins: dict
    new_ins: dict
    invert_out: bool = False
    points: list = field(default_factory=list)
    how: str = ""

    @property
    def is_flop(self):
        return self.old_type.startswith("FD")

    def kind(self):
        if self.is_flop:
            return "wrong-connection"
        if self.new_type == "IBUF1":
            return "spurious-inverter"
        if sorted(self.old_ins.values()) != sorted(self.new_ins.values()):
            return "wrong-connection"
        if list(self.old_ins.values()) != list(self.new_ins.values()) and self.new_type == self.old_type:
            return "swapped-pins"
        if self.invert_out and self.new_type == self.old_type:
            return "inverted-output"
        return "wrong-gate"

    def describe(self):
        k = self.kind()
        if self.is_flop:
            return f"{self.cell}: D pin is wired to net {self.old_ins['D']}; it should be driven by net {self.new_ins['D']}"
        if k == "spurious-inverter":
            return f"{self.cell}: spurious inverter ({self.old_type}) - should be a plain wire"
        pins = ""
        if list(self.old_ins.values()) != list(self.new_ins.values()):
            pins = " with inputs (" + ", ".join(f"{p}={n}" for p, n in self.new_ins.items()) + ")"
        inv = " followed by an inverter" if self.invert_out else ""
        if self.new_type == self.old_type:
            return f"{self.cell} ({self.old_type}): {k.replace('-', ' ')}{pins}{inv}"
        return f"{self.cell}: cell {self.old_type} should be {self.new_type}{pins}{inv}"

    def as_dict(self):
        return {"cell": self.cell, "kind": self.kind(), "old_type": self.old_type, "new_type": self.new_type,
                "old_ins": self.old_ins, "new_ins": self.new_ins, "invert_out": self.invert_out,
                "description": self.describe(), "points": self.points, "found_by": self.how}


class Diagnoser:
    def __init__(self, impl: Circuit, ref: Circuit, width=2048, seed=2024, log=print):
        self.impl, self.ref = impl, ref
        self.W = width
        self.mask = (1 << width) - 1
        self.rng = random.Random(seed)
        self.log = log
        self.patch = {}              # cell -> (type, ins, invert_out)
        self.history = []            # applied corrections (in order)
        self.leaves = {k: self.rng.getrandbits(width) for k in impl.leaves()}

        # library alternatives, one representative per Boolean function
        self.cells_by_arity = {}
        seen = set()
        for name in sorted(impl.libu, key=lambda n: (len(n), n)):
            c = impl.libu[name]
            if not impl.exprs.get(name) or list(c.outputs) != ["Z"] or c.ff or c.tristate:
                continue
            key = (tuple(c.inputs), repr(impl.exprs[name]["Z"]))
            if key not in seen:
                seen.add(key)
                self.cells_by_arity.setdefault(len(c.inputs), []).append(name)

        # static structure
        self.pos = {c.name: i for i, c in enumerate(impl.order)}
        readers = {}
        for c in impl.comb:
            for n in c.ins.values():
                readers.setdefault(n, []).append(c.name)
        self.cell_fo = {c.name: sorted({r for n in c.outs.values() for r in readers.get(n, [])},
                                        key=self.pos.get) for c in impl.comb}
        self._tfo = {}
        outs = set(impl.outputs.values())
        self.dangling = {n for c in impl.comb for n in c.outs.values() if n not in readers and n not in outs
                         and not any(f.ins.get("D") == n for f in impl.flops.values())}
        self.point_net = {impl.flop_name[f]: c.ins["D"] for f, c in impl.flops.items()}
        self.point_net.update(impl.outputs)
        self.flop_of_point = {impl.flop_name[f]: f for f in impl.flops}
        self.cone_cells = {p: self._cone(n) for p, n in self.point_net.items()}
        self.reach = {}
        for p, cells in self.cone_cells.items():
            for c in cells:
                self.reach.setdefault(c, set()).add(p)
        self._resim()

    # ------------------------------------------------------------------ structure helpers
    def _cone(self, net):
        cone, stack = set(), [net]
        while stack:
            n = stack.pop()
            d = self.impl.driver.get(n)
            if d and d[0] not in cone and d[0] not in self.impl.flops:
                cone.add(d[0])
                stack.extend(self.impl.cells[d[0]].ins.values())
        return cone

    @staticmethod
    def support(circ, net):
        """Names of inputs / flip-flops a net structurally depends on."""
        qname = {}
        for f, c in circ.flops.items():
            for n in c.outs.values():
                qname[n] = circ.flop_name[f]
        sup, seen, stack = set(), set(), [net]
        while stack:
            n = stack.pop()
            if n in seen:
                continue
            seen.add(n)
            if n in qname:
                sup.add(qname[n])
            elif n in circ.driver:
                stack.extend(circ.cells[circ.driver[n][0]].ins.values())
            elif n not in ("0", "1"):
                sup.add(n)
        return frozenset(sup)

    def ref_support(self, point):
        f = next((f for f in self.ref.flops if self.ref.flop_name[f] == point), None)
        net = self.ref.flops[f].ins["D"] if f else self.ref.outputs[point]
        return self.support(self.ref, net)

    def tfo(self, cname):
        if cname not in self._tfo:
            out, stack = set(), [cname]
            while stack:
                for r in self.cell_fo.get(stack.pop(), []):
                    if r not in out:
                        out.add(r)
                        stack.append(r)
            self._tfo[cname] = out
        return self._tfo[cname]

    # ------------------------------------------------------------------ simulation
    def _resim(self):
        self.ref_cp = self.ref.compare_values(self.ref.simulate(self.leaves, self.W))
        self.base_v = self.impl.simulate(self.leaves, self.W, patch=self.patch)
        self.base_err = self._errors_from(self.base_v, self.patch)

    def add_vectors(self, cexs):
        for ce in cexs:
            for k in self.leaves:
                self.leaves[k] = (self.leaves[k] << 1) | ce.get(k, self.rng.getrandbits(1))
            self.W += 1
        self.mask = (1 << self.W) - 1
        self._resim()

    def _cell_value(self, cname, v, spec):
        t, ins, inv = spec
        env = {p: (v.get(n, 0) if n not in ("0", "1") else (self.mask if n == "1" else 0)) for p, n in ins.items()}
        r = _eval_word(self.impl.exprs[t]["Z"], env, self.mask)
        return (~r & self.mask) if inv else r

    def spec(self, cname, patch=None):
        patch = self.patch if patch is None else patch
        c = self.impl.cells[cname]
        return patch.get(cname, (c.type, dict(c.ins), False))

    def evaluate(self, extra: dict, base_patch=None):
        """Values after applying `extra` on top of base_patch (default: current patch).
        Only the transitive fan-out of changed cells is re-simulated."""
        base_patch = self.patch if base_patch is None else base_patch
        patch = dict(base_patch)
        patch.update(extra)
        changed = {c for c in set(extra) | (set(base_patch) ^ set(self.patch)) |
                   {c for c in base_patch if base_patch.get(c) != self.patch.get(c)}
                   if c in self.pos}
        affected = set(changed)
        for c in changed:
            affected |= self.tfo(c)
        v = self.base_v.copy()
        overlay = v
        for cname in sorted(affected, key=self.pos.get):
            c = self.impl.cells[cname]
            if len(c.outs) != 1:
                r = self.impl.eval_cell(c, v, self.mask)
                for p, n in c.outs.items():
                    overlay[n] = r[p]
                continue
            overlay[next(iter(c.outs.values()))] = self._cell_value(cname, v, self.spec(cname, patch))
        return v, patch

    def _errors_from(self, v, patch):
        err = {}
        for p, net in self.point_net.items():
            f = self.flop_of_point.get(p)
            if f in patch:
                net = patch[f][1]["D"]
            val = v.get(net, 0) if net not in ("0", "1") else (self.mask if net == "1" else 0)
            err[p] = val ^ self.ref_cp[p]
        return err

    def errors(self, extra=None, base_patch=None):
        if not extra and base_patch is None:
            return self.base_err, self.base_v
        v, patch = self.evaluate(extra or {}, base_patch)
        return self._errors_from(v, patch), v

    def commit(self, fixes, how):
        for fx in fixes:
            self.patch[fx.cell] = (fx.new_type, fx.new_ins, fx.invert_out)
            fx.how = how
        before = self.base_err
        self._resim()
        repaired = sorted(k for k in before if before[k] and not self.base_err[k])
        for fx in fixes:
            fx.points = repaired
            self.history.append(fx)
            self.log(f"  [{how}] {fx.describe()}")
        if repaired:
            self.log(f"      repairs: {', '.join(repaired)}")

    # ------------------------------------------------------------------ localisation
    def suspects(self, err, cells=None, base_patch=None):
        bad = {k for k, e in err.items() if e}
        scores = []
        for cname in (cells if cells is not None else self.pos):
            c = self.impl.cells[cname]
            if len(c.outs) != 1 or not (self.reach.get(cname, set()) & bad):
                continue
            t, ins, inv = self.spec(cname, base_patch)
            e2, _ = self.errors({cname: (t, ins, not inv)}, base_patch)
            explained = sum(POP(err[k] & ~e2[k]) for k in bad)
            if explained:
                scores.append((explained, cname))
        scores.sort(key=lambda x: (-x[0], self.pos[x[1]]))
        return scores

    # ------------------------------------------------------------------ error model
    def alternatives(self, cname, v, base_patch=None):
        t0, ins0, inv0 = self.spec(cname, base_patch)
        orig = self.impl.cells[cname]
        nets = list(ins0.values())
        cands = []
        for t in [t0] + [x for x in self.cells_by_arity.get(len(nets), []) if x != t0]:
            tp = self.impl.libu[t].inputs
            for perm in itertools.permutations(nets):
                for inv in (False, True):
                    cost = (0 if list(perm) == nets else 1) + (3 if inv else 0) + (0.5 if t == t0 else 0) \
                        + self.complexity(t)
                    cands.append((cost, t, dict(zip(tp, perm)), inv))
        if len(nets) == 1:
            cands.append((0, "IBUF1", {"A": nets[0]}, False))
        if (t0, ins0, inv0) != (orig.type, orig.ins, False):
            cands.append((-1, orig.type, dict(orig.ins), False))       # undo an earlier correction
        cands.sort(key=lambda x: x[0])
        seen = {self._cell_value(cname, v, (t0, ins0, inv0))}
        out = []
        for cost, t, ins, inv in cands:
            r = self._cell_value(cname, v, (t, ins, inv))
            if r in seen:
                continue
            seen.add(r)
            out.append(Fix(cname, orig.type, t, dict(orig.ins), ins, inv))
        return out

    @staticmethod
    def complexity(t):
        """Tie-breaker between equally good corrections: prefer simple gates."""
        base = t.rstrip("IP")
        if base in ("AN2", "OR2", "ND2", "NR2", "AN3", "OR3", "ND3", "NR3", "AN4", "OR4", "ND4", "NR4", "IV"):
            return 0.0
        if base.startswith(("EO", "EN")):
            return 0.3
        return 0.2

    def flop_alternatives(self, point, v):
        f = self.flop_of_point[point]
        c = self.impl.flops[f]
        want = self.ref_cp[point]
        q = {n for x in self.impl.flops.values() for n in x.outs.values()}
        out = []
        for n, val in v.items():
            if n in ("0", "1") or n in q or n in self.impl.inputs or n == c.ins["D"]:
                continue
            if val == want:
                out.append((0 if n in self.dangling else 1, n))
        out.sort()
        return [Fix(f, c.type, c.type, dict(c.ins), {**c.ins, "D": n}) for _, n in out]

    # ------------------------------------------------------------------ search strategies
    def step_single(self, strict=True, top=30):
        err, v = self.base_err, self.base_v
        before = sum(POP(e) for e in err.values())
        best = None
        # flip-flops wired to the wrong driver
        for p, e in err.items():
            if e and p in self.flop_of_point:
                for fx in self.flop_alternatives(p, v)[:3]:
                    e2, _ = self.errors({fx.cell: (fx.new_type, fx.new_ins, False)})
                    if not e2[p]:
                        return self.commit([fx], "dangling driver" if fx.new_ins["D"] in self.dangling else "rewire")
        for score, cname in self.suspects(err)[:top]:
            for fx in self.alternatives(cname, v)[:150]:
                e2, _ = self.errors({cname: (fx.new_type, fx.new_ins, fx.invert_out)})
                after = sum(POP(x) for x in e2.values())
                if after >= before:
                    continue
                newly = sum(POP(e2[k] & ~err[k]) for k in err)
                repaired = sum(1 for k in err if err[k] and not e2[k])
                if strict and (newly or not repaired):
                    continue
                key = (newly > 0, -repaired, after)
                if best is None or key < best[0]:
                    best = (key, fx)
        if best:
            self.commit([best[1]], "single gate" if strict else "partial")
            return True
        return False

    def step_dangling(self):
        """A flop's D was re-wired away from its real driver (left dangling) AND a
        gate inside that dangling cone is wrong too: try both corrections jointly."""
        err = self.base_err
        used = {s[1].get("D") for c, s in self.patch.items() if c in self.impl.flops}
        for p in sorted(k for k, e in err.items() if e and k in self.flop_of_point):
            f = self.flop_of_point[p]
            c = self.impl.flops[f]
            want_sup = self.ref_support(p)
            for dnet in sorted(self.dangling - used):
                if self.support(self.impl, dnet) != want_sup:
                    continue            # the intended driver must depend on the same signals
                rew = Fix(f, c.type, c.type, dict(c.ins), {**c.ins, "D": dnet})
                bp = dict(self.patch)
                bp[f] = (c.type, rew.new_ins, False)
                e1, v1 = self.errors({}, bp)
                for g in sorted(self._cone(dnet), key=self.pos.get):
                    for fx in self.alternatives(g, v1, bp)[:60]:
                        e2, _ = self.errors({g: (fx.new_type, fx.new_ins, fx.invert_out)}, bp)
                        newly = sum(POP(e2[k] & ~err[k]) for k in err)
                        if not e2[p] and not newly:
                            self.commit([rew, fx], "dangling driver + gate")
                            return True
        return False

    def step_pair(self, top1=40):
        """Two interacting errors in one cone. Earlier corrections in the same cone
        may be undone (they are treated as a guess that turned out wrong)."""
        err = self.base_err
        stuck = {k for k, e in err.items() if e}
        cluster = set().union(*[self.cone_cells[p] for p in stuck])
        related = set().union(*[self.reach.get(c, set()) for c in cluster]) | stuck
        undo = {c for c in self.patch if c in cluster or (c in self.reach and self.reach[c] & related)}
        bases = [dict(self.patch)] + [{c: s for c, s in self.patch.items() if c != u} for u in sorted(undo)]
        for bp in bases:
            e0, v0 = self.errors({}, bp)
            tot0 = sum(POP(e0[k]) for k in related)
            for _, g1 in self.suspects(e0, cluster, bp)[:top1]:
                for f1 in self.alternatives(g1, v0, bp)[:40]:
                    ex1 = {g1: (f1.new_type, f1.new_ins, f1.invert_out)}
                    e1, v1 = self.errors(ex1, bp)
                    rem = {k for k in related if e1[k]}
                    if not rem or sum(POP(e1[k]) for k in related) >= tot0 or not any(e1[k] != e0[k] for k in stuck):
                        continue
                    need = sum(POP(e1[k]) for k in rem)
                    bp1 = dict(bp)
                    bp1.update(ex1)
                    for sc, g2 in self.suspects(e1, cluster, bp1):
                        if sc < need or g2 == g1:
                            break
                        for f2 in self.alternatives(g2, v1, bp1)[:60]:
                            e2, _ = self.errors({g2: (f2.new_type, f2.new_ins, f2.invert_out)}, bp1)
                            if any(e2[k] for k in stuck):
                                continue
                            if any(e2[k] & ~err[k] for k in err):
                                continue
                            dropped = [c for c in self.patch if c not in bp]
                            for c in dropped:
                                self.log(f"  [back-track] undoing earlier correction of {c}")
                                del self.patch[c]
                                self.history = [h for h in self.history if h.cell != c]
                            self.commit([f1, f2], "two-gate search")
                            return True
        return False

    # ------------------------------------------------------------------ driver
    def run(self, verify=None, max_steps=80):
        """verify(patch) -> list of counter-example dicts ([] when proven equivalent)."""
        steps = 0
        while steps < max_steps:
            steps += 1
            failing = sorted(k for k, e in self.base_err.items() if e)
            if not failing:
                if verify is None:
                    return True
                cexs = verify(self.patch)
                if not cexs:
                    return True
                self.log(f"  simulation is clean but SAT found {len(cexs)} counter-example(s); adding them")
                self.add_vectors(cexs)
                continue
            self.log(f"  {len(failing)} failing compare points "
                     f"({sum(POP(e) for e in self.base_err.values())} failing point/vector pairs)")
            # cheap strategies first; the two-gate search is reserved for the last
            # few interacting errors, where back-tracking pays off
            few = len(failing) <= 4
            if (self.step_single(strict=True) or self.step_dangling() or (few and self.step_pair())
                    or self.step_single(strict=False) or (not few and self.step_pair())):
                continue
            self.log("  no correction found within the error model")
            return False
        return False

    def minimise(self, verify):
        """Drop corrections that are not needed (proof-checked)."""
        for cname in list(self.patch):
            saved = self.patch.pop(cname)
            self._resim()
            if any(self.base_err.values()) or verify(self.patch):     # cheap simulation first
                self.patch[cname] = saved
            else:
                self.log(f"  minimise: correction of {cname} is redundant - dropped")
        self._resim()

    def net_changes(self):
        out = []
        by_cell = {h.cell: h for h in self.history}
        for cname, (t, ins, inv) in self.patch.items():
            c = self.impl.cells[cname]
            if t == c.type and ins == c.ins and not inv:
                continue
            f = Fix(cname, c.type, t, dict(c.ins), dict(ins), inv)
            if cname in by_cell:
                f.how = by_cell[cname].how
            out.append(f)
        return out
