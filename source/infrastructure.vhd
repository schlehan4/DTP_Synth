-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : infrastructure.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

 
entity infrastructure is               

  port(CLOCK_50     : in  std_logic;                      -- 50 MHz Clock IN
       KEY          : in  std_logic_vector(1 downto 0);   -- IN (KEY_0 & KEY_1)
       GPIO_26      : in  std_logic;                      --  to "sync_inst_3"
       SW           : in  std_logic_vector(17 downto 0);  -- Input buttons
       clk_12m      : out std_logic;                      -- Clock out @ 12.5 MHz
       reset_n      : out std_logic;                      -- Reset key to Codec Controller & I2C Master
       key_1_sync   : out std_logic;                      -- to Codec Controller
       gpio_26_sync : out std_logic;                      -- ND, out from "sync_inst_3"
       sw_sync      : out std_logic_vector(17 downto 0)   -- synchronized input keys (x18)
       );
  
end infrastructure;

-------------------------------------------------------------------------------

architecture rtl of infrastructure is
  component modulo_divider is
       port (
      clk     : in  std_logic;
      clk_12m : out std_logic;
      reset_n : in  std_logic);
  end component modulo_divider;

  component sync is
    generic (
      width : positive);
    port (
      clock_i  : in  std_logic;
      signal_i : in  std_logic_vector(width-1 downto 0);
      signal_o : out std_logic_vector(width-1 downto 0));
  end component sync;

  
  -- Signals 
  signal clk_12m_int    : std_logic;
  signal control_key_o  : std_logic_vector(1 downto 0);  -- reset_n & key_1_sync
  signal GPIO_26_i      : std_logic_vector(0 downto 0);
  signal GPIO_26_sync_i : std_logic_vector(0 downto 0);  -- before split up

-------------------------------------------------------------------------------
  
begin

  takt_inst : modulo_divider
    port map (
      clk     => CLOCK_50,
      clk_12m => clk_12m_int,
      reset_n =>'1');

  sync_inst_1 : sync
    generic map (width => 2)
    port map (
      clock_i  => clk_12m_int,
      signal_i => KEY,
      signal_o => control_key_o);

  sync_inst_2 : sync
    generic map (width => 18)
    port map (
      clock_i  => clk_12m_int,
      signal_i => SW,
      signal_o => sw_sync);

  sync_inst_3 : sync
    generic map (width => 1)
    port map (
      clock_i  => clk_12m_int,
      signal_i => GPIO_26_i,
      signal_o => gpio_26_sync_i);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisungen
   GPIO_26_i(0) <= GPIO_26;
   GPIO_26_sync <= GPIO_26_sync_i(0);
   clk_12m    <= clk_12m_int;
   key_1_sync <= control_key_o(1);
   reset_n    <= control_key_o(0);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture;
