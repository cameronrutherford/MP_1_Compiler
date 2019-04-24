------------------------------------------------------------------------------
-- Data Memory
------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_UNSIGNED.all;  
use IEEE.NUMERIC_STD.all;

entity dmem is -- data memory
  port(clk, wea, web, ena, enb:   in STD_LOGIC;
       addra:                     in STD_LOGIC_VECTOR(6 downto 0);
       dina:                      in STD_LOGIC_VECTOR(31 downto 0);
       douta:                     out STD_LOGIC_VECTOR(31 downto 0);
       addrb :                    in STD_LOGIC_VECTOR(4 DOWNTO 0);
       dinb :                     in STD_LOGIC_VECTOR(127 DOWNTO 0);
       doutb :                    out STD_LOGIC_VECTOR(127 DOWNTO 0)
);
end;

architecture behave of dmem is

component dual_port_ram is
    PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );
    end component;

begin

  MULTI_PORT_REG : dual_port_ram
    port map(clka => clk, clkb => clk, addra => addra, dina => dina, wea(0) => wea, ena => ena, enb => enb,
                web(0) => web, addrb => addrb, dinb => dinb, douta => douta, doutb => doutb);
                
end;