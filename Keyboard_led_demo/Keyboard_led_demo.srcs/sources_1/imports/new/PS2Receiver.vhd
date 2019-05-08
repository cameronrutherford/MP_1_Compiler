--------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Original Engineer: Thomas Kappenman
-- 
-- Create Date: 03/03/2015 09:06:31 PM
-- Design Name: 
-- Module Name: PS2Reciver
-- Project Name: Nexys4DDR Keyboard Demo
-- Target Devices: Nexys4DDR
-- Tool Versions: 
-- Description: This project takes keyboard input from the PS2 port,
--  and outputs the keyboard scan code to the 7 segment display on the board.
--  The scan code is shifted left 2 characters each time a new code is
--  read.
-- 
-- Dependencies: 
-- 
-- Revision: Kent Jones, Whitworth University
-- Converted to VHDL
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity PS2Receiver is
    Port ( clk : in STD_LOGIC;
           kclk : in STD_LOGIC;
           kdata : in STD_LOGIC;
           keycodeout : out STD_LOGIC_VECTOR (31 downto 0));
end PS2Receiver;

architecture Behavioral of PS2Receiver is

    component debounce is
        Port ( clk : in STD_LOGIC;
               I0 : in STD_LOGIC;
               I1 : in STD_LOGIC;
               o0 : out STD_LOGIC;
               o1 : out STD_LOGIC);
    end component;
    
    signal kclkf, kdataf : STD_LOGIC;
    signal datacur : STD_LOGIC_VECTOR( 7 downto 0);
    signal dataprev : STD_LOGIC_VECTOR( 7 downto 0);
    signal cnt : STD_LOGIC_VECTOR(3 downto 0);
    signal keycode : STD_LOGIC_VECTOR(31 downto 0);
    signal flag : STD_LOGIC;  -- register

begin

    -- This implements a serial to parallel conversion
    process ( kclkf, kdataf, cnt ) begin
        if falling_edge(kclkf) then
            case cnt is
                when "0001" => datacur(0) <= kdataf; 
                when "0010" => datacur(1) <= kdataf;   
                when "0011" => datacur(2) <= kdataf;  
                when "0100" => datacur(3) <= kdataf; 
                when "0101" => datacur(4) <= kdataf;
                when "0110" => datacur(5) <= kdataf;  
                when "0111" => datacur(6) <= kdataf;  
                when "1000" => datacur(7) <= kdataf;  
                when "1001" => flag <= '1';
                when others => flag <= '0';                                                  
            end case;
            
            -- update the counter            
            if cnt <= "1001" then 
                cnt <= cnt + 1;
            elsif cnt = "1010" then 
                cnt <= "0000";
            end if;
        end if;
    end process;
    
    -- This is a shift register where bits shift left
    -- 8 bits at a time. Holds current and previous 
    -- scan code information from the keyboard
    process ( flag, dataprev, datacur, keycode ) 
    begin 
        if rising_edge( flag ) then
            keycode( 31 downto 24 ) <= keycode( 23 downto 16 );
            keycode( 23 downto 16 ) <= keycode( 15 downto 8 );
            keycode( 15 downto 8 ) <= dataprev;   
            keycode( 7 downto 0 ) <= datacur;   
            dataprev <= datacur;                 
        end if; 
    end process;
    
    -- Data out from the keyboard
    keycodeout <= keycode;

    -- synchronize the clk and data signals from the keyboard
    debouncer : debounce port map( clk => clk, I0 => kclk, I1 => kdata, o0 => kclkf, o1 => kdataf );

end Behavioral;
