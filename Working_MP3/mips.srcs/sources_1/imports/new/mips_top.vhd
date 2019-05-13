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
       fast_clk : in STD_LOGIC;
       reset: in STD_LOGIC;
       out_port_1 : out STD_LOGIC_VECTOR(31 downto 0);
       vga_output : out STD_LOGIC_VECTOR(127 downto 0);
       led_signal : in STD_LOGIC_VECTOR(3 downto 0)
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
  
  component listProc is
      port (
          CLOCK : in STD_LOGIC;
          reset : in STD_LOGIC;
          opcode : in STD_LOGIC_VECTOR(7 downto 0);
          opA : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register
          opB : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register or memory location
          mem_bus_in :  in STD_LOGIC_VECTOR(127 downto 0);    -- data bus for reading from memory
          mem_bus_out : out STD_LOGIC_VECTOR(127 downto 0);   -- data bus for writing to memory
          memWrite : out STD_LOGIC;
          LED_signal : in STD_LOGIC_VECTOR(3 downto 0)
      );
  end component;

  -- signals to wire the instruction memory, data memory and mips processor together
  signal readdata: STD_LOGIC_VECTOR(31 downto 0);
  signal instr: STD_LOGIC_VECTOR(31 downto 0);
  signal writedata, dataadr: STD_LOGIC_VECTOR(31 downto 0);
  signal memwrite: STD_LOGIC;
  signal pc: STD_LOGIC_VECTOR(31 downto 0); 
  signal write_enable_b, write_enable_beta : STD_LOGIC;
  signal address_b : STD_LOGIC_VECTOR(4 downto 0);
  signal data_into_b, data_out_of_b : STD_LOGIC_VECTOR(127 downto 0);
  signal vga_out : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
  signal LED_sig : STD_LOGIC_VECTOR(3 downto 0);
         
  
  begin     
      -- wire the vga register out
      vga_output <= vga_out;
      
      -- wire this up...
      LED_sig <= LED_signal;
      
      -- wire output port signal
      out_port_1 <= instr;
      
      -- This is not the most elegant solution to this problem...
      process(instr) begin
            address_b <= instr(11 downto 7);
      end process;

      
      -- This is here so that when we get the vga reg address we disable writing to dmem
      process(address_b, write_enable_b) begin
            case(address_b) is
                when "11111" =>
                        write_enable_beta <= '0';
                when others =>
                        write_enable_beta <= write_enable_b;
            end case;
      end process;
      
      -- Register that will store the information to go out to the vga
      process(clk, data_into_b, address_b, instr) begin
      if rising_edge(clk) then
            case(instr(31 downto 24)) is
                  when "10010111" =>
                          vga_out <= data_into_b;
                  when others =>
                          vga_out <= vga_out;
            end case;
      end if;      
      end process;
      
      
	  -- wire up the processor and memories
	  mips1: mips generic map(32) port map(clk => clk, reset => reset, pc => pc, 
	                                       instr => instr, memwrite => memwrite, aluout => dataadr, 
	                                       writedata => writedata, readdata => readdata);
	  imem1: imem generic map(32) port map( a => pc(7 downto 2), rd => instr);
	  dmem1: dmem port map( clk => fast_clk, wea => memwrite, web => write_enable_beta, addra => dataadr(6 downto 0),
	                        ena => '1', enb => '1', addrb => address_b, dinb => data_into_b,
	                        doutb => data_out_of_b, dina => writedata, douta => readdata);
	                                        
	  listProcessor : listProc port map(CLOCK => clk, reset => '0', opcode => instr(31 downto 24),
	                                    opA => instr(23 downto 19), opB => instr(18 downto 14),
	                                    mem_bus_in => data_out_of_b, mem_bus_out => data_into_b,
	                                    memWrite => write_enable_b, LED_signal => LED_sig);
	                                    
  end mips_top;


