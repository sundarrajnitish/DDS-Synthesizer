/* main.js - wiring for the DDS formal verification site. */
(function () {
  "use strict";
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const tok = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
  const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const FCLK = 100e6;
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
  const nat = (a, b) => a.localeCompare(b, undefined, { numeric: true });
  const hex = (v, w = 8) => (typeof v === "bigint" ? v : BigInt(v)).toString(16).toUpperCase().padStart(w, "0");
  const redraws = [];

  /* ------------------------------------------------------------------ theme */
  const themeBtn = $("#themeBtn");
  function setTheme(t) {
    if (t) document.documentElement.setAttribute("data-theme", t); else document.documentElement.removeAttribute("data-theme");
    themeBtn.textContent = t === "dark" ? "dark" : t === "light" ? "light" : "auto";
    try { t ? localStorage.setItem("theme", t) : localStorage.removeItem("theme"); } catch (e) { /* storage unavailable */ }
    redraws.forEach(f => f());
  }
  let saved = null; try { saved = localStorage.getItem("theme"); } catch (e) { saved = null; }
  setTheme(saved);
  themeBtn.addEventListener("click", () => {
    const cur = document.documentElement.getAttribute("data-theme");
    setTheme(cur === null ? "dark" : cur === "dark" ? "light" : null);
  });
  matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => redraws.forEach(f => f()));

  /* TOC highlight */
  const tocLinks = $$(".toc a");
  const obs = new IntersectionObserver(es => es.forEach(e => {
    if (e.isIntersecting) tocLinks.forEach(a => a.classList.toggle("on", a.getAttribute("href") === "#" + e.target.id));
  }), { rootMargin: "-40% 0px -55% 0px" });
  $$("section.chapter").forEach(s => obs.observe(s));

  /* ------------------------------------------------------------------ canvas helper */
  function ctx2d(cv) {
    const dpr = window.devicePixelRatio || 1;
    const w = cv.clientWidth || cv.parentElement.clientWidth, h = +cv.getAttribute("height");
    cv.style.height = h + "px";
    if (cv.width !== Math.round(w * dpr) || cv.height !== Math.round(h * dpr)) { cv.width = Math.round(w * dpr); cv.height = Math.round(h * dpr); }
    const c = cv.getContext("2d");
    c.setTransform(dpr, 0, 0, dpr, 0, 0);
    c.clearRect(0, 0, w, h);
    return { c, w, h };
  }
  let rs; window.addEventListener("resize", () => { clearTimeout(rs); rs = setTimeout(() => redraws.forEach(f => f()), 120); });

  /* ------------------------------------------------------------------ compare point order */
  const CP_ORDER = [];
  for (let i = 0; i < 10; i++) CP_ORDER.push(`ampl_o[${i}]`);
  for (let i = 0; i < 10; i++) CP_ORDER.push(`phase_o[${i}]`);
  for (let i = 0; i < 32; i++) CP_ORDER.push(`ftw_accu[${i}]`);
  for (let i = 0; i < 10; i++) CP_ORDER.push(`phase[${i}]`);
  for (let i = 0; i < 9; i++) CP_ORDER.push(`lut_out[${i}]`);
  for (let i = 0; i < 9; i++) CP_ORDER.push(`lut_out_delay[${i}]`);
  for (let i = 0; i < 10; i++) CP_ORDER.push(`lut_out_inv_delay[${i}]`);
  CP_ORDER.push("quadrant_3_or_4_delay", "quadrant_3_or_4_2delay");

  function makeGrid(el, onClick) {
    el.innerHTML = "";
    const cells = new Map();
    CP_ORDER.forEach(n => {
      const b = document.createElement("button");
      b.type = "button";
      b.className = "cp pending" + (n.includes("_o[") ? " port" : "");
      b.title = n; b.setAttribute("aria-label", n);
      if (onClick) b.addEventListener("click", () => onClick(n, b)); else b.tabIndex = -1;
      el.appendChild(b); cells.set(n, b);
    });
    return cells;
  }
  function paintGrid(cells, res) {
    const by = new Map(res.points.map(p => [p.name, p]));
    cells.forEach((b, n) => {
      const p = by.get(n);
      b.classList.remove("pending");
      b.classList.toggle("fail", !!p && !p.pass);
      b.title = n + (p ? (p.pass ? " - equivalent" : " - NOT equivalent") : "");
    });
  }

  /* ------------------------------------------------------------------ data */
  let NET = null, RES = null;
  const designs = {};
  function implDesign(kind, fixSet) {
    if (kind === "manual") return designs.manual;
    const d = designs.buggy.clone("patched");
    NET.fixes.forEach((f, i) => { if (kind === "fixed" || fixSet.has(i)) d.applyFix(f); });
    return d;
  }

  Promise.all(["data/netlists.json", "data/results.json"].map(u => fetch(u).then(r => { if (!r.ok) throw new Error(u); return r.json(); })))
    .then(([n, r]) => {
      NET = n; RES = r;
      for (const k of ["golden", "buggy", "manual"]) designs[k] = new Checker.Design(NET.designs[k], NET.lib, k);
      initHero(); initWorkbench(); initSynth(); initManual(); initReplay(); initBugs(); initSvf();
      initProps(); initMutants(); initTheorems(); initLean();
    })
    .catch(err => {
      $$(".instrument-body").forEach(b => { if (!b.children.length) b.textContent = "Could not load data: " + err.message; });
      $("#heroNote").textContent = "Data files could not be loaded (open the page through a web server: make serve).";
    });

  /* ------------------------------------------------------------------ hero */
  function initHero() {
    const cells = makeGrid($("#heroGrid"));
    const set = new Set();
    let timer = null;
    function run() {
      const r = Checker.compare(designs.golden, implDesign("buggy", set));
      paintGrid(cells, r);
      $("#heroCount").textContent = `${r.summary.pass} / 92 pass`;
      $("#heroLed").classList.toggle("bad", r.summary.fail > 0);
      $("#heroTitle").textContent = set.size === 0 ? "golden vs buggy netlist" : set.size === 14 ? "golden vs repaired netlist" : `golden vs buggy + ${set.size} fixes`;
      $("#heroMs").textContent = `${Math.max(1, Math.round(r.ms))} ms`;
      return r;
    }
    run();
    $("#heroRepair").addEventListener("click", () => {
      clearInterval(timer);
      if (reduced) { NET.fixes.forEach((_, i) => set.add(i)); run(); return; }
      let i = 0;
      timer = setInterval(() => { set.add(i++); run(); if (i >= NET.fixes.length) clearInterval(timer); }, 260);
    });
    $("#heroReset").addEventListener("click", () => { clearInterval(timer); set.clear(); run(); });
  }

  // animated scope in the hero (runs independently of the data)
  (function heroScope() {
    const cv = $("#heroScope");
    const d = new DDS();
    const buf = [];
    const ftw = 0x03000000;           // ~1.17 MHz at 100 MHz: about 85 samples per period
    for (let i = 0; i < 200; i++) { d.clock(ftw, 0); buf.push(d.ampl); }
    function draw() {
      const { c, w, h } = ctx2d(cv);
      c.strokeStyle = tok("--rule"); c.lineWidth = 1;
      for (let x = 0; x <= 10; x++) { c.beginPath(); c.moveTo(x * w / 10, 0); c.lineTo(x * w / 10, h); c.stroke(); }
      for (let y = 0; y <= 4; y++) { c.beginPath(); c.moveTo(0, y * h / 4); c.lineTo(w, y * h / 4); c.stroke(); }
      c.strokeStyle = tok("--trace"); c.lineWidth = 2; c.beginPath();
      const n = buf.length;
      buf.forEach((v, i) => { const x = i / (n - 1) * w, y = h / 2 - v / 512 * (h / 2 - 8); i ? c.lineTo(x, y) : c.moveTo(x, y); });
      c.stroke();
      c.fillStyle = tok("--muted"); c.font = "11px " + tok("--f-mono");
      c.fillText("ampl_o  FTW=0x03000000  f = 1.172 MHz", 8, 14);
    }
    redraws.push(draw);
    draw();
    if (!reduced) {
      let last = 0;
      const tick = t => { if (t - last > 33) { last = t; for (let k = 0; k < 2; k++) { d.clock(ftw, 0); buf.push(d.ampl); buf.shift(); } draw(); } requestAnimationFrame(tick); };
      requestAnimationFrame(tick);
    }
  })();

  /* ------------------------------------------------------------------ 1. DDS explorer */
  (function explorer() {
    const sim = new DDS();
    let ftw = 0x028F5C29, phi = 0, running = false, hist = [];
    const fS = $("#fSlider"), fOut = $("#fOut"), hexIn = $("#ftwHex"), phS = $("#phSlider"), phOut = $("#phOut");
    const sliderToF = v => 1e4 * Math.pow(4500, v / 1000);           // 10 kHz ... 45 MHz, log
    const fToSlider = f => Math.round(1000 * Math.log(Math.max(f, 1e4) / 1e4) / Math.log(4500));
    const fmtF = f => f >= 1e6 ? (f / 1e6).toFixed(4) + " MHz" : f >= 1e3 ? (f / 1e3).toFixed(3) + " kHz" : f.toFixed(3) + " Hz";
    function setFtw(v, from) {
      ftw = ((v % 2 ** 32) + 2 ** 32) % 2 ** 32;
      const f = ftw / 2 ** 32 * FCLK;
      fOut.textContent = fmtF(f);
      if (from !== "hex") hexIn.value = hex(ftw);
      if (from !== "slider") fS.value = fToSlider(f > FCLK / 2 ? FCLK - f : f);
      $("#freqLbl").textContent = `f_out = ${ftw} / 2^32 × 100 MHz = ${fmtF(f)}`;
      scheduleSpec();
    }
    fS.addEventListener("input", () => setFtw(Math.round(sliderToF(+fS.value) / FCLK * 2 ** 32), "slider"));
    hexIn.addEventListener("change", () => { const v = parseInt(hexIn.value.replace(/^0x/i, ""), 16); if (!isNaN(v)) setFtw(v, "hex"); else hexIn.value = hex(ftw); });
    phS.addEventListener("input", () => { phi = +phS.value; phOut.textContent = `${phi} (${(phi / 1024 * 360).toFixed(1)}°)`; });
    function step(n = 1) { for (let i = 0; i < n; i++) { sim.clock(ftw, phi); hist.push({ a: sim.ampl, p: sim.phase }); if (hist.length > 400) hist.shift(); } draw(); }
    $("#stepBtn").addEventListener("click", () => step(1));
    $("#rstBtn").addEventListener("click", () => { sim.reset(); hist = []; draw(); });
    const runBtn = $("#runBtn");
    runBtn.addEventListener("click", () => { running = !running; runBtn.textContent = running ? "Pause" : "Run"; if (running) loop(); });
    let lt = 0;
    function loop(t = 0) { if (!running) return; if (t - lt > 40) { lt = t; step(1); } requestAnimationFrame(loop); }

    function regRows() {
      const f = sim.fold(sim.phase);
      const rows = [
        ["ftw_i (input)", "0x" + hex(ftw), "frequency tuning word"],
        ["phase_i (input)", phi, "phase offset"],
        ["ftw_accu", "0x" + hex(sim.ftw_accu), "stage 0: accumulator"],
        ["phase = phase_o", `${sim.phase} = ${sim.phase.toString(2).padStart(10, "0")}b`, "stage 1: top 10 bits + phase_i"],
        ["quadrant", `${(sim.phase >> 8) + 1}  (mirror ${f.q2or4}, negate ${f.q3or4})`, "phase bits 8 and 9"],
        ["lut_in", f.peak ? "256 → special case" : f.lut_in, f.q2or4 ? "256 − low, read backwards" : "low 8 bits"],
        ["lut_out", sim.lut_out, "stage 2: |sin|"],
        ["lut_out_delay", sim.lut_out_delay, "stage 3: +sin"],
        ["lut_out_inv_delay", sim.lut_out_inv_delay, "stage 3: −sin"],
        ["quadrant_3_or_4 delays", `${sim.q34_d}, ${sim.q34_2d}`, "sign travels with the sample"],
        ["ampl_o (output)", sim.ampl, "select by delayed sign"],
      ];
      $("#regTable").innerHTML = "<thead><tr><th>signal</th><th>value</th><th>role</th></tr></thead><tbody>" +
        rows.map(r => `<tr${r[0].startsWith("ampl") ? ' class="hl"' : ""}><td>${esc(r[0])}</td><td class="num">${esc(r[1])}</td><td style="font-family:var(--f-body)">${esc(r[2])}</td></tr>`).join("") + "</tbody>";
      $("#cycleLbl").textContent = `cycle ${sim.cycle}`;
    }
    function drawScope() {
      const { c, w, h } = ctx2d($("#scope"));
      const pad = 28, H = h - pad;
      c.strokeStyle = tok("--rule"); c.lineWidth = 1;
      for (let y = 0; y <= 4; y++) { c.beginPath(); c.moveTo(pad, 6 + y * (H - 12) / 4); c.lineTo(w, 6 + y * (H - 12) / 4); c.stroke(); }
      c.fillStyle = tok("--muted"); c.font = "10px " + tok("--f-mono"); c.textAlign = "right";
      [511, 256, 0, -256, -511].forEach((v, i) => c.fillText(v, pad - 4, 10 + i * (H - 12) / 4));
      const n = 128, data = hist.slice(-n);
      const X = i => pad + i / (n - 1) * (w - pad - 4), Y = v => 6 + (1 - (v + 512) / 1024) * (H - 12);
      // ideal sine from the phase that produced each sample (phase two cycles earlier)
      c.strokeStyle = tok("--accent"); c.globalAlpha = 0.45; c.lineWidth = 1.5; c.beginPath();
      data.forEach((s, i) => { const ph = i >= 2 ? data[i - 2].p : null; if (ph === null) return; const y = Y(511 * Math.sin(2 * Math.PI * ph / 1024)); i === 2 ? c.moveTo(X(i), y) : c.lineTo(X(i), y); });
      c.stroke(); c.globalAlpha = 1;
      c.strokeStyle = tok("--trace"); c.lineWidth = 2; c.beginPath();
      data.forEach((s, i) => { const x = X(i), y = Y(s.a); if (!i) c.moveTo(x, y); else { c.lineTo(x, Y(data[i - 1].a)); c.lineTo(x, y); } });
      c.stroke();
      c.textAlign = "left"; c.fillStyle = tok("--muted");
      c.fillText(`last ${data.length} samples · amber = ampl_o · teal = 511·sin(2π·phase/1024)`, pad, h - 8);
      if (!data.length) { c.fillStyle = tok("--ink-2"); c.font = "13px " + tok("--f-body"); c.fillText("Press Run or Step to clock the DDS.", pad + 10, H / 2); }
    }
    function drawWheel() {
      const { c, w, h } = ctx2d($("#wheel"));
      const r = Math.min(h / 2 - 22, w * 0.22), cx = r + 16, cy = h / 2 - 6;
      const f = sim.fold(sim.phase), ang = 2 * Math.PI * sim.phase / 1024;
      // quadrants
      for (let q = 0; q < 4; q++) {
        c.beginPath(); c.moveTo(cx, cy); c.arc(cx, cy, r, -q * Math.PI / 2, -(q + 1) * Math.PI / 2, true); c.closePath();
        c.fillStyle = q === (sim.phase >> 8) ? tok("--accent-soft") : "transparent"; c.fill();
        c.strokeStyle = tok("--rule-strong"); c.stroke();
      }
      c.fillStyle = tok("--muted"); c.font = "10px " + tok("--f-mono"); c.textAlign = "center";
      ["Q1 +", "Q2 + mirror", "Q3 −", "Q4 − mirror"].forEach((t, q) => {
        const a = -(q + 0.5) * Math.PI / 2; c.fillText(t, cx + Math.cos(a) * r * 0.62, cy + Math.sin(a) * r * 0.62 + 3);
      });
      c.strokeStyle = tok("--ink"); c.lineWidth = 2.5; c.beginPath(); c.moveTo(cx, cy); c.lineTo(cx + Math.cos(-ang) * r, cy + Math.sin(-ang) * r); c.stroke();
      c.fillStyle = tok("--trace"); c.beginPath(); c.arc(cx + Math.cos(-ang) * r, cy + Math.sin(-ang) * r, 5, 0, 7); c.fill();
      c.fillStyle = tok("--ink-2"); c.fillText(`phase ${sim.phase} / 1024`, cx, cy + r + 16);
      // quarter-wave table
      const x0 = cx + r + 26, x1 = w - 8, y0 = 14, y1 = h - 44;
      if (x1 - x0 > 60) {
        const lut = sim.lut, n = lut.length;
        c.strokeStyle = tok("--rule"); c.strokeRect(x0, y0, x1 - x0, y1 - y0);
        c.fillStyle = tok("--sunk");
        c.beginPath(); c.moveTo(x0, y1);
        lut.forEach((v, i) => c.lineTo(x0 + i / (n - 1) * (x1 - x0), y1 - v / 511 * (y1 - y0 - 4)));
        c.lineTo(x1, y1); c.closePath(); c.fill();
        c.strokeStyle = tok("--accent"); c.lineWidth = 1.5; c.beginPath();
        lut.forEach((v, i) => { const x = x0 + i / (n - 1) * (x1 - x0), y = y1 - v / 511 * (y1 - y0 - 4); i ? c.lineTo(x, y) : c.moveTo(x, y); });
        c.stroke();
        const idx = f.peak ? n : f.lut_in, xi = x0 + Math.min(idx, n - 1) / (n - 1) * (x1 - x0), val = f.value;
        c.strokeStyle = f.peak ? tok("--fail") : tok("--trace"); c.lineWidth = 2;
        c.beginPath(); c.moveTo(xi, y1); c.lineTo(xi, y1 - val / 511 * (y1 - y0 - 4)); c.stroke();
        c.fillStyle = tok("--muted"); c.textAlign = "left"; c.font = "10px " + tok("--f-mono");
        c.fillText("quarter-wave table: 256 words", x0, y0 - 3);
        c.fillStyle = tok("--ink-2"); c.font = "11px " + tok("--f-mono");
        const lines = [
          `low = phase mod 256 = ${f.low}`,
          f.peak ? "index 256 does not fit: peak case → 511" : `index = ${f.q2or4 ? "256 − " + f.low + " = " : ""}${f.lut_in} → ${sim.lut[f.lut_in]}`,
          `sign ${f.q3or4 ? "−" : "+"}  →  sample ${f.q3or4 ? -f.value : f.value}`,
        ];
        lines.forEach((t, i) => c.fillText(t, x0, y1 + 14 + i * 13));
      }
    }
    function draw() { regRows(); drawScope(); drawWheel(); }
    redraws.push(draw);

    // spectrum
    let M = 10, A = 10, specTimer = null;
    function scheduleSpec() { clearTimeout(specTimer); specTimer = setTimeout(drawSpec, 60); }
    function seg(id, cb) { $$(`#${id} button`).forEach(b => b.addEventListener("click", () => { $$(`#${id} button`).forEach(x => x.classList.toggle("on", x === b)); cb(+b.textContent); })); }
    seg("mSel", v => { M = v; scheduleSpec(); });
    seg("aSel", v => { A = v; scheduleSpec(); });
    let specData = null;
    function drawSpec() {
      const d = new DDS(32, M, A), n = 4096, s = new Float64Array(n);
      for (let i = 0; i < n + 4; i++) { d.clock(ftw, 0); if (i >= 4) s[i - 4] = d.ampl; }
      const sp = spectrum(s, 2 ** (A - 1) - 1), r = sfdr(sp);
      specData = { sp, r };
      paintSpec();
      $("#sfdrLbl").textContent = `SFDR ${r.sfdr.toFixed(1)} dB · M=${M}, A=${A}`;
    }
    function paintSpec() {
      if (!specData) return;
      const { sp, r } = specData;
      const { c, w, h } = ctx2d($("#spec"));
      const pad = 34, bot = h - 20, floor = -140;
      const X = i => pad + i / (sp.length - 1) * (w - pad - 6), Y = db => 6 + (Math.max(db, floor) / floor) * (bot - 6);
      c.strokeStyle = tok("--rule"); c.lineWidth = 1; c.fillStyle = tok("--muted"); c.font = "10px " + tok("--f-mono"); c.textAlign = "right";
      for (let db = 0; db >= floor; db -= 20) { c.beginPath(); c.moveTo(pad, Y(db)); c.lineTo(w - 6, Y(db)); c.stroke(); c.fillText(db, pad - 4, Y(db) + 3); }
      c.textAlign = "center";
      [0, 10, 20, 30, 40, 50].forEach(mhz => c.fillText(mhz + " MHz", X(mhz / 50 * (sp.length - 1)), h - 6));
      c.strokeStyle = tok("--accent"); c.lineWidth = 1; c.beginPath();
      for (let i = 0; i < sp.length; i++) { const x = X(i), y = Y(sp[i]); i ? c.lineTo(x, y) : c.moveTo(x, y); }
      c.stroke();
      c.strokeStyle = tok("--fail"); c.setLineDash([4, 3]);
      c.beginPath(); c.moveTo(pad, Y(r.spur)); c.lineTo(w - 6, Y(r.spur)); c.stroke(); c.setLineDash([]);
      c.fillStyle = tok("--fail"); c.textAlign = "left"; c.fillText(`largest spur ${r.spur.toFixed(1)} dBFS`, pad + 6, Y(r.spur) - 4);
    }
    redraws.push(paintSpec);
    setFtw(ftw); phOut.textContent = "0 (0.0°)";
    step(90); drawSpec();
  })();

  /* ------------------------------------------------------------------ 2. synthesis table */
  function eqOf(ref, imp) { return (RES.equivalence || []).find(m => m.reference === ref && m.implementation === imp); }
  function verdict(m) {
    if (!m) return '<span class="chip">n/a</span>';
    const s = m.summary;
    return s.succeeded ? `<span class="chip pass">equivalent ${s.passing}/${s.passing + s.failing}</span>` : `<span class="chip fail">${s.failing} failing</span>`;
  }
  function initSynth() {
    const ys = RES.yosys_stat || "";
    const yc = +(ys.match(/Number of cells:\s+(\d+)/) || [0, 0])[1], ya = +(ys.match(/Chip area[^:]*:\s+([\d.]+)/) || [0, 0])[1];
    const yf = +(ys.match(/FD2\s+(\d+)/) || [0, 0])[1];
    const R = RES.repair;
    const rows = [
      ["RTL (original, 2009)", "-", "74", "-", '<span class="chip acc">reference</span>'],
      ["Design Compiler: golden", R.cells.golden, "72", R.area.golden, verdict(eqOf("rtl_orig", "golden"))],
      ["Hand-out: buggy", R.cells.buggy, "72", R.area.buggy, verdict(eqOf("golden", "buggy"))],
      ["Buggy + 14 fixes (this work)", R.cells.fixed, "72", R.area.fixed, verdict(eqOf("golden", "fixed"))],
      ["Yosys + ABC (this work)", yc || "-", yf || "-", ya || "-", verdict(eqOf("rtl", "yosys"))],
    ];
    $("#synthTable").innerHTML = "<thead><tr><th>netlist</th><th class='n'>cells</th><th class='n'>flip-flops</th><th class='n'>area</th><th>proof</th></tr></thead><tbody>" +
      rows.map(r => `<tr><td>${r[0]}</td><td class="n">${r[1]}</td><td class="n">${r[2]}</td><td class="n">${typeof r[3] === "number" ? r[3].toFixed(0) : r[3]}</td><td>${r[4]}</td></tr>`).join("") + "</tbody>";
  }

  /* ------------------------------------------------------------------ 3.1 miter + BDD */
  (function miter() {
    let a = 1, b = 0, c = 1, bug = false, sweepT = null;
    const svg = $("#miterSvg");
    const fA = (a, b, c) => bug ? ((a | b) | (c & (a ^ b))) : ((a & b) | (c & (a ^ b)));
    const fB = (a, b, c) => 1 - (1 - ((a & b) | (a & c) | (b & c)));
    const insEl = $("#miterIns");
    ["a", "b", "c"].forEach(nm => {
      const bt = document.createElement("button"); bt.type = "button"; bt.className = "btn ghost"; bt.id = "in_" + nm;
      bt.addEventListener("click", () => { if (nm === "a") a ^= 1; if (nm === "b") b ^= 1; if (nm === "c") c ^= 1; draw(); });
      insEl.appendChild(bt);
    });
    $("#miterBreak").addEventListener("click", () => { bug = !bug; $("#miterBreak").textContent = bug ? "Remove the bug" : "Plant a bug"; draw(); drawBdd(); });
    $("#miterSweep").addEventListener("click", () => {
      clearInterval(sweepT); let k = 0;
      const go = () => { a = k >> 2 & 1; b = k >> 1 & 1; c = k & 1; draw(k); k++; if (k > 7) clearInterval(sweepT); };
      if (reduced) { for (k = 0; k < 8;) go(); } else { go(); sweepT = setInterval(go, 380); }
    });
    function wire(x1, y1, x2, y2, v) {
      const col = v ? tok("--trace") : tok("--rule-strong");
      const mx = (x1 + x2) / 2;
      return `<path d="M${x1} ${y1} H${mx} V${y2} H${x2}" fill="none" stroke="${col}" stroke-width="${v ? 2.2 : 1.4}"/>`;
    }
    function gate(x, y, label, v, wdt = 46) {
      return `<rect x="${x}" y="${y - 14}" width="${wdt}" height="28" rx="3" fill="${tok("--surface")}" stroke="${tok("--ink")}" stroke-width="1.2"/>` +
        `<text x="${x + wdt / 2}" y="${y + 4}" text-anchor="middle" font-family="${tok("--f-mono")}" font-size="11" fill="${tok("--ink")}">${label}</text>` +
        `<circle cx="${x + wdt + 6}" cy="${y}" r="3" fill="${v ? tok("--trace") : tok("--rule-strong")}"/>`;
    }
    function draw(sweepRow) {
      const ab = bug ? (a | b) : (a & b), x = a ^ b, cx = c & x, A = fA(a, b, c), B = fB(a, b, c), X = A ^ B, maj = (a & b) | (a & c) | (b & c);
      let s = "";
      const inY = { a: 40, b: 95, c: 150 };
      const t = (x, y, str, anchor = "start", col = tok("--muted"), size = 11) => `<text x="${x}" y="${y}" text-anchor="${anchor}" font-family="${tok("--f-mono")}" font-size="${size}" fill="${col}">${str}</text>`;
      // circuit A
      s += t(80, 14, "circuit A: sum of products", "start");
      s += wire(40, inY.a, 90, 38, a) + wire(40, inY.b, 90, 50, b);
      s += wire(40, inY.a, 90, 88, a) + wire(40, inY.b, 90, 100, b);
      s += gate(90, 44, bug ? "OR" : "AND", ab) + gate(90, 94, "XOR", x);
      if (bug) s += `<rect x="86" y="26" width="54" height="36" rx="4" fill="none" stroke="${tok("--fail")}" stroke-dasharray="4 3"/>`;
      s += wire(142, 94, 168, 100, x) + wire(40, inY.c, 168, 112, c);
      s += gate(168, 106, "AND", cx);
      s += wire(142, 44, 236, 66, ab) + wire(220, 106, 236, 80, cx);
      s += gate(236, 73, "OR", A);
      // circuit B
      s += t(80, 188, "circuit B: AO5 cell + inverter (as in the buggy netlist)", "start");
      s += wire(40, inY.a, 110, 200, a) + wire(40, inY.b, 110, 212, b) + wire(40, inY.c, 110, 224, c);
      s += gate(110, 212, "AO5", 1 - maj, 50) + wire(166, 212, 190, 212, 1 - maj) + gate(190, 212, "IV", B, 36);
      // miter
      s += wire(292, 73, 330, 130, A) + wire(232, 212, 330, 146, B);
      s += gate(330, 138, "XOR", X);
      s += `<rect x="326" y="120" width="54" height="36" rx="4" fill="none" stroke="${X ? tok("--fail") : tok("--pass")}" stroke-width="2"/>`;
      s += t(356, 175, X ? "outputs differ" : "outputs agree", "middle", X ? tok("--fail") : tok("--pass"), 11);
      // inputs
      ["a", "b", "c"].forEach(nm => {
        const v = nm === "a" ? a : nm === "b" ? b : c;
        s += `<circle cx="28" cy="${inY[nm]}" r="11" fill="${v ? tok("--trace") : tok("--surface")}" stroke="${tok("--ink")}"/>` + t(28, inY[nm] + 4, nm, "middle", v ? tok("--surface") : tok("--ink"), 12);
      });
      // truth table
      s += t(420, 14, "a b c  A B  A⊕B", "start", tok("--muted"), 10);
      for (let k = 0; k < 8; k++) {
        const aa = k >> 2 & 1, bb = k >> 1 & 1, cc = k & 1, ra = fA(aa, bb, cc), rb = fB(aa, bb, cc);
        const y = 30 + k * 16, cur = aa === a && bb === b && cc === c;
        if (cur) s += `<rect x="414" y="${y - 11}" width="100" height="15" fill="${tok("--accent-soft")}"/>`;
        s += t(420, y, `${aa} ${bb} ${cc}  ${ra} ${rb}  ${ra ^ rb}`, "start", ra ^ rb ? tok("--fail") : tok("--ink-2"), 10);
      }
      svg.innerHTML = s;
      ["a", "b", "c"].forEach(nm => { $("#in_" + nm).textContent = `${nm} = ${nm === "a" ? a : nm === "b" ? b : c}`; });
      let diff = 0; for (let k = 0; k < 8; k++) diff += fA(k >> 2 & 1, k >> 1 & 1, k & 1) ^ fB(k >> 2 & 1, k >> 1 & 1, k & 1);
      $("#miterOut").textContent = diff ? `${diff} of 8 inputs differ` : "equivalent on all 8 inputs";
    }
    function drawBdd() {
      const m = new BDD(3), va = m.ithvar(0), vb = m.ithvar(1), vc = m.ithvar(2);
      const A = m.or(bug ? m.or(va, vb) : m.and(va, vb), m.and(vc, m.xor(va, vb)));
      const B = m.not(m.not(m.or(m.or(m.and(va, vb), m.and(va, vc)), m.and(vb, vc))));
      const svgB = $("#bddSvg");
      let s = "";
      [[A, "circuit A", 20], [B, "circuit B", 340]].forEach(([root, title, ox]) => {
        const g = m.graph(root), levels = { 0: [], 1: [], 2: [], 3: [] };
        g.forEach(n => (n.v === null ? levels[3] : levels[n.v]).push(n));
        const pos = {};
        Object.entries(levels).forEach(([lv, ns]) => ns.sort((x, y) => x.id - y.id).forEach((n, i) => { pos[n.id] = { x: ox + 140 + (i - (ns.length - 1) / 2) * 90, y: 40 + lv * 55 }; }));
        g.forEach(n => {
          if (n.v === null) return;
          [["lo", true], ["hi", false]].forEach(([k, dash]) => {
            const p = pos[n.id], q = pos[n[k]];
            s += `<line x1="${p.x}" y1="${p.y}" x2="${q.x}" y2="${q.y - 12}" stroke="${tok("--ink-2")}" stroke-width="1.3" ${dash ? 'stroke-dasharray="4 3"' : ""}/>`;
          });
        });
        g.forEach(n => {
          const p = pos[n.id];
          if (n.v === null) s += `<rect x="${p.x - 12}" y="${p.y - 12}" width="24" height="24" fill="${n.id ? tok("--pass-soft") : tok("--sunk")}" stroke="${tok("--ink")}"/><text x="${p.x}" y="${p.y + 4}" text-anchor="middle" font-family="${tok("--f-mono")}" font-size="12" fill="${tok("--ink")}">${n.id}</text>`;
          else s += `<circle cx="${p.x}" cy="${p.y}" r="13" fill="${tok("--surface")}" stroke="${tok("--accent")}" stroke-width="1.6"/><text x="${p.x}" y="${p.y + 4}" text-anchor="middle" font-family="${tok("--f-mono")}" font-size="12" fill="${tok("--ink")}">${"abc"[n.v]}</text>`;
        });
        s += `<text x="${ox + 140}" y="16" text-anchor="middle" font-family="${tok("--f-mono")}" font-size="11" fill="${tok("--muted")}">${title}: root #${root}, ${m.count(root)} decision nodes</text>`;
      });
      svgB.innerHTML = s;
      $("#bddVerdict").innerHTML = A === B ? `<span class="chip pass">same node #${A}: equivalent</span>` : `<span class="chip fail">#${A} ≠ #${B}: not equivalent</span>`;
    }
    redraws.push(() => { draw(); drawBdd(); });
    draw(); drawBdd();
  })();

  /* ------------------------------------------------------------------ 3.3 workbench */
  const fixSet = new Set();
  let wb = { impl: "buggy", res: null, sel: null, cells: null };
  function wbRun() {
    const impl = implDesign(wb.impl === "fixed" ? "buggy" : wb.impl, wb.impl === "fixed" ? new Set(NET.fixes.map((_, i) => i)) : fixSet);
    const r = Checker.compare(designs.golden, impl);
    wb.res = r;
    paintGrid(wb.cells, r);
    const s = r.summary;
    $("#wbStat").textContent = `${s.pass} passing · ${s.fail} failing · ${r.ms.toFixed(0)} ms · ${r.bddNodes.toLocaleString()} BDD nodes`;
    $("#wbLed").classList.toggle("bad", s.fail > 0);
    const pp = r.points.filter(p => p.type === "Port"), dp = r.points.filter(p => p.type === "DFF");
    const cnt = (arr, ok) => arr.filter(p => p.pass === ok).length;
    $("#wbTable").innerHTML = `<thead><tr><th>matched compare points</th><th class="n">Port</th><th class="n">DFF</th><th class="n">total</th></tr></thead><tbody>
      <tr><td>passing (equivalent)</td><td class="n">${cnt(pp, true)}</td><td class="n">${cnt(dp, true)}</td><td class="n">${s.pass}</td></tr>
      <tr><td>failing (not equivalent)</td><td class="n">${cnt(pp, false)}</td><td class="n">${cnt(dp, false)}</td><td class="n">${s.fail}</td></tr></tbody>`;
    $("#fixCount").textContent = wb.impl === "manual" ? "n/a (different netlist)" : `${wb.impl === "fixed" ? 14 : fixSet.size} of 14`;
    if (wb.sel) showDetail(wb.sel);
    $$(".bug").forEach(el => { const i = +el.dataset.i; el.classList.toggle("applied", wb.impl === "fixed" || (wb.impl === "buggy" && fixSet.has(i))); const cb = $("input", el); cb.checked = wb.impl === "fixed" || fixSet.has(i); cb.disabled = wb.impl === "manual"; });
  }
  function showDetail(name) {
    wb.sel = name;
    wb.cells.forEach((b, n) => b.classList.toggle("sel", n === name));
    const p = wb.res.points.find(x => x.name === name);
    if (!p) return;
    let h = `<b>${esc(p.name)}</b> · ${p.type === "Port" ? "output bit" : "flip-flop D input"}<br>`;
    h += `fan-in cone: ${p.refCone} cells (reference), ${p.cone} cells (implementation)<br>`;
    h += `BDD size: ${p.refSize} / ${p.implSize} nodes<br>`;
    if (p.pass) h += `<span class="chip pass">equivalent</span> both cones reduce to the same BDD node.`;
    else {
      h += `<span class="chip fail">not equivalent</span> reference = ${p.refVal}, implementation = ${p.implVal} when:<br>`;
      Object.entries(p.cex).sort((x, y) => nat(x[0], y[0])).forEach(([w, o]) => {
        const width = w === "ftw_i" || w === "ftw_accu" ? 32 : 10;
        const shown = width === 32 ? "0x" + hex(o.value, 8) : o.value.toString() + " (0x" + hex(o.value, 3) + ")";
        h += `&nbsp;&nbsp;${esc(w).padEnd(20, " ")} = ${shown}<br>`;
      });
      h += `<span class="muted">(${p.support.length} signals influence the difference; unlisted bits are 0)</span>`;
    }
    $("#wbDetail").innerHTML = h;
  }
  function initWorkbench() {
    wb.cells = makeGrid($("#wbGrid"), n => showDetail(n));
    $("#wbLegend").innerHTML = '<span><i style="background:var(--pass)"></i>equivalent</span><span><i style="background:var(--fail)"></i>not equivalent</span><span>round = output bit, square = flip-flop; order: ampl_o, phase_o, ftw_accu[0..31], phase, lut_out, lut_out_delay, lut_out_inv_delay, quadrant delays</span>';
    $$("#implSel button").forEach(b => b.addEventListener("click", () => {
      $$("#implSel button").forEach(x => x.classList.toggle("on", x === b));
      wb.impl = b.dataset.impl; wbRun();
    }));
    $("#allFixes").addEventListener("click", () => { NET.fixes.forEach((_, i) => fixSet.add(i)); selectImpl("buggy"); });
    $("#noFixes").addEventListener("click", () => { fixSet.clear(); selectImpl("buggy"); });
    wbRun();
    showDetail("ftw_accu[3]");
  }
  function selectImpl(k) { wb.impl = k; $$("#implSel button").forEach(x => x.classList.toggle("on", x.dataset.impl === k)); wbRun(); }

  /* ------------------------------------------------------------------ 4.1 manual attempts */
  function initManual() {
    const co = RES.cells_of || {};
    const rows = [["buggy hand-out", eqOf("golden", "buggy"), co.buggy]];
    for (let i = 1; i <= 5; i++) rows.push([co[`manual_0${i}_file`] || `attempt ${i}`, eqOf("golden", `manual_0${i}`), co[`manual_0${i}`]]);
    rows.push(["automatic repair (2026)", eqOf("golden", "fixed"), co.buggy]);
    $("#manualTable").innerHTML = "<thead><tr><th>netlist</th><th class='n'>failing</th><th class='n'>cells</th></tr></thead><tbody>" +
      rows.map(r => `<tr${r[0].startsWith("automatic") ? ' class="hl"' : ""}><td class="mono" style="font-size:.78rem">${esc(r[0].replace(".vhd", ""))}</td><td class="n">${r[1] ? r[1].summary.failing : "-"}</td><td class="n">${r[2] || "-"}</td></tr>`).join("") + "</tbody>";
  }

  /* ------------------------------------------------------------------ 4.2 replay chart */
  function initReplay() {
    const log = RES.repair.log || [];
    const pts = [];
    let pending = [];
    log.forEach(l => {
      const m = l.match(/(\d+) failing compare points \((\d+) failing point\/vector pairs\)/);
      if (m) { pts.push({ pairs: +m[2], points: +m[1], fixes: pending }); pending = []; }
      const f = l.match(/^\s+\[(.+?)\] (.*)$/);
      if (f) pending.push({ how: f[1], text: f[2] });
    });
    pts.push({ pairs: 0, points: 0, fixes: pending });
    const steps = pts.map((p, i) => ({ ...p, fixes: i + 1 < pts.length ? pts[i + 1].fixes : [] }));
    $("#replayLbl").textContent = `${steps.length - 1} steps · ${RES.repair.seconds} s including proofs`;
    function draw() {
      const { c, w, h } = ctx2d($("#replay"));
      const pad = 46, bot = h - 26, top = 26, max = steps[0].pairs;
      const X = i => pad + i / (steps.length - 1) * (w - pad - 12), Y = v => bot - v / max * (bot - top);
      c.font = "10px " + tok("--f-mono"); c.fillStyle = tok("--muted"); c.strokeStyle = tok("--rule"); c.textAlign = "right";
      for (let k = 0; k <= 4; k++) { const v = max * k / 4; c.beginPath(); c.moveTo(pad, Y(v)); c.lineTo(w - 12, Y(v)); c.stroke(); c.fillText(Math.round(v), pad - 5, Y(v) + 3); }
      c.textAlign = "center";
      steps.forEach((s, i) => c.fillText(i, X(i), h - 10));
      c.fillStyle = tok("--accent-soft"); c.beginPath(); c.moveTo(X(0), bot);
      steps.forEach((s, i) => c.lineTo(X(i), Y(s.pairs))); c.lineTo(X(steps.length - 1), bot); c.closePath(); c.fill();
      c.strokeStyle = tok("--accent"); c.lineWidth = 2; c.beginPath();
      steps.forEach((s, i) => (i ? c.lineTo(X(i), Y(s.pairs)) : c.moveTo(X(i), Y(s.pairs)))); c.stroke();
      steps.forEach((s, i) => {
        const bt = s.fixes.some(f => /back-track|two-gate/.test(f.how));
        c.fillStyle = bt ? tok("--trace") : tok("--accent"); c.beginPath(); c.arc(X(i), Y(s.pairs), bt ? 5 : 3.5, 0, 7); c.fill();
      });
      c.textAlign = "left"; c.fillStyle = tok("--muted");
      c.textAlign = "right";
      c.fillText("failing (point, vector) pairs per step · amber = two-gate step with back-tracking", w - 14, top + 14);
    }
    redraws.push(draw); draw();
  }

  /* ------------------------------------------------------------------ 4.3 bug cards with schematics */
  function schematic(fx) {
    const d = designs.buggy;
    const isFlop = fx.old_type === "FD2";
    const loads = new Map();
    d.cells.forEach(c => c.ins.forEach(n => { if (!loads.has(n)) loads.set(n, []); loads.get(n).push(c.name); }));
    const qName = new Map();
    d.flops.forEach(f => { if (f.q > 0) qName.set(f.q, f.canon); if (f.qn > 0) qName.set(f.qn, f.canon + "'"); });
    const drvLabel = n => {
      const idx = d.net(n);
      if (qName.has(idx)) return { t: "FD2", s: qName.get(idx) };
      const c = d.driver.get(idx);
      if (c) return { t: c.type, s: c.name.split("/").pop() };
      if (n in d.inputs || idx in d.inputs) return { t: "in", s: n };
      return { t: "", s: n };
    };
    const pins = isFlop ? ["D"] : Object.keys(fx.new_ins);
    const W = 330, rowH = 30, H = Math.max(pins.length, 1) * rowH + 44;
    const f = tok("--f-mono"), ink = tok("--ink"), mut = tok("--muted"), bad = tok("--fail"), good = tok("--pass");
    let s = `<svg viewBox="0 0 ${W} ${H}" role="img" aria-label="Schematic of ${esc(fx.cell)}">`;
    const cx = 160, cy = 22 + (pins.length * rowH) / 2;
    pins.forEach((p, i) => {
      const y = 30 + i * rowH;
      const oldN = fx.old_ins[p], newN = fx.new_ins[p];
      const changed = oldN !== newN;
      const src = drvLabel(newN), osrc = drvLabel(oldN);
      if (changed) {
        s += `<text x="4" y="${y - 3}" font-family="${f}" font-size="9" fill="${bad}" text-decoration="line-through">${esc(osrc.t)} ${esc(osrc.s)}</text>`;
        s += `<text x="4" y="${y + 9}" font-family="${f}" font-size="9" fill="${good}">${esc(src.t)} ${esc(src.s)}${d.driver.get(d.net(newN)) && !loads.has(d.net(newN)) ? " (dangling)" : ""}</text>`;
      } else s += `<text x="4" y="${y + 3}" font-family="${f}" font-size="9" fill="${mut}">${esc(src.t)} ${esc(src.s)}</text>`;
      s += `<path d="M112 ${y} H${cx - 36}" stroke="${changed ? good : mut}" stroke-width="1.3" fill="none"/>`;
      s += `<text x="${cx - 40}" y="${y - 3}" font-family="${f}" font-size="8" fill="${mut}" text-anchor="end">${p}</text>`;
    });
    const bh = pins.length * rowH;
    s += `<rect x="${cx - 36}" y="${cy - bh / 2 + 4}" width="72" height="${bh - 8 + 10}" rx="3" fill="${tok("--surface")}" stroke="${ink}" stroke-width="1.3"/>`;
    if (fx.old_type !== fx.new_type) {
      s += `<text x="${cx}" y="${cy}" text-anchor="middle" font-family="${f}" font-size="10" fill="${bad}" text-decoration="line-through">${fx.old_type}</text>`;
      s += `<text x="${cx}" y="${cy + 14}" text-anchor="middle" font-family="${f}" font-size="12" font-weight="600" fill="${good}">${fx.new_type}</text>`;
    } else s += `<text x="${cx}" y="${cy + 5}" text-anchor="middle" font-family="${f}" font-size="12" fill="${ink}">${fx.old_type}</text>`;
    s += `<path d="M${cx + 36} ${cy + 5} H${W - 110}" stroke="${mut}" stroke-width="1.3"/>`;
    const tgt = isFlop ? fx.cell.replace(/_reg_(\d+)_inst$/, "[$1]") : (fx.points || []).slice(0, 2).join(", ") + ((fx.points || []).length > 2 ? " …" : "");
    s += `<text x="${W - 106}" y="${cy + 8}" font-family="${f}" font-size="9" fill="${mut}">${esc(isFlop ? "Q → " + tgt : "→ " + tgt)}</text>`;
    s += `</svg>`;
    return s;
  }
  function initBugs() {
    const svf = RES.sim_vs_formal || [];
    const el = $("#bugList");
    el.innerHTML = NET.fixes.map((fx, i) => {
      const sv = svf[i];
      const kind = fx.kind.replace("-", " ");
      const pts = sv ? sv.formal.failing_points : fx.points;
      return `<article class="bug" data-i="${i}">
        <div class="bug-top"><h4>#${i + 1} ${esc(fx.cell)}</h4><span class="chip ${fx.kind === "wrong-connection" ? "warn" : "acc"}">${esc(kind)}</span></div>
        <div class="sch">${schematic(fx)}</div>
        <p class="desc">${esc(fx.description)}</p>
        <p class="pts">alone it fails ${pts.length} point${pts.length === 1 ? "" : "s"}: ${esc(pts.slice(0, 6).join(", "))}${pts.length > 6 ? " …" : ""}${sv ? ` · random simulation catches it in ${(sv.sim.detected * 100).toFixed(0)}% of tests` : ""}</p>
        <label class="toggle"><input type="checkbox" id="fix${i}"> apply in Figure 6</label>
      </article>`;
    }).join("");
    $$(".bug input").forEach(cb => cb.addEventListener("change", () => {
      const i = +cb.id.slice(3);
      if (wb.impl === "fixed") { NET.fixes.forEach((_, k) => fixSet.add(k)); }
      cb.checked ? fixSet.add(i) : fixSet.delete(i);
      selectImpl("buggy");
    }));
    wbRun();
  }

  /* ------------------------------------------------------------------ 4.4 simulation vs formal */
  function initSvf() {
    const data = RES.sim_vs_formal || [];
    function draw() {
      const { c, w, h } = ctx2d($("#svf"));
      if (!data.length) return;
      const lab = 150, top = 8, rowH = (h - top - 26) / data.length, X = v => lab + v * (w - lab - 50);
      c.font = "10px " + tok("--f-mono");
      c.strokeStyle = tok("--rule");
      [0, 0.25, 0.5, 0.75, 1].forEach(v => { c.beginPath(); c.moveTo(X(v), top); c.lineTo(X(v), h - 22); c.stroke(); c.fillStyle = tok("--muted"); c.textAlign = "center"; c.fillText(v * 100 + "%", X(v), h - 8); });
      data.forEach((d, i) => {
        const y = top + i * rowH, v = d.sim.detected;
        c.fillStyle = tok("--ink-2"); c.textAlign = "right";
        c.fillText(`#${d.bug} ${d.cell.replace("lut_out_inv_delay_reg_", "inv_delay_").replace("_inst", "")}`, lab - 8, y + rowH / 2 + 3);
        c.fillStyle = v < 0.5 ? tok("--fail") : tok("--accent");
        c.fillRect(X(0), y + rowH * 0.2, Math.max(2, X(v) - X(0)), rowH * 0.6);
        c.fillStyle = tok("--ink"); c.textAlign = "left";
        c.fillText((v * 100).toFixed(v < 0.1 ? 1 : 0) + "%", X(v) + 6, y + rowH / 2 + 3);
      });
    }
    redraws.push(draw); draw();
  }

  /* ------------------------------------------------------------------ 5.1 k-induction toy */
  (function kind() {
    const next = s => (s === 5 ? 0 : (s + 1) & 7);
    const P = s => s !== 7;
    const reach = new Set([0, 1, 2, 3, 4, 5]);
    let k = 1, hl = { path: [], kind: null };
    $$("#kSel button").forEach(b => b.addEventListener("click", () => { $$("#kSel button").forEach(x => x.classList.toggle("on", x === b)); k = +b.textContent; hl = { path: [], kind: null }; draw(); $("#kiVerdict").textContent = ""; }));
    $("#kiBase").addEventListener("click", () => {
      const path = [0]; for (let i = 1; i < k; i++) path.push(next(path[i - 1]));
      const ok = path.every(P);
      hl = { path, kind: "base" }; draw();
      $("#kiVerdict").innerHTML = ok ? `<span class="chip pass">base holds: P true for cycles 0..${k - 1}</span>` : `<span class="chip fail">real bug</span>`;
    });
    $("#kiStep").addEventListener("click", () => {
      let found = null;
      for (let s = 0; s < 8 && !found; s++) {
        const path = [s]; for (let i = 0; i < k; i++) path.push(next(path[i]));
        if (path.slice(0, k).every(P) && !P(path[k])) found = path;
      }
      hl = { path: found || [], kind: found ? "cti" : "proof" }; draw();
      $("#kiVerdict").innerHTML = found
        ? `<span class="chip fail">step fails: ${found.join(" → ")}</span> <span class="small muted">starts in unreachable state ${found[0]}</span>`
        : `<span class="chip pass">step holds: proven for every reachable state</span>`;
    });
    function draw() {
      const svg = $("#kiSvg"), f = tok("--f-mono");
      const pos = s => { const a = -Math.PI / 2 + s * 2 * Math.PI / 8; return { x: 230 + 150 * Math.cos(a) * 1.15, y: 125 + 95 * Math.sin(a) }; };
      let str = `<defs><marker id="ar" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="${tok("--ink-2")}"/></marker>
        <marker id="arh" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="${hl.kind === "cti" ? tok("--fail") : tok("--accent")}"/></marker></defs>`;
      const onPath = (a, b) => { for (let i = 0; i + 1 < hl.path.length; i++) if (hl.path[i] === a && hl.path[i + 1] === b) return true; return false; };
      for (let s = 0; s < 8; s++) {
        const t = next(s), p = pos(s), q = pos(t);
        const dx = q.x - p.x, dy = q.y - p.y, L = Math.hypot(dx, dy), ux = dx / L, uy = dy / L;
        const hot = onPath(s, t);
        str += `<line x1="${p.x + ux * 19}" y1="${p.y + uy * 19}" x2="${q.x - ux * 21}" y2="${q.y - uy * 21}" stroke="${hot ? (hl.kind === "cti" ? tok("--fail") : tok("--accent")) : tok("--ink-2")}" stroke-width="${hot ? 3 : 1.3}" marker-end="url(#${hot ? "arh" : "ar"})"/>`;
      }
      for (let s = 0; s < 8; s++) {
        const p = pos(s), inPath = hl.path.includes(s);
        str += `<circle cx="${p.x}" cy="${p.y}" r="18" fill="${reach.has(s) ? tok("--pass-soft") : tok("--sunk")}" stroke="${!P(s) ? tok("--fail") : inPath ? tok("--accent") : tok("--rule-strong")}" stroke-width="${!P(s) || inPath ? 3 : 1.3}"/>`;
        str += `<text x="${p.x}" y="${p.y + 5}" text-anchor="middle" font-family="${f}" font-size="14" fill="${tok("--ink")}">${s}</text>`;
      }
      str += `<text x="8" y="244" font-family="${f}" font-size="10" fill="${tok("--muted")}">reset = 0 · next = (c == 5) ? 0 : c + 1 · P: c ≠ 7 · k = ${k}</text>`;
      svg.innerHTML = str;
    }
    redraws.push(draw); draw();
  })();

  /* ------------------------------------------------------------------ 5.x tables */
  const PROP_TEXT = {
    p_sine: "ampl_o equals round(511·sin(2π·phase/1024)) for the phase two cycles earlier",
    p_range: "ampl_o never takes the value −512 (the output range is symmetric)",
    p_step: "with constant inputs, phase_o advances by ftw>>22 or ftw>>22 + 1 each clock",
    p_offset: "a change of phase_i moves phase_o by the same amount one clock later",
  };
  function initProps() {
    const P = RES.properties || [];
    $("#propTable").innerHTML = "<thead><tr><th>property</th><th>meaning</th><th>k = 1</th><th>k = 2</th></tr></thead><tbody>" +
      P.map(p => {
        const t1 = p.tries.find(t => t.k === 1), t2 = p.tries.find(t => t.k === 2);
        const chip = t => !t ? "-" : t.status === "PROVEN" ? `<span class="chip pass">proven</span> <span class="small muted">${t.seconds}s</span>` : `<span class="chip warn">undecided</span>`;
        return `<tr><td class="mono">${p.property}</td><td>${esc(PROP_TEXT[p.property] || "")}</td><td>${chip(t1)}</td><td>${chip(t2)}</td></tr>`;
      }).join("") + "</tbody>";
  }
  function initMutants() {
    const M = RES.mutants || [];
    $("#mutTable").innerHTML = "<thead><tr><th>planted mistake</th><th>caught by</th><th class='n'>trace length</th></tr></thead><tbody>" +
      M.map(m => {
        const by = m.killed_by, depth = Math.min(...by.map(p => m.results[p].depth));
        return `<tr><td>${esc(m.description)}<br><span class="mono small muted">${esc(m.change.to)}</span></td><td>${by.map(p => `<span class="chip fail">${p}</span>`).join(" ")}</td><td class="n">${depth} cycles</td></tr>`;
      }).join("") + "</tbody>";
  }
  function initTheorems() {
    const T = RES.theorems || [];
    $("#thmTable").innerHTML = "<thead><tr><th>id</th><th>statement</th><th>result</th></tr></thead><tbody>" +
      T.map(t => {
        const st = t.status === "PROVEN" ? '<span class="chip pass">proven</span>' : t.status === "FALSE" ? '<span class="chip fail">false</span>' : `<span class="chip">${t.status}</span>`;
        const ce = t.counterexample ? `<br><span class="mono small">counter-example: ${esc(Object.entries(t.counterexample).map(([k, v]) => k + " = " + v).join(", "))}</span>` : "";
        return `<tr><td class="mono">${t.id}</td><td>${esc(t.statement)}<br><span class="small muted">${esc(t.note)}</span>${ce}</td><td>${st}</td></tr>`;
      }).join("") + "</tbody>";
  }
  function initLean() {
    const S = RES.seq_equiv || { flops: {}, runs: [] };
    const run = k => S.runs.find(r => r.k === k) || {};
    $("#leanTable").innerHTML = `<thead><tr><th></th><th class="n">original</th><th class="n">lean</th></tr></thead><tbody>
      <tr><td>flip-flops</td><td class="n">${S.flops.rtl_orig}</td><td class="n">${S.flops.lean}</td></tr>
      <tr><td>matched by name</td><td class="n" colspan="2">${run(2).matched_registers}</td></tr>
      <tr><td>without a partner</td><td class="n">${(run(2).ref_only || []).length}</td><td class="n">${(run(2).impl_only || []).length}</td></tr>
      <tr><td>amplitude output</td><td class="n">mux after registers</td><td class="n">registered</td></tr>
      <tr><td>k-induction, k = 1</td><td class="n" colspan="2"><span class="chip warn">${esc(run(1).status || "")}</span></td></tr>
      <tr><td>k-induction, k = 2</td><td class="n" colspan="2"><span class="chip pass">${esc(run(2).status || "")}</span></td></tr></tbody>`;
  }
})();
