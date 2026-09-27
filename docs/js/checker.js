/* checker.js - equivalence checking of the real gate-level netlists, in the browser.
 *
 * Same method as Formality / Conformal (and formal/fv/eqcheck.py in the repo):
 *   1. match compare points by name: 20 output bits + 72 flip-flops
 *   2. cut the design at the flip-flops: their outputs become free variables
 *   3. build a BDD for every compare point's logic cone in both designs
 *   4. equal BDD node <=> equivalent; otherwise XOR the two and read a
 *      counter-example off any path to TRUE
 */
(function (global) {
  "use strict";

  function variableOrder() {
    // Interleave the operands of each adder, least significant bit first, so the
    // carry chains stay linear in size. The LUT and output logic follows.
    const o = [];
    for (let k = 0; k < 22; k++) o.push(`ftw_i[${k}]`, `ftw_accu[${k}]`);
    for (let k = 0; k < 10; k++) o.push(`ftw_i[${22 + k}]`, `ftw_accu[${22 + k}]`, `phase_i[${k}]`);
    for (let k = 9; k >= 0; k--) o.push(`phase[${k}]`);
    for (let k = 0; k < 10; k++) o.push(`lut_out[${k}]`);
    o.push("quadrant_3_or_4_delay", "quadrant_3_or_4_2delay");
    for (let k = 0; k < 10; k++) o.push(`lut_out_delay[${k}]`, `lut_out_inv_delay[${k}]`);
    return o;
  }

  class Design {
    constructor(json, lib, name) {
      this.name = name;
      this.lib = lib;
      this.nets = json.nets;
      this.netIdx = new Map(json.nets.map((n, i) => [n, i]));
      this.inputs = json.inputs;
      this.outputs = json.outputs;
      this.cells = json.cells.map(c => ({ name: c[0], type: c[1], ins: c[2].slice(), outs: c[3].slice() }));
      this.cellByName = new Map(this.cells.map(c => [c.name, c]));
      this.flops = json.flops.map(f => ({ canon: f[0], inst: f[1], d: f[2], q: f[3], qn: f[4] }));
      this.flopByInst = new Map(this.flops.map(f => [f.inst, f]));
      this.area = json.area;
      this.ncells = json.ncells;
      this.driver = new Map();
      this.cells.forEach(c => c.outs.forEach(o => this.driver.set(o, c)));
    }
    clone(name) {
      const d = Object.create(Design.prototype);
      Object.assign(d, this);
      d.name = name;
      d.cells = this.cells.map(c => ({ name: c.name, type: c.type, ins: c.ins.slice(), outs: c.outs.slice() }));
      d.cellByName = new Map(d.cells.map(c => [c.name, c]));
      d.flops = this.flops.map(f => Object.assign({}, f));
      d.flopByInst = new Map(d.flops.map(f => [f.inst, f]));
      d.driver = new Map();
      d.cells.forEach(c => c.outs.forEach(o => d.driver.set(o, c)));
      return d;
    }
    net(name) {
      if (!this.netIdx.has(name)) throw new Error("unknown net " + name);
      return this.netIdx.get(name);
    }
    /* apply one diagnosed correction (from the repair report) */
    applyFix(fx) {
      const f = this.flopByInst.get(fx.cell);
      if (f) { f.d = this.net(fx.new_ins.D); return; }
      const c = this.cellByName.get(fx.cell);
      c.type = fx.new_type;
      c.ins = this.lib[fx.new_type].in.map(p => this.net(fx.new_ins[p]));
    }
    comparePoints() {
      const pts = [];
      for (const o of Object.keys(this.outputs)) pts.push({ type: "Port", name: o, net: this.outputs[o] });
      for (const f of this.flops) pts.push({ type: "DFF", name: f.canon, net: f.d });
      return pts;
    }
    coneSize(net) {
      const seen = new Set(), st = [net];
      while (st.length) {
        const n = st.pop(); const c = this.driver.get(n);
        if (!c || seen.has(c)) continue; seen.add(c); c.ins.forEach(x => st.push(x));
      }
      return seen.size;
    }
    /* BDD for every net (cut at flip-flops) */
    build(bdd, order) {
      const node = new Int32Array(this.nets.length).fill(-1);
      node[0] = 0; node[1] = 1;
      for (const [nm, i] of Object.entries(this.inputs)) node[i] = bdd.ithvar(order.get(nm));
      for (const f of this.flops) {
        const v = bdd.ithvar(order.get(f.canon));
        if (f.q > 0) node[f.q] = v;
        if (f.qn > 0) node[f.qn] = bdd.not(v);
      }
      for (const c of this.cells) {
        const L = this.lib[c.type];
        const env = {};
        L.in.forEach((p, k) => { env[p] = node[c.ins[k]] < 0 ? 0 : node[c.ins[k]]; });
        const outs = Object.keys(L.out);
        outs.forEach((p, k) => { if (c.outs[k] > 1) node[c.outs[k]] = evalExpr(bdd, L.out[p], env); });
      }
      return node;
    }
  }

  function wordsOf(assign, order) {
    // group a flat counter-example back into the design's words (hex)
    const byWord = {};
    order.forEach((name, v) => {
      if (!(v in assign)) return;
      const m = name.match(/^(\w+)\[(\d+)\]$/);
      const w = m ? m[1] : name, b = m ? +m[2] : 0;
      byWord[w] = byWord[w] || { value: 0n, bits: [] };
      if (assign[v]) byWord[w].value |= 1n << BigInt(b);
      byWord[w].bits.push(b);
    });
    return byWord;
  }

  /* compare two designs; returns {points, summary, ms, bddNodes} */
  function compare(ref, impl) {
    const t0 = performance.now();
    const orderList = variableOrder();
    const order = new Map(orderList.map((n, i) => [n, i]));
    const bdd = new BDD(orderList.length);
    const nr = ref.build(bdd, order);
    const ni = impl.build(bdd, order);
    const points = [];
    for (const p of ref.comparePoints()) {
      const q = impl.comparePoints().find(x => x.name === p.name);
      if (!q) continue;
      const a = nr[p.net], b = ni[q.net];
      const rec = { type: p.type, name: p.name, pass: a === b, refSize: bdd.count(a), implSize: bdd.count(b),
                    cone: impl.coneSize(q.net), refCone: ref.coneSize(p.net) };
      if (!rec.pass) {
        const x = bdd.xor(a, b);
        const sat = bdd.anySat(x);
        rec.cex = wordsOf(sat, orderList);
        rec.refVal = bdd.eval(a, sat);
        rec.implVal = bdd.eval(b, sat);
        rec.support = bdd.support(x).map(v => orderList[v]);
      }
      points.push(rec);
    }
    const summary = { pass: points.filter(p => p.pass).length, fail: points.filter(p => !p.pass).length,
                      portFail: points.filter(p => !p.pass && p.type === "Port").length,
                      dffFail: points.filter(p => !p.pass && p.type === "DFF").length };
    return { points, summary, ms: performance.now() - t0, bddNodes: bdd.size };
  }

  global.Checker = { Design, compare, variableOrder };
})(window);
