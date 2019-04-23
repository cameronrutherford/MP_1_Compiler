library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

-- List Control Unit
-- Wait 20s for ready on LL SL

entity ListProc is
    port (
        CLOCK : in STD_LOGIC;
        reset : in STD_LOGIC;
        opcode : in STD_LOGIC_VECTOR(3 downto 0);
        opA : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register
        opB : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register or memory location
        result : out STD_LOGIC_VECTOR(127 downto 0); 
        ready : out STD_LOGIC
    );
end ListProc;

architecture ListProc of ListProc is

type regArray is array (0 to 1) of std_logic_vector(127 downto 0);

component bit128_reg is
    generic(N:integer := 128);
    Port ( load: in std_logic;
        clk: in std_logic;
        clr : in std_logic;
        data_in : in std_logic_vector(N-1 downto 0);
        data_out : out std_logic_vector(N-1 downto 0)
    );
end component;

component alu_block is
    Port(
        opcode : in std_logic_vector(3 downto 0);
        opA : in std_logic_vector(4 downto 0);
        opB : in std_logic_vector(4 downto 0);
        regValues : in regArray;
        chinchilla: out signed(127 downto 0)
    );
end component;

--register signals
signal ld : std_logic;
signal datain : std_logic_vector(127 downto 0);
signal dataout : std_logic_vector(127 downto 0);
signal A, B : std_logic_vector(127 downto 0);
signal regArgs : regArray;

begin
-- may need a process to synchronize the alu outputs into chinchilla before passing it to the result register    
    process(opA,  opB)
    begin
        A <= regArgs(to_integer(signed( opA )))(127 downto 0);
        B <= regArgs(to_integer(signed( opB )))(127 downto 0);           
end process;
    
    results : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            data_in => std_logic_vector(chinchilla),
            data_out => dataout
        );
        
    regA : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            data_in => datain,
            data_out => regArgs(0)
        );
            
    regB : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            data_in => datain,
            data_out => regArgs(1)
        );
        
    alus : alu_block
        port map(
            opcode => opcode,
            opA => A,
            opB => B,
            std_logic_vector(chinchilla) => result
        );    
end ListProc;
