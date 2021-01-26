
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : pcie_blk_ll.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Block LocalLink Bridge
//--
//--             
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module pcie_blk_ll #
(
   parameter   BAR0 = 32'hffff_0001,               // base address                                   cfg[ 95: 64]
   parameter   BAR1 = 32'hffff_0000,               // base address                                   cfg[127: 96]
   parameter   BAR2 = 32'hffff_0004,               // base address                                   cfg[159:128]
   parameter   BAR3 = 32'hffff_ffff,               // base address                                   cfg[191:160]
   parameter   BAR4 = 32'h0000_0000,               // base address                                   cfg[223:192]
   parameter   BAR5 = 32'h0000_0000,               // base address                                   cfg[255:224]
   parameter   XROM_BAR = 32'hffff_f001,           // expansion rom bar                              cfg[351:320]
   parameter   MPS = 3'b101,                       // Max Payload Size                               cfg[370:368]
   parameter   LEGACY_EP = 1'b0,                   // Legacy PCI endpoint?
   parameter   TRIM_ECRC = 1'b0,                   // Trim ECRC from rx TLPs                         cfg[508]
   parameter   CPL_STREAMING_PRIORITIZE_P_NP = 0,  // arb priority to P/NP during cpl strm
   parameter   C_CALENDAR_LEN     = 9,
   parameter   C_CALENDAR_SUB_LEN = 12,
   parameter   C_CALENDAR_SEQ     = 72'h68_08_68_2C_68_08_68_0C_FF, //S Tc S T1 S Tc S T2 F
   parameter   C_CALENDAR_SUB_SEQ = 96'h40_60_44_64_4C_6C_20_24_28_2C_30_34,
   parameter   TX_DATACREDIT_FIX_EN     = 1,
   parameter   TX_DATACREDIT_FIX_1DWONLY= 1,
   parameter   TX_DATACREDIT_FIX_MARGIN = 6,
   parameter   TX_CPL_STALL_THRESHOLD = 6
)
(
       // Clock and reset
       input wire         clk,
       input wire         rst_n,
    
       // Transaction Link Up
       input              trn_lnk_up_n,

       // PCIe Block Tx Ports
       output      [63:0] llk_tx_data,
       output             llk_tx_src_rdy_n,
       output             llk_tx_src_dsc_n,
       output             llk_tx_sof_n,
       output             llk_tx_eof_n,
       output             llk_tx_sop_n,
       output             llk_tx_eop_n,
       output      [1:0]  llk_tx_enable_n,
       output      [2:0]  llk_tx_ch_tc,
       output      [1:0]  llk_tx_ch_fifo,

       input  wire        llk_tx_dst_rdy_n,
       input  wire [9:0]  llk_tx_chan_space,
       input  wire [7:0]  llk_tx_ch_posted_ready_n,
       input  wire [7:0]  llk_tx_ch_non_posted_ready_n,
       input  wire [7:0]  llk_tx_ch_completion_ready_n,

       // PCIe Block Rx Ports
       output             llk_rx_dst_req_n,
       output             llk_rx_dst_cont_req_n,
       output [2:0]       llk_rx_ch_tc,
       output [1:0]       llk_rx_ch_fifo,

       input  wire [7:0]  llk_tc_status,
       input  wire [63:0] llk_rx_data,
       output wire [63:0] llk_rx_data_d, //needed by mgmt module
       input  wire        llk_rx_src_rdy_n,
       input  wire        llk_rx_src_last_req_n,
       input  wire        llk_rx_src_dsc_n,
       input  wire        llk_rx_sof_n,
       input  wire        llk_rx_eof_n,
       input  wire [1:0]  llk_rx_valid_n,
       input  wire [7:0]  llk_rx_ch_posted_available_n,
       input  wire [7:0]  llk_rx_ch_non_posted_available_n,
       input  wire [7:0]  llk_rx_ch_completion_available_n,
       input  wire [15:0] llk_rx_preferred_type,

       // PCIe Block MGMT Credit Status
       
       output wire [6:0]  mgmt_stats_credit_sel,
       input  wire [11:0] mgmt_stats_credit,

       // LocalLink Tx Ports (User)
           
       input  wire [63:0] trn_td,
       input  wire [7:0]  trn_trem_n,
       input  wire        trn_tsof_n,
       input              trn_teof_n,
       input              trn_tsrc_rdy_n,
       input              trn_tsrc_dsc_n,
       input              trn_terrfwd_n,

       output             trn_tdst_rdy_n,
       output             trn_tdst_dsc_n,
       output      [3:0]  trn_tbuf_av,

       output      [7:0]  trn_pfc_nph_cl,
       output      [11:0] trn_pfc_npd_cl,
       output      [7:0]  trn_pfc_ph_cl,
       output      [11:0] trn_pfc_pd_cl,
       output      [7:0]  trn_pfc_cplh_cl,
       output      [11:0] trn_pfc_cpld_cl,
 
       // LocalLink TX Ports (Cfg/Mgmt)

       input       [63:0] cfg_tx_td,
       input              cfg_tx_rem_n,
       input              cfg_tx_sof_n,
       input              cfg_tx_eof_n,
       input              cfg_tx_src_rdy_n,
       output             cfg_tx_dst_rdy_n,

       // LocalLink Rx Ports

       output      [63:0] trn_rd,
       output      [7:0]  trn_rrem_n,
       output             trn_rsof_n,
       output             trn_reof_n,
       output             trn_rsrc_rdy_n,
       output             trn_rsrc_dsc_n,
       output             trn_rerrfwd_n,
       output      [6:0]  trn_rbar_hit_n,
       output      [7:0]  trn_rfc_nph_av,
       output      [11:0] trn_rfc_npd_av,
       output      [7:0]  trn_rfc_ph_av,
       output      [11:0] trn_rfc_pd_av,
       output      [7:0]  trn_rfc_cplh_av,
       output      [11:0] trn_rfc_cpld_av,

       input  wire        trn_rnp_ok_n,
       input  wire        trn_rdst_rdy_n,
       input  wire        trn_rcpl_streaming_n,

       // Sideband signals to control operation
       input  wire [31:0] cfg_rx_bar0,
       input  wire [31:0] cfg_rx_bar1,
       input  wire [31:0] cfg_rx_bar2,
       input  wire [31:0] cfg_rx_bar3,
       input  wire [31:0] cfg_rx_bar4,
       input  wire [31:0] cfg_rx_bar5,
       input  wire [31:0] cfg_rx_xrom,
       input  wire [7:0]  cfg_bus_number,
       input  wire [4:0]  cfg_device_number,
       input  wire [2:0]  cfg_function_number,
       input  wire [15:0] cfg_dcommand,
       input  wire [15:0] cfg_pmcsr,
       input  wire        io_space_enable,
       input  wire        mem_space_enable,
       input  wire [2:0]  max_payload_size,

       // Error signaling logic
       output wire        rx_err_cpl_abort_n,
       output wire        rx_err_cpl_ur_n,
       output wire        rx_err_cpl_ep_n,
       output wire        rx_err_ep_n,
       output wire [47:0] err_tlp_cpl_header,
       output wire        err_tlp_p,
       output wire        err_tlp_ur,
       output wire        err_tlp_ur_lock,
       output wire        err_tlp_uc,
       output wire        err_tlp_malformed,
       output wire        tx_err_wr_ep_n,

       input              l0_stats_tlp_received,
       input              l0_stats_cfg_transmitted
);

wire  [7:0] tx_ch_credits_consumed;
wire [11:0] tx_pd_credits_consumed;
wire [11:0] tx_pd_credits_available;
wire [11:0] tx_npd_credits_consumed;
wire [11:0] tx_npd_credits_available;
wire [11:0] tx_cd_credits_consumed;
wire [11:0] tx_cd_credits_available;
wire  [7:0] rx_ch_credits_received;
wire        trn_pfc_cplh_cl_upd;

pcie_blk_plus_ll_tx #
( .TX_CPL_STALL_THRESHOLD   ( TX_CPL_STALL_THRESHOLD ),
  .TX_DATACREDIT_FIX_EN     ( TX_DATACREDIT_FIX_EN ),
  .TX_DATACREDIT_FIX_1DWONLY( TX_DATACREDIT_FIX_1DWONLY ),
  .TX_DATACREDIT_FIX_MARGIN ( TX_DATACREDIT_FIX_MARGIN ),
  .MPS                      ( MPS ),
  .LEGACY_EP                ( LEGACY_EP )
)
tx_bridge 
(
       // Clock & Reset

       .clk( clk ),                                               // I
       .rst_n( rst_n ),                                           // I

       // Transaction Link Up

       .trn_lnk_up_n (trn_lnk_up_n),                              // I

       // PCIe Block Tx Ports

       .llk_tx_data( llk_tx_data ),                               // O[63:0] 
       .llk_tx_src_rdy_n( llk_tx_src_rdy_n ),                     // O
       .llk_tx_src_dsc_n( llk_tx_src_dsc_n ),                     // O
       .llk_tx_sof_n( llk_tx_sof_n ),                             // O
       .llk_tx_eof_n( llk_tx_eof_n ),                             // O
       .llk_tx_sop_n( llk_tx_sop_n ),                             // O
       .llk_tx_eop_n( llk_tx_eop_n ),                             // O
       .llk_tx_enable_n( llk_tx_enable_n ),                       // O[1:0]
       .llk_tx_ch_tc( llk_tx_ch_tc ),                             // O[2:0]
       .llk_tx_ch_fifo( llk_tx_ch_fifo ),                         // O[1:0]

       .llk_tx_dst_rdy_n( llk_tx_dst_rdy_n ),                     // I
       .llk_tx_chan_space( llk_tx_chan_space ),                   // I[9:0]
       .llk_tx_ch_posted_ready_n( llk_tx_ch_posted_ready_n ),     // I[7:0]
       .llk_tx_ch_non_posted_ready_n( llk_tx_ch_non_posted_ready_n ), // I[7:0]
       .llk_tx_ch_completion_ready_n( llk_tx_ch_completion_ready_n ), // I[7:0]

       // LocalLink Tx Ports

       .trn_td( trn_td ),                                         // I[63:0]
       .trn_trem_n( trn_trem_n ),                                 // I[7:0]
       .trn_tsof_n( trn_tsof_n ),                                 // I
       .trn_teof_n( trn_teof_n ),                                 // I
       .trn_tsrc_rdy_n( trn_tsrc_rdy_n ),                         // I
       .trn_tsrc_dsc_n( trn_tsrc_dsc_n ),                         // I
       .trn_terrfwd_n( trn_terrfwd_n ),                           // I

       .trn_tdst_rdy_n( trn_tdst_rdy_n ),                         // O
       .trn_tdst_dsc_n( trn_tdst_dsc_n ),                         // O
       .trn_tbuf_av( trn_tbuf_av ),                               // O[2:0]

       // Config Tx Ports

       .cfg_tx_td( cfg_tx_td ),                                   // I[63:0]
       .cfg_tx_rem_n( cfg_tx_rem_n ),                             // I
       .cfg_tx_sof_n( cfg_tx_sof_n ),                             // I
       .cfg_tx_eof_n( cfg_tx_eof_n ),                             // I
       .cfg_tx_src_rdy_n( cfg_tx_src_rdy_n ),                     // I
       .cfg_tx_dst_rdy_n( cfg_tx_dst_rdy_n ),                     // O

       // Status Ports
       .tx_err_wr_ep_n( tx_err_wr_ep_n ),                         // O
       .tx_ch_credits_consumed   ( tx_ch_credits_consumed ),
       .tx_pd_credits_available  ( tx_pd_credits_available ),
       .tx_pd_credits_consumed   ( tx_pd_credits_consumed ),
       .tx_npd_credits_available ( tx_npd_credits_available ),
       .tx_npd_credits_consumed  ( tx_npd_credits_consumed ),
       .tx_cd_credits_available  ( tx_cd_credits_available ),
       .tx_cd_credits_consumed   ( tx_cd_credits_consumed ),
       .clear_cpl_count          ( clear_cpl_count ),
       .pd_credit_limited        ( pd_credit_limited ),
       .npd_credit_limited       ( npd_credit_limited ),
       .cd_credit_limited        ( cd_credit_limited ),
       .trn_pfc_cplh_cl          ( trn_pfc_cplh_cl),
       .trn_pfc_cplh_cl_upd      ( trn_pfc_cplh_cl_upd),
       .l0_stats_cfg_transmitted ( l0_stats_cfg_transmitted )
);

pcie_blk_plus_ll_rx #
(      .BAR0( BAR0 ),
       .BAR1( BAR1 ),
       .BAR2( BAR2 ),
       .BAR3( BAR3 ),
       .BAR4( BAR4 ),
       .BAR5( BAR5 ),
       .XROM_BAR( XROM_BAR ),
       .MPS( MPS ),
       .LEGACY_EP ( LEGACY_EP ),
       .TRIM_ECRC ( TRIM_ECRC ),
       .CPL_STREAMING_PRIORITIZE_P_NP(CPL_STREAMING_PRIORITIZE_P_NP)
)
rx_bridge 
(
       // Clock & Reset

       .clk( clk ),                                               // I
       .rst_n( rst_n ),                                           // I

       // PCIe Block Rx Ports

       .llk_rx_dst_req_n( llk_rx_dst_req_n ),                     // O
       .llk_rx_ch_tc( llk_rx_ch_tc ),                             // O[2:0]
       .llk_rx_ch_fifo( llk_rx_ch_fifo ),                         // O[1:0]
       .llk_rx_dst_cont_req_n(llk_rx_dst_cont_req_n ),            // O
       .llk_tc_status( llk_tc_status ),                           // I[7:0]
       .llk_rx_data  ( llk_rx_data ),                             // I[63:0]
       .llk_rx_data_d( llk_rx_data_d ),                           // O[63:0]
       .llk_rx_src_rdy_n( llk_rx_src_rdy_n ),                     // I
       .llk_rx_src_last_req_n( llk_rx_src_last_req_n ),           // I
       .llk_rx_src_dsc_n( llk_rx_src_dsc_n ),                     // I
       .llk_rx_sof_n( llk_rx_sof_n ),                             // I
       .llk_rx_eof_n( llk_rx_eof_n ),                             // I
       .llk_rx_valid_n( llk_rx_valid_n ),                         // I[1:0]
       .llk_rx_ch_posted_available_n( llk_rx_ch_posted_available_n ),         // I[7:0]
       .llk_rx_ch_non_posted_available_n( llk_rx_ch_non_posted_available_n ), // I[7:0]
       .llk_rx_ch_completion_available_n( llk_rx_ch_completion_available_n ), // I[7:0]
       .llk_rx_preferred_type( llk_rx_preferred_type ),           // I[15:0]

       // LocalLink Rx Ports
       .trn_rd( trn_rd ),                                         // O[63:0]
       .trn_rrem_n( trn_rrem_n ),                                 // O[7:0]
       .trn_rsof_n( trn_rsof_n ),                                 // O
       .trn_reof_n( trn_reof_n ),                                 // O
       .trn_rsrc_rdy_n( trn_rsrc_rdy_n ),                         // O
       .trn_rsrc_dsc_n( trn_rsrc_dsc_n ),                         // O
       .trn_rerrfwd_n( trn_rerrfwd_n ),                           // O
       .trn_rbar_hit_n( trn_rbar_hit_n ),                         // O[6:0]
       .trn_lnk_up_n( trn_lnk_up_n ),                             // O

       .trn_rnp_ok_n( trn_rnp_ok_n ),                             // I
       .trn_rdst_rdy_n( trn_rdst_rdy_n ),                         // I
       .trn_rcpl_streaming_n( trn_rcpl_streaming_n ),             // I

       // Sideband signals to control operation
       .cfg_rx_bar0( cfg_rx_bar0 ),                               // I[31:0]
       .cfg_rx_bar1( cfg_rx_bar1 ),                               // I[31:0]
       .cfg_rx_bar2( cfg_rx_bar2 ),                               // I[31:0]
       .cfg_rx_bar3( cfg_rx_bar3 ),                               // I[31:0]
       .cfg_rx_bar4( cfg_rx_bar4 ),                               // I[31:0]
       .cfg_rx_bar5( cfg_rx_bar5 ),                               // I[31:0]
       .cfg_rx_xrom( cfg_rx_xrom ),                               // I[31:0]
       .cfg_bus_number( cfg_bus_number ),                         // I[7:0]
       .cfg_device_number( cfg_device_number ),                   // I[4:0]
       .cfg_function_number( cfg_function_number ),               // I[2:0]
       .cfg_dcommand( cfg_dcommand ),                             // I[15:0]
       .cfg_pmcsr( cfg_pmcsr ),                                   // I[15:0]
       .io_space_enable( io_space_enable ),                       // I
       .mem_space_enable( mem_space_enable ),                     // I
       .max_payload_size( max_payload_size ),                     // I[2:0]

       // Error reporting
       .rx_err_cpl_abort_n( rx_err_cpl_abort_n ),                 // O
       .rx_err_cpl_ur_n( rx_err_cpl_ur_n ),                       // O
       .rx_err_cpl_ep_n( rx_err_cpl_ep_n ),                       // O
       .rx_err_ep_n( rx_err_ep_n ),                               // O
       .err_tlp_cpl_header( err_tlp_cpl_header ),                 // O[47:0]
       .err_tlp_p( err_tlp_p ),                                   // O
       .err_tlp_ur( err_tlp_ur ),                                 // O
       .err_tlp_ur_lock( err_tlp_ur_lock ),                       // O
       .err_tlp_uc( err_tlp_uc ),                                 // O
       .err_tlp_malformed( err_tlp_malformed ),                   // O
       .rx_ch_credits_received     (rx_ch_credits_received),
       .rx_ch_credits_received_inc (rx_ch_credits_received_inc),
       .l0_stats_tlp_received (l0_stats_tlp_received)
);

  // Rx Credit calculation logic
  pcie_blk_ll_credit
  #( .C_CALENDAR_LEN     (C_CALENDAR_LEN),
     .C_CALENDAR_SUB_LEN (C_CALENDAR_SUB_LEN),
     .C_CALENDAR_SEQ     (C_CALENDAR_SEQ),
     .C_CALENDAR_SUB_SEQ (C_CALENDAR_SUB_SEQ),
     .MPS                (MPS),
     .LEGACY_EP          (LEGACY_EP)
  )
  ll_credit 
  (.clk                   (clk),
   .rst_n                 (rst_n),
   .mgmt_stats_credit_sel (mgmt_stats_credit_sel),
   .mgmt_stats_credit     (mgmt_stats_credit),
   .trn_pfc_nph_cl( trn_pfc_nph_cl),
   .trn_pfc_npd_cl( trn_pfc_npd_cl),
   .trn_pfc_ph_cl( trn_pfc_ph_cl),
   .trn_pfc_pd_cl( trn_pfc_pd_cl),
   .trn_pfc_cplh_cl       (trn_pfc_cplh_cl),
   .trn_pfc_cplh_cl_upd   (trn_pfc_cplh_cl_upd),
   .trn_pfc_cpld_cl       (trn_pfc_cpld_cl),
   .trn_lnk_up_n          (trn_lnk_up_n),
   .trn_rfc_ph_av         (trn_rfc_ph_av),
   .trn_rfc_pd_av         (trn_rfc_pd_av),
   .trn_rfc_nph_av        (trn_rfc_nph_av),
   .trn_rfc_npd_av        (trn_rfc_npd_av),
   .trn_rfc_cplh_av       (trn_rfc_cplh_av),
   .trn_rfc_cpld_av       (trn_rfc_cpld_av),
   .trn_rcpl_streaming_n  (trn_rcpl_streaming_n),
   .rx_ch_credits_received     (rx_ch_credits_received),
   .rx_ch_credits_received_inc (rx_ch_credits_received_inc),
   .tx_ch_credits_consumed     (tx_ch_credits_consumed),
   .tx_pd_credits_available    (tx_pd_credits_available),
   .tx_pd_credits_consumed     (tx_pd_credits_consumed),
   .tx_npd_credits_available   (tx_npd_credits_available),
   .tx_npd_credits_consumed    (tx_npd_credits_consumed),
   .tx_cd_credits_available    (tx_cd_credits_available),
   .tx_cd_credits_consumed     (tx_cd_credits_consumed),
   .clear_cpl_count            (clear_cpl_count),
   .pd_credit_limited          (pd_credit_limited),
   .npd_credit_limited         (npd_credit_limited),
   .cd_credit_limited          (cd_credit_limited),
   .l0_stats_cfg_transmitted   (l0_stats_cfg_transmitted)
);

endmodule // pcie_blk_ll
