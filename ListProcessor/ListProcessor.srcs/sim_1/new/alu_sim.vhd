library IEEE;

use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;

use IEEE.NUMERIC_STD.all;



ENTITY TestALU IS

END TestALU;



ARCHITECTURE behavior OF TestALU IS

    COMPONENT alu

    PORT(   A  : in  signed(31 downto 0);   -- operand A

            B  : in  signed(31 downto 0);   -- operand B

            OP : in  unsigned(3 downto 0);   -- opcode

            Y  : out signed(31 downto 0)  -- operation result

        );

    END COMPONENT;

    --Inputs

    signal a, b : signed(31 downto 0) := (others => '0');

    signal op : unsigned(3 downto 0);

    --Outputs

    signal y : signed(31 downto 0);

    

BEGIN

    uut: alu PORT MAP ( a => a, b => b, op => op, y => y );

    stim_proc: process

        variable i: INTEGER range 0 to 16;

    begin

        for i in 0 to 16 loop

            a <= to_signed(i, 32);

            b <= to_signed(i, 32);

            op <= to_unsigned(i, 3);

            wait for 2 ns;

            case op is

                --testing the and function

                when "0010" =>

                    assert y = signed(a and b) report "Failed the "&integer'image(i)&" operation.";

                --testing the  or function

                when "0011" =>

                    assert y = signed(a or b) report "Failed the "&integer'image(i)&" operation.";

                --testing the add function

                when "0000" =>

                    assert y = signed(a + b) report "Failed the "&integer'image(i)&" operation.";

                --testing the subtraction function

                when "0001" =>

                    assert y = signed(a - b) report "Failed the "&integer'image(i)&" operation.";

               --testing the 111 do nothing function

                when "0111" =>

                    assert y = "00000000000000000000000000000000" report "Failed the "&integer'image(i)&" operation.";

                --testing the xor function

                when "0100" =>

                    assert y = signed(a xor b) report "Failed the "&integer'image(i)&" operation.";

                --tesintg the not b function

                when "0101" => 

                    assert y = signed(not b) report "Failed the "&integer'image(i)&" operation.";

                when others =>

            end case;

        end loop;

        wait;

    end process;

END;