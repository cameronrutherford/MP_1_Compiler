-- Listing 13.3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity vga_top is
   port(
      clk, reset: in std_logic;
      hsync, vsync: out  std_logic;
      red: out std_logic_vector(3 downto 0);
      green: out std_logic_vector(3 downto 0);
      blue: out std_logic_vector(3 downto 0);  
      vga_input : in STD_LOGIC_VECTOR(127 downto 0)           
   );
end vga_top;

architecture vga_top of vga_top is
   signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
   signal player_xl, player_xr, player_yt, player_yb: integer := 0;
   signal video_on, pixel_tick: std_logic;
   signal red_reg, red_next: std_logic_vector(3 downto 0) := (others => '0');
   signal green_reg, green_next: std_logic_vector(3 downto 0) := (others => '0');
   signal blue_reg, blue_next: std_logic_vector(3 downto 0) := (others => '0'); 
   signal dir_x, dir_y : integer := 1;  
   signal x, y : integer := 0;       
   signal box_xl, box_yt, box_xr, box_yb : integer := 50; 
   signal update_pos : std_logic := '0';  
   signal game_over : std_logic := '0';
begin
   -- instantiate VGA sync circuit
   vga_sync_unit: entity work.vga_sync
    port map(clk=>clk, reset=>reset, hsync=>hsync,
               vsync=>vsync, video_on=>video_on,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               p_tick=>pixel_tick);
               
    -- box position
    box_xl <= x;  
    box_yt <= y;
    box_xr <= x + 100;
    box_yb <= y + 100;  
    
    -- player position
    process(vga_input) begin
        player_xl <= to_integer(unsigned(vga_input(63 downto 32)));
        player_yt <= to_integer(unsigned(vga_input(31 downto 0)));
        player_xr <= player_xl + 20;
        player_yb <= player_yt + 20;
    end process;
    
    -- process to generate update position signal
    process ( video_on )
        variable counter : integer := 0;
    begin
        if rising_edge(video_on) then
            counter := counter + 1;
            if counter > 120 then
                counter := 0;
                update_pos <= '1';
            else
                update_pos <= '0';
            end if;
         end if;
    end process;

    -- compute the position and direction of box 
    process ( update_pos, x, y, box_xr, box_xl, box_yt, box_yb, dir_x, dir_y )
    begin
        if rising_edge(update_pos) then 
            if (box_xr > 639) and (dir_x = 1) then
                dir_x <= -1;
                x <= 539;
            elsif (box_xl < 1) and (dir_x = -1) then
                dir_x <= 1;    
                x <= 0;
            else
                x <= x + dir_x;
            end if;
            
            if (box_yb > 479) and (dir_y = 1) then
                dir_y <= -1;
                y <= 379;
            elsif (box_yt < 1) and (dir_y = -1) then
                dir_y <= 1;   
                y <= 0; 
            else        
                y <= y + dir_y;                
            end if;  
        end if; 
        
    end process;
    
    
    -- process to generate next colors           
    process (pixel_x, pixel_y)
    begin
           if (unsigned(pixel_x) > box_xl) and (unsigned(pixel_x) < box_xr) and
           (unsigned(pixel_y) > box_yt) and (unsigned(pixel_y) < box_yb) then
               -- foreground box color yellow
               red_next <= "1111";
               green_next <= "1111";
               blue_next <= "0000"; 
           elsif (unsigned(pixel_x) > player_xl) and (unsigned(pixel_x) < player_xr) and
                 (unsigned(pixel_y) > player_yt) and (unsigned(pixel_y) < player_yb) then
               red_next <= "0000";
               green_next <= "1111";
               blue_next <= "0000";
           else    
               -- background color blue
               red_next <= "0000";
               green_next <= "0000";
               blue_next <= "1111";
           end if;   
    end process;

   -- generate r,g,b registers
   process ( video_on, pixel_tick, red_next, green_next, blue_next)
   begin
      if rising_edge(pixel_tick) then
          if (video_on = '1') then
            red_reg <= red_next;
            green_reg <= green_next;
            blue_reg <= blue_next;   
          else
            red_reg <= "0000";
            green_reg <= "0000";
            blue_reg <= "0000";                    
          end if;
      end if;
   end process;
   
   red <= STD_LOGIC_VECTOR(red_reg);
   green <= STD_LOGIC_VECTOR(green_reg); 
   blue <= STD_LOGIC_VECTOR(blue_reg);
     
end vga_top;