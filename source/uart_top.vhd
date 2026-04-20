-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : uart_top.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_top is
  port (clk          : in  std_logic;
        reset_n      : in  std_logic;
        serial_in    : in  std_logic;
        parallel_out : out std_logic_vector(7 downto 0);
        data_valid   : out std_logic
        );

end entity uart_top;

-------------------------------------------------------------------------------

architecture str of uart_top is
  component flanken_detect is
    port (
      serdata_sync : in  std_logic;
      Clk          : in  std_logic;
      reset_n      : in  std_logic;
      fall_edge    : out std_logic);
  end component flanken_detect;

  component baud_tick is
    port (
      Clk       : in  std_logic;
      start_bit : in  std_logic;
      reset_n   : in  std_logic;
      baud_tick : out std_logic);
  end component baud_tick;

  component uart_controller_fsm is
    port (
      Clk          : in  std_logic;
      baud_tick_i  : in  std_logic;
      reset_n      : in  std_logic;
      fall_edge    : in  std_logic;
      parallel_i   : in  std_logic_vector (9 downto 0);
      start_bit_o  : out std_logic;
      data_valid_o : out std_logic;
      shift_enable : out std_logic);
  end component uart_controller_fsm;

  component shiftreg_s2p is
    port (
      Clk          : in  std_logic;
      reset_n      : in  std_logic;
      shift_enable : in  std_logic;
      parallel_out : out std_logic_vector(9 downto 0);
      serdata_sync : in  std_logic);
  end component shiftreg_s2p;

  
  --Signals
  signal signal_flank     : std_logic;
  signal signal_bit       : std_logic;
  signal signal_baud_tick : std_logic;
  signal signal_parallel  : std_logic_vector(9 downto 0);
  signal signal_shift     : std_logic;

-------------------------------------------------------------------------------

begin

  -- instance "flanken_detect_1"
  flanken_detect_1 : flanken_detect
    port map (
      serdata_sync => serial_in,
      Clk          => clk,
      reset_n      => reset_n,
      fall_edge    => signal_flank);

  -- instance "baud_tick_1"
  baud_tick_1 : baud_tick
    port map (
      Clk       => clk,
      start_bit => signal_bit,
      reset_n   => reset_n,
      baud_tick => signal_baud_tick);
  
  -- instance "uart_controller_fsm_1"
  uart_controller_fsm_1 : uart_controller_fsm
    port map (
      Clk          => clk,
      baud_tick_i  => signal_baud_tick,
      reset_n      => reset_n,
      fall_edge    => signal_flank,
      parallel_i   => signal_parallel,
      start_bit_o  => signal_bit,
      data_valid_o => data_valid,
      shift_enable => signal_shift);

  -- instance "shiftreg_s2p_1"
  shiftreg_s2p_1 : shiftreg_s2p
    port map (
      Clk          => clk,
      reset_n      => reset_n,
      shift_enable => signal_shift,
      parallel_out => signal_parallel,
      serdata_sync => serial_in);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Zuweisung
  parallel_out <= signal_parallel(8 downto 1);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end str;
