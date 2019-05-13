----------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Original Engineer: Thomas Kappenman
-- 
-- Create Date: 03/03/2015 09:06:31 PM
-- Design Name: 
-- Module Name: top
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
-- Revision: Kent Jones Whithworth University
-- Revision 0.01 - File Created
-- Additional Comments: Converted to VHDL from Verilog
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keyboard_top is
    Port ( CLK100MHZ : in STD_LOGIC;
           PS2_CLK : in STD_LOGIC;
           PS2_DATA : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR(3 downto 0)
           --UART_TXD : out STD_LOGIC 
           );
end keyboard_top;

architecture Behavioral of keyboard_top is

    component PS2Receiver is
        Port ( clk : in STD_LOGIC;
               kclk : in STD_LOGIC;
               kdata : in STD_LOGIC;
               keycodeout : out STD_LOGIC_VECTOR (31 downto 0)
               );
    end component;

    signal CLK50MHZ : STD_LOGIC := '0';
    signal keycode : STD_LOGIC_VECTOR(31 downto 0);
    

begin

    process ( CLK100MHZ ) begin
        if rising_edge( CLK100MHZ ) then
            CLK50MHZ <= not CLK50MHZ;
        end if;
    end process;

    keyboard : PS2Receiver port map( clk => CLK50MHZ, kclk => PS2_CLK, kdata => PS2_DATA, keycodeout => keycode );
    process(keycode) begin
        if (keycode(7 downto 0) = x"6B") then
            LED(3 downto 0) <= "0001";
        elsif (keycode(7 downto 0) = x"1C") then
            LED(3 downto 0) <= "0001";
        elsif (keycode(7 downto 0) = x"75") then
            LED(3 downto 0) <= "0010";
        elsif (keycode(7 downto 0) = x"1D") then
                LED(3 downto 0) <= "0010";
        elsif (keycode(7 downto 0) = x"74") then 
            LED(3 downto 0) <= "0100";
        elsif (keycode(7 downto 0) = x"23") then 
                LED(3 downto 0) <= "0100";
        elsif (keycode(7 downto 0) = x"72") then
            LED(3 downto 0) <= "1000"; 
         elsif (keycode(7 downto 0) = x"1B") then
             LED(3 downto 0) <= "1000"; 
        elsif (keycode(7 downto 0) = x"F0") then
            LED(3 downto 0) <= "0000"; 
        else 
            LED(3 downto 0) <= "0000";
    end if;
    end process;
end Behavioral;