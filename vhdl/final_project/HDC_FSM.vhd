-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: HDC_FSM.vhd
--Author: M.Banks
--Date: 04/15/2021
--Description: This code is the Finite State Machine for the entire HDC design.  It
--consists of four states: RST, ENCODE, SUPER, HAMM.
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;

entity HDC_FSM is
	port(
		CLOCK				: in  std_logic;	--clock input
		RESET				: in  std_logic;	--reset input
		MODE				: in  std_logic;	--Mode control input. 1=Training mode, 0=Testing mode
		HDC_START			: in  std_logic;	--Signal to start the HDC
		ENC_DONE			: in  std_logic;	--Encoding Done flag
		TRAINING_INPUT_DONE	: in  std_logic;	--All images of this class have been trained flag
		QUERY_RDY			: in  std_logic;	--Test Mode of Supervised Controller Done flag
		CLASS_TRAIN_DONE	: in  std_logic;	--Training Mode of Supervised Controller Done flag
		ACC_DONE			: in  std_logic;	--Accumulation operation in Supervised Controller of current image Done flag
		HAMM_DONE			: in  std_logic;	--Hamming module Done flag
		
		--OUTPUTS
		ENC_EN			: out std_logic;	--Enable for Encoding module
		SUP_EN			: out std_logic;	--Enable for Supervised Controller module
		HAMM_EN			: out std_logic;	--Enable for Hamming module
		HDC_DONE		: out std_logic		--Flag for when the HDC is finished with inference		
		);
	
end HDC_FSM;
	
architecture FSM of HDC_FSM is

Type STATE is(RST,ENCODE, SUPER, HAMM);
attribute enum_encoding : string;
attribute enum_encoding of STATE : type is "0001 0010 0100 1000";
signal current_state		: STATE;
signal next_state			: STATE;

signal ENC_EN_current	: std_logic;
signal ENC_EN_next		: std_logic;
signal SUP_EN_current	: std_logic;
signal SUP_EN_next		: std_logic;
signal HAMM_EN_current	: std_logic;
signal HAMM_EN_next		: std_logic;
signal HDC_DONE_current	: std_logic;
signal HDC_DONE_next	: std_logic;


begin

	clocked_proc_fsm : process(CLOCK, RESET) begin
		if(RESET = '1') then
			current_state			<= RST;
			ENC_EN_current			<= '0';	
			SUP_EN_current			<= '0';	
			HAMM_EN_current			<= '0';		
			HDC_DONE_current		<= '0';			
		elsif(rising_edge(CLOCK)) then
			current_state			<= next_state;
			ENC_EN_current			<= ENC_EN_next;	
			SUP_EN_current			<= SUP_EN_next;	
			HAMM_EN_current			<= HAMM_EN_next;
			HDC_DONE_current		<= HDC_DONE_next;
		end if;
	end process clocked_proc_fsm;
	
	state_machine : process(HDC_START, MODE, current_state, ENC_DONE, ACC_DONE, QUERY_RDY, CLASS_TRAIN_DONE, HAMM_DONE) 
		
	begin
		------------------------------------------------
		--STATE MACHINE
		------------------------------------------------
		case current_state is
			
			--------------------------------------------
			-- RESET STATE
			--------------------------------------------
			when RST =>
				next_state		<= ENCODE;
			    ENC_EN_next		<= '0';
			    SUP_EN_next		<= '0';
			    HAMM_EN_next	<= '0';
			    HDC_DONE_next	<= '0';
			--------------------------------------------
			
			--------------------------------------------
			-- ENCODE STATE
			--------------------------------------------
			when ENCODE =>	
			    SUP_EN_next		<= '0';
			    HAMM_EN_next	<= '0';
			    HDC_DONE_next	<= '0';
			
				if HDC_START = '0' then
					next_state	<= ENCODE;
					ENC_EN_next	<= '0';
				else
					if TRAINING_INPUT_DONE = '1' then
						ENC_EN_next	<= '0';
						SUP_EN_next	<= '1';
						next_state <= SUPER;
					else						
						if ENC_DONE = '1' then
							ENC_EN_next	<= '0';
							SUP_EN_next	<= '1';
							next_state <= SUPER;
						else
							ENC_EN_next	<= '1';
							next_state <= ENCODE;
						end if;
					end if;
				end if;
			--------------------------------------------
			
			--------------------------------------------
			-- SUPERVISED CONTROLLER STATE
			--------------------------------------------
			when SUPER =>
				ENC_EN_next		<= '0';
			    HAMM_EN_next	<= '0';
			    HDC_DONE_next	<= '0';
				if MODE = '0' then
					if QUERY_RDY = '1' then
						next_state		<= HAMM;
						HAMM_EN_next	<= '1';
						SUP_EN_next		<= '0';
					else
						next_state	<= SUPER;
						SUP_EN_next	<= '1';
					end if;
				else
					if ACC_DONE = '1' then
						next_state	<= ENCODE;
						SUP_EN_next	<= '0';
						ENC_EN_next	<= '1';
					elsif CLASS_TRAIN_DONE = '1' then
						next_state	<= SUPER;
						SUP_EN_next	<= '1';
						ENC_EN_next	<= '0';
					else
						next_state	<= SUPER;
						SUP_EN_next		<= '1';
					end if;
				end if;
			--------------------------------------------
			
			--------------------------------------------
			-- HAMMING DISTANCE STATE
			--------------------------------------------
			when HAMM =>
				ENC_EN_next		<= '0';
			    SUP_EN_next		<= '0';
				if HAMM_DONE = '1' then
					next_state		<= ENCODE;
					HDC_DONE_next	<= '1';
					HAMM_EN_next	<= '0';
				else
					next_state		<= HAMM;
					HDC_DONE_next	<= '0';
					HAMM_EN_next	<= '1';
				end if;
			
			--------------------------------------------
			-- ALL OTHER STATES
			--------------------------------------------
			when others =>
				next_state		<= ENCODE;
				ENC_EN_next		<= '0';
			    SUP_EN_next		<= '0';
			    HAMM_EN_next	<= '0';
			    HDC_DONE_next	<= '0';
		end case;		
		
	end process state_machine;
	
	ENC_EN			<= ENC_EN_current;	
	SUP_EN			<= SUP_EN_current;	
	HAMM_EN			<= HAMM_EN_current;	
	HDC_DONE		<= HDC_DONE_current;
	
end architecture FSM;

