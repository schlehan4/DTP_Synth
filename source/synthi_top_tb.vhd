-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project: Synthesizer
-- Group  : Samuel Dozio, Hannah Schlemper, Tim Siegrist und Nicolas Koller
-- Date   : 10.06.2019
-- File   : synthi_top_tb.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;
use work.simulation_pkg.all;
use work.standard_driver_pkg.all;
use work.user_driver_pkg.all;
use work.reg_table_pkg.all;


entity synthi_top_tb is

end entity synthi_top_tb;

-------------------------------------------------------------------------------

architecture struct of synthi_top_tb is
  component synthi_top is
    port (
      CLOCK_50     : in    std_logic;
      KEY_0        : in    std_logic;
      KEY_1        : in    std_logic;
      SW           : in    std_logic_vector(17 downto 0);  
      GPIO_26      : in    std_logic;   
      AUD_XCK      : out   std_logic;
      AUD_DACDAT   : out   std_logic;   
      AUD_BCLK     : out   std_logic;   
      AUD_DACLRCK  : out   std_logic;   
      AUD_ADCLRCK  : out   std_logic;   
      AUD_ADCDAT   : in    std_logic;  
      I2C_SCLK     : out   std_logic;
      I2C_SDAT     : inout std_logic);
  end component synthi_top;

  component i2c_slave_bfm is
    generic (
      verbose : boolean);
    port (
      AUD_XCK   : in    std_logic;
      I2C_SDAT  : inout std_logic := 'H';
      I2C_SCLK  : inout std_logic := 'H';
      reg_data0 : out   std_logic_vector(31 downto 0);
      reg_data1 : out   std_logic_vector(31 downto 0);
      reg_data2 : out   std_logic_vector(31 downto 0);
      reg_data3 : out   std_logic_vector(31 downto 0);
      reg_data4 : out   std_logic_vector(31 downto 0);
      reg_data5 : out   std_logic_vector(31 downto 0);
      reg_data6 : out   std_logic_vector(31 downto 0);
      reg_data7 : out   std_logic_vector(31 downto 0);
      reg_data8 : out   std_logic_vector(31 downto 0);
      reg_data9 : out   std_logic_vector(31 downto 0));
  end component i2c_slave_bfm;

  
  -- Signals & Types & Constants
  signal CLOCK_50     : std_logic;
  signal KEY_0        : std_logic;
  signal KEY_1        : std_logic;
  signal SW           : std_logic_vector(17 downto 0);
  signal GPIO_26      : std_logic;
  signal gpio_26_sync : std_logic;
  signal AUD_XCK      : std_logic;
  signal AUD_DACDAT   : std_logic;
  signal AUD_BCLK     : std_logic;
  signal AUD_DACLRCK  : std_logic;
  signal AUD_ADCLRCK  : std_logic;
  signal AUD_ADCDAT   : std_logic :='0';
  signal I2C_SCLK     : std_logic;
  signal I2C_SDAT     : std_logic;

  signal reg_data0 : std_logic_vector(31 downto 0);
  signal reg_data1 : std_logic_vector(31 downto 0);
  signal reg_data2 : std_logic_vector(31 downto 0);
  signal reg_data3 : std_logic_vector(31 downto 0);
  signal reg_data4 : std_logic_vector(31 downto 0);
  signal reg_data5 : std_logic_vector(31 downto 0);
  signal reg_data6 : std_logic_vector(31 downto 0);
  signal reg_data7 : std_logic_vector(31 downto 0);
  signal reg_data8 : std_logic_vector(31 downto 0);
  signal reg_data9 : std_logic_vector(31 downto 0);

  signal dacdat_check : std_logic_vector(31 downto 0);
  signal switch       : std_logic_vector(31 downto 0);

  constant clock_freq   : natural := 50_000_000;
  constant clock_period : time    := 1000 ms/clock_freq;

-------------------------------------------------------------------------------

begin 

  DUT : synthi_top
    port map (
      CLOCK_50     => CLOCK_50,
      KEY_0        => KEY_0,
      KEY_1        => KEY_1,
      SW           => SW,
      GPIO_26      => GPIO_26,
      AUD_XCK      => AUD_XCK,
      AUD_DACDAT   => AUD_DACDAT,
      AUD_BCLK     => AUD_BCLK,
      AUD_DACLRCK  => AUD_DACLRCK,
      AUD_ADCLRCK  => AUD_ADCLRCK,
      AUD_ADCDAT   => AUD_ADCDAT,
      I2C_SCLK     => I2C_SCLK,
      I2C_SDAT     => I2C_SDAT);

  readcmd : process
    -- This process loops through a file and reads one line
    -- at a time, parsing the line to get the values and
    -- expected result.

    variable cmd          : string(1 to 7);  --stores test command
    variable line_in      : line;       --stores the to be processed line     
    variable tv           : test_vect;  --stores arguments 1 to 4
    variable lincnt       : integer := 0;  --counts line number in testcase file
    variable fail_counter : integer := 0;  --counts failed tests

-------------------------------------------------------------------------------

  begin
    -------------------------------------
    -- Open the Input and output files
    -------------------------------------
    FILE_OPEN(cmdfile, "../testcase.dat", read_mode);
    FILE_OPEN(outfile, "../results.dat", write_mode);

    -------------------------------------
    -- Start the loop
    -------------------------------------

    loop

      --------------------------------------------------------------------------
      -- Check for end of test file and print out results at the end
      --------------------------------------------------------------------------
      if endfile(cmdfile) then          -- Check EOF
        end_simulation(fail_counter);
        exit;
      end if;
      --------------------------------------------------------------------------
      -- Read all the argumnents and commands
      --------------------------------------------------------------------------

      readline(cmdfile, line_in);       -- Read a line from the file
      lincnt := lincnt + 1;


      next when line_in'length = 0;     -- Skip empty lines
      next when line_in.all(1) = '#';   -- Skip lines starting with #

      read_arguments(tv, line_in, cmd);
      tv.clock_period := clock_period;  -- set clock period for driver calls


      
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
      -------------------------------------
      -- Reset the circuit
      -------------------------------------

      if cmd = string'("rst_sim") then      -- Restart
        rst_sim(tv, key_0);

      elsif cmd = string'("run_sim") then   -- Start
        run_sim(tv);
        
      elsif cmd = string'("ini_cod") then   --ini_cod ist nur für die ersten
        ini_cod(tv, sw(2 downto 0), KEY_1); --drei Schalter nutzbar, dannach
                                            --brauchen wir gpi_sim
-------------------------------------------------------------------------------
------MS 1
-------------------------------------------------------------------------------
      elsif cmd = string'("i2c_ch0") then
        gpo_chk(tv, reg_data0);
      elsif cmd = string'("i2c_ch1") then
        gpo_chk(tv, reg_data1);
      elsif cmd = string'("i2c_ch2") then
        gpo_chk(tv, reg_data2);
      elsif cmd = string'("i2c_ch3") then
        gpo_chk(tv, reg_data3);
      elsif cmd = string'("i2c_ch4") then
        gpo_chk(tv, reg_data4);
      elsif cmd = string'("i2c_ch5") then
        gpo_chk(tv, reg_data5);
      elsif cmd = string'("i2c_ch6") then
        gpo_chk(tv, reg_data6);
      elsif cmd = string'("i2c_ch7") then
        gpo_chk(tv, reg_data7);
      elsif cmd = string'("i2c_ch8") then
        gpo_chk(tv, reg_data8);
      elsif cmd = string'("i2c_ch9") then
        gpo_chk(tv, reg_data9);
        
-------------------------------------------------------------------------------
------MS 2
------------------------------------------------------------------------------  
      elsif cmd = string'("gpi_sim") then
        gpi_sim(tv, switch);
        
      elsif cmd = string'("i2s_sim") then
        i2s_sim(tv, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT);

      elsif cmd = string'("i2s_ch1") then
        i2s_chk(tv, AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, dacdat_check);
       
-------------------------------------------------------------------------------
------MS 3
-------------------------------------------------------------------------------
		
--      simuliert sw(17..15)und (10..4) mit befehl aus MS 2:
        
--      elsif cmd = string'("gpi_sim") then 
--      gpi_sim(tv, switch)

-------------------------------------------------------------------------------
------MS 4 
-------------------------------------------------------------------------------
       elsif cmd = string'("uar_sim") then
         uar_sim(tv, GPIO_26);

       elsif cmd = string'("run_sim") then
        run_sim(tv);

       elsif cmd = string'("uar_sim") then
         uar_sim(tv, GPIO_26);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
 


      else
        assert false
          report "Unknown Command"
          severity failure;
      end if;

      if tv.fail_flag = true then       --count failures in tests
        fail_counter := fail_counter + 1;
      else fail_counter := fail_counter;
      end if;
    end loop;  --finished processing command line

    wait;  -- to avoid infinite loop simulator warning

  end process;

  clkgen : process
    
  begin
    clock_50 <= '0';
    wait for clock_period/2;
    clock_50 <= '1';
    wait for clock_period/2;

  end process clkgen;

  -- instance "i2c_slave_bfm_1"
  i2c_slave_bfm_1 : i2c_slave_bfm
    generic map (
      verbose => false)
    port map (
      AUD_XCK   => AUD_XCK,
      I2C_SDAT  => I2C_SDAT,
      I2C_SCLK  => I2C_SCLK,
      reg_data0 => reg_data0,
      reg_data1 => reg_data1,
      reg_data2 => reg_data2,
      reg_data3 => reg_data3,
      reg_data4 => reg_data4,
      reg_data5 => reg_data5,
      reg_data6 => reg_data6,
      reg_data7 => reg_data7,
      reg_data8 => reg_data8,
      reg_data9 => reg_data9);

  -- instance "synthi_top_1"
  synthi_top_1 : synthi_top
    port map (
      CLOCK_50     => CLOCK_50,
      KEY_0        => KEY_0,
      KEY_1        => KEY_1,
      SW           => SW,
      GPIO_26      => GPIO_26,
      AUD_XCK      => AUD_XCK,
      AUD_DACDAT   => AUD_DACDAT,
      AUD_BCLK     => AUD_BCLK,
      AUD_DACLRCK  => AUD_DACLRCK,
      AUD_ADCLRCK  => AUD_ADCLRCK,
      AUD_ADCDAT   => AUD_ADCDAT,
      I2C_SCLK     => I2C_SCLK,
      I2C_SDAT     => I2C_SDAT);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Zuweisung
   SW(17 downto 4) <= switch(17 downto 4);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

end architecture struct;
