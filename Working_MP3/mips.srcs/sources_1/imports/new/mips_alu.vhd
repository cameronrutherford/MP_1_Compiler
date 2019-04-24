---------------------------------------------------------------
-- Arithmetic/Logic unit with add/sub, AND, OR, set less than
---------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity alu is 
  generic(width: integer);
  port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(2 downto 0);
       result:     inout STD_LOGIC_VECTOR((width-1) downto 0);
       zero:       out STD_LOGIC);
end;

architecture behave of alu is
  signal b2, sum, slt: STD_LOGIC_VECTOR((width-1) downto 0);
  signal const_zero : STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
begin

  -- hardware inverter for 2's complement 
  b2 <= not b when alucontrol(2) = '1' else b;
  
  -- hardware adder
  sum <= a + b2 + alucontrol(2);
  
  -- slt should be 1 if most significant bit of sum is 1
  slt <= ( const_zero(width-1 downto 1) & '1') when sum((width-1)) = '1' else (others =>'0');
  
  -- determine alu operation from alucontrol bits 0 and 1
  with alucontrol(1 downto 0) select result <=
    a and b when "00",
    a or b  when "01",
    sum     when "10",
    slt     when others;
	
  -- set the zero flag if result is 0
  zero <= '1' when result = const_zero else '0';
  
end;
