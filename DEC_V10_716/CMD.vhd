----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:11:37 07/09/2014 
-- Design Name: 
-- Module Name:    CMD - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CMD is
port(
   clk : in STD_LOGIC;	
	
	timer_i :in STD_LOGIC_VECTOR(31 DOWNTO 0);
	counter_i : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	stop_mode_i : in STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	list_mode_length_i: in STD_LOGIC_VECTOR(1 DOWNTO 0);


	time_out_o : 
	count_out_o :


-----------------
)
end CMD;

architecture Behavioral of CMD is

begin
process(clk,rst,)
begin
if rst='1' then

	
elsif rising_edge(clk) then

end if;

end process;

end Behavioral;

