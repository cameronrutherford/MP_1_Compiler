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
  
  component dmem
     port(clk, wea, web, ena, enb:   in STD_LOGIC;
        addra:                     in STD_LOGIC_VECTOR(6 downto 0);
        dina:                      in STD_LOGIC_VECTOR(31 downto 0);
        douta:                     out STD_LOGIC_VECTOR(31 downto 0);
        addrb :                    in STD_LOGIC_VECTOR(4 DOWNTO 0);
        dinb :                     in STD_LOGIC_VECTOR(127 DOWNTO 0);
        doutb :                    out STD_LOGIC_VECTOR(127 DOWNTO 0));
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
	  dmem1: dmem port map( clk => clk, wea => memwrite, web => '0', addra => dataadr(6 downto 0),
	                        ena => '1', enb => '1', addrb => "00000", dinb => (others => '0'),
	                                        dina => writedata, douta => readdata);  
  end mips_top;


