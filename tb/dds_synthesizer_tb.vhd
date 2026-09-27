-------------------------------------------------------------------------------
-- dds_synthesizer_tb.vhd - self-checking testbench (GHDL, VHDL-2008)
--
-- Runs the same checks against any of the implementations:
--   IMPL = "rtl"   refactored RTL             (rtl/dds_synthesizer.vhd)
--   IMPL = "orig"  original RTL                (rtl/original/, -fsynopsys)
--   IMPL = "lean"  62-flip-flop variant        (rtl/dds_synthesizer_lean.vhd)
--   IMPL = "gate"  any gate-level netlist      (netlists/*/, + cell models)
--
-- Checks, every clock cycle after reset:
--   1. ampl_o = round(511*sin(2*pi*phase/1024)) for the phase two cycles earlier
--      (reference: formal/props/sine_full_pkg.vhd, computed with sin())
--   2. |ampl_o| <= 511
--   3. with constant inputs, phase_o advances by FTW>>22 or FTW>>22 + 1
-- plus a frequency measurement (zero crossings) for each tuning word.
--
-- A CSV trace of the first cycles is written to TRACE_FILE so the Python model
-- (tools/dds_model.py) can be compared sample-by-sample with the HDL.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

use work.sine_full_pkg.all;

entity dds_synthesizer_tb is
  generic (
    IMPL        : string  := "rtl";
    EXPECT_FAIL : boolean := false;          -- true for the buggy netlist
    CYCLES      : natural := 4096;           -- cycles per tuning word
    TRACE_FILE  : string  := "dds_trace.csv"
  );
end entity dds_synthesizer_tb;

architecture sim of dds_synthesizer_tb is

  constant N : natural := 32;
  constant M : natural := 10;
  constant A : natural := 10;
  constant T_CLK : time := 10 ns;             -- 100 MHz

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal ftw     : std_logic_vector(N-1 downto 0) := (others => '0');
  signal phi     : std_logic_vector(M-1 downto 0) := (others => '0');
  signal phase_o : std_logic_vector(M-1 downto 0);
  signal ampl_o  : std_logic_vector(A-1 downto 0);
  signal done    : boolean := false;

  component dds_synthesizer is
    generic (ftw_width : positive := 32);
    port (clk_i, rst_i : in std_logic; ftw_i : in std_logic_vector(ftw_width-1 downto 0);
          phase_i : in std_logic_vector(M-1 downto 0); phase_o : out std_logic_vector(M-1 downto 0);
          ampl_o : out std_logic_vector(A-1 downto 0));
  end component;
  component dds_synthesizer_lean is
    generic (ftw_width : positive := 32);
    port (clk_i, rst_i : in std_logic; ftw_i : in std_logic_vector(ftw_width-1 downto 0);
          phase_i : in std_logic_vector(M-1 downto 0); phase_o : out std_logic_vector(M-1 downto 0);
          ampl_o : out std_logic_vector(A-1 downto 0));
  end component;
  component dds_synthesizer_ftw_width32 is
    port (clk_i, rst_i : in std_logic; ftw_i : in std_logic_vector(31 downto 0);
          phase_i : in std_logic_vector(9 downto 0); phase_o, ampl_o : out std_logic_vector(9 downto 0));
  end component;

  type ftw_list is array (natural range <>) of std_logic_vector(N-1 downto 0);
  -- f_out = FTW / 2^32 * 100 MHz
  constant TUNING : ftw_list := (
    x"028F5C29",   -- ~1.000 MHz
    x"00A7C5AC",   -- ~0.256 MHz
    x"10000000",   -- 6.25 MHz exactly (FTW/2^32 = 1/16)
    x"7FFFFFFF",   -- just below Nyquist
    x"00000001",   -- slowest possible, phase barely moves
    x"DEADBEEF",   -- 'negative' frequency (wraps backwards)
    x"12345679"    -- odd word: full period 2^32
  );

begin

  clk <= not clk after T_CLK / 2 when not done;

  g_rtl : if IMPL = "rtl" or IMPL = "orig" generate
    dut : dds_synthesizer generic map (ftw_width => N)
      port map (clk, rst, ftw, phi, phase_o, ampl_o);
  end generate;
  g_lean : if IMPL = "lean" generate
    dut : dds_synthesizer_lean generic map (ftw_width => N)
      port map (clk, rst, ftw, phi, phase_o, ampl_o);
  end generate;
  g_gate : if IMPL = "gate" generate
    dut : dds_synthesizer_ftw_width32 port map (clk, rst, ftw, phi, phase_o, ampl_o);
  end generate;

  stimulus_and_check : process
    variable errors, checks  : natural := 0;
    variable first_err       : integer := -1;
    variable ph1, ph2        : integer := 0;          -- phase_o one / two cycles ago
    variable prev_phase      : integer := 0;
    variable expect, got, d  : integer;
    variable step            : integer;
    variable prev_a          : integer := 0;
    variable crossings       : natural;
    variable first_x, last_x : natural;
    variable f_meas, f_exp   : real;
    variable cyc             : natural := 0;
    file trace               : text;
    variable l               : line;
  begin
    file_open(trace, TRACE_FILE, write_mode);
    write(l, string'("cycle,ftw,phase_i,phase_o,ampl_o"));
    writeline(trace, l);

    rst <= '1';
    wait for 3 * T_CLK;
    wait until falling_edge(clk);
    rst <= '0';
    assert unsigned(phase_o) = 0 and unsigned(ampl_o) = 0
      report "outputs not zero after reset" severity error;

    for w in TUNING'range loop
      ftw <= TUNING(w);
      phi <= std_logic_vector(to_unsigned((w * 97) mod 1024, M));   -- a different offset per tone
      crossings := 0;
      for i in 0 to CYCLES - 1 loop
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        cyc := cyc + 1;
        got := to_integer(signed(ampl_o));
        -- (1) amplitude against the full-period sine reference
        if i >= 3 then
          expect := SINE_FULL(ph2);
          checks := checks + 1;
          if got /= expect then
            errors := errors + 1;
            if first_err < 0 then
              first_err := cyc;
              report IMPL & ": first mismatch at cycle " & integer'image(cyc) &
                     " phase=" & integer'image(ph2) & " expected " & integer'image(expect) &
                     " got " & integer'image(got) severity note;
            end if;
          end if;
          -- (3) phase step with constant inputs
          step := to_integer(unsigned(TUNING(w)(N-1 downto N-M)));
          d := (to_integer(unsigned(phase_o)) - prev_phase) mod 1024;
          if d /= step and d /= (step + 1) mod 1024 then
            errors := errors + 1;
          end if;
          -- zero crossings (upward) for the frequency measurement
          if prev_a < 0 and got >= 0 then
            if crossings = 0 then
              first_x := i;
            end if;
            last_x := i;
            crossings := crossings + 1;
          end if;
        end if;
        -- (2) symmetric range
        if got < -511 then
          errors := errors + 1;
        end if;
        if cyc <= 256 then
          write(l, integer'image(cyc) & "," & integer'image(to_integer(unsigned(TUNING(w)(31 downto 16)))) &
                   "," & integer'image(to_integer(unsigned(phi))) & "," &
                   integer'image(to_integer(unsigned(phase_o))) & "," & integer'image(got));
          writeline(trace, l);
        end if;
        prev_a := got;
        prev_phase := to_integer(unsigned(phase_o));
        ph2 := ph1;
        ph1 := to_integer(unsigned(phase_o));
      end loop;
      -- words above 2^31 are negative frequencies: |f| = (2^32 - FTW)/2^32 * f_clk
      f_exp  := real(to_integer(unsigned(TUNING(w)(N-1 downto 16)))) * 65536.0 / 4294967296.0;
      if f_exp > 0.5 then
        f_exp := 1.0 - f_exp;
      end if;
      f_exp  := f_exp * 100.0e6;
      if crossings >= 2 then       -- periods between the first and the last upward zero crossing
        f_meas := real(crossings - 1) / (real(last_x - first_x) * 10.0e-9);
      else
        f_meas := 0.0;
      end if;
      report IMPL & ": FTW=0x" & to_hstring(TUNING(w)) & "  expected " &
             integer'image(integer(f_exp / 1.0e3)) & " kHz, measured ~" &
             integer'image(integer(f_meas / 1.0e3)) & " kHz (" & integer'image(crossings) & " periods seen)"
             severity note;
    end loop;

    file_close(trace);
    if errors = 0 then
      report IMPL & ": PASS - " & integer'image(checks) & " cycle checks, 0 errors" severity note;
    else
      report IMPL & ": " & integer'image(errors) & " errors in " & integer'image(checks) &
             " cycle checks (first at cycle " & integer'image(first_err) & ")" severity note;
    end if;
    if EXPECT_FAIL then
      assert errors > 0 report IMPL & ": the buggy netlist was expected to fail" severity failure;
    else
      assert errors = 0 report IMPL & ": FAILED" severity failure;
    end if;
    done <= true;
    wait;
  end process;

end architecture sim;
