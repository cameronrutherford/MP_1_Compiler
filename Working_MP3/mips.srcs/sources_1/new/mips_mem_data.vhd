------------------------------------------------------------------------------
-- Data Memory
------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_UNSIGNED.all;  
use IEEE.NUMERIC_STD.all;

entity dmem is -- data memory
  generic(width: integer);
  port(clk, we:  in STD_LOGIC;
       a, wd:    in STD_LOGIC_VECTOR((width-1) downto 0);
       rd:       out STD_LOGIC_VECTOR((width-1) downto 0));
end;

architecture behave of dmem is
  type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR((width-1) downto 0);
  signal mem: ramtype;
begin
  process ( clk, a ) is
  begin
    if clk'event and clk = '1' then
        if (we = '1') then 
			mem( to_integer(unsigned(a(7 downto 2))) ) <= wd;
        end if;
    end if;
    rd <= mem( to_integer(unsigned(a(7 downto 2))) ); -- word aligned
  end process;
end;