-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: Hamming_module.vhd
--Author: M.Banks
--Date: 04/26/2021
--Description: This code takes a query hypervector and a character hypervector as input.
--The character hypervector has the character label encoded as the N Most Significant Bits,
--where N = floor(log2(the # of character hypervectors)).  The similarity distance between the two
--hypervectors is calculated (XOR function) and then this is repeated for all character 
--hypervectors.  The character hypervector with the shortest distance to the query
--hypervector is the result.  The output is the N-bit code representing the associated character
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;

entity Hamming_module is
	generic(
		D				: 	integer := 10;	--# of dimensions of hypervector
		NUM_OF_HV		:	integer := 6;	--# of memory hypervectors 
		N				:	integer := 6	--# of bits used to represent the character hypervector label
		);
	port(
		CLOCK			: in  std_logic;	--clock input
		RESET			: in  std_logic;	--reset input
		HAMM_ENABLE		: in  std_logic;	--Hamming module enable
		QUERY_HV		: in  std_logic_vector(D-1 downto 0);	--query hypervector
		CHAR_HV			: in  std_logic_vector(D-1 downto 0);	--character hypervector
	
		--Outputs
		AM_ADDRESS		: out std_logic_vector(N-1 downto 0);	--address to associative memory
		COMPARE_DONE	: out std_logic;	                    --encoding complete flag
		CLASS_OUT		: out std_logic_vector(N-1 downto 0)	--output Classification code
		);
	
end Hamming_module;
	
architecture HAMM of Hamming_module is

signal shortest_distance_r		: integer;
signal shortest_distance_next	: integer;
signal CLASS_OUT_BUFF_r			: std_logic_vector(N-1 downto 0);
signal CLASS_OUT_BUFF_next		: std_logic_vector(N-1 downto 0);
signal CLASS_OUT_r				: std_logic_vector(N-1 downto 0);
signal CLASS_OUT_next			: std_logic_vector(N-1 downto 0);
signal ASSOC_HV_counter_r    	: std_logic_vector(N-1 downto 0);
signal ASSOC_HV_counter_next	: std_logic_vector(N-1 downto 0);
signal AM_ADDRESS_next	    	: std_logic_vector(N-1 downto 0);
signal AM_ADDRESS_r				: std_logic_vector(N-1 downto 0);
signal COMPARE_DONE_r			: std_logic;
signal COMPARE_DONE_next		: std_logic;
signal label_ts		 			: integer;	--debug signal


begin

	clocked_proc1 : process(CLOCK, RESET) begin
		if(RESET = '1') then
			COMPARE_DONE_r			<= '0';
			shortest_distance_r		<= D+1;
			ASSOC_HV_counter_r		<= (others => '0');
			CLASS_OUT_r				<= (others => '0');
			CLASS_OUT_BUFF_r		<= (others => '0');
			AM_ADDRESS_r			<= (others => '0');
		elsif(rising_edge(CLOCK)) then
			COMPARE_DONE_r			<= COMPARE_DONE_next;
			shortest_distance_r		<= shortest_distance_next;
			ASSOC_HV_counter_r		<= ASSOC_HV_counter_next;
			CLASS_OUT_r				<= CLASS_OUT_next;
			CLASS_OUT_BUFF_r		<= CLASS_OUT_BUFF_next;
			AM_ADDRESS_r			<= AM_ADDRESS_next;
		end if;
	end process clocked_proc1;
	
	hamming_distance : process(HAMM_ENABLE, ASSOC_HV_counter_r, QUERY_HV, CHAR_HV, shortest_distance_r) 
		variable j 				: integer := 0;
		variable distance		: integer := 0;
		variable xor_result		: boolean;
		variable char_label		: std_logic_vector(N-1 downto 0);
		
	begin
		
		shortest_distance_next	<= shortest_distance_r;
		COMPARE_DONE_next		<= COMPARE_DONE_r;
		ASSOC_HV_counter_next	<= ASSOC_HV_counter_r;
		CLASS_OUT_BUFF_next		<= CLASS_OUT_BUFF_r;
		AM_ADDRESS_next			<= AM_ADDRESS_r;
		
		if HAMM_ENABLE = '1' then
			char_label := ASSOC_HV_counter_r;
			if(ASSOC_HV_counter_r < NUM_OF_HV) then
				distance := 0;
				
				--Perform bitwise XOR operations and add each bit together to determine distance
				for j in 0 to D-1 loop
					if(QUERY_HV(j) /= CHAR_HV(j)) then
						distance := distance + 1;
					else
						distance := distance;
					end if;
				end loop;
				label_ts	<= distance;
				
				--Least Distance Comparator
				if (distance <= shortest_distance_r) then
					shortest_distance_next	<= distance;
					CLASS_OUT_next			<= char_label;			
				else
					shortest_distance_next  <= shortest_distance_r;
					CLASS_OUT_next			<= CLASS_OUT_r;
				end if;
				ASSOC_HV_counter_next 	<= ASSOC_HV_counter_r + 1;
				COMPARE_DONE_next		<= '0';
				
					
				if ASSOC_HV_counter_r + 1 >= NUM_OF_HV then
					AM_ADDRESS_next	<= AM_ADDRESS_r;
				else
					AM_ADDRESS_next	<= AM_ADDRESS_r + 1;
				end if;	
			else
				ASSOC_HV_counter_next 	<= (others => '0');
				AM_ADDRESS_next			<= (others => '0');
				COMPARE_DONE_next		<= '1';	
				shortest_distance_next	<= 0;
				CLASS_OUT_next			<= CLASS_OUT_r;
				CLASS_OUT_BUFF_next		<= CLASS_OUT_r;
			end if;
		else
			COMPARE_DONE_next	<= '0';
			CLASS_OUT_next		<= CLASS_OUT_r;
		end if;
	end process hamming_distance;
	AM_ADDRESS		<= AM_ADDRESS_r;
	CLASS_OUT		<= CLASS_OUT_BUFF_r;
	COMPARE_DONE	<= COMPARE_DONE_r;
	
end architecture HAMM;

