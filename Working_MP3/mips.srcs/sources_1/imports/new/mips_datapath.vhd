library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;

entity datapath is  -- MIPS datapath
  generic(width: integer);
  port(clk, reset:        in  STD_LOGIC;
       memtoreg, pcsrc:   in  STD_LOGIC;
       alusrc:            in  STD_LOGIC;
       mov_enable:        in  STD_LOGIC;
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
  component mips_alu generic(width: integer);
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
	port(a: in  STD_LOGIC_VECTOR(18 downto 0);
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
  
  -- The datapath needs a way to keep track of the zero flag
  component bit_reg generic(N: integer);
    port(   load: in std_logic;
            clk: in std_logic;
            clr : in std_logic;
            data_in : in std_logic_vector(N-1 downto 0);
            data_out : out std_logic_vector(N-1 downto 0));
  end component;
  
  -- The signals to wire the datapath components together
  signal writereg: STD_LOGIC_VECTOR(4 downto 0);
  signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR((width-1) downto 0);
  signal signimm, signimmsh: STD_LOGIC_VECTOR((width-1) downto 0);
  signal srca, srcb, res_mux_out, result: STD_LOGIC_VECTOR((width-1) downto 0);
  signal const_zero: STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
  signal four: STD_LOGIC_VECTOR((width-1) downto 0);
  signal z_prev: STD_LOGIC_VECTOR(0 downto 0);
  signal reg_2 : STD_LOGIC_VECTOR((width-1) downto 0);
  signal alu_result : STD_LOGIC_VECTOR((width-1) downto 0);

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
	zreg: bit_reg generic map(1)     port map(clk => clk, clr => '0', data_in => z_prev, data_out(0) => zero, load => '1');

	-- register file logic
	rf: regfile generic map(width) port map(clk => clk, we3 => regwrite, 
	                                       ra1 => instr(23 downto 19), 
	                                       ra2 => instr(18 downto 14),
										   wa3 => instr(23 downto 19), wd3 => result, 
										   rd1 => srca, rd2 => reg_2);
    
    -- select between alu output and data read from memory	
	resmux: mux2 generic map(width) port map( d0 => alu_result, d1 => readdata, 
	                                           s => memtoreg, y => res_mux_out);
	
	-- sign extend immediate data
	se: signext generic map(width) port map( a => instr(18 downto 0), y => signimm);

	-- ALU logic
	srcbmux: mux2 generic map(width) port map( d0 => reg_2, d1 => signimm, 
	                                            s => alusrc, y => srcb);
	                                       
	mov_mux: mux2 generic map(width) port map( d0 => res_mux_out, d1 => reg_2, s => mov_enable, y => result);
	
	-- wire up the main ALU
	mainalu: mips_alu generic map(width) port map(a => srca, b => srcb, 
	                                          alucontrol => alucontrol, result => alu_result, zero => z_prev(0));
	                                          
	writedata <= srca;
	aluout <= signimmsh;
end;


