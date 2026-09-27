-------------------------------------------------------------------------------
-- dds_props.vhd - formal property monitor for the DDS.
--
-- Wraps the refactored RTL and computes one "ok" bit per property from an
-- INDEPENDENT specification (a full-period sine table computed with sin(),
-- no quarter-wave tricks). fv/induction.py proves every ok bit is always '1'
-- by k-induction. The ports are the DUT inputs plus the property bits.
--
--   p_sine    ampl_o equals SINE_FULL(phase_o two cycles earlier)
--             -> the quadrant folding, the peak special case, the table and
--                the negation are all correct, for every phase value
--   p_range   ampl_o is never -2**(A-1) (the output is symmetric: |ampl| <= 511)
--   p_step    with constant ftw_i / phase_i, phase_o advances by
--             ftw(N-1 downto N-M) or that + 1 every clock (phase truncation)
--   p_offset  a change of phase_i shows up in phase_o exactly one cycle later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sine_lut_pkg.all;
use work.sine_full_pkg.all;

entity dds_props is
  generic (ftw_width : positive := 32);
  port (
    clk_i    : in  std_logic;
    rst_i    : in  std_logic;
    ftw_i    : in  std_logic_vector(ftw_width-1 downto 0);
    phase_i  : in  std_logic_vector(PHASE_WIDTH-1 downto 0);
    p_sine   : out std_logic;
    p_range  : out std_logic;
    p_step   : out std_logic;
    p_offset : out std_logic
  );
end entity dds_props;

architecture monitor of dds_props is

  constant M : natural := PHASE_WIDTH;

  signal phase_o, phase_d1, phase_d2 : std_logic_vector(M-1 downto 0);
  signal ampl_o                      : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal ftw_d1, ftw_d2              : std_logic_vector(ftw_width-1 downto 0);
  signal phi_d1, phi_d2              : std_logic_vector(M-1 downto 0);
  signal age                         : unsigned(1 downto 0);     -- cycles since reset, saturating

begin

  dut : entity work.dds_synthesizer
    generic map (ftw_width => ftw_width)
    port map (clk_i => clk_i, rst_i => rst_i, ftw_i => ftw_i, phase_i => phase_i,
              phase_o => phase_o, ampl_o => ampl_o);

  history : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      phase_d1 <= (others => '0');
      phase_d2 <= (others => '0');
      ftw_d1   <= (others => '0');
      ftw_d2   <= (others => '0');
      phi_d1   <= (others => '0');
      phi_d2   <= (others => '0');
      age      <= (others => '0');
    elsif rising_edge(clk_i) then
      phase_d1 <= phase_o;
      phase_d2 <= phase_d1;
      ftw_d1   <= ftw_i;
      ftw_d2   <= ftw_d1;
      phi_d1   <= phase_i;
      phi_d2   <= phi_d1;
      if age /= 3 then
        age <= age + 1;
      end if;
    end if;
  end process history;

  -- P1: functional correctness against the full-period specification
  p_sine <= '1' when to_integer(signed(ampl_o)) = SINE_FULL(to_integer(unsigned(phase_d2))) else '0';

  -- P2: no asymmetric full-scale negative value
  p_range <= '0' when signed(ampl_o) = -(2**(AMPL_WIDTH-1)) else '1';

  -- P3: phase increment per clock, valid once two cycles of history exist and
  --     the inputs were stable: delta = floor-difference of the accumulator MSBs
  p_step_proc : process (all)
    variable d, f : unsigned(M-1 downto 0);
  begin
    d := unsigned(phase_o) - unsigned(phase_d1);
    f := unsigned(ftw_d2(ftw_width-1 downto ftw_width-M));
    if age >= 2 and phi_d1 = phi_d2 then
      if d = f or d = f + 1 then
        p_step <= '1';
      else
        p_step <= '0';
      end if;
    else
      p_step <= '1';
    end if;
  end process;

  -- P4: the phase offset input is applied with exactly one cycle of latency:
  --     changing phase_i by x (accumulator frozen, ftw = 0) moves phase_o by x
  p_offset_proc : process (all)
    variable d : unsigned(M-1 downto 0);
  begin
    d := unsigned(phase_o) - unsigned(phase_d1);
    if age >= 2 and unsigned(ftw_d2) = 0 then
      if d = unsigned(phi_d1) - unsigned(phi_d2) then
        p_offset <= '1';
      else
        p_offset <= '0';
      end if;
    else
      p_offset <= '1';
    end if;
  end process;

end architecture monitor;
