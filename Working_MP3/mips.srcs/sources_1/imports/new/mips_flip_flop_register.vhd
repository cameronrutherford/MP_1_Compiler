library IEEE; 
use IEEE.STD_LOGIC_1164.all;  
use IEEE.NUMERIC_STD.all;

entity flopr is -- flip-flop with synchronous reset
  generic(width: integer);
  port(clk, reset: in  STD_LOGIC;
       d:          in  STD_LOGIC_VECTOR((width-1) downto 0);
       q:          out STD_LOGIC_VECTOR((width-1) downto 0));
end;

architecture asynchronous of flopr is
begin
  process(clk, reset) begin
    if reset = '1' then  
	  -- q <= std_logic_vector(to_unsigned(0,width)); -- alternate
	  q <= (others => '0');
    elsif clk'event and clk = '1' then
      q <= d;
    end if;
  end process;
end;


