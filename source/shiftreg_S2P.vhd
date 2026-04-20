-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : shiftreg_S2P.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity shiftreg_s2p is

  port(Clk          : in  std_logic;
       reset_n      : in  std_logic;
       shift_enable : in  std_logic;
       serdata_sync : in  std_logic;
       parallel_out : out std_logic_vector(9 downto 0)
       );
  
end shiftreg_s2p;

-------------------------------------------------------------------------------

architecture rtl of shiftreg_s2p is

  -- Signals
  signal shiftreg      : std_logic_vector(9 downto 0);
  signal next_shiftreg : std_logic_vector(9 downto 0);

-------------------------------------------------------------------------------

begin

  comb_logic : process(all)
  begin
    
    if shift_enable = '1' then
      next_shiftreg <=serdata_sync & shiftreg(9 downto 1);
    else
      next_shiftreg <= shiftreg; --sonst bleibt es gleich
    end if;

  end process comb_logic;

  
  flip_flops : process(all)
  begin
    
    if reset_n = '0' then
      shiftreg <= (others => '0');
    elsif rising_edge(Clk) then
      shiftreg <= next_shiftreg;
    end if;
    
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  parallel_out <= shiftreg; 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
end rtl;
