-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : phase_counter.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;


entity phase_counter is

  generic (L     : positive := 2**N_LUT;
           N_CUM : positive := 19;
           N_LUT : positive := 8
           );

  port (reset_n    : in  std_logic;
        clk_12m    : in  std_logic;
        load_i     : in  std_logic;
        phi_incr_i : in  std_logic_vector(N_CUM-1 downto 0);
        count_o    : out std_logic_vector(N_CUM-1 downto 0) 
        );

end entity phase_counter;

-------------------------------------------------------------------------------

architecture str of phase_counter is

  -- Signals
  signal count, next_count : unsigned(N_CUM-1 downto 0);

-------------------------------------------------------------------------------
  
begin 

  count_logic : process(all)
  begin
    --default
    next_count <= count;

    if (load_i = '1') then             
      next_count <= unsigned(phi_incr_i) + count;
    else
      next_count <= count;
    end if;

  end process count_logic;

  
  flip_flops : process(all)
  begin
    
    if reset_n = '0' then
      count <= to_unsigned(0, N_CUM);
    elsif falling_edge(clk_12m) then
      count <= next_count;
    end if;
    
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  count_o <= std_logic_vector(count);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture str;
