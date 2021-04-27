-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: images_ram.vhd
--Authors: M.Banks, Angelo Luchetti
--Date: 
--Description:
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity main is
generic(
    HV_LENGTH			: 	integer := 10000;	--# of dimensions of hypervector
    NUM_PIXELS			:	integer	:= 1024;	--# of pixels in image
    NUM_CLASS_IMAGES	:	integer := 26;	    --# of images in the class (ex: The total number of images of the letter "B")
    NUM_ASSOC_HV		:	integer := 26;	    --# of hypervectors stored in Associative Memory
    LABEL_BIT_LEN		:	integer := 5;	    --# of bits used to encode the character hypervector label
    IMAGE_COUNT_BIT_LEN	:	integer := 5;	    --# of bits used to represent the # of images in the class
    IM_ADDR_BIT_LEN		:	integer := 11;	    --# of bits used to represent the # of pixels 
    AM_ADDR_BIT_LEN		:	integer := 5	    --# of bits used to represent the # of hypervectors stored in Associative Memory 
    );
port(
    CLK					: in  std_logic;										--clock input
    RST					: in  std_logic;										--reset input
    OP_MODE				: in  std_logic;										--Mode control input. 1=Training mode, 0=Testing mode
    START_FLAG			: in  std_logic;										--Supervised controller module enable
    INPUT_PIXEL			: in  std_logic_vector(NUM_PIXELS-1 downto 0);			--Input Image. 0=Black, 1=White
    INPUT_IMAGES_DONE	: in  std_logic;										--Input images for this class are done
    ITEM_MEM_HV			: in  std_logic_vector(HV_LENGTH-1 downto 0);			--Item Memory hypervector
    ASSOC_MEM_HV_IN		: in  std_logic_vector(HV_LENGTH-1 downto 0);			--Associative Memory hypervector
    
    --Outputs
    ITEM_MEM_ADDR		: out std_logic_vector(IM_ADDR_BIT_LEN-1 downto 0);		--Address line to Item Memory
    ASSOC_MEM_ADDR		: out std_logic_vector(AM_ADDR_BIT_LEN-1 downto 0);		--Address line to Associative Memory
    IMAGE_ADDR			: out std_logic_vector(IMAGE_COUNT_BIT_LEN-1 downto 0);	--Address line to Image Memory
    TRAINING_DONE		: out std_logic;										--output flag to indicate to the user that training is finished
    RDY_NEXT_IMAGE		: out std_logic;										--output flag to indicate to the user that the HDC is ready for the next training image
    ASSOC_MEM_WRITE		: out std_logic;										--output to memory to indicate a write
    ASSOC_MEM_HV_OUT	: out std_logic_vector(HV_LENGTH-1 downto 0);			--Hypervector being written to associative memory
    INF_DONE			: out std_logic;										--output flag to user.  1=inference complete, 0=inference not complete
    QUERY_RDY_OUT		: out std_logic;										--output flag to user to indicate the query vector is ready for comparison
    OUTPUT_LABEL		: out std_logic_vector(LABEL_BIT_LEN-1 downto 0);		--output label to user
    
    -- split output for large hypervector:
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
end main;

architecture behavior of main is

-- ========================== components (instances of other VHDL files) ==========================

-- pixel hypervector ram
component pixel_hypervector_ram is
port(
    clk     : in    std_logic;                              -- clock
    we      : in    std_logic;                              -- write enable
    addr    : in    std_logic_vector(10 downto 0);          -- address
    din     : in    std_logic_vector(9999 downto 0);        -- data in
    dout    : out   std_logic_vector(9999 downto 0)         -- data out
);
end component pixel_hypervector_ram;

-- image data ram
component images_ram is
port(
    clk     : in    std_logic;                              -- clock
    we      : in    std_logic;                              -- write enable
    addr    : in    std_logic_vector(4 downto 0);           -- address
    din     : in    std_logic_vector(1023 downto 0);        -- data in
    dout    : out   std_logic_vector(1023 downto 0)         -- data out
);
end component images_ram;

component associative_memory_ram is
port(
    clk     : in    std_logic;                              -- clock
    we      : in    std_logic;                              -- write enable
    addr    : in    std_logic_vector(4 downto 0);           -- address
    din     : in    std_logic_vector(9999 downto 0);        -- data in
    dout    : out   std_logic_vector(9999 downto 0)         -- data out
);
end component associative_memory_ram;

-- Matt Finite State Machine
component HDC_FSM is
port(
    CLOCK				: in  std_logic;	--clock input
    RESET				: in  std_logic;	--reset input
    MODE				: in  std_logic;	--Mode control input. 1=Training mode, 0=Testing mode
    HDC_START			: in  std_logic;	--Signal to start the HDC
    ENC_DONE			: in  std_logic;	--Encoding Done flag
    TRAINING_INPUT_DONE	: in  std_logic;	--All images of this class have been trained flag
    QUERY_RDY			: in  std_logic;	--Test Mode of Supervised Controller Done flag
    CLASS_TRAIN_DONE	: in  std_logic;	--Training Mode of Supervised Controller Done flag
    ACC_DONE			: in  std_logic;	--Accumulation operation of current image Done flag
    HAMM_DONE			: in  std_logic;	--Hamming module Done flag
    
    --OUTPUTS
    ENC_EN			: out std_logic;	--Enable for Encoding module
    SUP_EN			: out std_logic;	--Enable for Supervised Controller module
    HAMM_EN			: out std_logic;	--Enable for Hamming module
    HDC_DONE		: out std_logic		--Flag for when the HDC is finished with inference		
    );
end component;
	
-- Matt Encoding Module
component encoding_module is
generic(
    D				: 	integer := 10000;	--# of dimensions of hypervector
    I				:	integer := 10;	    --# of times the encoding is repeated.  This is equal to the size of the input (N x M)
    ADDR_BITS		:	integer := 11	    --# of bits used to represent the ram address for the pixel hypervectors
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
end component;
	
-- Matt Supervised Controller
component Supervised_controller is
generic(
    D				: 	integer := 10000;						--# of dimensions of hypervector
    NUM_CLASS_IMG	:	integer := 26;							--# of images in the class (ex: The total number of images of the letter "B")
    N				:	integer := 5							--# of bits used to represent the # of images in the class
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
end component;
	
-- Hamming Module
component Hamming_module is
generic(
    D				: 	integer := 10000;	--# of dimensions of hypervector
    NUM_OF_HV		:	integer := 26;	    --# of memory hypervectors 
    N				:	integer := 5	    --# of bits used to represent the character hypervector label
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
end component;

-- ======================================== signals ===============================================

-- Matt Signals
signal TRAINING_INPUT_DONE_s	: std_logic;
signal Training_Done_s			: std_logic;
signal QUERY_DAT_RDY_s			: std_logic;
signal ENC_DONE_s				: std_logic;
signal ACC_DONE_s				: std_logic;
signal ENC_EN_s					: std_logic;
signal SUP_EN_s					: std_logic;
signal HAM_EN_s					: std_logic;
signal HAMM_DONE_s				: std_logic;
signal ENC_HV_s					: std_logic_vector(HV_LENGTH-1 downto 0);
signal QUERY_HV_s				: std_logic_vector(HV_LENGTH-1 downto 0);

signal ASSOC_MEM_HV_OUT_s : std_logic_vector(9999 downto 0);
signal ASSOC_MEM_HV_IN_s  : std_logic_vector(HV_LENGTH-1 downto 0);		



-- Ram Signals
signal pixel_hypervector_ram_addr : std_logic_vector(10 downto 0) := (others => '0');
signal pixel_hypervector_ram_dout : std_logic_vector(9999 downto 0) := (others => '0');
signal pixel_hypervector_ram_we : std_logic := '0';
signal pixel_hypervector_ram_din : std_logic_vector(9999 downto 0) := (others => '0');

signal image_ram_addr : std_logic_vector(4 downto 0) := (others => '0');
signal image_ram_dout : std_logic_vector(1023 downto 0) := (others => '0');
signal image_ram_we : std_logic := '0';
signal image_ram_din : std_logic_vector(1023 downto 0) := (others => '0');


signal associative_memory_ram_addr : std_logic_vector(4 downto 0) := (others => '0');
signal associative_memory_ram_dout : std_logic_vector(9999 downto 0) := (others => '0');
signal associative_memory_ram_we   : std_logic := '0';
signal associative_memory_ram_din :  std_logic_vector(9999 downto 0) := (others => '0');



begin

-- ========================= port maps (signal connections to components) =========================

phr1 : component pixel_hypervector_ram
port map (
    CLK,
    pixel_hypervector_ram_we,
    pixel_hypervector_ram_addr,
    pixel_hypervector_ram_din,
    pixel_hypervector_ram_dout
);

im1 : component images_ram
port map (
    CLK,
    image_ram_we,
    image_ram_addr,
    image_ram_din,
    image_ram_dout
);

am1: component associative_memory_ram
port map (
    CLK,
    associative_memory_ram_we,
    associative_memory_ram_addr,
    associative_memory_ram_din,
    associative_memory_ram_dout
);



FSM_Controller : HDC_FSM
port map(
    CLOCK				=> CLK,
    RESET				=> RST,
    MODE				=> OP_MODE,
    HDC_START			=> START_FLAG,
    ENC_DONE			=> ENC_DONE_s,
    TRAINING_INPUT_DONE	=> INPUT_IMAGES_DONE,
    QUERY_RDY			=> QUERY_DAT_RDY_s,
    CLASS_TRAIN_DONE	=> Training_Done_s,
    ACC_DONE			=> ACC_DONE_s,
    HAMM_DONE			=> HAMM_DONE_s,
    
    --OUTPUTS
    ENC_EN				=> ENC_EN_s,		
    SUP_EN				=> SUP_EN_s,			
    HAMM_EN				=> HAM_EN_s,			
    HDC_DONE			=> INF_DONE
);

ENC_Module : encoding_module
generic map(
    D			=> HV_LENGTH,
    I			=> NUM_PIXELS,
    ADDR_BITS	=> IM_ADDR_BIT_LEN
)
port map(
    CLOCK		=> CLK,
    RESET		=> RST,
    ENC_ENABLE	=> ENC_EN_s,	
    INPUT_HV0	=> pixel_hypervector_ram_dout,
    PIXEL_VAL	=> image_ram_dout,
    
    --Outputs
    PHR_ADDRESS	=> pixel_hypervector_ram_addr,
    ENC_DONE	=> ENC_DONE_s,	
    OUT_HV		=> ENC_HV_s		
);

SUPER_Controller : Supervised_controller
generic map(
    D				=> HV_LENGTH,
    NUM_CLASS_IMG	=> NUM_CLASS_IMAGES,
    N				=> IMAGE_COUNT_BIT_LEN
)
port map(
    CLOCK			=> CLK,
    RESET			=> RST,
    MODE			=> OP_MODE,
    SUPER_ENABLE	=> SUP_EN_s,
    TRAINING_DONE	=> INPUT_IMAGES_DONE,
    ENC_HV			=> ENC_HV_s,
    
    --Outputs
    IMAGE_COUNT		=> image_ram_addr,
    ACCUM_DONE		=> ACC_DONE_s,
    AS_MEM_WRITE	=> ASSOC_MEM_WRITE,
    AS_DAT_RDY		=> Training_Done_s,		
    QUERY_DAT_RDY	=> QUERY_DAT_RDY_s,	
    QUERY_HV_OUT	=> QUERY_HV_s,
    ASSOC_HV_OUT	=> ASSOC_MEM_HV_OUT_s
);

HAMM_Module : Hamming_module
generic map(
    D				=> HV_LENGTH,
    NUM_OF_HV		=> NUM_ASSOC_HV,
    N				=> LABEL_BIT_LEN			
)
port map(
    CLOCK			=> CLK,
    RESET		    => RST,
    HAMM_ENABLE		=> HAM_EN_s,
    QUERY_HV		=> QUERY_HV_s,
    CHAR_HV			=> associative_memory_ram_dout,
    
    --Outputs
    AM_ADDRESS      => associative_memory_ram_addr,
    COMPARE_DONE	=> HAMM_DONE_s,
    CLASS_OUT       => OUTPUT_LABEL     
);

-- =================================== other signal connections ===================================
RDY_NEXT_IMAGE	<= ACC_DONE_s;
TRAINING_DONE	<= Training_Done_s;	
QUERY_RDY_OUT	<= QUERY_DAT_RDY_s;

ASSOC_MEM_HV_OUT <= ASSOC_MEM_HV_OUT_s;

-- split output of large hypervector
out_1  <= ASSOC_MEM_HV_OUT_s(9999 downto 9500);
out_2  <= ASSOC_MEM_HV_OUT_s(9499 downto 9000);
out_3  <= ASSOC_MEM_HV_OUT_s(8999 downto 8500);
out_4  <= ASSOC_MEM_HV_OUT_s(8499 downto 8000);
out_5  <= ASSOC_MEM_HV_OUT_s(7999 downto 7500);
out_6  <= ASSOC_MEM_HV_OUT_s(7499 downto 7000);
out_7  <= ASSOC_MEM_HV_OUT_s(6999 downto 6500);
out_8  <= ASSOC_MEM_HV_OUT_s(6499 downto 6000);
out_9  <= ASSOC_MEM_HV_OUT_s(5999 downto 5500);
out_10 <= ASSOC_MEM_HV_OUT_s(5499 downto 5000);
out_11 <= ASSOC_MEM_HV_OUT_s(4999 downto 4500);
out_12 <= ASSOC_MEM_HV_OUT_s(4499 downto 4000);
out_13 <= ASSOC_MEM_HV_OUT_s(3999 downto 3500);
out_14 <= ASSOC_MEM_HV_OUT_s(3499 downto 3000);
out_15 <= ASSOC_MEM_HV_OUT_s(2999 downto 2500);
out_16 <= ASSOC_MEM_HV_OUT_s(2499 downto 2000);
out_17 <= ASSOC_MEM_HV_OUT_s(1999 downto 1500);
out_18 <= ASSOC_MEM_HV_OUT_s(1499 downto 1000);
out_19 <= ASSOC_MEM_HV_OUT_s(999 downto 500);
out_20 <= ASSOC_MEM_HV_OUT_s(499 downto 0);

end behavior;