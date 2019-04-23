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

component alu is
    generic(N : integer := 32);
    port(
        A : in signed(N - 1 downto 0); --operand A
        B : in signed(N -1 downto 0); --operand B
        OP : in unsigned(3 downto 0); --opcode
        Y : out signed(N-1 downto 0) --output Y 
    );
end component;

component bit128_reg is
         generic(N:integer := 128);
      Port ( load: in std_logic;
      clk: in std_logic;
      clr : in std_logic;
      data_in : in std_logic_vector(N-1 downto 0);
      data_out : out std_logic_vector(N-1 downto 0)
    );
end component;

-- Used to collect the output of the argument registers
type regArray is array (0 to 1) of std_logic_vector(127 downto 0);

--alu signals
signal intOpA : integer;
signal A0, B0 : std_logic_vector(127 downto 0);
signal A1, A2, A3, A4: signed(31 downto 0);
signal B1, B2, B3, B4: signed(31 downto 0);
signal chinchilla : unsigned (63 downto 0);
signal ctrl : unsigned(3 downto 0);
signal args : regArray;


signal in0 : signed(31 downto 0);
signal in1: signed(31 downto 0);
signal in2: signed(31 downto 0);
signal in3 : signed(31 downto 0);

signal out0 : signed(31 downto 0);
signal out1: signed(31 downto 0);
signal out2: signed(31 downto 0);
signal out3 : signed(31 downto 0);

signal concat : signed(127 downto 0);

--register signals
signal ld : std_logic;
signal datain : std_logic_vector(127 downto 0);
signal dataout : std_logic_vector(127 downto 0);

begin
    process(opA,  opB)
    begin
        A0 <= args(to_integer(signed( opA )))(127 downto 0);
        B0 <= args(to_integer(signed( opB )))(127 downto 0);
        A1 <= signed(A0(127 downto 96));
        A2 <= signed(A0(95 downto 64));
        A3 <= signed(A0(63 downto 32));
        A4 <= signed(A0(31 downto 0));
        B1 <= signed(B0(127 downto 96));
        B2 <= signed(B0(95 downto 64));
        B3 <= signed(B0(63 downto 32));
        B4 <= signed(B0(31 downto 0));
            
    end process;
    
    intOpA <= to_integer(signed(opA));
    results : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            --data_in => std_logic_vector(out0) & std_logic_vector(out1) & std_logic_vector(out2) & std_logic_vector(out3),
            data_in => std_logic_vector(concat),
            data_out => dataout
        );
        
    regA : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            data_in => datain,
            data_out => args(0)
        );
            
    regB : bit128_reg
        port map(
            load => ld,
            clk => CLOCK,
            clr => reset, 
            data_in => datain,
            data_out => args(1)
        );

    -- TODO: ALU inputs A and B need to select from args, not be hard coded
    alu0 : alu
        port map (
            A => A1,
            B => B1,
            OP => unsigned(opcode),
            Y => concat(127 downto 96)
        );
        
    alu1 : alu
        port map (
            A => A2,
            B => B2,
            OP => unsigned(opcode),
            Y => concat(95 downto 64)
        );

    alu2 : alu
        port map (
            A => A3,
            B => B3,
            OP => unsigned(opcode),
            Y => concat(63 downto 32)
        );
        
    alu3 : alu
        port map (
            A => A4,
            B => B4,
            OP => unsigned(opcode),
            Y => concat(31 downto 0)
        );

end ListProc;
