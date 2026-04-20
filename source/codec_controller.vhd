-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : codec_controller.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.reg_table_pkg.all;


entity codec_controller is

  port(initialise_i  : in  std_logic;
       write_done_i  : in  std_logic;
       ack_error_i   : in  std_logic;
       clock         : in  std_logic;
       reset_n       : in  std_logic;
       write_o       : out std_logic;
       write_data_o  : out std_logic_vector(15 downto 0);
       state_control : in  std_logic_vector(2 downto 0)
       );
  
end codec_controller;

-------------------------------------------------------------------------------

architecture rtl of codec_controller is

  -- Signals & Types
  type codec_state is (idle, start_write, wait_state);
  signal current_state : codec_state;
  signal next_state    : codec_state;
  signal count         : integer range 0 to 9;
  signal next_count    : integer range 0 to 9;

-------------------------------------------------------------------------------
  
begin

  send : process(all)
  begin

    case state_control is  --Einstellungen für verschiedene Kommandos(von reg_table_pkg)
      when "001"  => write_data_o <= "000" & std_logic_vector(to_unsigned (count, 4)) & C_W8731_ANALOG_BYPASS(count);
      when "011"  => write_data_o <= "000" & std_logic_vector(to_unsigned (count, 4)) & C_W8731_ANALOG_MUTE_RIGHT(count);
      when "101"  => write_data_o <= "000" & std_logic_vector(to_unsigned (count, 4)) & C_W8731_ANALOG_MUTE_LEFT(count);
      when "111"  => write_data_o <= "000" & std_logic_vector(to_unsigned (count, 4)) & C_W8731_ANALOG_MUTE_BOTH(count);
      when others => write_data_o <= "000" & std_logic_vector(to_unsigned (count, 4)) & C_W8731_ADC_DAC_0DB_48K(count);
    end case;

  end process;

  
  cc_fsm : process(all)                 --Codec Controller State_Machine
  begin
    write_o    <= '0';                  -- Anfangsbedingung
    next_state <= current_state;        -- "
    next_count <= count;                -- "

    case current_state is
      
      when idle =>
        if(initialise_i = '0')then      --Bei initialese HIGH (low-Aktiv)
          next_state <= start_write;
          next_count <= 0;
        else
          next_state <= idle;          
        end if;
        
      when start_write =>               --Nur ein Taktzyklus in
        next_state <= wait_state;       --start_write 'state'
        write_o    <= '1';
        
      when wait_state =>
        if ((write_done_i = '1') and (count >= 9))or (ack_error_i = '1')then
          next_state <= idle;
        elsif(write_done_i = '1')and (count < 9) then  --bei write done High
          next_count <= count + 1;
          next_state <= start_write;
        else                            --oder zu idle wenn count ueber 9
          next_state <= wait_state;
          next_count <= count;
        end if;
        
      when others => null;
    end case;
    
  end process cc_fsm;


  ff : process(all)
  begin
    
    if reset_n = '0' then
      count         <= 0;
      current_state <= idle;
    elsif rising_edge(clock) then
      current_state <= next_state;
      count         <= next_count;
    end if;
    
  end process;

end architecture;
