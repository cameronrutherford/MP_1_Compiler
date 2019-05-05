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
        mem_address : out STD_LOGIC_VECTOR(4 downto 0);
        memWrite : out STD_LOGIC
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
    rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0));
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
    process (opcode, regDataOutA, regDataOutB)
    begin
        -- If this is a list operation
         if opcode(4) = '0' then
             A <= (others => 'X');
             B <= (others => 'X');
        else
            operandA <= opA;
            operandB <= opB;
            A <= regDataOutA;
            B <= regDataOutB;
        end if;
         
        --mem_bus_out <= B;
        case opcode is 
            when  "00010001" => 
                decoded_opcode <= "0000";               --list add
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= chinchilla;
            --TODO: implement the following in parser and hardware(?)
            when "00010100" => 
                decoded_opcode <= "0010";               --list and
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= chinchilla;
            when "00010101" => 
                decoded_opcode <= "0011";               --list or
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= chinchilla;
            when "00010110" => 
                decoded_opcode <=  "0100";              --list xor
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= chinchilla;
            when "00010111" => 
                decoded_opcode <=  "0101";              --list not B
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= chinchilla;
            --TODO : implement subtract and assign it an opcode
            when "10010011" =>
                decoded_opcode <= "XXXX"; 
                internalMemWrite <= '1';                --list store
                regWrite <= '0';
                regDataIn <= chinchilla;
            when "10010010" =>                          --list load
                decoded_opcode <= "XXXX"; 
                regWrite <= '1';
                internalMemWrite <= '0';
                regDataIn <= mem_bus_in;
            when others => decoded_opcode <= "XXXX";    -- if we get a bad opcode, undefined output
         end case;
         --regWrite <= v_regWrite;
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
            rd2 => regDataOutB
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
        mem_address <= operandB;
end ListProc;
