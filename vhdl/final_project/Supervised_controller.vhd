-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: Supervised_controller.vhd
--Author: M.Banks
--Date: 04/26/2021
--Description: This code takes the output of the encoding module along with a control input
--which indicates if the system is in training or testing mode.  If training, the associative
--hypervector associated with the character being tested is loaded in as well and the two are
--bundled together and stored back into the associative memory.  If testing, the query hypervector
--is forwarded directly to the Hamming module from the encoding module
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;

entity Supervised_controller is
	generic(
		D				: 	integer := 10;							--# of dimensions of hypervector
		NUM_CLASS_IMG	:	integer := 5;							--# of images in the class (ex: The total number of images of the letter "B")
		N				:	integer := 7							--# of bits used to represent the # of images in the class
		);								                            
	port(								                            
		CLOCK			: in  std_logic;							--clock input
		RESET			: in  std_logic;							--reset input
		MODE			: in  std_logic;							--Mode control input. 1=Training mode, 0=Testing mode
		SUPER_ENABLE	: in  std_logic;							--Supervised controller module enable
		TRAINING_DONE	: in  std_logic;							--Input flag to indicate training set is finished
		ENC_HV			: in  std_logic_vector(D-1 downto 0);		--query hypervector
	
		--Outputs
		IMAGE_COUNT		: out std_logic_vector(N-1 downto 0);		--Indicates the current image # being processed.  This will be used as the ADDR to pull an image from memory
		ACCUM_DONE		: out std_logic;							--Output flag to indicate accumulation is complete
		AS_MEM_WRITE	: out std_logic;							--output flag to associative memory to indicate a write
		AS_DAT_RDY		: out std_logic;							--Output data to associative memory ready flag
		QUERY_DAT_RDY	: out std_logic;							--Output data to Hamming module ready flag
		QUERY_HV_OUT	: out std_logic_vector(D-1 downto 0);		--output query hypervector
		ASSOC_HV_OUT	: out std_logic_vector(D-1 downto 0)		--output associative memory hypervector
		
		);
	
end Supervised_controller;
	
architecture SUPER of Supervised_controller is

type hypervector is array (0 to D-1) of integer;
signal ASSOC_HV					: hypervector;
signal ASSOC_HV_r				: hypervector;
signal ASHV_OUT_r				: std_logic_vector(D-1 downto 0);
signal ASHV_OUT_next			: std_logic_vector(D-1 downto 0);
signal QHV_OUT_r				: std_logic_vector(D-1 downto 0);
signal QHV_OUT_next				: std_logic_vector(D-1 downto 0);
-- signal ASSOC_HV_counter_r    	: std_logic_vector(7 downto 0);
-- signal ASSOC_HV_counter_next	: std_logic_vector(7 downto 0);
signal data_counter		    	: std_logic_vector(N-1 downto 0);
signal data_in_counter_r		: std_logic_vector(N-1 downto 0);
signal IMAGE_COUNT_r	    	: std_logic_vector(N-1 downto 0);
signal IMAGE_COUNT_next			: std_logic_vector(N-1 downto 0);
signal ACC_DONE					: std_logic;
signal ACC_DONE_r				: std_logic;
signal AS_DAT_RDY_r				: std_logic;
signal AS_DAT_RDY_next			: std_logic;
signal QUERY_DAT_RDY_r			: std_logic;
signal QUERY_DAT_RDY_next		: std_logic;
--signal label_ts		 			: integer;	--debug signal


begin

	clocked_proc2 : process(CLOCK, RESET) begin
		if(RESET = '1') then
			ACC_DONE				<= '0';
			AS_DAT_RDY_r			<= '0';
			QUERY_DAT_RDY_r			<= '0';
			--ASSOC_HV_counter_r		<= (others => '0');
			ASHV_OUT_r				<= (others => '0');
			QHV_OUT_r				<= (others => '0');
			ASSOC_HV				<= (others => 0);
			data_counter			<= (others => '0');
			IMAGE_COUNT_r			<= (others => '0');
		elsif(rising_edge(CLOCK)) then
			ACC_DONE				<= ACC_DONE_r;
			AS_DAT_RDY_r			<= AS_DAT_RDY_next;
			QUERY_DAT_RDY_r			<= QUERY_DAT_RDY_next;
			--ASSOC_HV_counter_r		<= ASSOC_HV_counter_next;
			ASHV_OUT_r				<= ASHV_OUT_next;
			QHV_OUT_r				<= QHV_OUT_next;
			ASSOC_HV				<= ASSOC_HV_r;
			data_counter			<= data_in_counter_r;
			IMAGE_COUNT_r			<= IMAGE_COUNT_next;
		end if;
	end process clocked_proc2;
	
	bundling : process(MODE, SUPER_ENABLE, data_counter, ACC_DONE, ASSOC_HV, ENC_HV, TRAINING_DONE) 
		variable j 				: integer := 0;
		variable l 				: integer := 0;
		variable thresh			: integer := 0;
		
	begin
		
		ACC_DONE_r			<= ACC_DONE;
		ASSOC_HV_r			<= ASSOC_HV;
		AS_DAT_RDY_next		<= AS_DAT_RDY_r;
		QUERY_DAT_RDY_next	<= '0';
		ASHV_OUT_next		<= ASHV_OUT_r;
		QHV_OUT_next		<= QHV_OUT_r;
		data_in_counter_r	<= data_counter;
		IMAGE_COUNT_next	<= IMAGE_COUNT_r;
		
		if SUPER_ENABLE = '1' then
			if MODE = '1' then
				--Training
				if(data_counter < NUM_CLASS_IMG) then
				--if (TRAINING_DONE = '0') then	--Accumulate all encoded hypervectors for each image in class
					if (ACC_DONE = '0') then	--Need to make sure the same hypervector is not accumulated
						AS_DAT_RDY_next		<= '0';
						
						--bitwise add encoded hypervector to the associative memory hypervector				
						for j in 0 to D-1 loop
							if(ENC_HV(D-1-j) = '1') then
								ASSOC_HV_r(j)	<= ASSOC_HV(j) + 1;
							else
								ASSOC_HV_r(j)	<= ASSOC_HV(j);
							end if;
						end loop;
						ACC_DONE_r			<= '1';
						data_in_counter_r	<= data_counter+1;
						
						if(data_counter + 1 >= NUM_CLASS_IMG) then
							IMAGE_COUNT_next	<= IMAGE_COUNT_r;
						else
							IMAGE_COUNT_next	<= IMAGE_COUNT_r + 1;
						end if;
							
							
					else
						ASSOC_HV_r			<= ASSOC_HV;
					end if;
				else
				
					--Thresholding of accumulated hypervectors
					if(NUM_CLASS_IMG mod 2 = 0) then
						thresh := (NUM_CLASS_IMG/2) + 1;
					else
						thresh := (NUM_CLASS_IMG-1)/2 + 1;
					end if;
					
					for l in 0 to D-1 loop
						if(ASSOC_HV(D-1-l) < thresh) then
							ASHV_OUT_next(l) <= '0';
						else
							ASHV_OUT_next(l) <= '1';
						end if;
					end loop;
					AS_DAT_RDY_next		<= '1';
					ASSOC_HV_r			<= (others => 0); --Reset integer hypervector
					data_in_counter_r	<= (others => '0');
					IMAGE_COUNT_next	<= (others => '0');
				end if;
			else
				--Testing
				QHV_OUT_next		<= ENC_HV;	--Send output of encoding module to Hamming module
				QUERY_DAT_RDY_next	<= '1';
			end if;
		else
			AS_DAT_RDY_next		<= '0';
			QUERY_DAT_RDY_next	<= '0';
			ACC_DONE_r			<= '0';
		end if;
	end process bundling;
	
	IMAGE_COUNT			<= IMAGE_COUNT_r;
	ACCUM_DONE			<= ACC_DONE;
	ASSOC_HV_OUT		<= ASHV_OUT_r;
	AS_MEM_WRITE		<= AS_DAT_RDY_r;
	AS_DAT_RDY			<= AS_DAT_RDY_r;
	QUERY_HV_OUT		<= QHV_OUT_r;
	QUERY_DAT_RDY		<= QUERY_DAT_RDY_r;
	
end architecture SUPER;

