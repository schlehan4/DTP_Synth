-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : I2S_decoder.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity i2s_decoder is

  generic (width : positive := 7);

  port (bit_count_i : in  std_logic_vector(width-1 downto 0);
        load        : out std_logic;
        shift_l     : out std_logic;
        shift_r     : out std_logic;
        ws          : out std_logic
        );

end entity i2s_decoder;

-------------------------------------------------------------------------------

architecture str of i2s_decoder is

begin

  comb_logic : process(all)

  begin
    load    <= '0';
    shift_l <= '0';
    shift_r <= '0';

    ws <= bit_count_i(6);

    if (unsigned(bit_count_i) = 0) then
      load <= '1';
    elsif (unsigned(bit_count_i) < 17) then
      shift_l <= '1';
    elsif(unsigned(bit_count_i) > 64) and (unsigned(bit_count_i) < 81) then
      shift_r <= '1';
    end if;
  end process comb_logic;

end architecture str;
