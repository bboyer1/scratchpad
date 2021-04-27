-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: images_ram.vhd
--Author: Angelo Luchetti
--Date: 4/20/21
--Description:

-- File name is changed below when adding in different data.

-- Ram block containing image data for 1 particular letter category.

-- 22 lines (one for each image in distinct fonts)
-- 5 bit address to access each of 26 lines
-- 1,024 width (number of pixels per image)

--citation of example code:
--https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug901-vivado-synthesis.pdf#page=146
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity images_ram is
port(
    clk     : in    std_logic;                              -- clock
    we      : in    std_logic;                              -- write enable
    addr    : in    std_logic_vector(4 downto 0);           -- address
    din     : in    std_logic_vector(1023 downto 0);        -- data in
    dout    : out   std_logic_vector(1023 downto 0)         -- data out
);
end images_ram;

architecture behavior of images_ram is
type RamType is array (0 to 25) of bit_vector(1023 downto 0);

impure function InitRamFromFile(RamFileName : in string) return RamType is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable RAM : RamType;
begin
    for I in RamType'range loop
    readline(RamFile, RamFileLine);
    read(RamFileLine, RAM(I));
    end loop;
    return RAM;
end function;

-- Change file name here:
signal RAM : RamType := InitRamFromFile("z_verdana.data");
begin

process(we, din, addr)
begin

    if we = '1' then
        RAM(to_integer(unsigned(addr))) <= to_bitvector(din);
    end if;
    
    dout <= to_stdlogicvector(RAM(to_integer(unsigned(addr))));

end process;

end behavior;