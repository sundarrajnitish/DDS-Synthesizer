-------------------------------------------------------------------------------
-- dds_synthesizer.vhd
--
-- Direct Digital Synthesizer (DDS) / numerically controlled oscillator (NCO).
--
-- Refactored, cycle-exact version of Martin Kumm's dds_synthesizer (2009), the
-- design used in the COEN 6551 formal-verification project. It has *exactly*
-- the same registers and the same behaviour on every clock cycle as
-- rtl/original/dds_synthesizer.vhd - this is proven, not assumed:
--     make -C formal rtl-equiv     (combinational equivalence, 94/94 points)
--
-- What changed with respect to the original
--   * ieee.numeric_std only. The original mixed std_logic_arith and
--     std_logic_unsigned, which is non-standard and made the comparison in the
--     LUT branch ambiguous (GHDL rejects it without -fexplicit).
--   * rising_edge(), named constants, and comments on every pipeline stage.
--   * The quarter-wave mirroring is written out explicitly, including why the
--     phase = 256 / 768 corner case needs its own branch (see below).
--   * Elaboration-time checks of the generics.
--
-- Output frequency and phase (N = ftw_width, M = PHASE_WIDTH):
--     f_out   = ftw_i   / 2**N * f_clk
--     phi_out = phase_i / 2**M * 2*pi
-- (The original PDF writes 2**M in the frequency formula and 2**N in the phase
--  formula - the two exponents are swapped there.)
--
-- Pipeline (latency phase_i -> ampl_o: 3 clocks, ftw_i -> ampl_o: 4 clocks)
--   stage 0  ftw_accu   <= ftw_accu + ftw_i                 phase accumulator
--   stage 1  phase      <= ftw_accu(MSBs) + phase_i         phase offset, truncation
--   stage 2  lut_out    <= |sin|(phase) from quarter table  quadrant folding
--   stage 3  lut_out_delay / lut_out_inv_delay              +sin and -sin registered
--   output   ampl_o = sign(quadrant) ? -sin : +sin          output select
-- Note: phase_o is the stage-1 register, i.e. it leads ampl_o by two cycles.
--
-- Copyright (C) 2009 Martin Kumm (original design), GPL-3.0-or-later.
-- Refactoring and verification (C) 2024-2026 Nitish Sundarraj.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sine_lut_pkg.all;
use work.sine_lut_data.all;

entity dds_synthesizer is
  generic (
    ftw_width : positive := 32
  );
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;                                   -- asynchronous, active high
    ftw_i   : in  std_logic_vector(ftw_width-1 downto 0);      -- frequency tuning word
    phase_i : in  std_logic_vector(PHASE_WIDTH-1 downto 0);    -- phase offset word
    phase_o : out std_logic_vector(PHASE_WIDTH-1 downto 0);    -- instantaneous phase
    ampl_o  : out std_logic_vector(AMPL_WIDTH-1 downto 0)      -- signed amplitude
  );
end entity dds_synthesizer;

architecture dds_synthesizer_arch of dds_synthesizer is

  constant QW : natural := PHASE_WIDTH - 2;                    -- quarter-wave index width

  signal ftw_accu               : unsigned(ftw_width-1 downto 0);
  signal phase                  : unsigned(PHASE_WIDTH-1 downto 0);
  signal lut_in                 : unsigned(QW-1 downto 0);
  signal lut_out                : signed(AMPL_WIDTH-1 downto 0);
  signal lut_out_delay          : signed(AMPL_WIDTH-1 downto 0);
  signal lut_out_inv_delay      : signed(AMPL_WIDTH-1 downto 0);
  signal quadrant_2_or_4        : std_logic;                   -- phase MSB-1: mirror the index
  signal quadrant_3_or_4        : std_logic;                   -- phase MSB  : negate the sample
  signal quadrant_3_or_4_delay  : std_logic;
  signal quadrant_3_or_4_2delay : std_logic;
  signal peak                   : boolean;                     -- phase is exactly 90 or 270 deg

begin

  -- synthesis translate_off
  assert ftw_width >= PHASE_WIDTH
    report "dds_synthesizer: ftw_width must be >= PHASE_WIDTH" severity failure;
  assert PHASE_WIDTH >= 3
    report "dds_synthesizer: PHASE_WIDTH must be >= 3" severity failure;
  -- synthesis translate_on

  phase_o <= std_logic_vector(phase);

  quadrant_2_or_4 <= phase(PHASE_WIDTH-2);
  quadrant_3_or_4 <= phase(PHASE_WIDTH-1);

  -- Quarter-wave folding: in quadrants 2 and 4 the table is read backwards,
  -- index = 2**QW - phase_low. For phase_low = 0 that is 2**QW, which does not
  -- fit in QW bits (it would wrap to 0 and give sin = 0 instead of the peak),
  -- so that single case is handled by `peak` below.
  lut_in <= phase(QW-1 downto 0) when quadrant_2_or_4 = '0' else
            resize(to_unsigned(2**QW, QW+1) - resize(phase(QW-1 downto 0), QW+1), QW);

  peak <= quadrant_2_or_4 = '1' and phase(QW-1 downto 0) = 0;

  ampl_o <= std_logic_vector(lut_out_delay) when quadrant_3_or_4_2delay = '0' else
            std_logic_vector(lut_out_inv_delay);

  pipeline : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      ftw_accu               <= (others => '0');
      phase                  <= (others => '0');
      lut_out                <= (others => '0');
      lut_out_delay          <= (others => '0');
      lut_out_inv_delay      <= (others => '0');
      quadrant_3_or_4_delay  <= '0';
      quadrant_3_or_4_2delay <= '0';
    elsif rising_edge(clk_i) then
      -- stage 0: phase accumulator (wraps modulo 2**ftw_width)
      ftw_accu <= ftw_accu + unsigned(ftw_i);

      -- stage 1: keep the PHASE_WIDTH MSBs (phase truncation) and add the offset
      phase <= ftw_accu(ftw_width-1 downto ftw_width-PHASE_WIDTH) + unsigned(phase_i);

      -- stage 2: |sin| from the quarter-wave table
      if peak then
        lut_out <= to_signed(2**(AMPL_WIDTH-1) - 1, AMPL_WIDTH);
      else
        lut_out <= signed(sine_lut(to_integer(lut_in)));
      end if;

      -- stage 3: register both signs; the quadrant bit travels alongside
      quadrant_3_or_4_delay  <= quadrant_3_or_4;
      quadrant_3_or_4_2delay <= quadrant_3_or_4_delay;
      lut_out_delay          <= lut_out;
      lut_out_inv_delay      <= -lut_out;     -- never overflows: 0 <= lut_out <= 2**(A-1)-1
    end if;
  end process pipeline;

end architecture dds_synthesizer_arch;
