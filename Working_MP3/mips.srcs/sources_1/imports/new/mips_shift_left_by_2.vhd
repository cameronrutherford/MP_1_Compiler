--------------------------------------------------------
-- generic shift left by 2
--------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity sl2 is 
  generic(width: integer);
  port(a: in  STD_LOGIC_VECTOR(width-1 downto 0);
       y: out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of sl2 is
begin
  y <= a( ((width-2)-1) downto 0) & "00";
end;