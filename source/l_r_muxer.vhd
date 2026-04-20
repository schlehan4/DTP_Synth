-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : l_r_muxer.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity l_r_muxer is

  port (ser_i_l    : in  std_logic;
        ser_i_r    : in  std_logic;
        ws         : in  std_logic;
        dacdat_s_o : out std_logic
        );

end entity l_r_muxer;

-------------------------------------------------------------------------------

architecture str of l_r_muxer is

begin  

  l_r_muxer : process(all)
  begin
    if (ws = '0')then
      dacdat_s_o <= ser_i_l;
    else
      dacdat_s_o <= ser_i_r;
    end if;
  end process l_r_muxer;
  
end architecture str;
