----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2019 09:12:10 AM
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;   

entity alu is
    generic(N : integer := 32);
    port (  A: in signed(N - 1 downto 0); --operand A
            B : in signed(N -1 downto 0); --operand B
            OP : in unsigned(3 downto 0); --opcode
            Y : out signed(N-1 downto 0) --output Y
            );
end alu;

architecture Behavioral of alu is
begin
process(OP)
begin
    case OP is
        when "0000" => Y <= A + B; --list add
        when "0001" => Y <= A - B; --list subtract
        when "0111" => Y <= (others => 'X'); --mulitply, stretch goal not implelemted
        when "0010" => Y <= A and B; --list and
        when "0011" => Y <= A or B; --list or
        when "0100" => Y <= A xor B; --list xor
        when "0101" => Y <= not B; --list not B
        when others => Y <= (others => 'X');
        end case;
end process;
end Behavioral;
