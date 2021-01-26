----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:31:15 07/30/2013 
-- Design Name: 
-- Module Name:    aurora_module - Behavioral 
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

entity aurora_module is
Port ( 
	reset : in  STD_LOGIC;
   INIT_CLK : in  STD_LOGIC;
	CLK_OUT: OUT STD_LOGIC;  
   reset_out: OUT STD_LOGIC; 
--WRITE TO FIFO_RX
--   m_axis_tready : IN STD_LOGIC;
   m_axis_tvalid : OUT STD_LOGIC;
   m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	
--READ FROM FIFO_TX	 
   s_axis_tvalid : IN STD_LOGIC;
   s_axis_tready : OUT STD_LOGIC;
   s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--SFP Module
	SFP_TX_P : out  STD_LOGIC;
	SFP_TX_N : out  STD_LOGIC;
	SFP_RX_P : in  STD_LOGIC;
	SFP_RX_N : in  STD_LOGIC;

--GTX REF_CLK
	GTXQ1_P : in  STD_LOGIC;
	GTXQ1_N : in  STD_LOGIC;
--LED----
	LED_tx : out  STD_LOGIC;
	LED_rx : out  STD_LOGIC
	);
end aurora_module;

architecture Behavioral of aurora_module is

--component IBUFDS_GTXE1
--
--generic(
--   CLKCM_CFG	    : boolean       := TRUE;
--   CLKRCV_TRST   : boolean       := TRUE;
--   REFCLKOUT_DLY : bit_vector    := b"0000000000"
--);
--
--port(
--   O       : out std_ulogic;
--   ODIV2   : out std_ulogic;
--
--   CEB     : in  std_ulogic;
--   I       : in  std_ulogic;
--   IB      : in  std_ulogic
--   );
--
--end component; 
component IBUFDS
  port (
    O : out std_ulogic;
    I : in std_ulogic;
    IB : in std_ulogic
    );
end component;

component BUFG

port (
    O : out std_ulogic;
    I : in  std_ulogic
    );
end component;


component Aurora_V10_CLOCK_MODULE
port (
    GT_CLK                  : in std_logic;
    GT_CLK_LOCKED           : in std_logic;
    USER_CLK                : out std_logic;
    SYNC_CLK                : out std_logic;
    PLL_NOT_LOCKED          : out std_logic
     );
end component;


COMPONENT aurora_v10
   generic 
(                    
           SIM_GTXRESET_SPEEDUP   :integer :=   0      --Set to 1 to speed up sim reset
);
	PORT(
		TX_D : IN std_logic_vector(0 to 31);
		TX_SRC_RDY_N : IN std_logic;
		DO_CC : IN std_logic;
		WARN_CC : IN std_logic;
		RXP : IN std_logic;
		RXN : IN std_logic;
		GTXD4 : IN std_logic;
		USER_CLK : IN std_logic;
		SYNC_CLK : IN std_logic;
		RESET : IN std_logic;
		POWER_DOWN : IN std_logic;
		LOOPBACK : IN std_logic_vector(2 downto 0);
		GT_RESET : IN std_logic;          
		TX_DST_RDY_N : OUT std_logic;
		RX_D : OUT std_logic_vector(0 to 31);
		RX_SRC_RDY_N : OUT std_logic;
		TXP : OUT std_logic;
		TXN : OUT std_logic;
		HARD_ERR : OUT std_logic;
		SOFT_ERR : OUT std_logic;
		CHANNEL_UP : OUT std_logic;
		LANE_UP : OUT std_logic;
		TX_OUT_CLK : OUT std_logic;
		TX_LOCK : OUT std_logic
		);
	END COMPONENT;

component Aurora_V10_STANDARD_CC_MODULE

port (
   -- Clock Compensation Control Interface
   WARN_CC        : out std_logic;
   DO_CC          : out std_logic;
   -- System Interface
   PLL_NOT_LOCKED : in std_logic;
   USER_CLK       : in std_logic;
   RESET          : in std_logic
    );
end component;

component Aurora_V10_RESET_LOGIC
port (
       RESET                  : in std_logic;
       USER_CLK               : in std_logic;
       INIT_CLK               : in std_logic;
       GT_RESET_IN            : in std_logic;
       TX_LOCK_IN             : in std_logic;
       PLL_NOT_LOCKED         : in std_logic;

--       INIT_CLK_O             : out std_logic;  
       SYSTEM_RESET           : out std_logic;
       GT_RESET_OUT           : out std_logic
    );
end component;

signal loopback_i: std_logic_vector(2 downto 0);
signal GTXQ1_left_i,tx_out_clk_i,tx_lock_i,user_clk_i,sync_clk_i,pll_not_locked_i: std_logic;
signal tx_tvalid_i,tx_tready_i,rx_tvalid_i: std_logic;
signal tx_data_i,rx_data_i: std_logic_vector(31 downto 0);

signal hard_err_i,soft_err_i,channel_up_i,lane_up_i,warn_cc_i,do_cc_i,system_reset_i,power_down_i: std_logic;
signal gt_reset_i,init_clk_i,lane_up_reduce_i,rst_cc_module_i: std_logic;
signal tx_tmp,last_data_valid,reset_1,reset_2,in_reset,trans_ready,reset_a,buf_tx_out_clk_i: std_logic;

begin
-- ___________________________Clock Buffers________________________
IBUFDS_i :  IBUFDS
port map (
     I     => GTXQ1_P,
     IB    => GTXQ1_N,
     O     => GTXQ1_left_i
     );
-- Instantiate a clock module for clock division
      BUFG_i : BUFG
      port map(
           I => tx_out_clk_i ,
           O => buf_tx_out_clk_i
              );


clock_module_i : Aurora_V10_CLOCK_MODULE
port map (
     GT_CLK              => buf_tx_out_clk_i,
     GT_CLK_LOCKED       => tx_lock_i,
     USER_CLK            => user_clk_i,
     SYNC_CLK            => sync_clk_i,
     PLL_NOT_LOCKED      => pll_not_locked_i
         );
aurora_module_i : Aurora_V10
        generic map(
                    SIM_GTXRESET_SPEEDUP => 1
                   )
                   		
port map   (
-- AXI TX Interface
           TX_D              => tx_data_i,
           TX_SRC_RDY_N        => tx_tvalid_i,
           TX_DST_RDY_N        => tx_tready_i,
--  AXI RX Interface
           RX_D             => rx_data_i,
           RX_SRC_RDY_N       => rx_tvalid_i,
-- GT Serial I/O
           RXP              => SFP_RX_P,
           RXN              => SFP_RX_N,
           TXP              => SFP_TX_P,
           TXN              => SFP_TX_N,
-- GT Reference Clock Interface
           GTXD4    => GTXQ1_left_i,
-- Error Detection Interface
           HARD_ERR       => hard_err_i,
           SOFT_ERR       => soft_err_i,
-- Status
           CHANNEL_UP       => channel_up_i,
           LANE_UP          => lane_up_i,
-- Clock Compensation Control Interface
           WARN_CC          => warn_cc_i,
           DO_CC            => do_cc_i,
-- System Interface
           USER_CLK         => user_clk_i,
           SYNC_CLK         => sync_clk_i,
           RESET            => reset_a,   --system_reset_i,
           POWER_DOWN       => power_down_i,
           LOOPBACK         => loopback_i,
           GT_RESET         => gt_reset_i,
           TX_OUT_CLK       => tx_out_clk_i,
--           INIT_CLK_IN      => init_clk_i,
           TX_LOCK          => tx_lock_i
        );
        
    lane_up_reduce_i    <=  lane_up_i;
    rst_cc_module_i     <=  not lane_up_reduce_i;          

standard_cc_module_i : Aurora_V10_STANDARD_CC_MODULE
port map (
-- Clock Compensation Control Interface
           WARN_CC        => warn_cc_i,
           DO_CC          => do_cc_i,
-- System Interface
           PLL_NOT_LOCKED => pll_not_locked_i,
           USER_CLK       => user_clk_i,
           RESET          => rst_cc_module_i 
        );
        
        
        
RESET_1<=not RESET;
RESET_2<=RESET_1;        
reset_logic_i : Aurora_V10_RESET_LOGIC
port map (
           RESET            => RESET_2,
           USER_CLK         => user_clk_i,
           INIT_CLK         => INIT_CLK,
           GT_RESET_IN      => RESET,     --power on reset
           TX_LOCK_IN       => tx_lock_i,
           PLL_NOT_LOCKED   => pll_not_locked_i,

--           INIT_CLK_O       => init_clk_i,  
           SYSTEM_RESET     => system_reset_i,
           GT_RESET_OUT     => gt_reset_i
        );
---------------------------------------------
in_reset<=system_reset_i or hard_err_i or soft_err_i or (not channel_up_i) or (not lane_up_i);
reset_out<=in_reset;
reset_a<=system_reset_i or hard_err_i or soft_err_i;
CLK_OUT<=user_clk_i;
power_down_i     <= '0';
loopback_i       <= "000";


------------RX Module--------------------------------
--rx_fifo_ready  open
m_axis_tvalid<= not rx_tvalid_i;
m_axis_tdata<=rx_data_i;

LED_rx<=rx_tvalid_i;
LED_tx<=tx_tready_i;
--LED_rx<=channel_up_i and lane_up_i;
--LED_tx<=rx_tvalid_i or tx_tready_i;
------------TX Module-----------------
s_axis_tready<=not tx_tready_i;
tx_tvalid_i<=not s_axis_tvalid;
tx_data_i<=s_axis_tdata;
--trans_ready<= tx_tready_i and not empty;
--rd_en<=trans_ready;
--tx_tvalid_i<=((trans_ready and tx_tmp) or last_data_valid);
--tx_data_i<=din;
--TX_Module:process(user_clk_i,in_reset,tx_tmp,trans_ready,empty,last_data_valid,tx_tready_i)
--begin
--   if rising_edge(user_clk_i) then
--      if in_reset='1' then
--         tx_tmp<='0';
--         last_data_valid<='0';
--      else
--         if trans_ready='1' and tx_tmp='0' then
--            tx_tmp<='1';
--         else null;
--         end if;
--         if tx_tmp='1' and tx_tready_i='1' and empty='1' then
--            last_data_valid<='1';
--         else null;
--         end if;
--         if last_data_valid='1' and tx_tready_i='1' then
--            last_data_valid<='0';
--            tx_tmp<='0';  
--         else null;
--         end if;
--      end if;
--   end if;
--end process;
        
end Behavioral;

