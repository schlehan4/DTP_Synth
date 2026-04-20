-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : baud_tick.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity baud_tick is

  port(Clk       : in  std_logic;
       start_bit : in  std_logic;
       reset_n   : in  std_logic;
       baud_tick : out std_logic
       );

end baud_tick;

-------------------------------------------------------------------------------

architecture rtl of baud_tick is

  -- Signals & Constants
  constant count_width               : natural                            := 10; 
  constant one_period                : unsigned(count_width - 1 downto 0) := to_unsigned(400, count_width);
  constant half_period               : unsigned(count_width - 1 downto 0) := to_unsigned(200, count_width);
  signal baud_count, next_baud_count : unsigned(count_width - 1 downto 0);
-------------------------------------------------------------------------------
-- one_period  = 12'500'000 Hz / 31'250 Hz(midi-Frequenz)=400
-- half_period = one_period / 2 = 200
-------------------------------------------------------------------------------

begin

  reg_proc : process(all)
  begin
    baud_tick <= '0';                    -- Anfangsbedingung
    
    if start_bit = '1' then              -- Erzeugung von Baud-Frequenz
      next_baud_count <= half_period;
    elsif baud_count = 0 then
      next_baud_count <= one_period;
      baud_tick       <= '1';
    else next_baud_count <= baud_count-1;
    end if;

  end process reg_proc;

  
  clok : process(all)
  begin
    
    if reset_n = '0' then
      baud_count <= (others => '0');
    elsif rising_edge(Clk) then
      baud_count <= next_baud_count;
    end if;
    
  end process clok;

end rtl;
