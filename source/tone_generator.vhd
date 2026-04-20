-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : tone_generator.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;
use work.tone_gen_pkg.all;


entity tone_generator is

  port (clk_12m        : in  std_logic;
        reset_n        : in  std_logic;
        load_i         : in  std_logic;
        strobe_i       : in  std_logic;
        attenu_i       : in  std_logic_vector(1 downto 0);
        instr          : in  std_logic_vector(2 downto 0);
        data_vector_in : in  t_midi_array;
        ton_gen_o      : out std_logic_vector(15 downto 0)
        );

end entity tone_generator;

-------------------------------------------------------------------------------

architecture struct of tone_generator is
   component dds is
    port (
      reset_n    : in  std_logic;
      clk_12m    : in  std_logic;
      load_i     : in  std_logic;
      tone_on_i  : in  std_logic;
      attenu_i   : in  std_logic_vector(1 downto 0);
      instr      : in  std_logic_vector(2 downto 0);
      phi_incr_i : in  std_logic_vector(N_CUM-1 downto 0);
      dds_o      : out std_logic_vector(N_AUDIO-1 downto 0));
   end component dds;

   
  --Signalsr
  signal dds_o_array  : t_dds_o_array;
  signal next_sum_reg : integer range -(2**20) to (2**20);
  signal sum_reg      : integer range -(2**20) to (2**20);

-------------------------------------------------------------------------------

begin

  dds_gen : for i in 0 to 9 generate
    -- instance "dds_1"
    dds_1 : dds
      port map (
        reset_n    => reset_n,
        clk_12m    => clk_12m,
        load_i     => load_i,
        tone_on_i  => data_vector_in(i).valid, --valid bit aus midi-array type
        attenu_i   => attenu_i,
        instr      => instr,
        phi_incr_i => LUT_midi2dds(to_integer(unsigned(data_vector_in(i).number))),
        --phi_incr_i: Aufruf nach Lookup Tabelle durch Konstante "LUT_midi2dds"
        dds_o      => dds_o_array(i)
        );
  end generate dds_gen;

  comb_sum_output : process(all)   --Ausgaenge der 10 DDS werden zusammengefuegt
    variable var_sum : integer range -(2**20) to (2**20);

  begin
    var_sum := 0;
    
    if strobe_i = '1' then
      
      dds_sum_loop : for i in 0 to 9 loop
        var_sum := var_sum + to_integer(unsigned(dds_o_array(i)));
      end loop dds_sum_loop;
      
      next_sum_reg <= var_sum;
    else
      next_sum_reg <= sum_reg;
    end if;
  end process comb_sum_output;

  
  reg_sum_output : process(clk_12m, reset_n)
  begin
    
    if reset_n = '0' then
      sum_reg <= 0;
    elsif rising_edge(clk_12m) then
      sum_reg <= next_sum_reg;
    end if;
    
  end process reg_sum_output;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  ton_gen_o <= std_logic_vector(to_unsigned(sum_reg, 16));
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture struct;
