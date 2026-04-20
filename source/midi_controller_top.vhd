-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : midi_controller_top.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;


entity midi_controller_top is

  port (clk            : in  std_logic;
        reset_n        : in  std_logic;
        GPIO_26        : in  std_logic;
        data_out_array : out t_midi_array
        );

end entity midi_controller_top;

-------------------------------------------------------------------------------

architecture str of midi_controller_top is
  component uart_top is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      serial_in    : in  std_logic;
      parallel_out : out std_logic_vector(7 downto 0);
      data_valid   : out std_logic);
  end component uart_top;

  component midi_fsm_controller is
    port (
      rx_data        : in  std_logic_vector(7 downto 0);
      rx_data_valid  : in  std_logic;
      clk12_m        : in  std_logic;
      reset          : in  std_logic;
      midi_out_array : out t_midi_array
      );
  end component midi_fsm_controller;


  -- Signals
  signal signal_parallel : std_logic_vector(7 downto 0);
  signal signal_valid    : std_logic;
  signal midi_out_array  : t_midi_array;

------------------------------------------------------------------------------

begin 

  -- instance "uart_top_1"
  uart_top_1 : uart_top
    port map (
      clk          => clk,
      reset_n      => reset_n,
      serial_in    => GPIO_26,
      parallel_out => signal_parallel,
      data_valid   => signal_valid);

  -- instance "midi_fsm_controller_1"
  midi_fsm_controller_1 : midi_fsm_controller
    port map (
      rx_data        => signal_parallel,
      rx_data_valid  => signal_valid,
      clk12_m        => clk,
      reset          => reset_n,
      midi_out_array => midi_out_array);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisungen
  data_out_array <= midi_out_array;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end str;
