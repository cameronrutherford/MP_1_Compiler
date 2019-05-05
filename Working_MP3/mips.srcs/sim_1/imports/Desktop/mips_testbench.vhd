library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity mips_testbench is
end;

architecture mips_testbench of mips_testbench is

    component mips_top is -- top-level design for testing
      port( 
           clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           out_port_1 : out STD_LOGIC_VECTOR(31 downto 0)
           );
    end component;

    signal clk : STD_LOGIC;
    signal reset : STD_LOGIC;
    signal out_port_1 : STD_LOGIC_VECTOR(31 downto 0);
    
begin
  
  -- Generate simulated mips clock with 10 ns period
  clkproc: process begin
    clk <= '1';
    wait for 20 ns; 
    clk <= '0';
    wait for 20 ns;
  end process;
  
  -- Generate reset for first few clock cycles
  reproc: process begin
    reset <= '1';
    wait for 44 ns;
    reset <= '0';
    wait;
  end process;
  
  -- instantiate device to be tested
  dut: mips_top port map( 
       clk => clk, 
       reset => reset,
       out_port_1 => out_port_1 );

end mips_testbench;