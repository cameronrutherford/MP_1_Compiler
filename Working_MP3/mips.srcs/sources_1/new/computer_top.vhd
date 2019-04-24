--------------------------------------------------
-- mipssingletop.vhd
-- David_Harris@hmc.edu 30 May 2006
-- Single Cycle MIPS testbench & mem
-- Single Cycle MIPS testbench & mem
-- Modified and updated to standard libraries by Kent Jones
--------------------------------------------------

---------------------------------------------------------
-- Entity Declarations
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
       reset : in STD_LOGIC
	   );
end;

---------------------------------------------------------
-- Architecture Definitions
---------------------------------------------------------

architecture computer_top of computer_top is

  component display_hex
	port (
		clk : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(31 downto 0);
        A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
        AN : out STD_LOGIC_VECTOR(7 downto 0);
        DP : out STD_LOGIC;
        LED : out  STD_LOGIC_VECTOR(3 downto 0);
        clkdiv: out STD_LOGIC_VECTOR(28 downto 0)
	 );
  end component;

  component mips_top  -- top-level design for testing
    port( 
         clk : in STD_LOGIC;
         reset: in STD_LOGIC;
         out_port_1 : out STD_LOGIC_VECTOR(31 downto 0)
         );
  end component;
  
  -- signals to wire the instruction memory, data memory and mips processor together
  signal instr, readdata: STD_LOGIC_VECTOR(31 downto 0);
  signal clkdiv : STD_LOGIC_VECTOR(28 downto 0);
  signal clk : STD_LOGIC := '0';
  
  signal writedata, dataadr: STD_LOGIC_VECTOR(31 downto 0);
  signal memwrite: STD_LOGIC;
  signal pc: STD_LOGIC_VECTOR(31 downto 0); 
  signal hexdisp: STD_LOGIC_VECTOR(31 downto 0); 
         
  
  begin
      -- wire up slow clock 
      -- clk <= clkdiv(0);  -- use this for simulation (fast clk)
      clk <= clkdiv(27); -- use this for synthesis
      
      -- put instruction hex on the led hex displays
      hexdisp <= instr;
      
	  -- wire up the processor and memories
	  mips1: mips generic map(32) port map(clk => clk, reset => reset, pc => pc, 
	                                       instr => instr, memwrite => memwrite, aluout => dataadr, 
	                                       writedata => writedata, readdata => readdata);
	  imem1: imem generic map(32) port map( a => pc(7 downto 2), rd => instr);
	  dmem1: dmem generic map(32) port map( clk => clk, we => memwrite, a => dataadr, 
	                                        wd => writedata, rd => readdata);
	  display: display_7seg port map( clk  => CLKM,  x => hexdisp, 
	                                   A_TO_G => A_TO_G,  AN => AN,  DP => DP,  LED => LED, clkdiv => clkdiv );                                      
	  
  end computer_top;
