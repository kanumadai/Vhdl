----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:28:12 07/09/2014 
-- Design Name: 
-- Module Name:    TLP_GEN - Behavioral 
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

entity TLP_GEN is
port(
	clk : in STD_LOGIC; 
---read from the fifo,which connect to the aurora   
   rd_en_o : out STD_LOGIC;
   data_i : in STD_LOGIC_VECTOR(31 DOWNTO 0);
   empty_i : in STD_LOGIC;
---write to the fifo ,which connect to the pcie 
   rd_en_i : in STD_LOGIC;
   data_o : out STD_LOGIC_VECTOR(31 DOWNTO 0);
   empty_o : out STD_LOGIC;
---
	data_count_i : in 
	
	timer_i :in STD_LOGIC_VECTOR(31 DOWNTO 0);
	counter_i : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	stop_mode_i : in STD_LOGIC_VECTOR(1 DOWNTO 0);
	list_mode_length_o: in STD_LOGIC_VECTOR(31 DOWNTO 0);

	time_out_i : in STD_LOGIC;  
	count_out_i :in STD_LOGIC;  
	start_i:in STD_LOGIC;  
	stop_i:in STD_LOGIC;  
	);
end TLP_GEN;

architecture Behavioral of TLP_GEN is

constant PET_ACK 						:std_logic_vector(7 downto 0):= x"22";
constant PET_NACK 					:std_logic_vector(7 downto 0):= x"23";
constant PET_ALLPRO 					:std_logic_vector(7 downto 0):= x"24";
constant PET_FRAME_ACK				:std_logic_vector(7 downto 0):= x"25";


constant LIST_LEN_318_DW 					:std_logic_vector(31 downto 0):= x"0000013e";
constant LIST_LEN_1998_DW 					:std_logic_vector(31 downto 0):= x"000007ce";
constant LIST_LEN_3998_DW 					:std_logic_vector(31 downto 0):= x"00000f9e";
constant LIST_LEN_7998_DW					:std_logic_vector(31 downto 0):= x"00001f3e";



component fifo_32_16k
port  (
	rst : in STD_LOGIC;

    wr_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : in STD_LOGIC;
	 full : out STD_LOGIC;
 
    rd_clk : in STD_LOGIC;    
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    empty : out STD_LOGIC

);
begin
P_DAS_RX:process(clk,rst,rx_state,one_acq_done,rx_fifo_empty,rx_fifo_data,header_data,stop_mode,byte_cnt,
			time_out,count_out,read_back,gantry_rx_done,protocol_data_cnt,mode_select,pet_gc_fifo_rd_length,
			gc_rd_fifo_rd_en)
begin
if rst='1' then
	rx_fifo_rd_en<='0';
	rx_state<= idle;
	soft_reset_o<='1';
	A<="00";
	CS<='0';
	WR_tmp<='0';
	cdata_out<=(others=>'1');
	working<='0';
	debuging<='0';
	counting<='0';	
	stop<='0';
	led_gc<='0';	
	led_debug<='0';
	led_work<='0';
	tx_header_comm<=(others=>'0');
	tx_header_length_B<=(others=>'0');
	test_wait_cnt<=(others=>'0');	
	frame_wait_ack<='0';		
---	
	gc_rd_fifo_rd_en_clr <= '0';
	PET_GC_CTRL_B_length<=(others=>'0');
	pet_gc_fifo_rd_length<=(others=>'0');

	channel_test<='0';
	
elsif rising_edge(clk) then
	case rx_state is
	when idle =>
		wr_en<='0';
		rd_en_o<='0';
		if empty_i='0' then					-- this means that the acs has send a cmd to the DA;
			rd_en_o<='1';
			rx_state<= RD_HEADER_CMD_STATE;
		else
			rx_state<= idle;
		end if;
	when RD_HEADER_CMD_STATE =>
		header_data<=data_i;
		if data_i(31 downto 8) = x"7e7e7e" then
			rx_state<= RD_HEADER_LENGTH_STATE;
		else
			rd_en_o<='0';
			rx_state<= idle;
		end if;
	when RD_HEADER_LENGTH_STATE =>
		if empty_i='0' then			
			case header_data(7 downto 0) is
--///////////////////////////////
				
				when PET_LISTMODE	=>			--
					din<= header_data;
					wr_en<='1';						
					if data_count_i < 400 then
						header_length<=LIST_LEN_318_DW;
						rx_state <= WR_HEADER_LENGTH_STATE;
					elsif data_count_i < 2000 then
						header_length<=LIST_LEN_1998_DW;
						rx_state <= WR_HEADER_LENGTH_STATE;	
					elsif data_count_i < 4000 then
						header_length<=LIST_LEN_3998_DW;
						rx_state <= WR_HEADER_LENGTH_STATE;
					else
						header_length<=LIST_LEN_7998_DW;
						rx_state <= WR_HEADER_LENGTH_STATE;
					end if;				
				when others =>
					wr_en<='0';	
					rx_state <= idle;
			end case;
		else
			rx_state<= RD_HEADER_LENGTH_STATE;
		end if;		
----////////////////////////////
	when WR_HEADER_LENGTH_STATE =>
		din<= header_length;
		wr_en<='1';			
		if header_length >0 then
			if empty_i='0' then
				list_data<=data_i;
				header_length<=header_length-4;
				rx_state <= WR_LIST_DATA_STATE;
			else 
				rx_state <= WR_LIST_DATA_STATE;
			end if;
		else
			rd_en_o<='0';
			rx_state<= idle;
		end if;
	
	when WR_LIST_DATA_STATE =>	
		if header_length >0 then
			if empty_i='0' then
				din<=list_data;
				wr_en<='1';
				list_data<=data_i;
				header_length<=header_length-4;
				rx_state <= WR_LIST_DATA_STATE;
			else 
				wr_en<='0';
				rx_state <= WR_LIST_DATA_STATE;
			end if;
		else
			din<=list_data;
			wr_en<='1';
			rd_en_o<='0';
			if (stop_i='1' and stop_mode="11") or count_out='1' or time_out='1' then		-- stop
				header_data<=x"7e7e7e" & PET_ACK;
				header_length<=x"00000000";
				rx_state <= WR_STOP_CMD_STATE;
			elsif stop_i='1' and stop_mode="01" and time_out='0' then		--timing stop
				header_data<=x"7e7e7e" & PET_NACK;
				header_length<=x"00000000";
				rx_state <= WR_STOP_CMD_STATE;
			elsif stop_i='1' and stop_mode="10" and count_out='0' then		--counting stop
				header_data<=x"7e7e7e" & PET_NACK;
				header_length<=x"00000000";
				rx_state <= WR_STOP_CMD_STATE;
			else				
				rx_state<= idle;
			end if;
		end if;	
	when WR_STOP_CMD_STATE =>	
		din<=header_data;
		wr_en<='1';
		rx_state <= WR_STOP_LEN_STATE;
	when WR_STOP_LEN_STATE =>	
		din<=header_length;
		wr_en<='1';
		rx_state <= idle;		
				
	when others => 
		rx_state <= idle;
	end case;
end if;

end process;

end Behavioral;

