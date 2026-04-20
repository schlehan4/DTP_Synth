-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : synthi_top.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.reg_table_pkg.all;
use work.tone_gen_pkg.all;


entity synthi_top is

  port (CLOCK_50 : in std_logic;                      -- DE2 clock from xtal 50MHz
        KEY_0    : in std_logic;                      -- DE2 low_active input buttons
        KEY_1    : in std_logic;                      -- DE2 low_active input buttons
        SW       : in std_logic_vector(17 downto 0);  -- DE2 input switches
        GPIO_26  : in std_logic;                      -- midi_uart serial_input

        AUD_ADCDAT  : in    std_logic;                -- audio serial data from Codec-ADC
        I2C_SDAT    : inout std_logic;                 -- data  from I2C master block
        AUD_XCK     : out   std_logic;                -- master clock for Audio Codec
        AUD_DACDAT  : out   std_logic;                -- audio serial data to Codec-DAC
        AUD_BCLK    : out   std_logic;                -- bit clock for audio serial data
        AUD_DACLRCK : out   std_logic;                -- left/right word select for Codec-DAC
        AUD_ADCLRCK : out   std_logic;                -- left/right word select for Codec-ADC
        I2C_SCLK    : out   std_logic                -- clock from I2C master block
        );

end entity synthi_top;

-------------------------------------------------------------------------------

architecture struct of synthi_top is
  component i2s_master is
    port (
      clk_12m     : in  std_logic;
      reset_n     : in  std_logic;
      load_o      : out std_logic;
      adcdat_pl_o : out std_logic_vector(15 downto 0);
      adcdat_pr_o : out std_logic_vector(15 downto 0);
      dacdat_pl_i : in  std_logic_vector(15 downto 0);
      dacdat_pr_i : in  std_logic_vector(15 downto 0);
      dacdat_s_o  : out std_logic;
      bclk_o      : out std_logic;
      ws_o        : out std_logic;
      adcdat_s_i  : in  std_logic);
  end component i2s_master;
  
  component path_control is
    port (
      sw_sync_3   : in  std_logic;
      dds_l_i     : in  std_logic_vector(15 downto 0);
      dds_r_i     : in  std_logic_vector(15 downto 0);
      adcdat_pl_i : in  std_logic_vector(15 downto 0);
      adcdat_pr_i : in  std_logic_vector(15 downto 0);
      dacdat_pl_o : out std_logic_vector(15 downto 0);
      dacdat_pr_o : out std_logic_vector(15 downto 0));
  end component path_control;
  
  component i2c_master is
    port (
      clk          : in    std_logic;
      reset_n      : in    std_logic;   
      write_i      : in    std_logic;
      write_data_i : in    std_logic_vector(15 downto 0);
      sda_io       : inout std_logic;
      scl_o        : out   std_logic;
      write_done_o : out   std_logic;
      ack_error_o  : out   std_logic);
  end component i2c_master;

  component codec_controller is
    port (
      initialise_i  : in  std_logic;
      write_done_i  : in  std_logic;
      ack_error_i   : in  std_logic;
      clock         : in  std_logic;
      reset_n       : in  std_logic;
      write_o       : out std_logic;
      write_data_o  : out std_logic_vector(15 downto 0);
      state_control : in  std_logic_vector(2 downto 0));
  end component codec_controller;

  component infrastructure is
    port (
      CLOCK_50     : in  std_logic;
      KEY          : in  std_logic_vector(1 downto 0);
      GPIO_26      : in  std_logic;
      SW           : in  std_logic_vector(17 downto 0);
      clk_12m      : out std_logic;
      reset_n      : out std_logic;
      key_1_sync   : out std_logic;
      gpio_26_sync : out std_logic;
      sw_sync      : out std_logic_vector(17 downto 0));
  end component infrastructure;

  component midi_controller_top is
    port (
      clk            : in  std_logic;
      reset_n        : in  std_logic;
      GPIO_26        : in  std_logic;
      data_out_array : out t_midi_array);
  end component midi_controller_top;

  component tone_generator is
    port (
      clk_12m        : in  std_logic;
      reset_n        : in  std_logic;
      load_i         : in  std_logic;
      strobe_i       : in  std_logic;
      attenu_i       : in  std_logic_vector(1 downto 0);
      instr          : in  std_logic_vector(2 downto 0);
      data_vector_in : in  t_midi_array;
      ton_gen_o      : out std_logic_vector(15 downto 0));
  end component tone_generator;

  --Signals & Types
  signal Clock_intern   : std_logic;
  signal ws_o_sig       : std_logic;
  signal reset_n_intern : std_logic;
  signal pr_o_sig       : std_logic_vector(15 downto 0);
  signal pr_i_sig       : std_logic_vector(15 downto 0);
  signal pl_o_sig       : std_logic_vector(15 downto 0);
  signal pl_i_sig       : std_logic_vector(15 downto 0);
  signal sw_sync_1      : std_logic_vector (17 downto 0);
  signal write_1        : std_logic;
  signal write_done     : std_logic;
  signal ack_error      : std_logic;
  signal write_data     : std_logic_vector(15 downto 0);
  signal key_ini_1      : std_logic;
  signal dds            : std_logic_vector(15 downto 0);
  signal dds_l          : std_logic_vector(15 downto 0);
  signal dds_r          : std_logic_vector(15 downto 0);
  signal gpio_26_sync   : std_logic;
  signal data_array     : t_midi_array;

-------------------------------------------------------------------------------

begin

  -- instance "i2s_master_1"
  i2s_master_1 : i2s_master
    port map (
      clk_12m     => Clock_intern,
      reset_n     => reset_n_intern,
      load_o      => open,
      adcdat_pl_o => pl_o_sig,
      adcdat_pr_o => pr_o_sig,
      dacdat_pl_i => pl_i_sig,
      dacdat_pr_i => pr_i_sig,
      dacdat_s_o  => AUD_DACDAT,
      bclk_o      => AUD_BCLK,
      ws_o        => ws_o_sig,
      adcdat_s_i  => AUD_ADCDAT);

  -- instance "path_control_1"
  path_control_1 : path_control
    port map (
      sw_sync_3   => sw_sync_1(3),
      dds_l_i     => dds_l,
      dds_r_i     => dds_r,
      adcdat_pl_i => pl_o_sig,
      adcdat_pr_i => pr_o_sig,
      dacdat_pl_o => pl_i_sig,
      dacdat_pr_o => pr_i_sig);

  -- instance "i2c_master_1"
  i2c_master_1 : i2c_master
    port map (
      clk          => Clock_intern,
      reset_n      => reset_n_intern,
      write_i      => write_1,
      write_data_i => write_data,
      sda_io       => I2C_SDAT,
      scl_o        => I2C_SCLK,
      write_done_o => write_done,
      ack_error_o  => ack_error);

  -- instance "codec_controller_1"
  codec_controller_1 : codec_controller
    port map (
      initialise_i  => key_ini_1,
      write_done_i  => write_done,
      ack_error_i   => ack_error,
      clock         => Clock_intern,
      reset_n       => reset_n_intern,
      write_o       => write_1,
      write_data_o  => write_data,
      state_control => sw_sync_1(2 downto 0));

  -- instance "infrastructure_1"
  infrastructure_1 : infrastructure
    port map (
      CLOCK_50     => CLOCK_50,
      KEY          => (KEY_1 & KEY_0),
      GPIO_26      => GPIO_26,          
      SW           => SW,
      clk_12m      => Clock_intern,
      reset_n      => reset_n_intern,
      key_1_sync   => key_ini_1,
      gpio_26_sync => gpio_26_sync,     
      sw_sync      => sw_sync_1);

  -- instance "midi_controller_top_1"
  midi_controller_top_1 : midi_controller_top
    port map (
      clk            => Clock_intern,
      reset_n        => reset_n_intern,
      GPIO_26        => GPIO_26,
      data_out_array => data_array);

  -- instance "tone_generator_1"
  tone_generator_1 : tone_generator
    port map (
      clk_12m        => Clock_intern,
      reset_n        => reset_n_intern,
      load_i         => sw_sync_1(15),
      attenu_i       => sw_sync_1(16) & sw_sync_1(17),
      instr          => sw_sync_1(13 downto 11),
      strobe_i       => sw_sync_1(14),
      data_vector_in => data_array,
      ton_gen_o      => dds);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Zuweisungen
  AUD_XCK     <= Clock_intern;
  AUD_DACLRCK <= ws_o_sig;
  AUD_ADCLRCK <= ws_o_sig;
  dds_l       <= dds;
  dds_r       <= dds;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
end architecture struct;
