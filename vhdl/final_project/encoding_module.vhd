-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: encoding_module.vhd
--Author: M.Banks
--Date: 04/26/2021
--Description: This code consists of the permutation, addition, and threshold operations
--on the input hypervectors.  The output is one of two hypervectors:
--1) During training, the output is the hypervector which will be stored into memory
--2) During testing, the output is the query hypervector
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;

entity encoding_module is
	generic(
		D				: 	integer := 10;	--# of dimensions of hypervector
		I				:	integer := 5;	--# of times the encoding is repeated.  This is equal to the size of the input (N x M)
		ADDR_BITS		:	integer := 6	--# of bits used to represent the ram address for the pixel hypervectors
		);
	port(
		CLOCK			: in  std_logic;	--clock input
		RESET			: in  std_logic;	--reset input
		ENC_ENABLE		: in  std_logic;	--encoding module enable
		INPUT_HV0		: in  std_logic_vector(D-1 downto 0);	--item hypervector 0
		PIXEL_VAL		: in  std_logic_vector(I-1 downto 0);	--value of current input pixel
	
		--Outputs
		PHR_ADDRESS		: out std_logic_vector(ADDR_BITS-1 downto 0);		--pixel hypervector ram address
		ENC_DONE		: out std_logic;	                    --encoding complete flag
		OUT_HV			: out std_logic_vector(D-1 downto 0)	--output hypervector
		);
	
end encoding_module;
	
architecture ENC of encoding_module is

signal index 				: integer;
signal index_r				: integer;
type hypervector is array (0 to D-1) of integer;
signal MEM_HV 				: hypervector;
signal MEM_HV_r				: hypervector;
signal OUT_HV_r				: std_logic_vector(D-1 downto 0);
signal OUT_HV_next			: std_logic_vector(D-1 downto 0);
signal data_counter		    : std_logic_vector(ADDR_BITS-1 downto 0);
signal data_in_counter_r	: std_logic_vector(ADDR_BITS-1 downto 0);
signal PHR_ADDRESS_r	    : std_logic_vector(ADDR_BITS-1 downto 0);
signal PHR_ADDRESS_next		: std_logic_vector(ADDR_BITS-1 downto 0);
signal ACC_DONE				: std_logic;
signal ACC_DONE_r			: std_logic;
signal ENC_DONE_r			: std_logic;
signal ENC_DONE_next		: std_logic;
signal INPUT_HV0_r 			: std_logic_vector(D-1 downto 0);	--debug signal
signal INPUT_HV0_s			: std_logic_vector(D-1 downto 0);	--debug signal


begin

	clocked_proc : process(CLOCK, RESET) begin
		if(RESET = '1') then
			index			<= 0;
			ENC_DONE_r		<= '0';
			ACC_DONE		<= '0';
			OUT_HV_r		<= (others => '0');
			MEM_HV			<= (others => 0);
			PHR_ADDRESS_r	<= (others => '0');
			data_counter	<= (others => '0');
			INPUT_HV0_r		<= (others => '0');
		elsif(rising_edge(CLOCK)) then
			index			<= index_r;
			ENC_DONE_r		<= ENC_DONE_next;
			ACC_DONE		<= ACC_DONE_r;
			OUT_HV_r		<= OUT_HV_next;
			MEM_HV			<= MEM_HV_r;
			PHR_ADDRESS_r	<= PHR_ADDRESS_next;
			data_counter	<= data_in_counter_r;
			INPUT_HV0_r		<= INPUT_HV0_s;
		end if;
	end process clocked_proc;
	
	shift_add_thresh : process(ENC_ENABLE, data_counter, PIXEL_VAL, ACC_DONE, MEM_HV, INPUT_HV0) 
		variable j 				: integer := 0;
		variable l 				: integer := 0;
		variable thresh			: integer := 0;
		variable INPUT_HV0_v	: std_logic_vector(D-1 downto 0) := (others => '0');
		
	begin
		
		ACC_DONE_r			<= ACC_DONE;		--This was set to 0
		ENC_DONE_next		<= ENC_DONE_r;
		MEM_HV_r			<= MEM_HV;
		OUT_HV_next			<= OUT_HV_r;
		data_in_counter_r	<= data_counter;
		PHR_ADDRESS_next	<= PHR_ADDRESS_r;
		index_r				<= index;
		
		if ENC_ENABLE = '1' then
			if (ACC_DONE = '0') then
				ENC_DONE_next		<= '0';
				if data_counter < I then
				
					--Shifter where the position HV is circular shifted right 1 if Pixel value = 0, and not shifted otherwise
						if PIXEL_VAL(I-1-index) = '0' then
							INPUT_HV0_v	:= INPUT_HV0(0) & INPUT_HV0(D-1 downto 1);
						else
							INPUT_HV0_v	:= INPUT_HV0;
						end if;
						INPUT_HV0_s			<= INPUT_HV0_v;
					
					--bitwise add to the mem hypervector until all pixels are processed
					
					for j in 0 to D-1 loop
						if(INPUT_HV0_v(D-1-j) = '1') then
							MEM_HV_r(j)	<= MEM_HV(j) + 1;
						else
							MEM_HV_r(j)	<= MEM_HV(j);
						end if;
					end loop;
					
					if data_counter + 1 >= I then
						index_r				<= index;
						PHR_ADDRESS_next	<= PHR_ADDRESS_r;
					else
						index_r				<= index + 1;
						PHR_ADDRESS_next	<= PHR_ADDRESS_r + 1;
					end if;	
					data_in_counter_r <= data_counter + 1;
				else
					ACC_DONE_r			<= '1';
					data_in_counter_r	<= (others => '0');
					PHR_ADDRESS_next	<= (others => '0');
					index_r			  	<= 0;
				end if;
			else	--ACC_DONE = 1
			
				--Thresholding
				if(I mod 2 = 0) then
					thresh := I/2 + 1;
				else
					thresh := (I-1)/2 + 1;
				end if;
				
				for l in 0 to D-1 loop
					if(MEM_HV(D-1-l) < thresh) then
						OUT_HV_next(l) <= '0';
					else
						OUT_HV_next(l) <= '1';
					end if;
				end loop;
				ENC_DONE_next	<= '1';
				ACC_DONE_r		<= '0';	--This was not here
				MEM_HV_r		<= (others => 0);
			end if;
		else
			--ENC_DONE_next	<= '0';
			PHR_ADDRESS_next	<= (others => '0');
			data_in_counter_r	<= (others => '0');
			index_r				<= 0;
			MEM_HV_r			<= (others => 0);
		end if;
	end process shift_add_thresh;
	
	PHR_ADDRESS	<= PHR_ADDRESS_r;
	OUT_HV		<= OUT_HV_r;
	ENC_DONE	<= ENC_DONE_r;
	
end architecture ENC;

