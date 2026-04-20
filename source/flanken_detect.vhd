-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : flanken_detect.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity flanken_detect is

  port(serdata_sync : in  std_logic;
       Clk          : in  std_logic;
       reset_n      : in  std_logic;
       fall_edge    : out std_logic
       );

end flanken_detect;

-------------------------------------------------------------------------------

architecture rtl of flanken_detect is

  -- Signals 
  signal shiftreg, next_shiftreg : std_logic_vector(1 downto 0);

-------------------------------------------------------------------------------

begin
 
  comb_proc : process(all)
  begin
    next_shiftreg <= serdata_sync & shiftreg(1);  -- shift direction towards LSB        
  end process comb_proc;

  
  reg_proc : process(all)
  begin
    if reset_n = '0' then
      shiftreg <= (others => '0');
    elsif (rising_edge(Clk)) then
      shiftreg <= next_shiftreg;
    end if;
  end process reg_proc;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  
  --steig   <= shiftreg(1) and not(shiftreg(0));
  fall_edge <= not(shiftreg(1)) and shiftreg(0);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end rtl;
