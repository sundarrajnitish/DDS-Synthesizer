/* bdd.js - a small reduced ordered binary decision diagram (ROBDD) package.
 *
 * Nodes are integers: 0 = FALSE, 1 = TRUE, n >= 2 = (var, lo, hi).
 * Because an ROBDD is canonical for a fixed variable order, two circuits
 * compute the same function exactly when their BDDs are the same node -
 * equivalence checking becomes an integer comparison.
 */
(function (global) {
  "use strict";

  class BDD {
    constructor(nvars) {
      this.nvars = nvars;
      this.cap = 1 << 16;
      this.v = new Int32Array(this.cap);
      this.lo = new Int32Array(this.cap);
      this.hi = new Int32Array(this.cap);
      this.v[0] = this.v[1] = nvars;          // terminals sit below every variable
      this.n = 2;
      this.unique = new Map();
      this.cache = new Map();
    }
    get size() { return this.n; }
    _grow() {
      const c = this.cap * 2;
      for (const k of ["v", "lo", "hi"]) { const a = new Int32Array(c); a.set(this[k]); this[k] = a; }
      this.cap = c;
    }
    mk(v, lo, hi) {
      if (lo === hi) return lo;
      const key = (v * 4194304 + lo) * 4194304 + hi;     // v < 2^9, lo/hi < 2^22
      let r = this.unique.get(key);
      if (r !== undefined) return r;
      if (this.n >= this.cap) this._grow();
      r = this.n++;
      this.v[r] = v; this.lo[r] = lo; this.hi[r] = hi;
      this.unique.set(key, r);
      return r;
    }
    ithvar(i) { return this.mk(i, 0, 1); }
    // op: 0 AND, 1 OR, 2 XOR
    apply(op, f, g) {
      if (op === 0) { if (f === 0 || g === 0) return 0; if (f === 1) return g; if (g === 1) return f; if (f === g) return f; }
      else if (op === 1) { if (f === 1 || g === 1) return 1; if (f === 0) return g; if (g === 0) return f; if (f === g) return f; }
      else { if (f === 0) return g; if (g === 0) return f; if (f === g) return 0; }
      if (f > g) { const t = f; f = g; g = t; }
      const key = (op * 4194304 + f) * 4194304 + g;
      const c = this.cache.get(key);
      if (c !== undefined) return c;
      const vf = this.v[f], vg = this.v[g], v = vf < vg ? vf : vg;
      const f0 = vf === v ? this.lo[f] : f, f1 = vf === v ? this.hi[f] : f;
      const g0 = vg === v ? this.lo[g] : g, g1 = vg === v ? this.hi[g] : g;
      const r = this.mk(v, this.apply(op, f0, g0), this.apply(op, f1, g1));
      this.cache.set(key, r);
      return r;
    }
    and(f, g) { return this.apply(0, f, g); }
    or(f, g) { return this.apply(1, f, g); }
    xor(f, g) { return this.apply(2, f, g); }
    not(f) { return this.apply(2, f, 1); }
    /* number of nodes reachable from f (the "size" shown in the UI) */
    count(f) {
      const seen = new Set(); const st = [f];
      while (st.length) { const x = st.pop(); if (x < 2 || seen.has(x)) continue; seen.add(x); st.push(this.lo[x], this.hi[x]); }
      return seen.size;
    }
    support(f) {
      const vars = new Set(), seen = new Set(), st = [f];
      while (st.length) { const x = st.pop(); if (x < 2 || seen.has(x)) continue; seen.add(x); vars.add(this.v[x]); st.push(this.lo[x], this.hi[x]); }
      return [...vars].sort((a, b) => a - b);
    }
    /* one satisfying assignment (var -> 0/1) or null; unmentioned vars are don't-care */
    anySat(f) {
      if (f === 0) return null;
      const a = {};
      while (f > 1) {
        if (this.lo[f] !== 0) { a[this.v[f]] = 0; f = this.lo[f]; }
        else { a[this.v[f]] = 1; f = this.hi[f]; }
      }
      return a;
    }
    eval(f, assign) {
      while (f > 1) f = assign[this.v[f]] ? this.hi[f] : this.lo[f];
      return f;
    }
    /* nodes of f by level, for drawing small diagrams */
    graph(f) {
      const nodes = [], seen = new Set(), st = [f];
      while (st.length) { const x = st.pop(); if (seen.has(x)) continue; seen.add(x); nodes.push(x); if (x > 1) st.push(this.lo[x], this.hi[x]); }
      return nodes.map(x => ({ id: x, v: x > 1 ? this.v[x] : null, lo: x > 1 ? this.lo[x] : null, hi: x > 1 ? this.hi[x] : null }));
    }
  }

  /* evaluate a Liberty expression tree (["and", [...]], ["var","A"], ...) on BDDs */
  function evalExpr(bdd, e, env) {
    switch (e[0]) {
      case "var": return env[e[1]];
      case "const": return e[1] ? 1 : 0;
      case "not": return bdd.not(evalExpr(bdd, e[1], env));
      case "and": { let r = 1; for (const x of e[1]) { r = bdd.and(r, evalExpr(bdd, x, env)); if (r === 0) break; } return r; }
      case "or": { let r = 0; for (const x of e[1]) { r = bdd.or(r, evalExpr(bdd, x, env)); if (r === 1) break; } return r; }
      case "xor": { let r = 0; for (const x of e[1]) r = bdd.xor(r, evalExpr(bdd, x, env)); return r; }
    }
    throw new Error("bad expression " + e[0]);
  }
  /* same expression on 32-bit words (bit-parallel simulation) */
  function evalWord(e, env) {
    switch (e[0]) {
      case "var": return env[e[1]];
      case "const": return e[1] ? -1 : 0;
      case "not": return ~evalWord(e[1], env);
      case "and": { let r = -1; for (const x of e[1]) r &= evalWord(x, env); return r; }
      case "or": { let r = 0; for (const x of e[1]) r |= evalWord(x, env); return r; }
      case "xor": { let r = 0; for (const x of e[1]) r ^= evalWord(x, env); return r; }
    }
    return 0;
  }

  global.BDD = BDD;
  global.evalExpr = evalExpr;
  global.evalWord = evalWord;
})(window);
