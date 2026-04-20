-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : dds.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;


entity dds is

  port (reset_n    : in  std_logic;
        clk_12m    : in  std_logic;
        load_i     : in  std_logic;
        tone_on_i  : in  std_logic;
        instr      : in  std_logic_vector(2 downto 0);
        attenu_i   : in  std_logic_vector(1 downto 0);
        phi_incr_i : in  std_logic_vector(N_CUM-1 downto 0);
        dds_o      : out std_logic_vector(N_AUDIO-1 downto 0)
        );

end entity dds;

-------------------------------------------------------------------------------

architecture str of dds is
  component phase_counter is
    port (reset_n    : in  std_logic;
          clk_12m    : in  std_logic;
          load_i     : in  std_logic;
          phi_incr_i : in  std_logic_vector(N_CUM-1 downto 0);
          count_o    : out std_logic_vector(N_CUM-1 downto 0)
          );
  end component phase_counter;

  
  -- Signals
  signal lut_addr     : unsigned(N_CUM-1 downto 0);
  signal unsig_to_int : integer range 0 to L-1;
  signal std_to_unsig : std_logic_vector (N_CUM-1 downto 0);
  signal lut_val      : signed(N_AUDIO-1 downto 0);
  signal atte         : integer range 0 to 4;

-------------------------------------------------------------------------------

begin 

  counter_register : phase_counter
    port map (
      reset_n    => reset_n,
      clk_12m    => clk_12m,
      load_i     => load_i,
      phi_incr_i => phi_incr_i,
      count_o    => std_to_unsig
      );

  casee : process(all)
  begin
    atte <= to_integer(unsigned(attenu_i));

    if tone_on_i = '1' then             --kommt von MSB der Midipackete
      
      case atte is                      --Lautstärkereglung durch Verschiebung
                                        --von lut_val
        when 0      => dds_o <= std_logic_vector(shift_right(lut_val, 3));
        when 1      => dds_o <= std_logic_vector(shift_right(lut_val, 5));
        when 2      => dds_o <= std_logic_vector(shift_right(lut_val, 6));
        when 3      => dds_o <= std_logic_vector(shift_right(lut_val, 7));
        when others => dds_o <= (others => '0');
      end case;
      
    else dds_o <= (others => '0');
    end if;
  end process casee;


  tone : process(all)
  begin
    case instr is                       -- Ansteuerung verschiedener Instrumente
      when "000" =>
        lut_addr     <= unsigned(std_to_unsig(N_CUM-1 downto 0));
        unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
        lut_val      <= to_signed(LUT_SINUS(unsig_to_int), N_AUDIO);  --Sinus

      when "001" => lut_addr <= unsigned(std_to_unsig(N_CUM-1 downto 0));
                    unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
                    lut_val      <= to_signed(LUT_TRUMPET(unsig_to_int), N_AUDIO);--Trompete

      when "010" => lut_addr <= unsigned(std_to_unsig(N_CUM-1 downto 0));
                    unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
                    lut_val      <= to_signed(LUT_PIANO(unsig_to_int), N_AUDIO);--Piano                  

      when "011" => lut_addr <= unsigned(std_to_unsig(N_CUM-1 downto 0));
                    unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
                    lut_val      <= to_signed(LUT_ORGAN(unsig_to_int), N_AUDIO);--Orgel

      when "100" => lut_addr <= unsigned(std_to_unsig(N_CUM-1 downto 0));
                    unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
                    lut_val      <= to_signed(LUT_OBOE(unsig_to_int), N_AUDIO);--Oboe

      when others => lut_addr <= unsigned(std_to_unsig(N_CUM-1 downto 0));
                     unsig_to_int <= to_integer(lut_addr (N_CUM-1 downto N_CUM - 8));
                     lut_val      <= to_signed(LUT_SINUS(unsig_to_int), N_AUDIO);
    end case;
  end process tone;

end architecture str;
