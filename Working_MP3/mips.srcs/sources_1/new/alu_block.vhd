library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity alu_block is
    port(
        opcode : in STD_LOGIC_VECTOR(3 downto 0);
        opA : in STD_LOGIC_VECTOR(127 downto 0);      -- operand A
        opB : in STD_LOGIC_VECTOR(127 downto 0);      -- operand B
        chinchilla : out signed(127 downto 0)       -- Results vector. Double check sign integrity
    );
end alu_block;

architecture Behavioral of alu_block is

-- Used to collect the output of the argument registers
-- type regArray is array (0 to 1) of std_logic_vector(127 downto 0);

component list_alu is
    generic(N : integer := 32);
    port(
        A : in signed(N - 1 downto 0); --operand A
        B : in signed(N -1 downto 0); --operand B
        OP : in unsigned(3 downto 0); --opcode
        Y : out signed(N-1 downto 0) --output Y 
    );
end component;

--alu signals
signal A1, A2, A3, A4: signed(31 downto 0);
signal B1, B2, B3, B4: signed(31 downto 0);
signal ctrl : unsigned(3 downto 0);

begin
    process(opA,  opB)
        begin
            A1 <= signed(opA(127 downto 96));
            A2 <= signed(opA(95 downto 64));
            A3 <= signed(opA(63 downto 32));
            A4 <= signed(opA(31 downto 0));
            B1 <= signed(opB(127 downto 96));
            B2 <= signed(opB(95 downto 64));
            B3 <= signed(opB(63 downto 32));
            B4 <= signed(opB(31 downto 0));
    end process;

    alu0 : list_alu
        port map (
            A => A1,
            B => B1,
            OP => unsigned(opcode),
            Y => chinchilla(127 downto 96)
        );
        
    alu1 : list_alu
        port map (
            A => A2,
            B => B2,
            OP => unsigned(opcode),
            Y => chinchilla(95 downto 64)
        );

    alu2 : list_alu
        port map (
            A => A3,
            B => B3,
            OP => unsigned(opcode),
            Y => chinchilla(63 downto 32)
        );
        
    alu3 : list_alu
        port map (
            A => A4,
            B => B4,
            OP => unsigned(opcode),
            Y => chinchilla(31 downto 0)
        );

end Behavioral;
