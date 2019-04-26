
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity list_alu_sim is
end list_alu_sim;

architecture Behavioral of list_alu_sim is
    component alu
    generic(N : integer := 32);
     port (  A: in signed(N - 1 downto 0); --operand A
             B : in signed(N -1 downto 0); --operand B
             OP : in unsigned(3 downto 0); --opcode
             Y : out signed(N-1 downto 0) --output Y
            );
end component;

signal A: signed(31 downto 0);
signal B: signed(31 downto 0);
signal OP: unsigned(3 downto 0);
signal Y : signed(31 downto 0);
--signal ctrl : unsigned(3 downto 0);

begin

uut: alu port map (A => A, B => B, OP => OP, Y=> Y);

sim_process : process
    begin
        --ADD--
        OP <= "0000";
            for i in 0 to 31 loop
                for j in 0 to 31 loop
                    A <= to_signed(i, 31);
                    B <= to_signed(j, 31);
                    wait for 1 ns;              
                    assert Y = A + B report "Failed A + B";
            end loop;
        end loop;
        
        --AND--
           OP <= "0010";
            for i in 0 to 31 loop
                for j in 0 to 31 loop
                    A <= to_signed(i, 31);
                    B <= to_signed(j, 31);
                    wait for 1 ns;              
                    assert Y = A and B report "Failed A and B";
            end loop;
        end loop;
        
        --OR--
            OP <= "0011";
            for i in 0 to 31 loop
                for j in 0 to 31 loop
                    A <= to_signed(i, 31);
                    B <= to_signed(j, 31);
                    wait for 1 ns;              
                    assert Y = A or B report "Failed A or B";
            end loop;
        end loop;
        
        --XOR--
            OP <= "0100";
            for i in 0 to 31 loop
                for j in 0 to 31 loop
                    A <= to_signed(i, 31);
                    B <= to_signed(j, 31);
                    wait for 1 ns;              
                    assert Y = A xor B report "Failed A xor B";
            end loop;
        end loop;
        
        --NOT B--
            OP <= "0101";
            for i in 0 to 31 loop
                for j in 0 to 31 loop
                    A <= to_signed(i, 31);
                    B <= to_signed(j, 31);
                    wait for 1 ns;              
                    assert Y = not B report "Failed not B";
            end loop;
        end loop;
    end process;
end Behavioral;
