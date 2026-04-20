-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : modulo_divider.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity modulo_divider is
  
  generic (width : positive := 2);
  
  port(clk     : in  std_logic;
       reset_n : in  std_logic;
       clk_12m : out std_logic
       );
  
end modulo_divider;

-------------------------------------------------------------------------------

architecture rtl of modulo_divider is

  -- Signals
  signal count, next_count : unsigned(width-1 downto 0) := (others => '0');

-------------------------------------------------------------------------------
  
begin

  comb_logic : process(count)
  begin
    next_count <= count + 1;
  end process comb_logic;

  
  flip_flops : process(all)
  begin
    
    if reset_n = '0' then
      count <= to_unsigned(0, width);
    elsif rising_edge(clk) then
      count <= next_count;
    end if;
    
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  clk_12m <= std_logic(count(width-1));
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end rtl;
