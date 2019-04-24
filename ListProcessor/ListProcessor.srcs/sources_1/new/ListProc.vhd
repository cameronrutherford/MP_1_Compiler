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
        mem_bus_in : STD_LOGIC_VECTOR(127 downto 0);
        mem_bus_out : out STD_LOGIC_VECTOR(127 downto 0); 
        ready : out STD_LOGIC
    );
end ListProc;

architecture ListProc of ListProc is

type regArray is array (0 to 1) of std_logic_vector(127 downto 0);


component  cntrl_unit is
  Port (CLOCK : in std_logic;
        reset: in std_logic;
        opcode_collection : std_logic_vector(7 downto 0);
        ready : out std_logic;
        reg_name : in std_logic_vector(4 downto 0);
        address_to_mem : in std_logic_vector(18 downto 0)
    
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

component alu_block is
    Port(
        opcode : in std_logic_vector(3 downto 0);
        opA : in std_logic_vector(127 downto 0);
        opB : in std_logic_vector(127 downto 0);
        chinchilla: out signed(127 downto 0)
    );
end component;

--register signals
signal regWrite, memWrite : std_logic;
signal dataout : std_logic_vector(127 downto 0);
signal A, B : std_logic_vector(127 downto 0);
signal regArgs : regArray;
signal chinchilla : std_logic_vector(127 downto 0);
signal decoded_opcode : std_logic_vector (3 downto 0);

begin
-- may need a process to synchronize the alu outputs into chinchilla before passing it to the result register    
    process(opA,  opB)
    begin
        A <= regArgs(to_integer(signed( opA )))(127 downto 0);
        B <= regArgs(to_integer(signed( opB )))(127 downto 0);           
    end process;

    process (opcode)
        begin
            regWrite <= '0';
            memWrite <= '0';
            mem_bus_out <= B;
            case opcode is 
                when  "00001001" => decoded_opcode <= "0000";   --list add
                --TODO: implement the following in parser and hardware(?)
                when "00010100" => decoded_opcode <= "0010";    --list and
                when "00010101" => decoded_opcode <= "0011";    --list or
                when "00010110" => decoded_opcode <=  "0100";   --list xor
                when "00010111" => decoded_opcode <=  "0101";   --list not B
                --TODO : implement subtract and assign it an opcode
                when "10010011" => regWrite <= '1';             --list store
                when "10010010" => memWrite <= '1';             --list load
                when others => decoded_opcode <= "XXXX"; -- if we get a bad opcode, undefined output
             end case;
       end process;

    results : bit128_reg
        port map(
            load => regWrite,
            clk => CLOCK,
            clr => reset, 
            data_in => chinchilla,
            data_out => mem_bus_out
        );
        
    regA : bit128_reg
        port map(
            load => regWrite,
            clk => CLOCK,
            clr => reset, 
            data_in => mem_bus_in,
            data_out => regArgs(0)
        );
            
    regB : bit128_reg
        port map(
            load => regWrite,
            clk => CLOCK,
            clr => reset, 
            data_in => mem_bus_in,
            data_out => regArgs(1)
        );
        
    alus : alu_block
        port map(
            opcode => opcode,
            opA => A,
            opB => B,
            std_logic_vector(chinchilla) => chinchilla
        );    
end ListProc;
