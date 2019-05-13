library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity mips_testbench is
end;

architecture mips_testbench of mips_testbench is

    component computer_top is -- top-level design for testing
     port( 
           CLKM : in STD_LOGIC;
           A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
           AN : out STD_LOGIC_VECTOR(7 downto 0);
           DP : out STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR(3 downto 0);
           reset : in STD_LOGIC;
           VGA_HS, VGA_VS : out STD_LOGIC;
           VGA_R, VGA_B, VGA_G : out STD_LOGIC_VECTOR(3 downto 0)
           );
    end component;

    --signal clk, speedy_clock : STD_LOGIC;
    signal clk : STD_LOGIC;
    signal reset : STD_LOGIC;
    signal out_port_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal vga_output : STD_LOGIC_VECTOR(127 downto 0);
    
begin
  
  -- Generate simulated mips clock with 10 ns period
  clkproc: process begin
    clk <= '1';
    wait for 5 ns; 
    clk <= '0';
    wait for 5 ns;
  end process;
  
--speedyClockProc: process begin
--    speedy_clock <= '1';
--    wait for 5 ns; 
--    speedy_clock <= '0';
--    wait for 5 ns;
--end process;
  
  -- Generate reset for first few clock cycles
  reproc: process begin
    reset <= '1';
    wait for 22 ns;
    reset <= '0';
    wait;
  end process;
  
  -- instantiate device to be tested
  dut: computer_top port map( 
       clkm => clk, 
       reset => reset);

end mips_testbench;