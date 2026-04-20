-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : i2s_master.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity i2s_master is

  port(clk_12m : in  std_logic;         -- 12.5M Clock
       reset_n : in  std_logic;         -- Reset or init used for re-initialisation
       load_o  : out std_logic;         -- Pulse once per audio frame 1/48kHz

       --Verbindungen zum audio_controller
       adcdat_pl_o : out std_logic_vector(15 downto 0);  --Ausgang zum audio_controller
       adcdat_pr_o : out std_logic_vector(15 downto 0);

       dacdat_pl_i : in std_logic_vector(15 downto 0);   --Eingang vom audio_controller
       dacdat_pr_i : in std_logic_vector(15 downto 0);

       --Verbindungen zum Audio-Codec
       dacdat_s_o : out std_logic;      --Serielle Daten Ausgang
       bclk_o     : out std_logic;      --Bus-Clock
       ws_o       : out std_logic;      --WordSelect (Links/Rechts)
       adcdat_s_i : in  std_logic       --Serielle Daten Eingang
       );

end i2s_master;

-------------------------------------------------------------------------------

architecture rtl of i2s_master is
  component bckl_gen is
    port (
      reset_n : in  std_logic;
      clk_12m : in  std_logic;
      bclk    : out std_logic);
  end component bckl_gen;

  component bit_cntr is
    generic (width : positive);
    port (
      initialise_i : in  std_logic;
      reset_n      : in  std_logic;
      clk_12m      : in  std_logic;
      bclk         : in  std_logic;
      bit_count_o  : out std_logic_vector(width-1 downto 0));
  end component bit_cntr;

  component i2s_decoder is
    generic (
      width : positive);
    port (
      bit_count_i : in  std_logic_vector(width-1 downto 0);
      load        : out std_logic;
      shift_l     : out std_logic;
      shift_r     : out std_logic;
      ws          : out std_logic);
  end component i2s_decoder;

  component p2s is
    port (
      dacdat_px_i : in  std_logic_vector(15 downto 0);
      reset_n     : in  std_logic;
      clk_12m     : in  std_logic;
      load        : in  std_logic;
      shift       : in  std_logic;
      bclk        : in  std_logic;
      ser_out     : out std_logic);
  end component p2s;

  component s2p is
    port (
      adcdat_s_i : in  std_logic;
      reset_n    : in  std_logic;
      clk_12m    : in  std_logic;
      shift      : in  std_logic;
      bclk       : in  std_logic;
      adcdat_p_o : out std_logic_vector(15 downto 0));
  end component s2p;

  component L_R_muxer is
    port (
      ser_i_l    : in  std_logic;
      ser_i_r    : in  std_logic;
      ws         : in  std_logic;
      dacdat_s_o : out std_logic);
  end component L_R_muxer;


  -- Signals
  signal bclk      : std_logic;
  signal bit_count : std_logic_vector(6 downto 0);
  signal load      : std_logic;
  signal shift_l   : std_logic;
  signal shift_r   : std_logic;
  signal ws_int    : std_logic;
  signal ser_out_l : std_logic;
  signal ser_out_r : std_logic;

-------------------------------------------------------------------------------

begin

  -- instance "bclk_gen_1"
  bclk_gen_1 : bckl_gen
    port map (
      reset_n => reset_n,
      clk_12m => clk_12m,
      bclk    => bclk);

  -- instance "bit_cntr_1"
  bit_cntr_1 : bit_cntr
    generic map (width => 7)
    port map (
      initialise_i => '1',
      reset_n      => reset_n,
      clk_12m      => clk_12m,
      bclk         => bclk,
      bit_count_o  => bit_count);

  -- instance "i2s_decoder"
  i2s_decoder_1 : i2s_decoder
    generic map (width => 7)
    port map (
      bit_count_i => bit_count,
      load        => load,
      shift_l     => shift_l,
      shift_r     => shift_r,
      ws          => ws_int);

  -- instance "p2s_1"
  p2s_1 : p2s
    port map (
      dacdat_px_i => dacdat_pl_i,
      reset_n     => reset_n,
      clk_12m     => clk_12m,
      load        => load,
      shift       => shift_l,
      bclk        => bclk,
      ser_out     => ser_out_l);

  -- instance "s2p_1"
  s2p_1 : s2p
    port map (
      adcdat_s_i => adcdat_s_i,
      reset_n    => reset_n,
      clk_12m    => clk_12m,
      shift      => shift_l,
      bclk       => bclk,
      adcdat_p_o => adcdat_pl_o);

  -- instance "s2p_2"
  s2p_2 : s2p
    port map (
      adcdat_s_i => adcdat_s_i,
      reset_n    => reset_n,
      clk_12m    => clk_12m,
      shift      => shift_r,
      bclk       => bclk,
      adcdat_p_o => adcdat_pr_o);

  -- instance "p2s_2"
  p2s_2 : p2s
    port map (
      dacdat_px_i => dacdat_pr_i,
      reset_n     => reset_n,
      clk_12m     => clk_12m,
      load        => load,
      shift       => shift_r,
      bclk        => bclk,
      ser_out     => ser_out_r);

  -- instance "l_r_muxer_1"
  l_r_muxer_1 : l_r_muxer
    port map (
      ser_i_l    => ser_out_l,
      ser_i_r    => ser_out_r,
      ws         => ws_int,
      dacdat_s_o => dacdat_s_o);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------  
-- Zuweisungen
  load_o <= load;
  ws_o   <= ws_int;
  bclk_o <= bclk;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end rtl;
