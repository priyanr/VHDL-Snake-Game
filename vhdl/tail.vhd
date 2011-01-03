--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the TAILREAD logic for the gamelogic_state
-- 
--              
-- Assisted by:
--
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.gamelogic_pkg.all;

entity tail_logic is
  port(
    gamelogic_state    : in  gamelogic_state_t;
    clk_slow           : in  std_logic;
    ext_reset          : in  std_logic;
    address_a_tailread : out unsigned(12 downto 0);
    tail_read_data     : in  unsigned(11 downto 0);
    tail_write_data    : out unsigned(11 downto 0);
    tailread_done      : out std_logic;
    tailwrite_done     : out std_logic
    );
end tail_logic;

architecture Behavioral of tail_logic is

  signal state              : unsigned(1 downto 0)  := (others => '0');
  signal next_tail_cell_int : unsigned(12 downto 0) := (others => '0');
  signal next_direction     : unsigned(2 downto 0)  := (others => '0');
  signal tailread_done_int  : std_logic             := '0';
  signal tailwrite_done_int : std_logic             := '0';
  signal tail_write_data_int : unsigned(11 downto 0) := (others => '0');
  

  
begin
  
  address_a_tailread <= next_tail_cell_int;
     tail_write_data_int <= (others => '0');
	  tail_write_data <= tail_write_data_int;
  tailread_done  <= tailread_done_int;
  tailwrite_done <= tailwrite_done_int;



  --purpose: checks what the next_direction of the tail is before it  erases a cell
  --type   : sequential

  p_tail_checker : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
      tailread_done_int  <= '0';
      next_direction     <= "001";      -- reset to moving up
      next_tail_cell_int <= to_unsigned(2520, next_tail_cell_int'length);
      state              <= (others => '0');
    elsif clk_slow'event and clk_slow = '1' then  --     rising clock edge
      if (gamelogic_state = TAIL_READ)then
        if (state = "00") then
          state <= "01";
          if (next_direction = "001") then
            next_tail_cell_int <= to_unsigned(to_integer(next_tail_cell_int) - 80, next_tail_cell_int'length);
          elsif (next_direction = "010") then
            next_tail_cell_int <= to_unsigned(to_integer(next_tail_cell_int) + 1, next_tail_cell_int'length);
          elsif (next_direction = "011") then
            next_tail_cell_int <= to_unsigned(to_integer(next_tail_cell_int) + 80, next_tail_cell_int'length);
          elsif (next_direction = "100") then
            next_tail_cell_int <= to_unsigned(to_integer(next_tail_cell_int) - 1, next_tail_cell_int'length);
          end if;
    --      address_a_tailread_int <= next_tail_cell_int;
        elsif (state = "01") then
          next_direction <= tail_read_data(11 downto 9);
        else
          state             <= (others => '0');
          next_direction    <= tail_read_data(11 downto 9);
          tailread_done_int <= '1';
        end if;
      else
        tailread_done_int <= '0';
        state             <= (others => '0');
      end if;
    end if;
  end process p_tail_checker;





  --purpose: erases the tail cell
  --type   : sequential

  p_tail_eraser : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
			tailwrite_done_int <= '0';
    elsif clk_slow'event and clk_slow = '1' then  --     rising clock edge
      if (gamelogic_state = TAIL_WRITE)then
			tailwrite_done_int <= '1';
        else
          tailwrite_done_int <= '0';
        end if;
    end if;
  end process p_tail_eraser;

end Behavioral;
