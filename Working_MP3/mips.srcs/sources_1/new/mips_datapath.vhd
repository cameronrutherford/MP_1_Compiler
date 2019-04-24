library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;

entity datapath is  -- MIPS datapath
  generic(width: integer);
  port(clk, reset:        in  STD_LOGIC;
       memtoreg, pcsrc:   in  STD_LOGIC;
       alusrc, regdst:    in  STD_LOGIC;
       regwrite, jump:    in  STD_LOGIC;
       alucontrol:        in  STD_LOGIC_VECTOR(2 downto 0);
       zero:              out STD_LOGIC;
       pc:                inout STD_LOGIC_VECTOR((width-1) downto 0);
       instr:             in  STD_LOGIC_VECTOR((width-1) downto 0);
       aluout, writedata: inout STD_LOGIC_VECTOR((width-1) downto 0);
       readdata:          in  STD_LOGIC_VECTOR((width-1) downto 0));
end;

architecture struct of datapath is

  -- The datapath needs an ALU component
  component alu generic(width: integer);
  port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(2 downto 0);
       result:     inout STD_LOGIC_VECTOR((width-1) downto 0);
       zero:       out STD_LOGIC);
  end component;

  -- The datapath needs a register file component
  component regfile generic(width: integer);
  port(clk:           in  STD_LOGIC;
       we3:           in  STD_LOGIC;
	   -- determine number of address bits based on generic width component
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(width))))-1) downto 0);
       wd3:           in  STD_LOGIC_VECTOR((width-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;

  -- The datapath needs an adder component for the program counter  etc. 
  component adder generic(width: integer);
  port(a, b: in  STD_LOGIC_VECTOR((width-1) downto 0);
       y:    out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;
  
  -- The datapath needs a shift left by 2 component for address computations
  component sl2 generic(width: integer);
  port(a: in  STD_LOGIC_VECTOR(width-1 downto 0);
       y: out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  
  -- The datapath needs a sign extender component for immediate values 
  component signext generic( width: integer );
	port(a: in  STD_LOGIC_VECTOR((width/2)-1 downto 0);
	     y: out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;

  -- The datapath needs a flip-flop register component for program counter etc.
  component flopr generic(width: integer);
    port(clk, reset: in  STD_LOGIC;
                  d: in  STD_LOGIC_VECTOR((width-1) downto 0);
                  q: out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;
 
  -- The datapath needs a mux2 component for routing data
  component mux2 generic(width: integer);
    port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
         s:      in  STD_LOGIC;
         y:      out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  
  -- The signals to wire the datapath components together
  signal writereg: STD_LOGIC_VECTOR(4 downto 0);
  signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR((width-1) downto 0);
  signal signimm, signimmsh: STD_LOGIC_VECTOR((width-1) downto 0);
  signal srca, srcb, result: STD_LOGIC_VECTOR((width-1) downto 0);
  signal const_zero: STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
  signal four: STD_LOGIC_VECTOR((width-1) downto 0);

  begin
    -- Wire up all the components for the datapath unit
    
    -- signal to add 4 to program counter
    four <= const_zero((width-1) downto 4) & X"4";
	
	-- next PC logic
	pcjump <= pcplus4((width-1) downto (width-4)) & instr((width-7) downto 0) & "00";
	pcreg:  flopr generic map(width) port map(clk => clk, reset => reset, d => pcnext, q => pc);
	pcadd1: adder generic map(width) port map(a => pc, b => four, y => pcplus4);
	immsh:    sl2 generic map(width) port map(a => signimm, y => signimmsh);
	pcadd2: adder generic map(width) port map(a => pcplus4, b => signimmsh, y => pcbranch);
	pcbrmux: mux2 generic map(width) port map(d0 => pcplus4, d1 => pcbranch, s => pcsrc, y => pcnextbr);
	pcmux:   mux2 generic map(width) port map(d0 => pcnextbr, d1 => pcjump, s => jump, y => pcnext);

	-- register file logic
	rf: regfile generic map(width) port map(clk => clk, we3 => regwrite, 
	                                       ra1 => instr(25 downto 21), 
	                                       ra2 => instr(20 downto 16),
										   wa3 => writereg, wd3 => result, 
										   rd1 => srca, rd2 => writedata);

	-- select destination register based on regdst signal
	wrmux: mux2 generic map(5) port map( d0 => instr(20 downto 16), d1 => instr(15 downto 11),
									      s => regdst, y => writereg);
    
    -- select between alu output and data read from memory	
	resmux: mux2 generic map(width) port map( d0 => aluout, d1 => readdata, 
	                                           s => memtoreg, y => result);
	
	-- sign extend immediate data
	se: signext generic map(width) port map( a => instr(((width/2)-1) downto 0), y => signimm);

	-- ALU logic
	srcbmux: mux2 generic map(width) port map( d0 => writedata, d1 => signimm, 
	                                            s => alusrc, y => srcb);
	
	-- wire up the main ALU
	mainalu:  alu generic map(width) port map(a => srca, b => srcb, 
	                                          alucontrol => alucontrol, result => aluout, zero => zero);
end;


