----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2019 09:51:44 AM
-- Design Name: 
-- Module Name: list_proc_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity list_proc_sim is
end list_proc_sim;

architecture Behavioral of list_proc_sim is
component ListProc
    port (
       -- CLOCK : in STD_LOGIC;
        reset : in STD_LOGIC;
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        opA : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register
        opB : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register or memory location
        mem_bus_in : STD_LOGIC_VECTOR(127 downto 0);    -- data bus for reading from memory
        mem_bus_out : out STD_LOGIC_VECTOR(127 downto 0);   -- data bus for writing to memory
        mem_address : out STD_LOGIC_VECTOR(4 downto 0);
        memWrite : out STD_LOGIC
    );
    end component;

signal reset : STD_LOGIC;
signal opcode :  STD_LOGIC_VECTOR(7 downto 0);
signal opA : STD_LOGIC_VECTOR(4 downto 0);      -- operand register
signal opB : STD_LOGIC_VECTOR(4 downto 0);      -- operand register or memory location
signal mem_bus_in : STD_LOGIC_VECTOR(127 downto 0);    -- data bus for reading from memory
signal mem_bus_out : STD_LOGIC_VECTOR(127 downto 0);   -- data bus for writing to memory
signal mem_address : STD_LOGIC_VECTOR(4 downto 0);
signal memWrite : STD_LOGIC;

begin
uut : ListProc port map (reset => reset, opcode => opcode, opA => opA, opB => opB, mem_bus_in => mem_bus_in, mem_bus_out => mem_bus_out, mem_address => mem_address, memWrite => memWrite);

end Behavioral;
