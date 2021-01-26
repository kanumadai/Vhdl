------------------------------------------------------------------------------/
-- (c) Copyright 2008 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- 
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 11.1
--  \   \         Application : 
--  /   /         Filename : aurora_v10_tile.vhd
-- /___/   /\     Timestamp : 03/26/2008 10:19:02
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: AURORA_V10_TILE
--
-- Module AURORA_V10_TILE
-- Written for synthesis tool: XST
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***************************** Entity Declaration ****************************

entity aurora_v10_GTX_TILE is
generic
(
    -- Simulation attributes
    TILE_SIM_MODE                : string    := "FAST"; -- Set to Fast Functional Simulation Model
    TILE_SIM_GTXRESET_SPEEDUP    : integer   := 0; -- Set to 1 to speed up sim reset
    TILE_SIM_PLL_PERDIV2         : bit_vector:= x"140"; -- Set to the VCO Unit Interval time 

    -- Channel bonding attributes
    TILE_CHAN_BOND_MODE_0        : string    := "OFF";  -- "MASTER", "SLAVE", or "OFF"
    TILE_CHAN_BOND_LEVEL_0       : integer   := 0;     -- 0 to 7. See UG for details

    TILE_CHAN_BOND_MODE_1        : string    := "OFF";  -- "MASTER", "SLAVE", or "OFF"
    TILE_CHAN_BOND_LEVEL_1       : integer   := 0      -- 0 to 7. See UG for details
);
port 
(
    ------------------------ Loopback and Powerdown Ports ----------------------
    LOOPBACK0_IN                            : in   std_logic_vector(2 downto 0);
    LOOPBACK1_IN                            : in   std_logic_vector(2 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0_OUT                      : out  std_logic_vector(3 downto 0);
    RXCHARISCOMMA1_OUT                      : out  std_logic_vector(3 downto 0);
    RXCHARISK0_OUT                          : out  std_logic_vector(3 downto 0);
    RXCHARISK1_OUT                          : out  std_logic_vector(3 downto 0);
    RXDISPERR0_OUT                          : out  std_logic_vector(3 downto 0);
    RXDISPERR1_OUT                          : out  std_logic_vector(3 downto 0);
    RXNOTINTABLE0_OUT                       : out  std_logic_vector(3 downto 0);
    RXNOTINTABLE1_OUT                       : out  std_logic_vector(3 downto 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0_OUT                        : out  std_logic_vector(2 downto 0);
    RXCLKCORCNT1_OUT                        : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    RXBYTEREALIGN0_OUT                      : out  std_logic;
    RXBYTEREALIGN1_OUT                      : out  std_logic;
    RXENMCOMMAALIGN0_IN                     : in   std_logic;
    RXENMCOMMAALIGN1_IN                     : in   std_logic;
    RXENPCOMMAALIGN0_IN	                    : in   std_logic;
    RXENPCOMMAALIGN1_IN	                    : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0_OUT                             : out  std_logic_vector(31 downto 0);
    RXDATA1_OUT                             : out  std_logic_vector(31 downto 0);
    RXRESET0_IN                             : in   std_logic;
    RXRESET1_IN                             : in   std_logic;
    RXUSRCLK0_IN                            : in   std_logic;
    RXUSRCLK1_IN                            : in   std_logic;
    RXUSRCLK20_IN                           : in   std_logic;
    RXUSRCLK21_IN                           : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    RXCDRRESET0_IN                          : in   std_logic;
    RXCDRRESET1_IN                          : in   std_logic;
    RXN0_IN                                 : in   std_logic;
    RXN1_IN                                 : in   std_logic;
    RXP0_IN                                 : in   std_logic;
    RXP1_IN                                 : in   std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    RXBUFRESET0_IN                          : in   std_logic;
    RXBUFRESET1_IN                          : in   std_logic;
    RXBUFSTATUS0_OUT                        : out  std_logic_vector(2 downto 0);
    RXBUFSTATUS1_OUT                        : out  std_logic_vector(2 downto 0);
    TXBUFSTATUS0_OUT                        : out  std_logic_vector(1 downto 0);
    TXBUFSTATUS1_OUT                        : out  std_logic_vector(1 downto 0);
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    RXCHANISALIGNED0_OUT                    : out  std_logic;
    RXCHANISALIGNED1_OUT                    : out  std_logic;
    RXCHANREALIGN0_OUT	                    : out  std_logic;
    RXCHANREALIGN1_OUT                      : out  std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY0_IN                          : in   std_logic;
    RXPOLARITY1_IN                          : in   std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    CLKIN_IN                                : in   std_logic;
    GTXRESET_IN                             : in   std_logic;
    PLLLKDET_OUT                            : out  std_logic;
    REFCLKOUT_OUT                           : out  std_logic;
    RESETDONE0_OUT                          : out  std_logic;
    RESETDONE1_OUT                          : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK0_IN                           : in   std_logic_vector(3 downto 0);
    TXCHARISK1_IN                           : in   std_logic_vector(3 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA0_IN                              : in   std_logic_vector(31 downto 0);
    TXDATA1_IN                              : in   std_logic_vector(31 downto 0);
    TXOUTCLK0_OUT                           : out  std_logic;
    TXOUTCLK1_OUT                           : out  std_logic;
    TXRESET0_IN                             : in   std_logic;
    TXRESET1_IN                             : in   std_logic;
    TXUSRCLK0_IN                            : in   std_logic;
    TXUSRCLK1_IN                            : in   std_logic;
    TXUSRCLK20_IN                           : in   std_logic;
    TXUSRCLK21_IN                           : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TXN0_OUT                                : out  std_logic;
    TXN1_OUT                                : out  std_logic;
    TXP0_OUT                                : out  std_logic;
    TXP1_OUT                                : out  std_logic


);
end aurora_v10_GTX_TILE;

architecture RTL of aurora_v10_GTX_TILE is
  attribute core_generation_info        : string;
  attribute core_generation_info of RTL : architecture is "aurora_v10,aurora_8b10b_v5_2,{backchannel_mode=Sidebands, c_aurora_lanes=1, c_column_used=left, c_gt_clock_1=GTXD4, c_gt_clock_2=None, c_gt_loc_1=X, c_gt_loc_10=X, c_gt_loc_11=X, c_gt_loc_12=X, c_gt_loc_13=X, c_gt_loc_14=X, c_gt_loc_15=X, c_gt_loc_16=X, c_gt_loc_17=X, c_gt_loc_18=X, c_gt_loc_19=X, c_gt_loc_2=X, c_gt_loc_20=X, c_gt_loc_21=X, c_gt_loc_22=X, c_gt_loc_23=X, c_gt_loc_24=X, c_gt_loc_25=X, c_gt_loc_26=X, c_gt_loc_27=X, c_gt_loc_28=X, c_gt_loc_29=X, c_gt_loc_3=X, c_gt_loc_30=X, c_gt_loc_31=X, c_gt_loc_32=X, c_gt_loc_33=X, c_gt_loc_34=X, c_gt_loc_35=X, c_gt_loc_36=X, c_gt_loc_37=X, c_gt_loc_38=X, c_gt_loc_39=X, c_gt_loc_4=X, c_gt_loc_40=X, c_gt_loc_41=X, c_gt_loc_42=X, c_gt_loc_43=X, c_gt_loc_44=X, c_gt_loc_45=X, c_gt_loc_46=X, c_gt_loc_47=X, c_gt_loc_48=X, c_gt_loc_5=X, c_gt_loc_6=X, c_gt_loc_7=X, c_gt_loc_8=X, c_gt_loc_9=1, c_lane_width=4, c_line_rate=1.25, c_nfc=false, c_nfc_mode=IMM, c_refclk_frequency=125.0, c_simplex=false, c_simplex_mode=TX, c_stream=true, c_ufc=false, flow_mode=None, interface_mode=Streaming, dataflow_config=Duplex}";
--***************************** Wire Declarations *****************************
    -- ground and vcc signals
   signal  tied_to_ground_i                :   std_logic;
   signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
   signal  tied_to_vcc_i                   :   std_logic;

    --RX Datapath signals
    signal rxdata0_i                        :   std_logic_vector(31 downto 0);  

    --TX Datapath signals
   signal txdata0_i                        :   std_logic_vector(31 downto 0);

    -- RX Datapath signals
    signal rxdata1_i                        :   std_logic_vector(31 downto 0);  

    -- TX Datapath signals
    signal txdata1_i                        :   std_logic_vector(31 downto 0);


--********************************* Main Body of Code**************************
begin
    ---------------------------  Static signal Assignments ---------------------
                                                                                                                                                                                              
    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';
                                            
    ---------------------  GTX Datapath byte mapping  -----------------
    -- The GTX provides little endian data (first byte received on RXDATA(7 downto 0))    
    RXDATA0_OUT    <=   rxdata0_i;

    -- The GTX transmits little endian data (TXDATA(7 downto 0) transmitted first)     
    txdata0_i    <=   TXDATA0_IN;
    
    RXDATA1_OUT    <=   rxdata1_i;

    -- The GTX transmits little endian data (TXDATA(7 downto 0) transmitted first)     
    txdata1_i    <=   TXDATA1_IN;

    ----------------------------- GTX_DUAL Instance  --------------------------   

    gtx_tile_i : GTX_DUAL
    generic map
    (

        --_______________________ Simulation-Only Attributes ___________________

        SIM_RECEIVER_DETECT_PASS_0  =>       TRUE,
        
        SIM_RECEIVER_DETECT_PASS_1  =>       TRUE,

        SIM_MODE                    =>       TILE_SIM_MODE,
        SIM_GTXRESET_SPEEDUP        =>       TILE_SIM_GTXRESET_SPEEDUP,
        SIM_PLL_PERDIV2             =>       TILE_SIM_PLL_PERDIV2,

        --___________________________ Shared Attributes ________________________

        -------------------------- Tile and PLL Attributes ---------------------

        CLK25_DIVIDER               =>       5, 
        CLKINDC_B                   =>       TRUE,
        CLKRCV_TRST                 =>       TRUE,
        OOB_CLK_DIVIDER             =>       4,
        OVERSAMPLE_MODE             =>       FALSE,
        PLL_COM_CFG                 =>       x"21680a",
        PLL_CP_CFG                  =>       x"00",
        PLL_DIVSEL_FB               =>       4,
        PLL_DIVSEL_REF              =>       1,
        PLL_FB_DCCEN                =>       FALSE,
        PLL_LKDET_CFG               =>       "101",
        PLL_TDCC_CFG                =>       "000",
        PMA_COM_CFG                 =>       x"000000000000000000",

        --____________________ Transmit Interface Attributes ___________________


        ------------------- TX Buffering and Phase Alignment -------------------   

        TX_BUFFER_USE_0             =>       TRUE,
        TX_XCLK_SEL_0               =>       "TXOUT",
        TXRX_INVERT_0               =>       "011",

        TX_BUFFER_USE_1             =>       TRUE,
        TX_XCLK_SEL_1               =>       "TXOUT",
        TXRX_INVERT_1               =>       "011",

        --------------------- TX Gearbox Settings -----------------------------

        GEARBOX_ENDEC_0             =>       "000", 
        TXGEARBOX_USE_0             =>       FALSE,

        GEARBOX_ENDEC_1             =>       "000", 
        TXGEARBOX_USE_1             =>       FALSE,

        --------------------- TX Serial Line Rate settings ---------------------   

        PLL_TXDIVSEL_OUT_0          =>       4,

        PLL_TXDIVSEL_OUT_1          =>       4, 

        --------------------- TX Driver and OOB signalling --------------------  

        CM_TRIM_0                   =>       "10",
        PMA_TX_CFG_0                =>       x"80082",
        TX_DETECT_RX_CFG_0          =>       x"1832",
        TX_IDLE_DELAY_0             =>       "010",

        CM_TRIM_1                   =>       "10",
        PMA_TX_CFG_1                =>       x"80082",
        TX_DETECT_RX_CFG_1          =>       x"1832",
        TX_IDLE_DELAY_1             =>       "010",

        ------------------ TX Pipe Control for PCI Express/SATA ---------------

        COM_BURST_VAL_0             =>       "1111",

        COM_BURST_VAL_1             =>       "1111",
        --_______________________ Receive Interface Attributes ________________


        ------------ RX Driver,OOB signalling,Coupling and Eq,CDR -------------  

        AC_CAP_DIS_0                =>       TRUE,
        OOBDETECT_THRESHOLD_0       =>       "111",
        PMA_CDR_SCAN_0              =>       x"6404035",
        PMA_RX_CFG_0                =>       x"0f44088",
        RCV_TERM_GND_0              =>       FALSE,
        RCV_TERM_VTTRX_0            =>       FALSE,
        TERMINATION_IMP_0           =>       50,

        AC_CAP_DIS_1                =>       TRUE,
        OOBDETECT_THRESHOLD_1       =>       "111",
        PMA_CDR_SCAN_1              =>       x"6404035",
        PMA_RX_CFG_1                =>       x"0f44088",
        RCV_TERM_GND_1              =>       FALSE,
        RCV_TERM_VTTRX_1            =>       FALSE,
        TERMINATION_IMP_1           =>       50,

        TERMINATION_CTRL            =>       "10100",
        TERMINATION_OVRD            =>       FALSE,

        ---------------- RX Decision Feedback Equalizer(DFE)  ----------------  

        DFE_CFG_0                   =>       "1001111011",
                 
        DFE_CFG_1                   =>       "1001111011",

        DFE_CAL_TIME                =>       "00110",

        --------------------- RX Serial Line Rate Attributes ------------------   

        PLL_RXDIVSEL_OUT_0          =>       4,
        PLL_SATA_0                  =>       FALSE,

        PLL_RXDIVSEL_OUT_1          =>       4,
        PLL_SATA_1                  =>       FALSE,

        ----------------------- PRBS Detection Attributes ---------------------  

        PRBS_ERR_THRESHOLD_0        =>       x"00000001",

        PRBS_ERR_THRESHOLD_1        =>       x"00000001",

        ---------------- Comma Detection and Alignment Attributes -------------  

        ALIGN_COMMA_WORD_0          =>       2,
        COMMA_10B_ENABLE_0          =>       "1111111111",
        COMMA_DOUBLE_0              =>       FALSE,
        DEC_MCOMMA_DETECT_0         =>       TRUE,
        DEC_PCOMMA_DETECT_0         =>       TRUE,
        DEC_VALID_COMMA_ONLY_0      =>       FALSE,
        MCOMMA_10B_VALUE_0          =>       "1010000011",
        MCOMMA_DETECT_0             =>       TRUE,
        PCOMMA_10B_VALUE_0          =>       "0101111100",
        PCOMMA_DETECT_0             =>       TRUE,
        RX_SLIDE_MODE_0             =>       "PCS",

        ALIGN_COMMA_WORD_1          =>       2,
        COMMA_10B_ENABLE_1          =>       "1111111111",
        COMMA_DOUBLE_1              =>       FALSE,
        DEC_MCOMMA_DETECT_1         =>       TRUE,
        DEC_PCOMMA_DETECT_1         =>       TRUE,
        DEC_VALID_COMMA_ONLY_1      =>       FALSE,
        MCOMMA_10B_VALUE_1          =>       "1010000011",
        MCOMMA_DETECT_1             =>       TRUE,
        PCOMMA_10B_VALUE_1          =>       "0101111100",
        PCOMMA_DETECT_1             =>       TRUE,
        RX_SLIDE_MODE_1             =>       "PCS",

        ------------------ RX Loss-of-sync State Machine Attributes -----------  

        RX_LOSS_OF_SYNC_FSM_0       =>       FALSE,
        RX_LOS_INVALID_INCR_0       =>       8,
        RX_LOS_THRESHOLD_0          =>       128,

        RX_LOSS_OF_SYNC_FSM_1       =>       FALSE,
        RX_LOS_INVALID_INCR_1       =>       8,
        RX_LOS_THRESHOLD_1          =>       128,

        --------------------- RX Gearbox Settings -----------------------------

        RXGEARBOX_USE_0             =>       FALSE,

        RXGEARBOX_USE_1             =>       FALSE,

        -------------- RX Elastic Buffer and Phase alignment Attributes -------   

        PMA_RXSYNC_CFG_0            =>       x"00",
        RX_BUFFER_USE_0             =>       TRUE,
        RX_XCLK_SEL_0               =>       "RXREC",

        PMA_RXSYNC_CFG_1            =>       x"00",
        RX_BUFFER_USE_1             =>       TRUE,
        RX_XCLK_SEL_1               =>       "RXREC",

        ------------------------ Clock Correction Attributes ------------------   

        CLK_CORRECT_USE_0           =>       TRUE,
        CLK_COR_ADJ_LEN_0           =>       4,
        CLK_COR_DET_LEN_0           =>       4,
        CLK_COR_INSERT_IDLE_FLAG_0  =>       FALSE,
        CLK_COR_KEEP_IDLE_0         =>       FALSE,
        CLK_COR_MAX_LAT_0           =>       32,
        CLK_COR_MIN_LAT_0           =>       28,
        CLK_COR_PRECEDENCE_0        =>       TRUE,
        CLK_COR_REPEAT_WAIT_0       =>       0,
        CLK_COR_SEQ_1_1_0           =>       "0111110111",
        CLK_COR_SEQ_1_2_0           =>       "0111110111",
        CLK_COR_SEQ_1_3_0           =>       "0111110111",
        CLK_COR_SEQ_1_4_0           =>       "0111110111",
        CLK_COR_SEQ_1_ENABLE_0      =>       "1111",
        CLK_COR_SEQ_2_1_0           =>       "0100000000",
        CLK_COR_SEQ_2_2_0           =>       "0100000000",
        CLK_COR_SEQ_2_3_0           =>       "0100000000",
        CLK_COR_SEQ_2_4_0           =>       "0100000000",
        CLK_COR_SEQ_2_ENABLE_0      =>       "1111",
        CLK_COR_SEQ_2_USE_0         =>       FALSE,
        RX_DECODE_SEQ_MATCH_0       =>       TRUE,

        CLK_CORRECT_USE_1           =>       TRUE,
        CLK_COR_ADJ_LEN_1           =>       4,
        CLK_COR_DET_LEN_1           =>       4,
        CLK_COR_INSERT_IDLE_FLAG_1  =>       FALSE,
        CLK_COR_KEEP_IDLE_1         =>       FALSE,
        CLK_COR_MAX_LAT_1           =>       32,
        CLK_COR_MIN_LAT_1           =>       28,
        CLK_COR_PRECEDENCE_1        =>       TRUE,
        CLK_COR_REPEAT_WAIT_1       =>       0,
        CLK_COR_SEQ_1_1_1           =>       "0111110111",
        CLK_COR_SEQ_1_2_1           =>       "0111110111",
        CLK_COR_SEQ_1_3_1           =>       "0111110111",
        CLK_COR_SEQ_1_4_1           =>       "0111110111",
        CLK_COR_SEQ_1_ENABLE_1      =>       "1111",
        CLK_COR_SEQ_2_1_1           =>       "0000000000",
        CLK_COR_SEQ_2_2_1           =>       "0000000000",
        CLK_COR_SEQ_2_3_1           =>       "0000000000",
        CLK_COR_SEQ_2_4_1           =>       "0000000000",
        CLK_COR_SEQ_2_ENABLE_1      =>       "0000",
        CLK_COR_SEQ_2_USE_1         =>       FALSE,
        RX_DECODE_SEQ_MATCH_1       =>       TRUE,

        ------------------------ Channel Bonding Attributes -------------------   

        CB2_INH_CC_PERIOD_0         =>       8,
        CHAN_BOND_1_MAX_SKEW_0      =>       7,
        CHAN_BOND_2_MAX_SKEW_0      =>       7,
        CHAN_BOND_KEEP_ALIGN_0      =>       FALSE,
        CHAN_BOND_LEVEL_0           =>       TILE_CHAN_BOND_LEVEL_0,
        CHAN_BOND_MODE_0            =>       TILE_CHAN_BOND_MODE_0,
        CHAN_BOND_SEQ_1_1_0         =>       "0101111100",
        CHAN_BOND_SEQ_1_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_0    =>       "0001",
        CHAN_BOND_SEQ_2_1_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_0    =>       "0000",
        CHAN_BOND_SEQ_2_USE_0       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_0         =>       1,
        PCI_EXPRESS_MODE_0          =>       FALSE,     

        CB2_INH_CC_PERIOD_1         =>       8,
        CHAN_BOND_1_MAX_SKEW_1      =>       7,
        CHAN_BOND_2_MAX_SKEW_1      =>       7,
        CHAN_BOND_KEEP_ALIGN_1      =>       FALSE,
        CHAN_BOND_LEVEL_1           =>       TILE_CHAN_BOND_LEVEL_1,
        CHAN_BOND_MODE_1            =>       TILE_CHAN_BOND_MODE_1,
        CHAN_BOND_SEQ_1_1_1         =>       "0101111100",
        CHAN_BOND_SEQ_1_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_1    =>       "0001",
        CHAN_BOND_SEQ_2_1_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_1    =>       "0000",
        CHAN_BOND_SEQ_2_USE_1       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_1         =>       1,
        PCI_EXPRESS_MODE_1          =>       FALSE,

        -------- RX Attributes to Control Reset after Electrical Idle  ------

        RX_EN_IDLE_HOLD_DFE_0       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_0      =>       TRUE,
        RX_IDLE_HI_CNT_0            =>       "1000",
        RX_IDLE_LO_CNT_0            =>       "0000",

        RX_EN_IDLE_HOLD_DFE_1       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_1      =>       TRUE,
        RX_IDLE_HI_CNT_1            =>       "1000",
        RX_IDLE_LO_CNT_1            =>       "0000",


        CDR_PH_ADJ_TIME             =>       "01010",
        RX_EN_IDLE_RESET_FR         =>       TRUE,
        RX_EN_IDLE_HOLD_CDR         =>       FALSE,
        RX_EN_IDLE_RESET_PH         =>       TRUE,

        ------------------ RX Attributes for PCI Express/SATA ---------------

        RX_STATUS_FMT_0             =>       "PCIE",
        SATA_BURST_VAL_0            =>       "100",
        SATA_IDLE_VAL_0             =>       "100",
        SATA_MAX_BURST_0            =>       7,
        SATA_MAX_INIT_0             =>       22,
        SATA_MAX_WAKE_0             =>       7,
        SATA_MIN_BURST_0            =>       4,
        SATA_MIN_INIT_0             =>       12,
        SATA_MIN_WAKE_0             =>       4,
        TRANS_TIME_FROM_P2_0        =>       x"003c",
        TRANS_TIME_NON_P2_0         =>       x"0019",
        TRANS_TIME_TO_P2_0          =>       x"0064",

        RX_STATUS_FMT_1             =>       "PCIE",
        SATA_BURST_VAL_1            =>       "100",
        SATA_IDLE_VAL_1             =>       "100",
        SATA_MAX_BURST_1            =>       7,
        SATA_MAX_INIT_1             =>       22,
        SATA_MAX_WAKE_1             =>       7,
        SATA_MIN_BURST_1            =>       4,
        SATA_MIN_INIT_1             =>       12,
        SATA_MIN_WAKE_1             =>       4,
        TRANS_TIME_FROM_P2_1        =>       x"003c",
        TRANS_TIME_NON_P2_1         =>       x"0019",
        TRANS_TIME_TO_P2_1          =>       x"0064"
    ) 
    port map 
    (
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK0                       =>      LOOPBACK0_IN,
        LOOPBACK1                       =>      LOOPBACK1_IN,
        RXPOWERDOWN0                    =>      tied_to_ground_vec_i(1 downto 0),
        RXPOWERDOWN1                    =>      tied_to_ground_vec_i(1 downto 0),
        TXPOWERDOWN0                    =>      tied_to_ground_vec_i(1 downto 0),
        TXPOWERDOWN1                    =>      tied_to_ground_vec_i(1 downto 0),
        -------------- Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        RXDATAVALID0                    =>      open,
        RXDATAVALID1                    =>      open,
        RXGEARBOXSLIP0                  =>      tied_to_ground_i,
        RXGEARBOXSLIP1                  =>      tied_to_ground_i,
        RXHEADER0                       =>      open,
        RXHEADER1                       =>      open,
        RXHEADERVALID0                  =>      open,
        RXHEADERVALID1                  =>      open,
        RXSTARTOFSEQ0                   =>      open,
        RXSTARTOFSEQ1                   =>      open,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA0                  =>      RXCHARISCOMMA0_OUT,
        RXCHARISCOMMA1                  =>      RXCHARISCOMMA1_OUT,
        RXCHARISK0                      =>      RXCHARISK0_OUT,
        RXCHARISK1                      =>      RXCHARISK1_OUT,
        RXDEC8B10BUSE0                  =>      tied_to_vcc_i,
        RXDEC8B10BUSE1                  =>      tied_to_vcc_i,
        RXDISPERR0                      =>      RXDISPERR0_OUT,
        RXDISPERR1                      =>      RXDISPERR1_OUT,
        RXNOTINTABLE0                   =>      RXNOTINTABLE0_OUT,
        RXNOTINTABLE1                   =>      RXNOTINTABLE1_OUT,
        RXRUNDISP0                      =>      open,
        RXRUNDISP1                      =>      open,
        ------------------- Receive Ports - Channel Bonding Ports ------------------
        RXCHANBONDSEQ0                  =>      open,
        RXCHANBONDSEQ1                  =>      open,
        RXCHBONDI0                      =>      tied_to_ground_vec_i(3 downto 0),
        RXCHBONDI1                      =>      tied_to_ground_vec_i(3 downto 0),
        RXCHBONDO0                      =>      open,
        RXCHBONDO1                      =>      open,
        RXENCHANSYNC0                   =>      tied_to_ground_i,
        RXENCHANSYNC1                   =>      tied_to_ground_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        RXCLKCORCNT0                    =>      RXCLKCORCNT0_OUT,
        RXCLKCORCNT1                    =>      RXCLKCORCNT1_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED0                =>      open,
        RXBYTEISALIGNED1                =>      open,
        RXBYTEREALIGN0                  =>      RXBYTEREALIGN0_OUT,
        RXBYTEREALIGN1                  =>      RXBYTEREALIGN1_OUT,
        RXCOMMADET0                     =>      open,
        RXCOMMADET1                     =>      open,
        RXCOMMADETUSE0                  =>      tied_to_vcc_i,
        RXCOMMADETUSE1                  =>      tied_to_vcc_i,
        RXENMCOMMAALIGN0                =>      RXENMCOMMAALIGN0_IN,
        RXENMCOMMAALIGN1                =>      RXENMCOMMAALIGN1_IN,
        RXENPCOMMAALIGN0                =>      RXENPCOMMAALIGN0_IN,
        RXENPCOMMAALIGN1                =>      RXENPCOMMAALIGN1_IN,
        RXSLIDE0                        =>      tied_to_ground_i,
        RXSLIDE1                        =>      tied_to_ground_i,
        ----------------------- Receive Ports - PRBS Detection ---------------------
        PRBSCNTRESET0                   =>      tied_to_ground_i,
        PRBSCNTRESET1                   =>      tied_to_ground_i,
        RXENPRBSTST0                    =>      tied_to_ground_vec_i(1 downto 0),
        RXENPRBSTST1                    =>      tied_to_ground_vec_i(1 downto 0),
        RXPRBSERR0                      =>      open,
        RXPRBSERR1                      =>      open,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA0                         =>      rxdata0_i,
        RXDATA1                         =>      rxdata1_i,
        RXDATAWIDTH0                    =>      "10",
        RXDATAWIDTH1                    =>      "10",
        RXRECCLK0                       =>      open,
        RXRECCLK1                       =>      open,
        RXRESET0                        =>      RXRESET0_IN,
        RXRESET1                        =>      RXRESET1_IN,
        RXUSRCLK0                       =>      RXUSRCLK0_IN,
        RXUSRCLK1                       =>      RXUSRCLK1_IN,
        RXUSRCLK20                      =>      RXUSRCLK20_IN,
        RXUSRCLK21                      =>      RXUSRCLK21_IN,
        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        DFECLKDLYADJ0                   =>      tied_to_ground_vec_i(5 downto 0),
        DFECLKDLYADJ1                   =>      tied_to_ground_vec_i(5 downto 0),
        DFECLKDLYADJMONITOR0            =>      open,
        DFECLKDLYADJMONITOR1            =>      open,
        DFEEYEDACMONITOR0               =>      open,
        DFEEYEDACMONITOR1               =>      open,
        DFESENSCAL0                     =>      open,
        DFESENSCAL1                     =>      open,
        DFETAP10                        =>      tied_to_ground_vec_i(4 downto 0),
        DFETAP11                        =>      tied_to_ground_vec_i(4 downto 0),
        DFETAP1MONITOR0                 =>      open,
        DFETAP1MONITOR1                 =>      open,
        DFETAP20                        =>      tied_to_ground_vec_i(4 downto 0),
        DFETAP21                        =>      tied_to_ground_vec_i(4 downto 0),
        DFETAP2MONITOR0                 =>      open,
        DFETAP2MONITOR1                 =>      open,
        DFETAP30                        =>      tied_to_ground_vec_i(3 downto 0),
        DFETAP31                        =>      tied_to_ground_vec_i(3 downto 0),
        DFETAP3MONITOR0                 =>      open,
        DFETAP3MONITOR1                 =>      open,
        DFETAP40                        =>      tied_to_ground_vec_i(3 downto 0),
        DFETAP41                        =>      tied_to_ground_vec_i(3 downto 0),
        DFETAP4MONITOR0                 =>      open,
        DFETAP4MONITOR1                 =>      open,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRRESET0                     =>      RXCDRRESET0_IN,
        RXCDRRESET1                     =>      RXCDRRESET1_IN,
        RXELECIDLE0                     =>      open,
        RXELECIDLE1                     =>      open,
        RXENEQB0                        =>      tied_to_ground_i,
        RXENEQB1                        =>      tied_to_ground_i,
        RXEQMIX0                        =>      "11",
        RXEQMIX1                        =>      "11",
        RXEQPOLE0                       =>      "0000",
        RXEQPOLE1                       =>      "0000",
        RXN0                            =>      RXN0_IN,
        RXN1                            =>      RXN1_IN,
        RXP0                            =>      RXP0_IN,
        RXP1                            =>      RXP1_IN,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        RXBUFRESET0                     =>      RXBUFRESET0_IN,
        RXBUFRESET1                     =>      RXBUFRESET1_IN,
        RXBUFSTATUS0                    =>      RXBUFSTATUS0_OUT,
        RXBUFSTATUS1                    =>      RXBUFSTATUS1_OUT,
        RXCHANISALIGNED0                =>      RXCHANISALIGNED0_OUT,
        RXCHANISALIGNED1                =>      RXCHANISALIGNED1_OUT,
        RXCHANREALIGN0                  =>      RXCHANREALIGN0_OUT,
        RXCHANREALIGN1                  =>      RXCHANREALIGN1_OUT,
        RXENPMAPHASEALIGN0              =>      tied_to_ground_i,
        RXENPMAPHASEALIGN1              =>      tied_to_ground_i,
        RXPMASETPHASE0                  =>      tied_to_ground_i,
        RXPMASETPHASE1                  =>      tied_to_ground_i,
        RXSTATUS0                       =>      open,
        RXSTATUS1                       =>      open,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        RXLOSSOFSYNC0                   =>      open,
        RXLOSSOFSYNC1                   =>      open,
        ---------------------- Receive Ports - RX Oversampling ---------------------
        RXENSAMPLEALIGN0                =>      tied_to_ground_i,
        RXENSAMPLEALIGN1                =>      tied_to_ground_i,
        RXOVERSAMPLEERR0                =>      open,
        RXOVERSAMPLEERR1                =>      open,
        -------------- Receive Ports - RX Pipe Control for PCI Express -------------
        PHYSTATUS0                      =>      open,
        PHYSTATUS1                      =>      open,
        RXVALID0                        =>      open,
        RXVALID1                        =>      open,
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        RXPOLARITY0                     =>      RXPOLARITY0_IN,
        RXPOLARITY1                     =>      RXPOLARITY1_IN,
        ------------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        DADDR                           =>      tied_to_ground_vec_i(6 downto 0),
        DCLK                            =>      tied_to_ground_i,
        DEN                             =>      tied_to_ground_i,
        DI                              =>      tied_to_ground_vec_i(15 downto 0),
        DO                              =>      open,
        DRDY                            =>      open,
        DWE                             =>      tied_to_ground_i,
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        CLKIN                           =>      CLKIN_IN,
        GTXRESET                        =>      GTXRESET_IN,
        GTXTEST                         =>      "10000000000000",
        INTDATAWIDTH                    =>      tied_to_vcc_i,
        PLLLKDET                        =>      PLLLKDET_OUT,
        PLLLKDETEN                      =>      tied_to_vcc_i,
        PLLPOWERDOWN                    =>      tied_to_ground_i,
        REFCLKOUT                       =>      REFCLKOUT_OUT,
        REFCLKPWRDNB                    =>      tied_to_vcc_i,
        RESETDONE0                      =>      RESETDONE0_OUT,
        RESETDONE1                      =>      RESETDONE1_OUT,
        -------------- Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        TXGEARBOXREADY0                 =>      open,
        TXGEARBOXREADY1                 =>      open,
        TXHEADER0                       =>      tied_to_ground_vec_i(2 downto 0),
        TXHEADER1                       =>      tied_to_ground_vec_i(2 downto 0),
        TXSEQUENCE0                     =>      tied_to_ground_vec_i(6 downto 0),
        TXSEQUENCE1                     =>      tied_to_ground_vec_i(6 downto 0),
        TXSTARTSEQ0                     =>      tied_to_ground_i,
        TXSTARTSEQ1                     =>      tied_to_ground_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXBYPASS8B10B0                  =>      tied_to_ground_vec_i(3 downto 0),
        TXBYPASS8B10B1                  =>      tied_to_ground_vec_i(3 downto 0),
        TXCHARDISPMODE0                 =>      tied_to_ground_vec_i(3 downto 0),
        TXCHARDISPMODE1                 =>      tied_to_ground_vec_i(3 downto 0),
        TXCHARDISPVAL0                  =>      tied_to_ground_vec_i(3 downto 0),
        TXCHARDISPVAL1                  =>      tied_to_ground_vec_i(3 downto 0),
        TXCHARISK0                      =>      TXCHARISK0_IN,
        TXCHARISK1                      =>      TXCHARISK1_IN,
        TXENC8B10BUSE0                  =>      tied_to_vcc_i,
        TXENC8B10BUSE1                  =>      tied_to_vcc_i,
        TXKERR0                         =>      open,
        TXKERR1                         =>      open,
        TXRUNDISP0                      =>      open,
        TXRUNDISP1                      =>      open,
        ------------- Transmit Ports - TX Buffering and Phase Alignment ------------
        TXBUFSTATUS0                    =>      TXBUFSTATUS0_OUT,
        TXBUFSTATUS1                    =>      TXBUFSTATUS1_OUT,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA0                         =>      txdata0_i,
        TXDATA1                         =>      txdata1_i,
        TXDATAWIDTH0                    =>      "10",
        TXDATAWIDTH1                    =>      "10",
        TXOUTCLK0                       =>      TXOUTCLK0_OUT,
        TXOUTCLK1                       =>      TXOUTCLK1_OUT,
        TXRESET0                        =>      TXRESET0_IN,
        TXRESET1                        =>      TXRESET1_IN,
        TXUSRCLK0                       =>      TXUSRCLK0_IN,
        TXUSRCLK1                       =>      TXUSRCLK1_IN,
        TXUSRCLK20                      =>      TXUSRCLK20_IN,
        TXUSRCLK21                      =>      TXUSRCLK21_IN,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TXBUFDIFFCTRL0                  =>      "101",
        TXBUFDIFFCTRL1                  =>      "101",
        TXDIFFCTRL0                     =>      "101",
        TXDIFFCTRL1                     =>      "101",
        TXINHIBIT0                      =>      tied_to_ground_i,
        TXINHIBIT1                      =>      tied_to_ground_i,
        TXN0                            =>      TXN0_OUT,
        TXN1                            =>      TXN1_OUT,
        TXP0                            =>      TXP0_OUT,
        TXP1                            =>      TXP1_OUT,
        TXPREEMPHASIS0                  =>      "0000",
        TXPREEMPHASIS1                  =>      "0000",
        -------- Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
        TXENPMAPHASEALIGN0              =>      tied_to_ground_i,
        TXENPMAPHASEALIGN1              =>      tied_to_ground_i,
        TXPMASETPHASE0                  =>      tied_to_ground_i,
        TXPMASETPHASE1                  =>      tied_to_ground_i,
        --------------------- Transmit Ports - TX PRBS Generator -------------------
        TXENPRBSTST0                    =>      tied_to_ground_vec_i(1 downto 0),
        TXENPRBSTST1                    =>      tied_to_ground_vec_i(1 downto 0),
        -------------------- Transmit Ports - TX Polarity Control ------------------
        TXPOLARITY0                     =>      tied_to_ground_i,
        TXPOLARITY1                     =>      tied_to_ground_i,
        ----------------- Transmit Ports - TX Ports for PCI Express ----------------
        TXDETECTRX0                     =>      tied_to_ground_i,
        TXDETECTRX1                     =>      tied_to_ground_i,
        TXELECIDLE0                     =>      tied_to_ground_i,
        TXELECIDLE1                     =>      tied_to_ground_i,
        --------------------- Transmit Ports - TX Ports for SATA -------------------
        TXCOMSTART0                     =>      tied_to_ground_i,
        TXCOMSTART1                     =>      tied_to_ground_i,
        TXCOMTYPE0                      =>      tied_to_ground_i,
        TXCOMTYPE1                      =>      tied_to_ground_i

    );

end RTL;

