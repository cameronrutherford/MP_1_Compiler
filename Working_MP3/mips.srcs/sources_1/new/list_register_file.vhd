---------------------------------------------------------------------
-- three-port register file
---------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;

entity listRegFile is 
    generic(
        width: integer := 128; 
        regCount: integer := 8
    );
  port(clk:           in  STD_LOGIC;
       we3:           in  STD_LOGIC;
	   -- determine number of address bits based on generic width
       --ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(regCount))))-1) downto 0);
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR(4 downto 0);
       wd3:           in  STD_LOGIC_VECTOR((width-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0);
       led : in STD_LOGIC_VECTOR(3 downto 0));
end;

architecture behave of listRegFile is
  type ramtype is array ((width-1) downto 0) of STD_LOGIC_VECTOR((width-1) downto 0);
  signal mem: ramtype;
  signal key_data : STD_LOGIC_VECTOR (127 downto 0);
begin
  -- three-ported register file
  
  -- write to the third port on rising edge of clock
  -- write address is in wa3
  process(clk) begin
    if rising_edge(clk) then
		if we3 = '1' then 
			mem(to_integer(unsigned(wa3))) <= wd3;
		end if;
    end if;
  end process;
  
  -- This updates the data from the keyboard
  process(led) begin
    case led is
          when "0000" => key_data <= (others => '0'); --nothing
          when "0001" => key_data <= (95 downto 64 => '1', others => '0'); --left
          when "0010" => key_data <= (127 downto 96 => '1', others => '0'); --up
          when "0100" => key_data <= (64 => '1', others => '0'); --right
          when "1000" => key_data <= (96 => '1', others => '0'); --down
          when others => key_data <= (others => '0'); --also nothing
     end case;
  end process;
  
  -- read mem from two separate ports 1 and 2 
  -- addresses are in ra1 and ra2
  process(ra1, ra2, mem, key_data) begin
    if ( to_integer(unsigned(ra1)) = 0) then 
		rd1 <= (others => '0'); -- register 0 holds 0
    else 
		rd1 <= mem(to_integer(unsigned(ra1)));
    end if;
	
    if ( to_integer(unsigned(ra2)) = 0) then 
 		rd2 <= (others => '0'); -- register 0 holds 0
    elsif ( to_integer(unsigned(ra2)) = 8) then
        rd2 <= key_data;
    else
		rd2 <= mem(to_integer( unsigned(ra2)));
    end if;
  end process;
end;