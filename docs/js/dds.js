/* dds.js - cycle-accurate model of the DDS (port of tools/dds_model.py) + an FFT.
 * The register names and update order match rtl/dds_synthesizer.vhd exactly; the
 * repository's testbench checks the Python model against the HDL sample by sample.
 */
(function (global) {
  "use strict";

  class DDS {
    constructor(N = 32, M = 10, A = 10) {
      this.N = N; this.M = M; this.A = A; this.QW = M - 2;
      const amp = 2 ** (A - 1) - 1;
      this.lut = Array.from({ length: 2 ** this.QW }, (_, i) => Math.round(amp * Math.sin(2 * Math.PI * i / 2 ** M)));
      // Python rounds half to even; the table never hits an exact .5 at these sizes
      this.reset();
    }
    reset() {
      this.ftw_accu = 0n; this.phase = 0; this.lut_out = 0; this.lut_out_delay = 0; this.lut_out_inv_delay = 0;
      this.q34_d = 0; this.q34_2d = 0; this.cycle = 0;
      this.last = { lut_in: 0, peak: false, q2or4: 0, q3or4: 0 };
    }
    get ampl() { return this.q34_2d ? this.lut_out_inv_delay : this.lut_out_delay; }
    fold(phase) {
      const M = this.M, QW = this.QW;
      const q2or4 = (phase >> (M - 2)) & 1, q3or4 = (phase >> (M - 1)) & 1;
      const low = phase & (2 ** QW - 1);
      const lut_in = q2or4 ? (2 ** QW - low) & (2 ** QW - 1) : low;
      const peak = q2or4 === 1 && low === 0;
      return { q2or4, q3or4, low, lut_in, peak, value: peak ? 2 ** (this.A - 1) - 1 : this.lut[lut_in] };
    }
    clock(ftw, phase_i) {
      const N = BigInt(this.N), M = this.M;
      const f = this.fold(this.phase);
      this.last = f;
      const accuTop = Number(this.ftw_accu >> (N - BigInt(M)));
      const next = {
        ftw_accu: (this.ftw_accu + BigInt(ftw)) % (1n << N),
        phase: (accuTop + phase_i) % 2 ** M,
        lut_out: f.value,
        lut_out_delay: this.lut_out,
        lut_out_inv_delay: -this.lut_out,
        q34_d: f.q3or4,
        q34_2d: this.q34_d,
      };
      Object.assign(this, next);
      this.cycle++;
    }
  }

  /* in-place radix-2 FFT, returns magnitude spectrum in dB relative to full scale */
  function spectrum(samples, fullScale) {
    const n = samples.length;
    const re = new Float64Array(n), im = new Float64Array(n);
    let wsum = 0;
    for (let i = 0; i < n; i++) {
      const w = 0.35875 - 0.48829 * Math.cos(2 * Math.PI * i / n) + 0.14128 * Math.cos(4 * Math.PI * i / n) - 0.01168 * Math.cos(6 * Math.PI * i / n);
      re[i] = samples[i] * w; wsum += w;
    }
    for (let i = 1, j = 0; i < n; i++) {
      let bit = n >> 1;
      for (; j & bit; bit >>= 1) j ^= bit;
      j ^= bit;
      if (i < j) { let t = re[i]; re[i] = re[j]; re[j] = t; t = im[i]; im[i] = im[j]; im[j] = t; }
    }
    for (let len = 2; len <= n; len <<= 1) {
      const ang = -2 * Math.PI / len, wr = Math.cos(ang), wi = Math.sin(ang);
      for (let i = 0; i < n; i += len) {
        let cr = 1, ci = 0;
        for (let k = 0; k < len / 2; k++) {
          const ur = re[i + k], ui = im[i + k];
          const vr = re[i + k + len / 2] * cr - im[i + k + len / 2] * ci;
          const vi = re[i + k + len / 2] * ci + im[i + k + len / 2] * cr;
          re[i + k] = ur + vr; im[i + k] = ui + vi;
          re[i + k + len / 2] = ur - vr; im[i + k + len / 2] = ui - vi;
          const t = cr * wr - ci * wi; ci = cr * wi + ci * wr; cr = t;
        }
      }
    }
    const out = new Float64Array(n / 2);
    const ref = fullScale * wsum / 2;
    for (let i = 0; i < n / 2; i++) out[i] = 20 * Math.log10(Math.max(Math.hypot(re[i], im[i]) / ref, 1e-9));
    return out;
  }

  /* spurious-free dynamic range: carrier minus the largest other peak (dB) */
  function sfdr(spec, guard = 6) {
    let k0 = 1; for (let i = 1; i < spec.length; i++) if (spec[i] > spec[k0]) k0 = i;
    let spur = -300, ks = 0;
    for (let i = 1; i < spec.length; i++) {
      if (Math.abs(i - k0) <= guard) continue;
      if (spec[i] > spur) { spur = spec[i]; ks = i; }
    }
    return { carrierBin: k0, carrier: spec[k0], spurBin: ks, spur, sfdr: spec[k0] - spur };
  }

  global.DDS = DDS;
  global.spectrum = spectrum;
  global.sfdr = sfdr;
})(window);
