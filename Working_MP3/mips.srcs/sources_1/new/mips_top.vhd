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

entity mips_top is -- top-level design for testing
  port( 
       clk : in STD_LOGIC;
       reset: in STD_LOGIC;
       out_port_1 : out STD_LOGIC_VECTOR(31 downto 0)
	   );
end;

---------------------------------------------------------
-- Architecture Definitions
---------------------------------------------------------

architecture mips_top of mips_top is


  component imem generic(width: integer);
    port(a:  in  STD_LOGIC_VECTOR(5 downto 0);
         rd: out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;
  
  component dmem generic(width: integer);
    port(clk, we:  in STD_LOGIC;
       a, wd:    in STD_LOGIC_VECTOR((width-1) downto 0);
       rd:       out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;
  
  component mips generic(width: integer);
    port(clk, reset:      in  STD_LOGIC;
       pc:                inout STD_LOGIC_VECTOR((width-1) downto 0);
       instr:             in  STD_LOGIC_VECTOR((width-1) downto 0);
       memwrite:          out STD_LOGIC;
       aluout, writedata: inout STD_LOGIC_VECTOR((width-1) downto 0);
       readdata:          in  STD_LOGIC_VECTOR((width-1) downto 0));
  end component;

  -- signals to wire the instruction memory, data memory and mips processor together
  signal readdata: STD_LOGIC_VECTOR(31 downto 0);
  signal instr: STD_LOGIC_VECTOR(31 downto 0);
  signal writedata, dataadr: STD_LOGIC_VECTOR(31 downto 0);
  signal memwrite: STD_LOGIC;
  signal pc: STD_LOGIC_VECTOR(31 downto 0); 
         
  
  begin     
      -- wire output port signal
      out_port_1 <= instr;
      
	  -- wire up the processor and memories
	  mips1: mips generic map(32) port map(clk => clk, reset => reset, pc => pc, 
	                                       instr => instr, memwrite => memwrite, aluout => dataadr, 
	                                       writedata => writedata, readdata => readdata);
	  imem1: imem generic map(32) port map( a => pc(7 downto 2), rd => instr);
	  dmem1: dmem generic map(32) port map( clk => clk, we => memwrite, a => dataadr, 
	                                        wd => writedata, rd => readdata);  
  end mips_top;


