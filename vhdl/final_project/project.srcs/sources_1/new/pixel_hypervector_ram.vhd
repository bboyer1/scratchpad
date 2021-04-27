-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--filename: pixel_hypervector_ram.vhd
--Author: Angelo Luchetti
--Date: 4/20/21
--Description:

-- Ram block containing hypervectors which were generated in Python.

-- 1,024 lines (one for each pixel of 32x32 images)
-- 11 bit address to access each of 1,024 lines
-- 10,000 width

--citation of example code:
--https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug901-vivado-synthesis.pdf#page=146
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity pixel_hypervector_ram is
port(
    clk     : in    std_logic;                              -- clock
    we      : in    std_logic;                              -- write enable
    addr    : in    std_logic_vector(10 downto 0);          -- address
    din     : in    std_logic_vector(9999 downto 0);        -- data in
    dout    : out   std_logic_vector(9999 downto 0)         -- data out
);
end pixel_hypervector_ram;

architecture behavior of pixel_hypervector_ram is
type RamType is array (0 to 1023) of bit_vector(9999 downto 0);

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

signal RAM : RamType := InitRamFromFile("pixel_hypervectors.data");
begin

process(we, din, addr)
begin

    if we = '1' then
        RAM(to_integer(unsigned(addr))) <= to_bitvector(din);
    end if;
    
    dout <= to_stdlogicvector(RAM(to_integer(unsigned(addr))));

end process;

end behavior;