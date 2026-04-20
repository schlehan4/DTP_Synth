-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : p2s.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity p2s is

  port (dacdat_px_i : in  std_logic_vector(15 downto 0);
        reset_n     : in  std_logic;
        clk_12m     : in  std_logic;
        load        : in  std_logic;
        shift       : in  std_logic;
        bclk        : in  std_logic;
        ser_out     : out std_logic
        );

end entity p2s;

-------------------------------------------------------------------------------

architecture str of p2s is

  -- Signals
  signal shiftreg, next_shiftreg : std_logic_vector(15 downto 0);

-------------------------------------------------------------------------------
  
begin 
 
  shift_comb : process(all)
  begin
    next_shiftreg <= shiftreg;
    
    if (bclk = '1') then
      
      if (load = '1') then
        next_shiftreg <= dacdat_px_i;
      elsif (shift = '1') then
        next_shiftreg <= shiftreg(14 downto 0)&'0';
      end if;
      
    end if;
  end process shift_comb;


  shift_flipflop : process(all)
  begin
    
    if reset_n = '0' then
      shiftreg <= (others => '0');
    elsif rising_edge(clk_12m) then
      shiftreg <= next_shiftreg;
    end if;
    
  end process shift_flipflop;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  ser_out <= shiftreg(15);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture str;
