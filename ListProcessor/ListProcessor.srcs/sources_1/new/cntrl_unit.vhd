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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity cntrl_unit is
  Port (CLOCK : in std_logic;
        reset: in std_logic;
        opcode : in std_logic_vector(7 downto 0);
        ready : out std_logic;
        mem_input : in std_logic_vector(18 downto 0); --the memory instruction inputs
        reg_nam_one : in std_logic_vector(4 downto 0);
        reg_nam_two : in std_logic_vector(4 downto 0);
        mem_bus_in : in std_logic_vector(127 downto 0);
        mem_bus_out : out std_logic_vector(127 downto 0);
        ram_output : in std_logic_vector(18 downto 0)
    
  );
end cntrl_unit;

architecture Behavioral of cntrl_unit is
    signal memory_bus : std_logic_vector(127 downto 0);
    --signal opcode : std_logic_vector(7 downto 0);
    signal decoded_opcode : std_logic_vector (3 downto 0);
    
    --process(OP)
    --begin
    --    case OP is
    --        when "0000" => Y <= A + B; --list add
    --        when "0001" => Y <= A - B; --list subtract
    --        when "0111" => Y <= (others => 'X'); --mulitply, stretch goal not implelemted
    --        when "0010" => Y <= A and B; --list and
    --        when "0011" => Y <= A or B; --list or
    --        when "0100" => Y <= A xor B; --list xor
    --        when "0101" => Y <= not B; --list not B
    --        when others => Y <= (others => 'X');
    --        end case;
    --end process;
    
    --ll = 00001001
    --ls = 10010011
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
                when "10010011" => memory_bus <= mem_input; --list store 
                when "00001001" => memory_bus <= mem_input; --list load
             end case;
       end process;
       
    

end Behavioral;
