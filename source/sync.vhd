-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : sync.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity sync is

  generic (width : positive);

  port (signal_i : in  std_logic_vector(width-1 downto 0);
        clock_i  : in  std_logic;
        signal_o : out std_logic_vector(width-1 downto 0)
        );

end entity sync;

-------------------------------------------------------------------------------

architecture rtl of sync is

begin 

  flipflops : process(all)                     -- Signale werden synchronisiert
  begin
    
    if(rising_edge(clock_i)) then       
      signal_o <= signal_i; 
    end if;
    
  end process flipflops;

end architecture rtl;
