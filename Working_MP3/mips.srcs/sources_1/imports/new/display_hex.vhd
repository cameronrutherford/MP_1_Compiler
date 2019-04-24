library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity display_hex is
	port (
		CLKM : in STD_LOGIC;
		x : in STD_LOGIC_VECTOR(31 downto 0);
		A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
		AN : out STD_LOGIC_VECTOR(7 downto 0);
		DP : out STD_LOGIC;
		LED : out  STD_LOGIC_VECTOR(3 downto 0);
        clk_div: out STD_LOGIC_VECTOR(28 downto 0)		
	 );
end	 display_hex;

architecture display_hex of display_hex is


signal s: STD_LOGIC_VECTOR(3 downto 0);
signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal clkdiv: STD_LOGIC_VECTOR(28 downto 0);	
signal clk : STD_LOGIC;

begin

    clk <= CLKM; 
    clk_div <= clkdiv;           -- output the clkdiv counter
    s <= clkdiv(18 downto 15);	 -- cycle through 7-seg displays
    		
	dp <= '1';			   -- turn off dp
	LED <= digit;		   -- see the code
	
	-- Quad 8-to-1 MUX to select binary code to display
	process(s)
	begin
		case s is
		when "0000" => digit <= x(3 downto 0);
		when "0001" => digit <= x(7 downto 4);
		when "0010" => digit <= x(11 downto 8);
		when "0011" => digit <= x(15 downto 12);		
		when "0100" => digit <= x(19 downto 16);
		when "0101" => digit <= x(23 downto 20);	
		when "0110" => digit <= x(27 downto 24);	
		when others => digit <= x(31 downto 28);				
		end case;
	end process;
	
	-- Select a 7-seg display based on s
	process(s)
		variable aen : std_logic_vector(7 downto 0) := "11111111";
	begin
		aen := "11111111";
		aen(conv_integer(s)) := '0'; 
		an <= aen;
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
		   when X"0" => a_to_g <= "0000001";	 --0
		   when X"1" => a_to_g <= "1001111";	 --1
		   when X"2" => a_to_g <= "0010010";	 --2
		   when X"3" => a_to_g <= "0000110";	 --3
		   when X"4" => a_to_g <= "1001100";	 --4
		   when X"5" => a_to_g <= "0100100";	 --5
		   when X"6" => a_to_g <= "0100000";	 --6
		   when X"7" => a_to_g <= "0001101";	 --7
		   when X"8" => a_to_g <= "0000000";	 --8
		   when X"9" => a_to_g <= "0000100";	 --9
		   when X"A" => a_to_g <= "0001000";	 --A
		   when X"B" => a_to_g <= "1100000";	 --b
		   when X"C" => a_to_g <= "0110001";	 --C
		   when X"D" => a_to_g <= "1000010";	 --d
		   when X"E" => a_to_g <= "0110000";	 --E
		   when others => a_to_g <= "0111000";	 --F
	   end case;
	end process;
	
end display_hex;