----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2019 12:48:47 PM
-- Design Name: 
-- Module Name: 128bit_reg - Behavioral
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

entity bit_reg is
         generic(N:integer);
      Port ( load: in std_logic;
      clk: in std_logic;
      clr : in std_logic;
      data_in : in std_logic_vector(N-1 downto 0);
      data_out : out std_logic_vector(N-1 downto 0)
    );
end bit_reg;

architecture Behavioral of bit_reg is
begin
    process(clk, clr)
    begin
    if clr = '1' then
        data_out <= (others => '0');
    elsif clk'event and clk = '1' then
        if load = '1' then
            data_out <= data_in;
            end if;
        end if;
       end process;
    

end Behavioral;
