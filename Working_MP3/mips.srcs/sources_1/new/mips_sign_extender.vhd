library IEEE; 
use IEEE.STD_LOGIC_1164.all;

-- sign extender for immediate values that are half the generic width
entity signext is 
  generic( width: integer );
  port(a: in  STD_LOGIC_VECTOR((width/2)-1 downto 0);
       y: out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of signext is
  signal const_zero : STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
  signal const_neg : STD_LOGIC_VECTOR((width-1) downto 0) := (others => '1');  
begin
  process( a, const_zero, const_neg )
  begin 
    if a((width/2)-1) = '0' then
        y <= const_zero((width-1) downto (width/2)) & a;
    else 
        y <=  const_neg((width-1) downto (width/2)) & a;
    end if;
  end process; 
end;