-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : midi_fsm_controller.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tone_gen_pkg.all;


entity midi_fsm_controller is

  port(rx_data        : in  std_logic_vector(7 downto 0); 
       rx_data_valid  : in  std_logic;
       clk12_m        : in  std_logic;
       reset          : in  std_logic;
       midi_out_array : out t_midi_array
       );

end midi_fsm_controller;

-------------------------------------------------------------------------------

architecture main of midi_fsm_controller is

  --Signals & Constants
  type midi_type is (wait_status, wait_data_1, wait_data_2);
  signal midi_state                      : midi_type;
  signal next_midi_state                 : midi_type;
  signal flagreg, next_flagreg           : std_logic;
  signal data_one_reg, next_data_one_reg : std_logic_vector(6 downto 0);
  signal data_two_reg, next_data_two_reg : std_logic_vector(6 downto 0);
  signal status_reg, next_status_reg     : std_logic_vector(2 downto 0);
  signal out_reg, next_out_reg           : t_midi_array;

  constant SET_NOTE : std_logic_vector(2 downto 0) := "001";
  constant DEL_NOTE : std_logic_vector(2 downto 0) := "000";

-------------------------------------------------------------------------------

begin

  midi_logik : process(all)
  begin
    --default
    next_midi_state   <= midi_state;
    next_status_reg   <= status_reg;
    next_flagreg      <= '0';
    next_data_one_reg <= data_one_reg;
    next_data_two_reg <= data_two_reg;

    case midi_state is

-------------------------------------------------------------------------------
      --wait state
-------------------------------------------------------------------------------
      when wait_status =>
        if rx_data_valid = '1' and rx_data(7) = '0' then
          next_midi_state   <= wait_data_2;
          next_data_one_reg <= rx_data(6 downto 0);
        elsif rx_data_valid = '1' and rx_data(7) = '1' then  
          next_midi_state <= wait_data_1;
          next_status_reg <= rx_data(6 downto 4);
        else
          next_midi_state <= wait_status;
        end if;

-------------------------------------------------------------------------------
      --wait data one
-------------------------------------------------------------------------------
      when wait_data_1 =>
        if rx_data_valid = '1' then
          next_data_one_reg <= rx_data(6 downto 0);
          next_midi_state   <= wait_data_2;
        else
          next_midi_state <= wait_data_1;
        end if;


------------------------------------------------------------------------------
        --wait data two
------------------------------------------------------------------------------
      when wait_data_2 =>
        if rx_data_valid = '1' then
          next_data_two_reg <= rx_data(6 downto 0);
          next_flagreg      <= '1';     
          next_midi_state   <= wait_status;
        else
          next_midi_state <= wait_data_2;
        end if;
------------------------------------------------------------------------------
        --others
------------------------------------------------------------------------------
        
      when others => next_midi_state <= midi_state;
    end case;
  end process midi_logik;


  out_array : process(all)
    --variable
    variable note_available : std_logic;
    variable note_written   : std_logic;

  begin
    --defaults
    next_out_reg   <= out_reg;
    note_available := '0';
    note_written   := '0';

    --delete note
    if flagreg = '1' then
      for i in 0 to 9 loop
        if out_reg(i).number = data_one_reg and out_reg(i).valid = '1' then  
          note_available := '1'; --compares played note to regnote
          if status_reg = DEL_NOTE then
            next_out_reg(i).valid <= '0';  --turns note  off
          elsif status_reg = SET_NOTE and data_two_reg = "0000000" then
            next_out_reg(i).valid <= '0';  --turns note off if velocity is 0
          end if;
        end if;
      end loop;

      --set note
      if note_available = '0' then
        for i in 0 to 9 loop
          if note_written = '0' then
            if (out_reg(i).valid = '0' or i = 9) and status_reg = SET_NOTE then
              next_out_reg(i).number   <= data_one_reg; 
              next_out_reg(i).velocity <= data_two_reg;
              next_out_reg(i).valid    <= '1';
              note_written             := '1';
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process out_array;


  --FF midi_state
  flip_flops : process(all)
  begin
    if reset = '0' then
      midi_state   <= wait_status;
      status_reg   <= (others => '0');
      flagreg      <= '0';
      data_one_reg <= (others => '0');
      data_two_reg <= (others => '0');
      out_reg      <= (others => NOTE_INIT_VALUE);

      
    elsif rising_edge(clk12_m) then
      midi_state   <= next_midi_state;
      status_reg   <= next_status_reg;
      flagreg      <= next_flagreg;
      data_one_reg <= next_data_one_reg;
      data_two_reg <= next_data_two_reg;
      out_reg      <= next_out_reg;
    end if;
  end process flip_flops;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Zuweisung
  midi_out_array <= out_reg;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
end main;
