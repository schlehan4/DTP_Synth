-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : BIT_CNTR.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bit_cntr is

  generic (width : positive := 7);

  port (initialise_i : in  std_logic;
        reset_n      : in  std_logic;
        clk_12m      : in  std_logic;
        bclk         : in  std_logic;
        bit_count_o  : out std_logic_vector(width-1 downto 0)
        );

end entity bit_cntr;

-------------------------------------------------------------------------------

architecture str of bit_cntr is

  -- Signals
  signal count, next_count : unsigned(width-1 downto 0);

-------------------------------------------------------------------------------

begin

  count_logic : process(all)
  begin
    --default
    next_count <= count;                   

    if (initialise_i = '0') then        --initialise
      next_count <= to_unsigned(0, width);
    elsif (bclk = '1') then             -- count
      next_count <= count + 1;
    end if;

  end process count_logic;

  
  flip_flops : process(all)
  begin
    
    if reset_n = '0' then
      count <= to_unsigned(0, width);    
    elsif rising_edge(clk_12m) then
      count <= next_count;
    end if;
    
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
  bit_count_o <= std_logic_vector(count);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture str;
