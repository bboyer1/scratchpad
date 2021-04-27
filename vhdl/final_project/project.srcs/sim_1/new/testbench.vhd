-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: testbench.vhd
--Author: Angelo Luchetti
--Date: 04/26/2021
--Description: Testbench for the main simulation
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity main_tb is
end;

architecture bench of main_tb is  
    component main
    generic(
        HV_LENGTH			: 	integer := 10000;
        NUM_PIXELS		    :	integer	:= 1024;
        NUM_CLASS_IMAGES	:	integer := 26;
        NUM_ASSOC_HV		:	integer := 26;
        LABEL_BIT_LEN		:	integer := 5;
        IMAGE_COUNT_BIT_LEN	:	integer := 5;
        IM_ADDR_BIT_LEN		:	integer := 5;
        AM_ADDR_BIT_LEN		:	integer := 5
    );
    port(
        CLK					    : in  std_logic;
        RST					    : in  std_logic;
        OP_MODE				    : in  std_logic;
        START_FLAG			    : in  std_logic;
        INPUT_PIXEL			    : in  std_logic_vector(NUM_PIXELS-1 downto 0);
        INPUT_IMAGES_DONE	    : in  std_logic;
        ITEM_MEM_HV			    : in  std_logic_vector(HV_LENGTH-1 downto 0);
        ASSOC_MEM_HV_IN		    : in  std_logic_vector(HV_LENGTH-1 downto 0);
        ITEM_MEM_ADDR		    : out std_logic_vector(IM_ADDR_BIT_LEN-1 downto 0);
        ASSOC_MEM_ADDR		    : out std_logic_vector(AM_ADDR_BIT_LEN-1 downto 0);
        IMAGE_ADDR			    : out std_logic_vector(IMAGE_COUNT_BIT_LEN-1 downto 0);
        TRAINING_DONE		    : out std_logic;
        RDY_NEXT_IMAGE		    : out std_logic;
        ASSOC_MEM_WRITE		    : out std_logic;
        ASSOC_MEM_HV_OUT	    : out std_logic_vector(HV_LENGTH-1 downto 0);
        INF_DONE			    : out std_logic;
        QUERY_RDY_OUT		    : out std_logic;
        OUTPUT_LABEL		    : out std_logic_vector(LABEL_BIT_LEN-1 downto 0);
        out_1  : out std_logic_vector(499 downto 0);
        out_2  : out std_logic_vector(499 downto 0);
        out_3  : out std_logic_vector(499 downto 0);
        out_4  : out std_logic_vector(499 downto 0);
        out_5  : out std_logic_vector(499 downto 0);
        out_6  : out std_logic_vector(499 downto 0);
        out_7  : out std_logic_vector(499 downto 0);
        out_8  : out std_logic_vector(499 downto 0);
        out_9  : out std_logic_vector(499 downto 0);
        out_10 : out std_logic_vector(499 downto 0);
        out_11 : out std_logic_vector(499 downto 0);
        out_12 : out std_logic_vector(499 downto 0);
        out_13 : out std_logic_vector(499 downto 0);
        out_14 : out std_logic_vector(499 downto 0);
        out_15 : out std_logic_vector(499 downto 0);
        out_16 : out std_logic_vector(499 downto 0);
        out_17 : out std_logic_vector(499 downto 0);
        out_18 : out std_logic_vector(499 downto 0);
        out_19 : out std_logic_vector(499 downto 0);
        out_20 : out std_logic_vector(499 downto 0)
    );
  end component;

-- ONLY NEED TO CHANGE THESE FOR DIFFERENT TESTBENCH RUNS
constant c_HV_LENGTH : integer := 10000;
constant c_NUM_PIXELS : integer := 1024;
constant c_NUM_CLASS_IMAGES : integer := 22;
constant c_NUM_ASSOC_HV : integer := 22;
constant c_LABEL_BIT_LEN : integer := 5;
constant c_IMAGE_COUNT_BIT_LEN : integer := 5;
constant c_IM_ADDR_BIT_LEN : integer := 11;
constant c_AM_ADDR_BIT_LEN : integer := 5;
constant CLK_period  : time := 20 ns;



  signal CLK: std_logic;
  signal RST: std_logic;
  signal OP_MODE: std_logic;
  signal START_FLAG: std_logic;
  signal INPUT_PIXEL: std_logic_vector(c_NUM_PIXELS-1 downto 0);
  signal INPUT_IMAGES_DONE: std_logic;
  signal ITEM_MEM_HV: std_logic_vector(c_HV_LENGTH-1 downto 0);
  signal ASSOC_MEM_HV_IN: std_logic_vector(c_HV_LENGTH-1 downto 0);
  signal ITEM_MEM_ADDR: std_logic_vector(c_IM_ADDR_BIT_LEN-1 downto 0);
  signal ASSOC_MEM_ADDR: std_logic_vector(c_AM_ADDR_BIT_LEN-1 downto 0);
  signal IMAGE_ADDR: std_logic_vector(c_IMAGE_COUNT_BIT_LEN-1 downto 0);
  signal TRAINING_DONE: std_logic;
  signal RDY_NEXT_IMAGE: std_logic;
  signal ASSOC_MEM_WRITE: std_logic;
  signal ASSOC_MEM_HV_OUT: std_logic_vector(c_HV_LENGTH-1 downto 0);
  signal INF_DONE: std_logic;
  signal QUERY_RDY_OUT: std_logic;
  signal OUTPUT_LABEL: std_logic_vector(c_LABEL_BIT_LEN-1 downto 0) ;
  signal out_1: std_logic_vector(499 downto 0);
  signal out_2: std_logic_vector(499 downto 0);
  signal out_3: std_logic_vector(499 downto 0);
  signal out_4: std_logic_vector(499 downto 0);
  signal out_5: std_logic_vector(499 downto 0);
  signal out_6: std_logic_vector(499 downto 0);
  signal out_7: std_logic_vector(499 downto 0);
  signal out_8: std_logic_vector(499 downto 0);
  signal out_9: std_logic_vector(499 downto 0);
  signal out_10: std_logic_vector(499 downto 0);
  signal out_11: std_logic_vector(499 downto 0);
  signal out_12: std_logic_vector(499 downto 0);
  signal out_13: std_logic_vector(499 downto 0);
  signal out_14: std_logic_vector(499 downto 0);
  signal out_15: std_logic_vector(499 downto 0);
  signal out_16: std_logic_vector(499 downto 0);
  signal out_17: std_logic_vector(499 downto 0);
  signal out_18: std_logic_vector(499 downto 0);
  signal out_19: std_logic_vector(499 downto 0);
  signal out_20: std_logic_vector(499 downto 0);
  
begin

  -- Insert values for generic parameters !!
  uut: main generic map ( HV_LENGTH           => c_HV_LENGTH,
                          NUM_PIXELS          => c_NUM_PIXELS,
                          NUM_CLASS_IMAGES    => c_NUM_CLASS_IMAGES,
                          NUM_ASSOC_HV        => c_NUM_ASSOC_HV,
                          LABEL_BIT_LEN       => c_LABEL_BIT_LEN,
                          IMAGE_COUNT_BIT_LEN => c_IMAGE_COUNT_BIT_LEN,
                          IM_ADDR_BIT_LEN     => c_IM_ADDR_BIT_LEN,
                          AM_ADDR_BIT_LEN     =>  c_AM_ADDR_BIT_LEN)
               port map ( CLK                 => CLK,
                          RST                 => RST,
                          OP_MODE             => OP_MODE,
                          START_FLAG          => START_FLAG,
                          INPUT_PIXEL         => INPUT_PIXEL,
                          INPUT_IMAGES_DONE   => INPUT_IMAGES_DONE,
                          ITEM_MEM_HV         => ITEM_MEM_HV,
                          ASSOC_MEM_HV_IN     => ASSOC_MEM_HV_IN,
                          ITEM_MEM_ADDR       => ITEM_MEM_ADDR,
                          ASSOC_MEM_ADDR      => ASSOC_MEM_ADDR,
                          IMAGE_ADDR          => IMAGE_ADDR,
                          TRAINING_DONE       => TRAINING_DONE,
                          RDY_NEXT_IMAGE      => RDY_NEXT_IMAGE,
                          ASSOC_MEM_WRITE     => ASSOC_MEM_WRITE,
                          ASSOC_MEM_HV_OUT    => ASSOC_MEM_HV_OUT,
                          INF_DONE            => INF_DONE,
                          QUERY_RDY_OUT       => QUERY_RDY_OUT,
                          OUTPUT_LABEL        => OUTPUT_LABEL,
                          out_1               => out_1,
                          out_2               => out_2,
                          out_3               => out_3,
                          out_4               => out_4,
                          out_5               => out_5,
                          out_6               => out_6,
                          out_7               => out_7,
                          out_8               => out_8,
                          out_9               => out_9,
                          out_10              => out_10,
                          out_11              => out_11,
                          out_12              => out_12,
                          out_13              => out_13,
                          out_14              => out_14,
                          out_15              => out_15,
                          out_16              => out_16,
                          out_17              => out_17,
                          out_18              => out_18,
                          out_19              => out_19,
                          out_20              => out_20 );

  stimulus: process
  begin
    wait;
  end process;
end;