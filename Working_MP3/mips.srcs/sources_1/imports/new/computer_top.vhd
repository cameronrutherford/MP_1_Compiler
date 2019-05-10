----------------------------------------------------------
-- mips computer wired to hexadecimal display and reset 
-- button
---------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity computer_top is -- top-level design for testing
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
end;

---------------------------------------------------------
-- Architecture Definitions
---------------------------------------------------------

architecture computer_top of computer_top is

  component display_hex
	port (
		CLKM : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(31 downto 0);
        A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
        AN : out STD_LOGIC_VECTOR(7 downto 0);
        DP : out STD_LOGIC;
        LED : out  STD_LOGIC_VECTOR(3 downto 0);
        clk_div: out STD_LOGIC_VECTOR(28 downto 0)
	 );
  end component;

  component mips_top  -- top-level design for testing
    port( 
         clk : in STD_LOGIC;
         fast_clk : in STD_LOGIC;
         reset: in STD_LOGIC;
         out_port_1 : out STD_LOGIC_VECTOR(31 downto 0)
         );
  end component;
  
  component vga_top is
     port(
        clk, reset: in std_logic;
        hsync, vsync: out  std_logic;
        red: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0)           
     );
  end component;
  
  -- this is a slowed signal clock provided to the mips_top
  -- set it from a lower bit on clk_div for a faster clock
  signal clk : STD_LOGIC := '0';
  signal speedy_clock : STD_LOGIC := '0';
  
  -- clk_div is a 29 bit counter provided by the display hex 
  -- use bits from this to provide a slowed clock
  signal clk_div : STD_LOGIC_VECTOR(28 downto 0);

  -- this data bus will hold a value for display by the 
  -- hex display  
  signal display_bus: STD_LOGIC_VECTOR(31 downto 0); 
         
  
  begin
      -- wire up slow clock 
      clk <= clk_div(2); -- use a lower bit for a faster clock
      -- clk <= clk_div(0);  -- use this in simulation (fast clk)
      speedy_clock <= clk_div(0); 
           
	  -- wire up the processor and memories
	  mips1: mips_top port map( clk => clk, reset => reset, out_port_1 => display_bus, fast_clk => speedy_clock );
	                                       
	  display: display_hex port map( CLKM  => CLKM,  x => display_bus, 
	           A_TO_G => A_TO_G,  AN => AN,  DP => DP,  LED => LED, clk_div => clk_div );
	  
	  vga: vga_top port map(clk => CLKM, reset => reset, hsync => VGA_HS, vsync => VGA_VS, red => VGA_R, green => VGA_G, blue => VGA_B);                                      
	  
  end computer_top;
