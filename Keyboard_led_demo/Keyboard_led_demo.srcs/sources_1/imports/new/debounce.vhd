--------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Original Engineer: Thomas Kappenman
-- 
-- Create Date: 03/03/2015 09:06:31 PM
-- Design Name: 
-- Module Name: debounce
-- Project Name: Nexys4DDR Keyboard Demo
-- Target Devices: Nexys4DDR
-- Tool Versions: 
-- Description: Syncrhonize with keyboard clk and data signals
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

entity debounce is
    Port ( clk : in STD_LOGIC;
           I0 : in STD_LOGIC;
           I1 : in STD_LOGIC;
           o0 : out STD_LOGIC;
           o1 : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is

    signal cnt0, cnt1 : STD_LOGIC_VECTOR(4 downto 0);
    signal Iv0,Iv1 : STD_LOGIC := '0';
    signal out0, out1 : STD_LOGIC;

begin
    process ( clk, cnt0 ) begin
        if rising_edge( clk ) then
            if I0 = Iv0 then 
                if cnt0 = 19 then
                    o0 <= I0;
                else
                    cnt0 <= cnt0 + 1;
                end if;
            else
                cnt0 <= "00000";
                Iv0 <= I0;
            end if;
            if I1 = Iv1 then 
                if cnt1 = 19 then
                    o1 <= I1;
                else
                    cnt1 <= cnt1 + 1;
                end if;
            else
                cnt1 <= "00000";
                Iv1 <= I1;
            end if;
        end if;
    end process;
end Behavioral;
