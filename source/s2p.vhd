-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : s2p.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity s2p is

  port (adcdat_s_i : in  std_logic;
        reset_n    : in  std_logic;
        clk_12m    : in  std_logic;
        shift      : in  std_logic;
        bclk       : in  std_logic;
        adcdat_p_o : out std_logic_vector(15 downto 0)
        );

end entity s2p;

-------------------------------------------------------------------------------

architecture str of s2p is

  -- Signals
  signal shiftreg, next_shiftreg : std_logic_vector(15 downto 0);

-------------------------------------------------------------------------------

begin
  
  logik : process(all)
  begin
    next_shiftreg <= shiftreg;

    if (bclk = '1') then
      
      if(shift = '1') then
        next_shiftreg <= shiftreg(14 downto 0) & adcdat_s_i;  
      end if;
      
    end if;
  end process logik;


  flip_flops : process(all)
  begin
    
    if reset_n = '0' then
      shiftreg <= (others => '0');
    elsif rising_edge(clk_12m) then
      shiftreg <= next_shiftreg;
    end if;
    
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  adcdat_p_o <= shiftreg;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
end architecture str;
