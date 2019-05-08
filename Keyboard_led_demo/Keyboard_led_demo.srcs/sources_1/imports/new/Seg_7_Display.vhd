---------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Original Engineer: Thomas Kappenman
-- 
-- Create Date:    03/03/2015 09:08:33 PM 
-- Design Name: 
-- Module Name:    seg7decimal 
-- Project Name: Nexys4DDR Keyboard Demo
-- Target Devices: Nexys4DDR
-- Tool Versions: 
-- Description: 7 segment display driver
-- 
-- Dependencies: 
--
-- Revision: Kent Jones Whitworth University
-- Revision 0.01 - File Created
-- Additional Comments: Converted to VHDL
--
---------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;


entity seg7decimal is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           dp : out STD_LOGIC);
end seg7decimal;

architecture Behavioral of seg7decimal is

signal s : STD_LOGIC_VECTOR(2 downto 0);	 
signal digit : STD_LOGIC_VECTOR(3 downto 0);
signal aen : STD_LOGIC_VECTOR(7 downto 0);
signal clkdiv : STD_LOGIC_VECTOR(19 downto 0);

begin

       s <= clkdiv( 19 downto 17 );
       dp <= '1';
       
	   -- Select a 7-seg display based on s
       process(s)
           variable aen : std_logic_vector(7 downto 0) := "11111111";
       begin
           aen := "11111111";
           aen(to_integer(unsigned(s))) := '0'; 
           an <= aen;
       end process;
       
       process ( clk, x, s ) begin
            if rising_edge(clk) then
                case s is
                    when "0000" => digit <= x(3 downto 0); 
                    when "0001" => digit <= x(7 downto 4); 
                    when "0010" => digit <= x(11 downto 8); 
                    when "0011" => digit <= x(15 downto 12);
                    when "0100" => digit <= x(19 downto 16); 
                    when "0101" => digit <= x(23 downto 20);
                    when "0110" => digit <= x(27 downto 24); 
                    when "0111" => digit <= x(31 downto 28);
                    when others => digit <= x(3 downto 0); 
                end case;
            end if;
       end process;
       
       -- Clock divider
       process(clk)
       begin
           if rising_edge(clk) then
               clkdiv <= clkdiv +1;
           end if;
       end process;
       
       	-- Decoder7-segment decoder: hex7seg
       process(digit)
       begin
          case digit is
              when X"0" => seg <= "1000000";     --0
              when X"1" => seg <= "1111001";     --1
              when X"2" => seg <= "0100100";     --2
              when X"3" => seg <= "0110000";     --3
              when X"4" => seg <= "0011001";     --4
              when X"5" => seg <= "0010010";     --5
              when X"6" => seg <= "0000010";     --6
              when X"7" => seg <= "1111000";     --7
              when X"8" => seg <= "0000000";     --8
              when X"9" => seg <= "0010000";     --9
              when X"A" => seg <= "0001000";     --A
              when X"B" => seg <= "0000011";     --b
              when X"C" => seg <= "1000110";     --C
              when X"D" => seg <= "0100001";     --d
              when X"E" => seg <= "0000110";     --E
              when others => seg <= "0001110";   --F
          end case;
       end process;
       

end Behavioral;
