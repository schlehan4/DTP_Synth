-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : uart_controller_fsm.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_controller_fsm is
  
  port(Clk          : in  std_logic;
       baud_tick_i  : in  std_logic;
       reset_n      : in  std_logic;
       fall_edge    : in  std_logic;
       parallel_i   : in  std_logic_vector (9 downto 0);
       start_bit_o  : out std_logic;
       data_valid_o : out std_logic;
       shift_enable : out std_logic
       );
  
end uart_controller_fsm;

-------------------------------------------------------------------------------

architecture rtl of uart_controller_fsm is

  --Signals & Types
  type uart_type is (idle, prepare_rx, wait_rx_byte, check_rx);
  signal uart_state, next_uart_state : uart_type;
  signal bit_count, next_bit_count   : unsigned(3 downto 0);

-------------------------------------------------------------------------------
  
begin

  reg_proc : process(all)
  begin
    next_uart_state <= uart_state;                           --Anfangsbedingung

    case uart_state is
      
      when idle =>
        if fall_edge = '1' then
          next_uart_state <= prepare_rx;
        end if;
      when prepare_rx   =>
        next_uart_state <= wait_rx_byte;        
      when wait_rx_byte =>              
        if bit_count = 1 and baud_tick_i = '1' then
          next_uart_state <= check_rx;
        end if;
      when others => next_uart_state <= idle;
                     
    end case;
  end process reg_proc;


  clok : process(all)
  begin
    
    if reset_n = '0' then
      uart_state <= idle;
      bit_count  <= (others => '0');
    elsif rising_edge(Clk) then
      bit_count  <= next_bit_count;
      uart_state <= next_uart_state;
    end if;
    
  end process clok;

  
  bit_counter : process (all)
  begin
    
    if uart_state = prepare_rx then
      next_bit_count <= to_unsigned(10, 4);  --Zahl 10 mit 4 Bits dargestellt     
    elsif                           
      bit_count > 0 and baud_tick_i = '1'then
      next_bit_count <= bit_count-1;     
    else
      next_bit_count <= bit_count;     
    end if;
    
  end process bit_counter;

  
  out_logic : process(all)
  begin
    start_bit_o  <= '0';                ------Anfangsbedingungen
    shift_enable <= '0';                ------ "
    data_valid_o <= '0';                ------ "

    case uart_state is
      
      when prepare_rx => start_bit_o <= '1';
      when wait_rx_byte =>
        if baud_tick_i = '1' then
          shift_enable <= '1';
        end if;
      when check_rx =>
        if parallel_i (0) = '0' and parallel_i (9) = '1' then
          data_valid_o <= '1';
        end if;
      when others => NULL;
                     
    end case;
  end process out_logic;


end rtl;
