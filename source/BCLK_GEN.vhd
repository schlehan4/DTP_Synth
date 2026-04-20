-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : BCLK_GEN.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bckl_gen is

  port (reset_n : in  std_logic;
        clk_12m : in  std_logic;
        bclk    : out std_logic
        );

end entity bckl_gen;

-------------------------------------------------------------------------------

architecture str of bckl_gen is

begin
  
  CLOCK_DIVIDER : process(all)
  begin
    if reset_n = '0' THEN
       bclk <= '0';
    elsif rising_edge(clk_12m)then
      bclk <= not bclk;
    end if;
  end process CLOCK_DIVIDER;

end architecture str;
