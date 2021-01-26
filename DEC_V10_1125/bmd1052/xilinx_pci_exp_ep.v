
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
// File       : xilinx_pci_exp_ep.v
//
// Description:  PCI Express Endpoint Core example design top level wrapper.
//
//------------------------------------------------------------------------------
//
module     xilinx_pci_exp_ep 
(
                        // PCI Express Fabric Interface

                        pci_exp_txp,
                        pci_exp_txn,
                        pci_exp_rxp,
                        pci_exp_rxn,

                        // System (SYS) Interface

                        sys_clk_p,
                        sys_clk_n,

                        sys_reset_n,
								
								aurora_offline,
								
								refclkout,
								
								rst_o,
								rst_txfifo_o,
								
								debug_o_1,
								debug_o_2,
								//connect to the RX fifo:	pcie-->rx fifo-->aurora
								wr_clk ,
							   din_o ,
							   wr_en_o ,
						      //connect the TX fifo    : aurora-->tx fifo-->pcie  
							   rd_clk,    
							   rd_en_o,
							   dout_i,
							   empty_i,
								data_count_i

                        );//synthesis syn_noclockbuf=1

    //-------------------------------------------------------
    // 1. PCI Express Fabric Interface
    //-------------------------------------------------------

    // Tx
    output    [(1 - 1):0]           pci_exp_txp;
    output    [(1 - 1):0]           pci_exp_txn;

    // Rx
    input     [(1 - 1):0]           pci_exp_rxp;
    input     [(1 - 1):0]           pci_exp_rxn;


    //-------------------------------------------------------
    // 4. System (SYS) Interface
    //-------------------------------------------------------
    input                                             sys_clk_p;
    input                                             sys_clk_n;
    input                                             sys_reset_n;
    input                     aurora_offline;
	 
    output					      refclkout;
    output					      rst_o;	 
    output					      rst_txfifo_o;	 	 
    output					      debug_o_1;
	 output					      debug_o_2;
    //-------------------------------------------------------
    // . fifo Interface
    //-------------------------------------------------------

    output                    wr_clk;
    output [31:0]             din_o;

    output					     	wr_en_o;
    output                    rd_clk;
    output                    rd_en_o;	 
    input [31:0]              dout_i;
    input                     empty_i;
    input [12:0]              data_count_i;

    //-------------------------------------------------------
    // Local Wires
    //-------------------------------------------------------

    wire                                              sys_clk_c;

//    wire                                              sys_reset_n_c; 
    wire                                              trn_clk_c;//synthesis attribute max_fanout of trn_clk_c is "100000"
    wire                                              trn_reset_n_c;
    wire                                              trn_lnk_up_n_c;
	 	 
    wire    [5:0]       										trn_tbuf_av_c;
    wire                                              trn_tcfg_req_n_c;
    wire                                              trn_terr_drop_n_c;	 
    wire                                              trn_tdst_rdy_n_c;	 
    wire    [(64 - 1):0]         							trn_td_c;
    wire    		          									trn_trem_n_c;	
    wire                                              trn_tsof_n_c;
    wire                                              trn_teof_n_c;	 
    wire                                              trn_tsrc_rdy_n_c;
    wire                                              trn_tsrc_dsc_n_c;	 
    wire                                              trn_terrfwd_n_c;
    wire                                              trn_tcfg_gnt_n_c;
    wire                                              trn_tstr_n_c;

    wire    [(64 - 1):0]        		 						trn_rd_c;
    wire    		          									trn_rrem_n_c;
    wire                                              trn_rsof_n_c;
    wire                                              trn_reof_n_c;
    wire                                              trn_rsrc_rdy_n_c;
    wire                                              trn_rsrc_dsc_n_c;
    wire                                              trn_rerrfwd_n_c;
    wire    [6:0]      											trn_rbar_hit_n_c;	 
    wire                                              trn_rdst_rdy_n_c;
    wire                                              trn_rnp_ok_n_c;

    wire    [11:0]      										trn_fc_cpld_c;
    wire    [7:0]       										trn_fc_cplh_c;
    wire    [11:0]      										trn_fc_npd_c;
    wire    [7:0]       										trn_fc_nph_c;
    wire    [11:0]      										trn_fc_pd_c;
    wire    [7:0]       										trn_fc_ph_c;
    wire    [2:0]       										trn_fc_sel_c;
	 

    wire    [31:0]         									cfg_do_c;
    wire                                              cfg_rd_wr_done_n_c;	 
    wire    [31:0]        	 									cfg_di_c;
    wire    [3:0]       										cfg_byte_en_n_c;	 
    wire    [9:0]         										cfg_dwaddr_c;
    wire                                              cfg_wr_en_n_c;
    wire                                              cfg_rd_en_n_c;
	 

    wire                                              cfg_err_cor_n_c;
    wire                                              cfg_err_ur_n_c;
    wire                                              cfg_err_ecrc_n_c;
    wire                                              cfg_err_cpl_timeout_n_c;
    wire                                              cfg_err_cpl_abort_n_c;
    wire                                              cfg_err_cpl_unexpect_n_c;
    wire                                              cfg_err_posted_n_c;
    wire                                              cfg_err_locked_n_c;
    wire    [47:0]       										cfg_err_tlp_cpl_header_c;
    wire                                              cfg_err_cpl_rdy_n_c;
    wire                                              cfg_interrupt_n_c;
    wire                                              cfg_interrupt_rdy_n_c;
    wire                                              cfg_interrupt_assert_n_c;
    wire [7 : 0]                                      cfg_interrupt_di_c;
    wire [7 : 0]                                      cfg_interrupt_do_c;
    wire [2 : 0]                                      cfg_interrupt_mmenable_c;
    wire                                              cfg_interrupt_msienable_c;
    wire                                              cfg_interrupt_msixenable_c;
    wire                                              cfg_interrupt_msixfm_c;
    wire                                              cfg_turnoff_ok_n_c;	 
    wire                                              cfg_to_turnoff_n_c;
    wire                                              cfg_trn_pending_n_c;	 
    wire                                              cfg_pm_wake_n_c;
    wire    [7:0]       										cfg_bus_number_c;
    wire    [4:0]       										cfg_device_number_c;
    wire    [2:0]       										cfg_function_number_c;	 
    wire    [15:0]          									cfg_status_c;
    wire    [15:0]         									cfg_command_c;
    wire    [15:0]          									cfg_dstatus_c;
    wire    [15:0]          									cfg_dcommand_c;
    wire    [15:0]         									cfg_lstatus_c;
    wire    [15:0]          									cfg_lcommand_c;
    wire    [15:0]          									cfg_dcommand2_c;	 
    wire    [2:0]        										cfg_pcie_link_state_n_c;


	wire [1:0]                                   		pl_directed_link_change_c;
	wire  [5:0]                                   		pl_ltssm_state_c;
	wire [1:0]                                   		pl_directed_link_width_c;
	wire                                         		pl_directed_link_speed_c;
	wire                                         		pl_directed_link_auton_c;
	wire                                         		pl_upstream_prefer_deemph_c;
	wire  [1:0]                                   		pl_sel_link_width_c;
	wire                                          		pl_sel_link_rate_c;
	wire                                          		pl_link_gen2_capable_c;
	wire                                          		pl_link_partner_gen2_supported_c;
	wire  [2:0]                                   		pl_initial_link_width_c;
	wire                                         		pl_link_upcfg_capable_c;
	wire  [1:0]                                   		pl_lane_reversal_mode_c;
	wire                                          		pl_received_hot_rst_c;

   wire [(64 - 1):0]             							cfg_dsn_n_c;


	
//-------------------------------------------------------
// Virtex6 Global Clock Buffer
//-------------------------------------------------------
  IBUFDS_GTXE1 refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n), .CEB(1'b0), .ODIV2());  // 100 MHz

  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------

 // IBUF sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));

assign wr_clk = trn_clk_c;
assign rd_clk = trn_clk_c;
assign refclkout = trn_clk_c;


  //-------------------------------------------------------
  // Endpoint Implementation Application
  //-------------------------------------------------------
pcie_app_v6 app (


      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // I
      .trn_reset_n( trn_reset_n_c ),           // I
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // I
		   
      // Tx Local-Link
		.trn_tbuf_av( trn_tbuf_av_c ),
		.trn_tcfg_req_n( trn_tcfg_req_n_c ),		// O
		.trn_terr_drop_n( trn_terr_drop_n_c ),		// O
		.trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // I
      
      .trn_td( trn_td_c ),                     // O [63/31:0]
      .trn_trem_n( trn_trem_n_c ),               // O 
      .trn_tsof_n( trn_tsof_n_c ),             // O
      .trn_teof_n( trn_teof_n_c ),             // O
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // O
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // O
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // O
      .trn_tcfg_gnt_n( trn_tcfg_gnt_n_c ),		// I
		.trn_tstr_n( trn_tstr_n_c ),	
		
      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // I [63/31:0]
      .trn_rrem_n(trn_rrem_n_c),               // I 
      .trn_rsof_n( trn_rsof_n_c ),             // I
      .trn_reof_n( trn_reof_n_c ),             // I
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // I
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // I
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // I
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // I [6:0]
		.trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // O
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // O
      
//		.trn_rfc_npd_av( trn_rfc_npd_av_c ),     // I [11:0]
//      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // I [7:0]
//      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // I [11:0]
//      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // I [7:0]
//      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),  // O

	  // Flow Control
	  .trn_fc_cpld( trn_fc_cpld_c ),						// O[11:0]
	  .trn_fc_cplh( trn_fc_cplh_c ),						// O[7:0]
	  .trn_fc_npd( trn_fc_npd_c ),							// O[11:0]
	  .trn_fc_nph( trn_fc_nph_c ),							// O[7:0]
	  .trn_fc_pd( trn_fc_pd_c ),								// O[11:0]
	  .trn_fc_ph( trn_fc_ph_c ),								// O[7:0]
	  .trn_fc_sel( trn_fc_sel_c ),	

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                   // I [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),               // I
      .cfg_di( cfg_di_c ),                                   // O [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                     // O
      .cfg_dwaddr( cfg_dwaddr_c ),                           // O
      .cfg_wr_en_n( cfg_wr_en_n_c ),                         // O
      .cfg_rd_en_n( cfg_rd_en_n_c ),                         // O
      
		
		.cfg_err_cor_n( cfg_err_cor_n_c ),                     // O
      .cfg_err_ur_n( cfg_err_ur_n_c ),                       // O
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                   // O
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),     // O
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),         // O
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),   // O
      .cfg_err_posted_n( cfg_err_posted_n_c ),               // O
      .cfg_err_locked_n( cfg_err_locked_n_c ),
		.cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),   // O [47:0]
  		.cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),             // I
      .cfg_interrupt_n( cfg_interrupt_n_c ),                 // O
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),         // I
      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),     // O
      .cfg_interrupt_di(cfg_interrupt_di_c),                 // O [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                 // I [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),     // I [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),   // I
		.cfg_interrupt_msixenable( cfg_interrupt_msixenable_c ),			// O
		.cfg_interrupt_msixfm( cfg_interrupt_msixfm_c ),					// O
      .cfg_turnoff_ok_n( cfg_turnoff_ok_n_c ),
		.cfg_to_turnoff_n( cfg_to_turnoff_n_c ),               // I
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),             // O
		.cfg_pm_wake_n( cfg_pm_wake_n_c ),                     // O
      .cfg_bus_number( cfg_bus_number_c ),                   // I [7:0]
      .cfg_device_number( cfg_device_number_c ),             // I [4:0]
      .cfg_function_number( cfg_function_number_c ),         // I [2:0]
      .cfg_status( cfg_status_c ),                           // I [15:0]
      .cfg_command( cfg_command_c ),                         // I [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                         // I [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                       // I [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                         // I [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // I [15:0]
		.cfg_dcommand2( cfg_dcommand2_c ),
		.cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),     // I [2:0]
      .pl_directed_link_change( pl_directed_link_change_c ),
		.pl_ltssm_state( pl_ltssm_state_c ),
		.pl_directed_link_width( pl_directed_link_width_c ),
		.pl_directed_link_speed( pl_directed_link_speed_c ),
		.pl_directed_link_auton( pl_directed_link_auton_c ),
		.pl_upstream_prefer_deemph( pl_upstream_prefer_deemph_c ),
		.pl_sel_link_width( pl_sel_link_width_c ),
		.pl_sel_link_rate( pl_sel_link_rate_c ),
		.pl_link_gen2_capable( pl_link_gen2_capable_c ),
		.pl_link_partner_gen2_supported( pl_link_partner_gen2_supported_c ),
		.pl_initial_link_width( pl_initial_link_width_c ),
		.pl_link_upcfg_capable( pl_link_upcfg_capable_c ),
		.pl_lane_reversal_mode( pl_lane_reversal_mode_c ),
		.pl_received_hot_rst( pl_received_hot_rst_c ),
  
		.cfg_dsn( cfg_dsn_n_c),                                // O [63:0]

      .aurora_offline( aurora_offline ),      
		.rst_o( rst_o ),
		.rst_txfifo_o( rst_txfifo_o ), 
		.debug_o_1( debug_o_1 ), 
		.debug_o_2( debug_o_2 ),
		
		
		.fifo_wr_data_o(din_o) ,
		.fifo_wr_en_o(wr_en_o) ,
		//connect the GTX-RX fifo    
 
		.fifo_rd_en_o(rd_en_o),
		.fifo_rd_data_i(dout_i),
		.fifo_empty_i(empty_i),
		.data_count_i(data_count_i)

      );
	 
pcie_v6_0 ep  (

  //-------------------------------------------------------
  // 1. PCI Express (pci_exp) Interface
  //-------------------------------------------------------
      .pci_exp_txp( pci_exp_txp ),             // O [7/3/0:0]
      .pci_exp_txn( pci_exp_txn ),             // O [7/3/0:0]
      .pci_exp_rxp( pci_exp_rxp ),             // I [7/3/0:0]
      .pci_exp_rxn( pci_exp_rxn ),             // I [7/3/0:0]

  //-------------------------------------------------------
  // 2. Transaction (TRN) Interface
  //-------------------------------------------------------
      .trn_clk( trn_clk_c ),                   // O
      .trn_reset_n( trn_reset_n_c ),           // O
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // O

      // Tx Local-Link
      .trn_tbuf_av( trn_tbuf_av_c ),           // O [5:0]
		.trn_tcfg_req_n( trn_tcfg_req_n_c ),		// O
		.trn_terr_drop_n( trn_terr_drop_n_c ),		// O
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // O
      .trn_td( trn_td_c ),                     // I [63/31:0]
      .trn_trem_n( trn_trem_n_c ),             	// I 
      .trn_tsof_n( trn_tsof_n_c ),             // I
      .trn_teof_n( trn_teof_n_c ),             // I
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // I
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // I
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // I
		.trn_tcfg_gnt_n( trn_tcfg_gnt_n_c ),		// I
		.trn_tstr_n( trn_tstr_n_c ),					// I

      // Rx Local-Link
      .trn_rd( trn_rd_c ),                     // O [63/31:0]
      .trn_rrem_n( trn_rrem_n_c ),               // O 
      .trn_rsof_n( trn_rsof_n_c ),             // O
      .trn_reof_n( trn_reof_n_c ),             // O
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // O
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // O
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // O
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // O [6:0]
		.trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // I
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // I
		
	  // Flow Control
	  .trn_fc_cpld( trn_fc_cpld_c ),						// O[11:0]
	  .trn_fc_cplh( trn_fc_cplh_c ),						// O[7:0]
	  .trn_fc_npd( trn_fc_npd_c ),							// O[11:0]
	  .trn_fc_nph( trn_fc_nph_c ),							// O[7:0]
	  .trn_fc_pd( trn_fc_pd_c ),								// O[11:0]
	  .trn_fc_ph( trn_fc_ph_c ),								// O[7:0]
	  .trn_fc_sel( trn_fc_sel_c ),							// I[2:0]

  //-------------------------------------------------------
  // 3. Configuration (CFG) Interface
  //-------------------------------------------------------
      .cfg_do( cfg_do_c ),                                    // O [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),                // O
      .cfg_di( cfg_di_c ),                                    // I [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                      // I [3:0]
      .cfg_dwaddr( cfg_dwaddr_c ),                            // I [9:0]
      .cfg_wr_en_n( cfg_wr_en_n_c ),                          // I
      .cfg_rd_en_n( cfg_rd_en_n_c ),                          // I

      .cfg_err_cor_n( cfg_err_cor_n_c ),                      // I
      .cfg_err_ur_n( cfg_err_ur_n_c ),                        // I
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                    // I
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),      // I
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),          // I
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),    // I
      .cfg_err_posted_n( cfg_err_posted_n_c ),                // I
      .cfg_err_locked_n( cfg_err_locked_n_c ),                // I
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),    // I [47:0]
		.cfg_err_cpl_rdy_n( cfg_err_cpl_rdy_n_c ),              // O
      .cfg_interrupt_n( cfg_interrupt_n_c ),                  // I
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),          // O
      .cfg_interrupt_assert_n(cfg_interrupt_assert_n_c),      // I
      .cfg_interrupt_di(cfg_interrupt_di_c),                  // I [7:0]
      .cfg_interrupt_do(cfg_interrupt_do_c),                  // O [7:0]
      .cfg_interrupt_mmenable(cfg_interrupt_mmenable_c),      // O [2:0]
      .cfg_interrupt_msienable(cfg_interrupt_msienable_c),    // O
		.cfg_interrupt_msixenable( cfg_interrupt_msixenable_c ),			// O
		.cfg_interrupt_msixfm( cfg_interrupt_msixfm_c ),					// O
      .cfg_turnoff_ok_n( cfg_turnoff_ok_n_c ),								// I
		.cfg_to_turnoff_n( cfg_to_turnoff_n_c ),                // I
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),              // I
		.cfg_pm_wake_n( cfg_pm_wake_n_c ),                      // I
      .cfg_bus_number( cfg_bus_number_c ),                    // O [7:0]
      .cfg_device_number( cfg_device_number_c ),              // O [4:0]
      .cfg_function_number( cfg_function_number_c ),          // O [2:0]
      .cfg_status( cfg_status_c ),                            // O [15:0]
      .cfg_command( cfg_command_c ),                          // O [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                          // O [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                        // O [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                          // O [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // O [15:0]
      .cfg_dcommand2( cfg_dcommand2_c ),// O [15:0] 
		.cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),      // O [2:0]
      
		
		
		.cfg_dsn( cfg_dsn_n_c),                                 // I [63:0]

  									 
//  .cfg_pmcsr_pme_en( ),													// O
//  .cfg_pmcsr_pme_status( ),												// O
//  .cfg_pmcsr_powerstate( ),												// O[1:0]

       // The following is used for simulation only.  Setting
       // the following core input to 1 will result in a fast
       // train simulation to happen.  This bit should not be set
       // during synthesis or the core may not operate properly.
// `ifdef SIMULATION
// .fast_train_simulation_only(1'b1)
// `else
// .fast_train_simulation_only(1'b0)
// `endif
   //-------------------------------------------------------
  // 4. Physical Layer Control and Status (PL) Interface
  //-------------------------------------------------------
  .pl_directed_link_change( pl_directed_link_change_c ),
  .pl_ltssm_state( pl_ltssm_state_c ),
  .pl_directed_link_width( pl_directed_link_width_c ),
  .pl_directed_link_speed( pl_directed_link_speed_c),
  .pl_directed_link_auton( pl_directed_link_auton_c ),
  .pl_upstream_prefer_deemph( pl_upstream_prefer_deemph_c),
  .pl_sel_link_width( pl_sel_link_width_c ),
  .pl_sel_link_rate( pl_sel_link_rate_c ),
  .pl_link_gen2_capable( pl_link_gen2_capable_c ),
  .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported_c ),
  .pl_initial_link_width( pl_initial_link_width_c ),
  .pl_link_upcfg_capable( pl_link_upcfg_capable_c ),
  .pl_lane_reversal_mode( pl_lane_reversal_mode_c ),
  .pl_received_hot_rst( pl_received_hot_rst_c ),
  
   //-------------------------------------------------------
  // 5. System  (SYS) Interface
  //-------------------------------------------------------
      .sys_clk( sys_clk_c ),                               // I
      .sys_reset_n( sys_reset_n )                         // I
      // .refclkout( refclkout ),       // O

  

);


endmodule // XILINX_PCI_EXP_EP
