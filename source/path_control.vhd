-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : path_control.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity path_control is

  port (sw_sync_3   : in std_logic;                      --3.Wert des Vektors sw_sync
        dds_l_i     : in std_logic_vector(15 downto 0);  -- beachte Vektorlaenge ff.
        dds_r_i     : in std_logic_vector(15 downto 0);
        adcdat_pl_i : in std_logic_vector(15 downto 0);  -- beachte Vektorlaenge ff.
        adcdat_pr_i : in std_logic_vector(15 downto 0);

        dacdat_pl_o : out std_logic_vector(15 downto 0);
        dacdat_pr_o : out std_logic_vector(15 downto 0)
        );

end entity path_control;

-------------------------------------------------------------------------------

architecture str of path_control is

begin
  
  multiplexer_path_controll : process(all)
  begin
    
    if sw_sync_3 = '1' then
      dacdat_pl_o <= adcdat_pl_i;
      dacdat_pr_o <= adcdat_pr_i;
    else
      dacdat_pl_o <= dds_l_i;
      dacdat_pr_o <= dds_r_i;
    end if;
    
  end process multiplexer_path_controll;
  
end architecture str;
