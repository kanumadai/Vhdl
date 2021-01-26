----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:34:02 09/04/2013 
-- Design Name: 
-- Module Name:    DEC_TOP - Behavioral 
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

entity DEC_TOP is
    generic(
           MODE_SELECT :integer := 0      --select 1 to chose the test mode ,0 to the work mode
           );
    Port ( 

--Aurora interface
           reset_n : in  STD_LOGIC;
			  clkin : in  STD_LOGIC;
			  --SFP Module
			  SFP_TX_P : out  STD_LOGIC;
			  SFP_TX_N : out  STD_LOGIC;
			  SFP_RX_P : in  STD_LOGIC;
			  SFP_RX_N : in  STD_LOGIC;
			  
--			  SFP_LOS : out  STD_LOGIC;
			  SFP_iic_sda : out  STD_LOGIC;
			  SFP_iic_scl : out  STD_LOGIC;
			  SFP_tx_en : out  STD_LOGIC;
			  --GTX REF_CLK
			  MGTCLK_P : in  STD_LOGIC;
			  MGTCLK_N : in  STD_LOGIC;
			  --LED----
			  LEDS: out std_logic_vector(7 downto 0);
			  
			  refclkout : out std_logic;
--PCIe interface			  
			  sys_clk_p         : in std_logic;
			  sys_clk_n         : in std_logic;
			  
			  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
			  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
			  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
			  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)			  
			  
			  
			  );


end DEC_TOP;

architecture Behavioral of DEC_TOP is

component aurora_module is
Port ( 
	reset : in  STD_LOGIC;
   INIT_CLK : in  STD_LOGIC;
	CLK_OUT: OUT STD_LOGIC;  
   reset_OUT: OUT STD_LOGIC;  		--auraro hard reset
--WRITE TO TX_FIFO
--   m_axis_tready : IN STD_LOGIC;
   m_axis_tvalid : OUT STD_LOGIC;
   m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	
--READ FROM  RX_FIFO	 
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
end component;

component xilinx_pci_exp_ep
--generic (FAST_SIMULATION: INTEGER := 0);
port  (

  sys_clk_p         : in std_logic;
  sys_clk_n         : in std_logic;

  sys_reset_n       : in std_logic;

  aurora_offline 	  : in std_logic;
  
  refclkout         : out std_logic;
  
  ------add by lee
    rst_o			: out std_logic;
    rst_txfifo_o			: out std_logic;	 
	 debug_o_1			: out std_logic;
	 debug_o_2			: out std_logic;
--connect to the RX fifo:	pcie-->rx fifo-->aurora
    wr_clk : out STD_LOGIC;
    din_o : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en_o : out STD_LOGIC;
--connect the TX fifo    : aurora-->tx fifo-->pcie
    rd_clk : out STD_LOGIC;    
    rd_en_o : out STD_LOGIC;
    dout_i : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    empty_i : in STD_LOGIC;
	 
    data_count_i : in STD_LOGIC_VECTOR(12 DOWNTO 0);	 
-----------------

  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)

);

end component;
--RX FIFO
component fifo_32_64
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
end component;
--TX _fifo, the real depth is 16k
component fifo_32_512
port  (
	rst : in STD_LOGIC;

    wr_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : in STD_LOGIC;
	 full : out STD_LOGIC;
 
    rd_clk : in STD_LOGIC;    
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    empty : out STD_LOGIC;
	 rd_data_count : out STD_LOGIC_VECTOR(12 DOWNTO 0)

);
end component;

signal aurora_reset,inreset,aurora_clkout,aurora_rst_o,pci_rst_i : std_logic;

signal pci_rst,rx_wr_clk,rx_wr_en,tx_rd_clk,tx_wr_en,tx_full,rx_full : std_logic;
signal tx_rd_en,tx_empty,fifo_rst,rx_rd_en,rx_empty,rst_txfifo,txfifo_rst : std_logic;       
signal rx_din,tx_dout,rx_dout,tx_din,clk_cnt: std_logic_vector(31 downto 0);
signal data_count: std_logic_vector(12 downto 0);


begin


pcie: xilinx_pci_exp_ep
--	generic map(FAST_SIMULATION = 0)
port map(
	sys_clk_p => sys_clk_p,
	sys_clk_n => sys_clk_n,
		
	sys_reset_n => pci_rst_i,
	
	aurora_offline => aurora_rst_o,

	refclkout   => open,
   rst_o			=>pci_rst,
   rst_txfifo_o	=>rst_txfifo,	
	debug_o_1	=> refclkout,		--leds(5),
	debug_o_2	=> leds(0),
--RX fifo ,write part  ,data from the pcie,and write into the rx fifo
   wr_clk => rx_wr_clk,
   din_o => rx_din,
   wr_en_o => rx_wr_en,
--TX fifo, read part  ,read data from the tx fifo and write into the pcie.  
   rd_clk => tx_rd_clk,  
   rd_en_o => tx_rd_en,
   dout_i => tx_dout,
   empty_i => tx_empty,
   data_count_i => data_count,	
-----------------

   pci_exp_rxn => pci_exp_rxn,
   pci_exp_rxp => pci_exp_rxp,
   pci_exp_txn => pci_exp_txn,
   pci_exp_txp => pci_exp_txp
);
RX_FIFO:fifo_32_64 port map(
	rst => inreset,
--RX fifo write part
    wr_clk => rx_wr_clk,
    din => rx_din,
    wr_en => rx_wr_en,
	 full => rx_full,
--RX fifo, read part   
    rd_clk => aurora_clkout,   
    rd_en => rx_rd_en,
    dout => rx_dout,
    empty => rx_empty
);
TX_FIFO:fifo_32_512 port map(
	rst => txfifo_rst,	
--TX fifo write part
    wr_clk => aurora_clkout,
    din => tx_din,
    wr_en => tx_wr_en,
	 full => tx_full,
--TX fifo, read part    
    rd_clk => tx_rd_clk,  
    rd_en => tx_rd_en,
    dout => tx_dout,
    empty => tx_empty,
	 rd_data_count => data_count
);

aurora: aurora_module
 port map(
	reset			=>		aurora_reset,
   init_clk    =>    clkin,
   clk_out     =>    aurora_clkout,
   reset_out   =>    aurora_rst_o,
--WRITE TO TX FIFO;	
--	m_axis_tready			=>		open,	
	m_axis_tvalid			=>  	tx_wr_en,
	m_axis_tdata			=>		tx_din,
--READ FROM RX FIFO
	s_axis_tvalid			=>		(not rx_empty),
	s_axis_tdata			=>		rx_dout,
	s_axis_tready			=>		rx_rd_en,

--SFP Module
	SFP_RX_P		=>		SFP_RX_P,
	SFP_RX_N 	=>		SFP_RX_N,
	SFP_TX_P 	=>		SFP_TX_P,
	SFP_TX_N		=>		SFP_TX_N,

--GTX REF_CLK
	GTXQ1_P		=>		MGTCLK_P,
	GTXQ1_N  	=>		MGTCLK_N,
--LED----
	LED_tx		=>		LEDS(7),
	LED_rx		=>		LEDs(6)
	);
	
aurora_reset <= not reset_n;
pci_rst_i <=  reset_n;		-- on board hard reset
--				or (not aurora_rst_o);			-- aurora reset
inreset <=  pci_rst or 			-- reg soft reset
				(not reset_n)		-- on board hard reset
				or aurora_rst_o;			-- aurora reset
txfifo_rst<= inreset or rst_txfifo;
leds(4)<= inreset;
leds(3)<= rx_wr_en;
leds(2)<= tx_wr_en;
leds(5)<= pci_rst;
--leds(0)<= tx_full;
leds(1)<= tx_full;
--leds(0)<= tx_empty;
--leds(0)<= tx_rd_en;

SFP_iic_sda<='0';
SFP_iic_scl<='0';
SFP_tx_en<='1';

end Behavioral;

