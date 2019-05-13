
library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
  port(op:                 in  STD_LOGIC_VECTOR(7 downto 0);
       memtoreg, memwrite: out STD_LOGIC;
       mov_enable:         out STD_LOGIC;
       branch, alusrc:     out STD_LOGIC;
       regwrite:           out STD_LOGIC;
       jump:               out STD_LOGIC;
       aluop:              out  STD_LOGIC_VECTOR(1 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(8 downto 0);
begin
  process(op) begin
    case op is
    when "00000000" => controls <= "100000XX1"; -- mov
    when "00000001" => controls <= "100000000"; -- add
    when "10000000" => controls <= "110000XX0"; -- movi
    when "10000001" => controls <= "110000000"; -- addi
    when "10000100" => controls <= "110010XX0"; -- lw
    when "10000101" => controls <= "010100XX0"; -- sw
    when "01000000" => controls <= "0X1000XX0"; -- beq
    when "00010001" => controls <= "0X0000XX0"; -- ladd
    when "10010010" => controls <= "0X0000XX0"; -- lload
    when "10010011" => controls <= "0X0000XX0"; -- lstore
    when "10010111" => controls <= "0X0000XX0"; -- vgastore
    when "00100000" => controls <= "0X0001XX0"; -- jmp
    when others => controls <= "---------"; -- illegal op
    end case;
  end process;

  regwrite <= controls(8);
  alusrc   <= controls(7);
  branch   <= controls(6);
  memwrite <= controls(5);
  memtoreg <= controls(4);
  jump     <= controls(3);
  aluop    <= controls(2 downto 1);
  mov_enable <= controls(0);
end;


