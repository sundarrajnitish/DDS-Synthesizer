-------------------------------------------------------------------------------
-- dds_synthesizer_lean.vhd
--
-- An improved micro-architecture of the same DDS - same ports, same latency,
-- the same output on every clock cycle - with fewer flip-flops and a fully
-- registered, glitch-free amplitude output.
--
--   original pipeline                      lean pipeline
--   -----------------                      -------------
--   lut_out            10 FF (MSB const)   lut_out            9 FF (magnitude only)
--   lut_out_delay      10 FF               ampl_reg          10 FF (signed result)
--   lut_out_inv_delay  10 FF
--   quadrant delays     2 FF               quadrant delay     1 FF
--   ampl_o = MUX(reg, reg)  (combinational) ampl_o = ampl_reg      (registered)
--   total 74 FF in RTL / 72 after synthesis   total 62 FF
--
-- 22 flip-flops of the original and 10 of this design have no counterpart, so
-- a combinational equivalence checker with name-based register matching
-- cannot prove the two equal. They are proven equal with sequential
-- equivalence checking instead: the 52 registers that do correspond are
-- matched, the rest is handled by k-induction (k = 2; k = 1 is not enough).
-- See formal/fv/induction.py and `make -C formal lean-equiv`.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sine_lut_pkg.all;
use work.sine_lut_data.all;

entity dds_synthesizer_lean is
  generic (
    ftw_width : positive := 32
  );
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    ftw_i   : in  std_logic_vector(ftw_width-1 downto 0);
    phase_i : in  std_logic_vector(PHASE_WIDTH-1 downto 0);
    phase_o : out std_logic_vector(PHASE_WIDTH-1 downto 0);
    ampl_o  : out std_logic_vector(AMPL_WIDTH-1 downto 0)
  );
end entity dds_synthesizer_lean;

architecture rtl of dds_synthesizer_lean is

  constant QW   : natural := PHASE_WIDTH - 2;
  constant PEAK : natural := 2**(AMPL_WIDTH-1) - 1;

  signal ftw_accu              : unsigned(ftw_width-1 downto 0);
  signal phase                 : unsigned(PHASE_WIDTH-1 downto 0);
  signal lut_in                : unsigned(QW-1 downto 0);
  signal lut_out               : unsigned(AMPL_WIDTH-2 downto 0);   -- |sin|, MSB is always 0
  signal quadrant_3_or_4_delay : std_logic;
  signal ampl_reg              : signed(AMPL_WIDTH-1 downto 0);

begin

  phase_o <= std_logic_vector(phase);
  ampl_o  <= std_logic_vector(ampl_reg);

  lut_in <= phase(QW-1 downto 0) when phase(PHASE_WIDTH-2) = '0' else
            resize(to_unsigned(2**QW, QW+1) - resize(phase(QW-1 downto 0), QW+1), QW);

  pipeline : process (clk_i, rst_i)
    variable mag : signed(AMPL_WIDTH-1 downto 0);
  begin
    if rst_i = '1' then
      ftw_accu              <= (others => '0');
      phase                 <= (others => '0');
      lut_out               <= (others => '0');
      quadrant_3_or_4_delay <= '0';
      ampl_reg              <= (others => '0');
    elsif rising_edge(clk_i) then
      ftw_accu <= ftw_accu + unsigned(ftw_i);
      phase    <= ftw_accu(ftw_width-1 downto ftw_width-PHASE_WIDTH) + unsigned(phase_i);

      if phase(PHASE_WIDTH-2) = '1' and phase(QW-1 downto 0) = 0 then
        lut_out <= to_unsigned(PEAK, AMPL_WIDTH-1);
      else
        lut_out <= unsigned(sine_lut(to_integer(lut_in))(AMPL_WIDTH-2 downto 0));
      end if;
      quadrant_3_or_4_delay <= phase(PHASE_WIDTH-1);

      mag := signed('0' & lut_out);
      if quadrant_3_or_4_delay = '1' then
        ampl_reg <= -mag;
      else
        ampl_reg <= mag;
      end if;
    end if;
  end process pipeline;

end architecture rtl;
