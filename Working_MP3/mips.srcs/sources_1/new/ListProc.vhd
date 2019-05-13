library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;

-- List Control Unit
-- Wait 20s for ready on LL SL

entity ListProc is
    port (
        CLOCK : in STD_LOGIC;
        reset : in STD_LOGIC;
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        opA : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register
        opB : in STD_LOGIC_VECTOR(4 downto 0);      -- operand register or memory location
        mem_bus_in : in STD_LOGIC_VECTOR(127 downto 0);    -- data bus for reading from memory
        mem_bus_out : out STD_LOGIC_VECTOR(127 downto 0);   -- data bus for writing to memory
        memWrite : out STD_LOGIC;
        LED_signal : in STD_LOGIC_VECTOR(3 downto 0)
    );
end ListProc;

architecture ListProc of ListProc is

-- The datapath needs a register file component
component listRegFile generic (width : integer; regCount : integer);
port(clk:           in  STD_LOGIC;
    -- write enable
    we3:           in  STD_LOGIC;
    -- determine number of address bits based on generic width component
    -- read address 1, read address 2, write address 3
    --ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(width))))-1) downto 0);
    ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(regCount))))-1) downto 0);
    -- date to write to the register file
    wd3:           in  STD_LOGIC_VECTOR((width-1) downto 0);
    -- outputs from the register file
    rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0);
    led : in STD_LOGIC_VECTOR(3 downto 0));
end component;


component alu_block is
    Port(
        opcode : in std_logic_vector(3 downto 0);
        opA : in std_logic_vector(127 downto 0);
        opB : in std_logic_vector(127 downto 0);
        chinchilla: out signed(127 downto 0)
    );
end component;

--register signals
signal dataout : std_logic_vector(127 downto 0);
signal A, B : std_logic_vector(127 downto 0);
signal chinchilla : std_logic_vector(127 downto 0);
signal decoded_opcode : std_logic_vector (3 downto 0);
signal operandA, operandB : STD_LOGIC_VECTOR(4 downto 0);
signal regDataOutA, regDataOutB : STD_LOGIC_VECTOR(127 downto 0);
signal regDataIn : STD_LOGIC_VECTOR(127 downto 0);
signal regWrite : STD_LOGIC;
signal internalmemWrite : STD_LOGIC;

begin

-- This process sets redDataIn
process (opcode, chinchilla, mem_bus_in) begin
    case opcode(7) is
        --when "10010010" => regDataIn <= mem_bus_in;
        --when others => regDataIn <= chinchilla;
        when '1' => regDataIn <= mem_bus_in;
        when '0' => regDataIn <= chinchilla;
        when others => regDataIn <= (others => 'X');
    end case;
end process;

-- This process sets decoded opcode
process (opcode)
begin
    case opcode is
        when "00010001" => decoded_opcode <= "0000";
        when others => decoded_opcode <= "XXXX";
    end case;
end process;


-- This process sets A, B, operandA and operandB
process (opcode, opA, opB, regDataOutA, regDataOutB)
begin
    case opcode(4) is
        when '0' =>
            A <= (others => 'X');
            B <= (others => 'X');
            operandA <= (others => 'X');
            operandB <= (others => 'X');
        when others =>
            A <= regDataOutA;
            B <= regDataOutB;
            operandA <= opA;
            operandB <= opB;
    end case;
end process;

-- This process sets regWrite and internalMemWrite
process (opcode)
begin
    case opcode is
        when "10010011" => regWrite <= '0';
                           internalMemWrite <= '1';
        when "10010111" => regWrite <= '0';
                           internalMemwrite <= '0';
        when "00010001" => regWrite <= '1';
                           internalMemwrite <= '0';
        when "10010010" => regWrite <= '1';
                           internalMemwrite <= '0';
        when others => regWrite <= '0';
                       internalMemWrite <= '0';
    end case;
end process;
    

    listRegs : listRegFile
        generic map (
            width => 128,
            regCount => 32
        )
        port map(
            clk => CLOCK,
            ra1 => operandA,
            ra2 => operandB,
            wa3 => operandA,
            wd3 => regDataIn,
            we3 => regWrite,
            rd1 => regDataOutA,
            rd2 => regDataOutB,
            led => LED_signal
        );

    alus : alu_block
        port map(
            opcode => decoded_opcode,
            opA => A,
            opB => B,
            std_logic_vector(chinchilla) => chinchilla
        );   
        memWrite <= internalMemWrite;
        mem_bus_out <= regDataOutA;
end ListProc;
