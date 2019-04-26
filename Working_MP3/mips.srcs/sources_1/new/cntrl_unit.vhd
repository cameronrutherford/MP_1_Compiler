----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2019 09:18:53 AM
-- Design Name: 
-- Module Name: cntrl_unit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;



entity cntrl_unit is
  Port (CLOCK : in std_logic;
        reset: in std_logic;
        opcode : in std_logic_vector(7 downto 0);
        ready : out std_logic;
        reg_nam_one : in std_logic_vector(4 downto 0);
        reg_nam_two : in std_logic_vector(4 downto 0);
        address_to_mem : out std_logic_vector(18 downto 0)
  );
end cntrl_unit;

architecture Behavioral of cntrl_unit is
    signal decoded_opcode : std_logic_vector (3 downto 0);

begin
    process (opcode)
        begin
            case opcode is 
                when  "00001001" => decoded_opcode <= "0000"; --list add
                --TODO: implement the following in parser and hardware(?)
                when "00010100" => decoded_opcode <= "0010"; --list and
                when "00010101" => decoded_opcode <= "0011"; --list or
                when "00010110" => decoded_opcode <=  "0100"; --list xor
                when "00010111" => decoded_opcode <=  "0101"; --list not B
                --TODO : implement subtract and assign it an opcode
                when "10010011" => address_to_mem <= mem_input; --list store 
                when "00001001" => address_to_mem <= mem_input; --list load
                when others => decoded_opcode <= "XXXX"; -- if we get a bad opcode, undefined output
             end case;
       end process;
       
    

end Behavioral;
