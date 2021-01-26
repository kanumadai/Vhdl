//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_EP_MEM.v
//--
//-- Description: Endpoint control and status registers
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns
//`define PCIE2_0 1

module BMD_EP_MEM# (
 parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14


)
(
                      clk,                   // I
                      rst_n,                 // I

                      cfg_cap_max_lnk_width, // I [5:0]
                      cfg_neg_max_lnk_width, // I [5:0]

                      cfg_cap_max_payload_size,  // I [2:0]
                      cfg_prg_max_payload_size,  // I [2:0]
                      cfg_max_rd_req_size,   // I [2:0]

                      a_i,                   // I [6:0]
                      wr_en_i,               // I 
                      rd_d_o,                // O [31:0]
                      wr_d_i,                // I [31:0]

                      init_rst_o,            // O

                      mrd_start_o,           // O
                      mrd_int_dis_o,         // O
                      mrd_done_o,            // O
                      mrd_addr_o,            // O [31:0]
                      mrd_len_o,             // O [31:0]
                      mrd_tlp_tc_o,          // O [2:0]
                      mrd_64b_en_o,          // O
                      mrd_phant_func_dis1_o,  // O
                      mrd_up_addr_o,         // O [7:0]
//                      mrd_count_o,           // O [31:0]
                      mrd_relaxed_order_o,   // O
                      mrd_nosnoop_o,         // O
//                      mrd_wrr_cnt_o,         // O [7:0]

                      mwr_start_o,           // O
                      mwr_int_dis_o,         // O 
                      mwr_done_i,            // I
                      mwr_addr_o,            // O [31:0]
                      mwr_len_i,             // O [31:0]
                      mwr_tlp_tc_o,          // O [2:0]
                      mwr_64b_en_o,          // O
                      mwr_phant_func_dis1_o,  // O
                      mwr_up_addr_o,         // O [7:0]
                      mwr_count_o,           // O [31:0]
                      mwr_data_o,            // O [31:0]
                      mwr_relaxed_order_o,   // O
                      mwr_nosnoop_o,         // O
                      mwr_wrr_cnt_o,         // O [7:0]
							 mwr_speed_i,				//I
							 
                      cpl_ur_found_i,        // I [7:0] 
                      cpl_ur_tag_i,          // I [7:0]

//                      cpld_data_o,           // O [31:0]
//                      cpld_found_i,          // I [31:0]
//                      cpld_data_size_i,      // I [31:0]
                      cpld_malformed_i,      // I
                      cpld_done_i,       // I
                      cpl_streaming_o,       // O
                      rd_metering_o,         // O
                      cfg_interrupt_di,      // O
                      cfg_interrupt_do,      // I
                      cfg_interrupt_mmenable,   // I
                      cfg_interrupt_msienable,  // I
                      cfg_interrupt_legacyclr,  // O
`ifdef PCIE2_0
                      pl_directed_link_change,
                      pl_ltssm_state,
                      pl_directed_link_width,
                      pl_directed_link_speed,
                      pl_directed_link_auton,
                      pl_upstream_preemph_src,
                      pl_sel_link_width,
                      pl_sel_link_rate,
                      pl_link_gen2_capable,
                      pl_link_partner_gen2_supported,
                      pl_initial_link_width,
                      pl_link_upcfg_capable,
                      pl_lane_reversal_mode,
                      pl_width_change_err_i,
                      pl_speed_change_err_i,
                      clr_pl_width_change_err,
                      clr_pl_speed_change_err,
                      clear_directed_speed_change_i,

`endif
                      trn_rnp_ok_n_o,
                      trn_tstr_n_o,
							 
							 listdata_cnt_i,
							 
							 immediate_coin_cnt_i,
							 delay_coin_cnt_i,
							 ///////
							 link_on_i,
							 
							 int_flag_i,
							 
							 gc_op_i,
							 
							 acq_time_o,
							 acq_count_o,
							 stop_mode_o,							 
							 
							 acq_param_dw0_o,
							 acq_param_dw1_o,	
	 

	                   acq_stop_o,
	                   acq_init_o,
							 acq_start_o
							 
                      );

    input             clk;
    input             rst_n;

    input [5:0]       cfg_cap_max_lnk_width;
    input [5:0]       cfg_neg_max_lnk_width;

    input [2:0]       cfg_cap_max_payload_size;
    input [2:0]       cfg_prg_max_payload_size;
    input [2:0]       cfg_max_rd_req_size;

    input [6:0]       a_i;
    input             wr_en_i;
    output [31:0]     rd_d_o;
    input  [31:0]     wr_d_i;

    // CSR bits

    output            init_rst_o;

    output            mrd_start_o;
    output            mrd_int_dis_o;
    output            mrd_done_o;
    output [31:0]     mrd_addr_o;
    output [31:0]     mrd_len_o;
    output [2:0]      mrd_tlp_tc_o;
    output            mrd_64b_en_o;
    output            mrd_phant_func_dis1_o;
    output [7:0]      mrd_up_addr_o;
//    output [31:0]     mrd_count_o;
    output            mrd_relaxed_order_o;
    output            mrd_nosnoop_o;
//    output [7:0]      mrd_wrr_cnt_o;

    output            mwr_start_o;
    output            mwr_int_dis_o;
    input             mwr_done_i;
    output [31:0]     mwr_addr_o;
    input [31:0]      mwr_len_i;
    output [2:0]      mwr_tlp_tc_o;
    output            mwr_64b_en_o;
    output            mwr_phant_func_dis1_o;
    output [7:0]      mwr_up_addr_o;
    output [31:0]     mwr_count_o;
    output [31:0]     mwr_data_o;
    output            mwr_relaxed_order_o;
    output            mwr_nosnoop_o;
    output [7:0]      mwr_wrr_cnt_o;
	 input             mwr_speed_i;

    input  [7:0]      cpl_ur_found_i;
    input  [7:0]      cpl_ur_tag_i;

//    output [31:0]     cpld_data_o;
//    input  [31:0]     cpld_found_i;
//    input  [31:0]     cpld_data_size_i;
    input             cpld_malformed_i;
    input             cpld_done_i;
    output            cpl_streaming_o;
    output            rd_metering_o;

    output            trn_rnp_ok_n_o;
    output            trn_tstr_n_o;
    output [7:0]      cfg_interrupt_di;
    input  [7:0]      cfg_interrupt_do;
    input  [2:0]      cfg_interrupt_mmenable;
    input             cfg_interrupt_msienable;
    output            cfg_interrupt_legacyclr;
	 
    input  [31:0]      listdata_cnt_i;
	 
    input  [31:0]      immediate_coin_cnt_i;	 
    input  [31:0]      delay_coin_cnt_i;	 
	 
	 output [31:0]      acq_param_dw0_o;
	 output [31:0]      acq_param_dw1_o;	
	 
	 output [31:0]      acq_time_o;
	 output [31:0]      acq_count_o;
	 output [1:0]       stop_mode_o;	 
	 

	 output               acq_stop_o;
	 output               acq_init_o;
	 output               acq_start_o;
	 
	 input               link_on_i; 
	 
	 input               int_flag_i; 
	 
	 input               gc_op_i; 
`ifdef PCIE2_0

    output [1:0]      pl_directed_link_change;
    input  [5:0]      pl_ltssm_state;
    output [1:0]      pl_directed_link_width;
    output            pl_directed_link_speed;
    output            pl_directed_link_auton;
    output            pl_upstream_preemph_src;
    input  [1:0]      pl_sel_link_width;
    input             pl_sel_link_rate;
    input             pl_link_gen2_capable;
    input             pl_link_partner_gen2_supported;
    input  [2:0]      pl_initial_link_width;
    input             pl_link_upcfg_capable;
    input  [1:0]      pl_lane_reversal_mode;

    input             pl_width_change_err_i;
    input             pl_speed_change_err_i;
    output            clr_pl_width_change_err;
    output            clr_pl_speed_change_err;
    input             clear_directed_speed_change_i;

`endif


    // Local Regs

    reg [31:0]        rd_d_o /* synthesis syn_direct_enable = 0 */; 

    reg               init_rst_o;
    reg               init_rst;
	 
    reg               mrd_start;	 
    reg               mwr_start;
	 
    reg               mrd_start_o;
    reg               mrd_int_dis_o;
    reg [31:0]        mrd_addr_o;
    reg [31:0]        mrd_len_o;
    reg [31:0]        mrd_count_o;
    reg [2:0]         mrd_tlp_tc_o;
    reg               mrd_64b_en_o;
    reg               mrd_phant_func_dis1_o;
    reg [7:0]         mrd_up_addr_o;
    reg               mrd_relaxed_order_o;
    reg               mrd_nosnoop_o;
    reg [7:0]         mrd_wrr_cnt_o;

    reg               mwr_start_o;
    reg               mwr_int_dis_o;
    reg [31:0]        mwr_addr_o;
//    reg [31:0]        mwr_len_o;
    reg [31:0]        mwr_count_o;
    reg [31:0]        mwr_data_o;
    reg [2:0]         mwr_tlp_tc_o;
    reg               mwr_64b_en_o;
    reg               mwr_phant_func_dis1_o;
    reg [7:0]         mwr_up_addr_o;
    reg               mwr_relaxed_order_o;
    reg               mwr_nosnoop_o;
    reg [7:0]         mwr_wrr_cnt_o;
//	 reg               mwr_speed_i;

    reg [31:0]        mrd_perf;
    reg [31:0]        mwr_perf;
 
    reg [31:0]        mrd_perf_post;
    reg [31:0]        mwr_perf_post;
    
   
    reg               mrd_done_o;

    reg [31:0]        cpld_data_o;
    reg [20:0]        expect_cpld_data_size;  // 2 GB max
    reg [20:0]        cpld_data_size;         // 2 GB max

    reg               cpl_streaming_o;
    reg               rd_metering_o;
    reg               trn_rnp_ok_n_o;
    reg               trn_tstr_n_o;
	 
    reg [15:0]         intclr_cnt;
    reg [15:0]         int_cnt;	 
	 
    reg [7:0]         cfg_interrupt_di;
    reg               cfg_interrupt_legacyclr;
    reg               LEGACYCLR_tmp;
	
    reg               mrd_done_flag;
    reg               mwr_done_flag;	

    reg               mwr_perf_clr;	
///
	 reg [31:0]         acq_time_o;
	 reg [31:0]         acq_count_o;	
	 reg [1:0]         stop_mode_o;	
	 
	 reg [31:0]         acq_param_dw0_o;
	 reg [31:0]         acq_param_dw1_o;	
	 
	 reg               acq_stop_o;
	 reg               acq_init_o; 
	 reg               acq_start_o; 
	 
	 reg               acq_start_flag;
	 reg               acq_stop_flag;
	 reg               acq_init_flag;
	 reg               acq_dma_wr_en_flag;	 	 
	 
	
`ifdef PCIE2_0

    reg [1:0]         pl_directed_link_change;
    reg [1:0]         pl_directed_link_width;
    wire              pl_directed_link_speed;
    reg [1:0]         pl_directed_link_speed_binary;
    reg               pl_directed_link_auton;
    reg               pl_upstream_preemph_src;
    reg               pl_width_change_err;
    reg               pl_speed_change_err;
    reg               clr_pl_width_change_err;
    reg               clr_pl_speed_change_err;
    wire [1:0]        pl_sel_link_rate_binary;

`endif  
   
    wire [7:0]        fpga_family;
    wire [3:0]        interface_type;
    wire [7:0]        version_number;


    assign version_number = 8'h16;
    assign interface_type = INTERFACE_TYPE;
    assign fpga_family = FPGA_FAMILY;

/*`ifdef BMD_64
    assign interface_type = 4'b0010;
`else // BMD_32
    assign interface_type = 4'b0001;
`endif // BMD_64

`ifdef VIRTEX2P 
    assign fpga_family = 8'h11;
`endif // VIRTEX2P 

`ifdef VIRTEX4FX
    assign fpga_family = 8'h12;
`endif // VIRTEX4FX

`ifdef PCIEBLK
    assign fpga_family = 8'h13;
`endif // PCIEBLK

`ifdef SPARTAN3
    assign fpga_family = 8'h18;
`endif // SPARTAN3

`ifdef SPARTAN3E
    assign fpga_family = 8'h28;
`endif // SPARTAN3E

`ifdef SPARTAN3A
    assign fpga_family = 8'h38;
`endif // SPARTAN3A

*/
//assign cfg_interrupt_di[7:0] = INTDI[7:0];
//wire cfg_interrupt_legacyclr = LEGACYCLR;
//assign cfg_interrupt_di = 8'haa;


`ifdef PCIE2_0

   assign pl_sel_link_rate_binary = (pl_sel_link_rate == 0) ? 2'b01 : 2'b10;
   assign pl_directed_link_speed = (pl_directed_link_speed_binary == 2'b01) ?
                                                0 : 1;
`endif

   
    always @(posedge clk ) begin
    
        if ( !rst_n ) begin

          init_rst  <= 1'b0;

			 mrd_done_flag <= 1'b0;
			 mwr_done_flag <= 1'b0;
          mrd_start_o <= 1'b0;
          mrd_int_dis_o <= 1'b0;
          mrd_addr_o  <= 32'b0;
          mrd_len_o   <= 32'b0;
          mrd_count_o <= 32'b0;
          mrd_tlp_tc_o <= 3'b0;
          mrd_64b_en_o <= 1'b0;
          mrd_up_addr_o <= 8'b0;
          mrd_relaxed_order_o <= 1'b0;
          mrd_nosnoop_o <= 1'b0;
          mrd_phant_func_dis1_o <= 1'b0;

          mwr_phant_func_dis1_o <= 1'b0;
          mwr_start_o <= 1'b0;
          mwr_int_dis_o <= 1'b0;
          mwr_addr_o  <= 32'b0;
//          mwr_len_o   <= 32'b0;
          mwr_count_o <= 32'b0;
          mwr_data_o  <= 32'b0;
          mwr_tlp_tc_o <= 3'b0;
          mwr_64b_en_o <= 1'b0;
          mwr_up_addr_o <= 8'b0;
          mwr_relaxed_order_o <= 1'b0;
          mwr_nosnoop_o <= 1'b0;

          cpld_data_o <= 32'b0;
          cpl_streaming_o <= 1'b1;
          rd_metering_o <= 1'b0;
          trn_rnp_ok_n_o <= 1'b0;
          trn_tstr_n_o <= 1'b0;
          mwr_wrr_cnt_o <= 8'h08;
          mrd_wrr_cnt_o <= 8'h08;

			 mrd_done_o <= 1'b0;
			 
			 mwr_perf_clr	<= 1'b0;
	
			 acq_time_o<= 32'b0;
			 acq_count_o<= 32'b0;	
			 stop_mode_o<= 2'b0;
			 
			 acq_param_dw0_o<= 32'b0;
			 acq_param_dw1_o<= 32'b0;	
	 
		    acq_stop_o<= 1'b0;
			 acq_init_o<= 1'b0;
			 acq_start_o<= 1'b0;
			 
			 acq_start_flag  <=1'b0;
			 acq_stop_flag  <= 1'b0;
			 acq_init_flag  <= 1'b0;
			 acq_dma_wr_en_flag <= 1'b0;	
			 
`ifdef PCIE2_0

          clr_pl_width_change_err <= 1'b0;
          clr_pl_speed_change_err <= 1'b0;
          pl_directed_link_change <= 2'h0;
          pl_directed_link_width  <= 2'h0;
          pl_directed_link_speed_binary  <= 2'b0; 
          pl_directed_link_auton  <= 1'b0;
          pl_upstream_preemph_src <= 1'b0;
          pl_width_change_err     <= 0;
          pl_speed_change_err     <= 0;

`endif          
          cfg_interrupt_di   <= 8'h00;
          cfg_interrupt_legacyclr  <=  1'b0;     
			 LEGACYCLR_tmp <= 1'b0;
        end else begin

`ifdef PCIE2_0

         if (a_i[6:0] != 7'b010011)   // Reg#19
         begin
            pl_width_change_err <= pl_width_change_err_i;
            pl_speed_change_err <= pl_speed_change_err_i;
            pl_directed_link_change <=
                        clear_directed_speed_change_i ? 0 :    // 1
                        pl_directed_link_change;               // 0
         end

`endif

		  if (cpld_done_i) begin
            mrd_done_o <= 1'b1;
				mrd_done_flag<= 1'b1;
				mrd_start <= 1'b0;
			end 
		  if (cfg_interrupt_legacyclr) begin
				mrd_done_flag<= 1'b0;
				mwr_done_flag <= 1'b0;
				cfg_interrupt_legacyclr <= 1'b0;
				LEGACYCLR_tmp <= 1'b1;
				
			end
		  if (mwr_done_i) begin
				mwr_done_flag <= 1'b1;
				mwr_start <= 1'b0;
			end
			
		  if (mrd_start_o) begin
				mrd_start <= 1'b1;
				mrd_start_o <= 1'b0;
			end				
//		  if (mwr_start_o) begin
//				mwr_start <= 1'b1;
//				mwr_start_o <= 1'b0;
//			end			
			
		  if (mrd_done_o) 
				mrd_done_o <= 1'b0;
				
		  if (mwr_perf_clr) 
				mwr_perf_clr	<= 1'b0;
				
		  if (acq_stop_o) 
				acq_stop_o <= 1'b0;
		  if (acq_init_o) 
				acq_init_o <= 1'b0;	
		  if (acq_start_o) 
				acq_start_o <= 1'b0;	
		  if (mwr_start_o) 
				mwr_start_o <= 1'b0;	
				
		  init_rst_o <= init_rst;		// when a acq finish ,the fifo needs be rst

       case (a_i[6:0])
        
            // 00-03H : Reg # 0 
            // Byte0[0]: Initiator Reset (RW) 0= no reset 1=reset.
            // Byte2[19:16]: Data Path Width
            // Byte3[31:24]: FPGA Family
            7'b0000000: begin
          
              if (wr_en_i)
                init_rst  <= wr_d_i[0];
        
              rd_d_o <= {fpga_family, {4'b0}, interface_type, version_number, {7'b0}, init_rst};
              
              if (init_rst) begin
               
                mwr_start_o <= 1'b0;
                mrd_start_o <= 1'b0;
					 LEGACYCLR_tmp <= 1'b0;
              end
             
            end

            // 04-07H :  Reg # 1
            // Byte0[0]: Memory Write Start (RW) 0=no start, 1=start
            // Byte0[7]: Memory Write Inter Disable (RW) 1=disable
            // Byte1[0]: Memory Write Done  (RO) 0=not done, 1=done
            // Byte2[0]: Memory Read Start (RW) 0=no start, 1=start
            // Byte2[7]: Memory Read Inter Disable (RW) 1=disable
            // Byte3[0]: Memory Read Done  (RO) 0=not done, 1=done
            7'b0000001: begin

              if (wr_en_i) begin
                mwr_start_o  <= wr_d_i[0];
					                 
					 acq_stop_o  <= wr_d_i[1];
					 acq_init_o  <= wr_d_i[2];					 
					 acq_start_o  <= wr_d_i[3];	
					 
                mwr_relaxed_order_o <=  wr_d_i[5];
                mwr_nosnoop_o <= wr_d_i[6];
                mwr_int_dis_o <= wr_d_i[7];
                mrd_start_o  <= wr_d_i[16];
                mrd_relaxed_order_o <=  wr_d_i[21];
                mrd_nosnoop_o <= wr_d_i[22];
                mrd_int_dis_o <= wr_d_i[23];
					 
					 mrd_done_flag <= 1'b0;
					 mwr_done_flag <= 1'b0;
					 mwr_perf_clr	<= 1'b0;
					 
//					 acq_start_flag  <=wr_d_i[0];
					 acq_stop_flag  <= wr_d_i[1];
					 acq_init_flag  <= wr_d_i[2];
					 acq_start_flag  <= wr_d_i[3];
					 acq_dma_wr_en_flag  <= wr_d_i[16];
              end 
				  				 
              rd_d_o <= { 7'b0, mrd_done_flag,
                         mrd_int_dis_o, 4'b0, mrd_nosnoop_o, mrd_relaxed_order_o, mrd_start_o, 
                         7'b0, mwr_done_flag,
                         mwr_int_dis_o, mwr_nosnoop_o, mwr_relaxed_order_o, 
								 acq_dma_wr_en_flag,acq_start_flag,acq_init_flag,acq_stop_flag,mwr_start_o};

            end

            // 08-0BH : Reg # 2
            // Memory Write DMA Address (RW)
            7'b0000010: begin

              if (wr_en_i)
//                mrd_addr_o  <= wr_d_i;
//              
//              rd_d_o <= mrd_addr_o;
				  mwr_addr_o  <= wr_d_i;
              
              rd_d_o <= mwr_addr_o;
//              rd_d_o <= 32'haa_55_0a_05;
            end

            // 0C-0FH : Reg # 3
            // Memory Write length in DWORDs (RW)
            7'b0000011: begin

              if (wr_en_i) begin
//                mwr_len_o  <= wr_d_i[15:0];
                mwr_tlp_tc_o  <= wr_d_i[18:16];
                mwr_64b_en_o <= wr_d_i[19];
                mwr_phant_func_dis1_o <= wr_d_i[20];
                mwr_up_addr_o <= wr_d_i[31:24];
              end
					rd_d_o <= mwr_len_i;
//              rd_d_o <= {mwr_up_addr_o, 
//                         3'b0, mwr_phant_func_dis1_o, mwr_64b_en_o, mwr_tlp_tc_o, 
//                         mwr_len_i[15:0]};

            end

            // 10-13H : Reg # 4
            // acq time (s) (RW)
            7'b0000100: begin

              if (wr_en_i)
                acq_time_o  <= wr_d_i;
              
					 rd_d_o <= acq_time_o;
//                mwr_count_o  <= wr_d_i;
//              
//              rd_d_o <= mwr_count_o;
            end

            // 14-17H : Reg # 5
            // acq count (RW)
            7'b0000101: begin

              if (wr_en_i)
                acq_count_o  <= wr_d_i;
              
					 rd_d_o <= acq_count_o;
//                mwr_data_o  <= wr_d_i;
//              
//              rd_d_o <= mwr_data_o;
            end

            // 18-1BH : Reg # 6
            // stop mode (RW)
            7'b0000110: begin

              if (wr_en_i)
                stop_mode_o  <= wr_d_i[1:0];

                rd_d_o <= {30'b0,stop_mode_o};				  
//                cpld_data_o  <= wr_d_i;
//
//              rd_d_o <= cpld_data_o;

            end

            // 1C-1FH : Reg # 7
            // Read DMA Address (RW)
            7'b0000111: begin

              if (wr_en_i)
//                mwr_addr_o  <= wr_d_i;
//              
//              rd_d_o <= mwr_addr_o;
                mrd_addr_o  <= wr_d_i;
              
              rd_d_o <= mrd_addr_o;
            end

            // 20-23H : Reg # 8
            // Read length in DWORDs (RW)
            7'b0001000: begin

              if (wr_en_i) begin
                mrd_len_o  <= wr_d_i[15:0];
                mrd_tlp_tc_o  <= wr_d_i[18:16];
                mrd_64b_en_o <= wr_d_i[19];
                mrd_phant_func_dis1_o <= wr_d_i[20];
                mrd_up_addr_o <= wr_d_i[31:24];
              end
              
              rd_d_o <= {mrd_up_addr_o, 
                         3'b0, mrd_phant_func_dis1_o, mrd_64b_en_o, mrd_tlp_tc_o, 
                         mrd_len_o[15:0]};

            end

            // 24-27H : Reg # 9
            //  (RO)
            7'b0001001: begin				  
              rd_d_o <= immediate_coin_cnt_i;
            end

            // 28-2BH : Reg # 10 
            // (RO)
            7'b0001010: begin
              rd_d_o <= delay_coin_cnt_i;
            end

            // 2C-2FH  : Reg # 11
            // Memory Read  Performance (RO)
            7'b0001011: begin

              rd_d_o <= int_flag_i;

            end

            // 30-33H  : Reg # 12
            // acq param DW0 (RW)
            7'b0001100: begin
				if (wr_en_i)
					acq_param_dw0_o<= wr_d_i;

					rd_d_o <=acq_param_dw0_o;

//              rd_d_o <= {{15'b0}, cpld_malformed_i, cpl_ur_tag_i, cpl_ur_found_i};

            end

            // 34-37H  : Reg # 13
            // acq param DW1 (RW)
            7'b0001101: begin
				if (wr_en_i)
					acq_param_dw1_o<= wr_d_i;
				rd_d_o <=acq_param_dw1_o;

            end

            // 38-3BH  : Reg # 14
            // link check (RO)
            7'b0001110: begin

              rd_d_o <= {30'b0,gc_op_i,link_on_i};

            end

            // 3C-3FH : Reg # 15
            // Link Width (RO)
            7'b0001111: begin

              rd_d_o <= {16'b0, 
                         2'b0, cfg_neg_max_lnk_width, 
                         2'b0, cfg_cap_max_lnk_width};

            end

            // 40-43H : Reg # 16
            // Link Payload (RO)
            7'b0010000: begin

              rd_d_o <= {8'b0,
                         5'b0, cfg_max_rd_req_size, 
                         5'b0, cfg_prg_max_payload_size, 
                         5'b0, cfg_cap_max_payload_size};

            end

            // 44-47H : Reg # 17
            // WRR MWr
            // WRR MRd
            // Rx NP TLP Control
            // Completion Streaming Control (RW)
            // Read Metering Control (RW)

            7'b0010001: begin

              if (wr_en_i) begin
                cpl_streaming_o <= wr_d_i[0];
                rd_metering_o <= wr_d_i[1];
                trn_rnp_ok_n_o <= wr_d_i[8];
                trn_tstr_n_o <= wr_d_i[9];
                mwr_wrr_cnt_o <= wr_d_i[23:16];
                mrd_wrr_cnt_o <= wr_d_i[31:24];
              end
        
              rd_d_o <= {mrd_wrr_cnt_o, 
                         mwr_wrr_cnt_o, 
                         6'b0, trn_tstr_n_o, trn_rnp_ok_n_o, 
                         6'b0, rd_metering_o, cpl_streaming_o};

            end


            // 48-4BH : Reg # 18
            // INTDI (RW)
            // INTDO
            // MMEN
            // MSIEN

            7'b0010010: begin
               if (wr_en_i) begin
                  cfg_interrupt_di[7:0] <= wr_d_i[7:0];  
//                  LEGACYCLR <= 1'b0;
                  cfg_interrupt_legacyclr <= wr_d_i[8];						
               end 	
//					rd_d_o <= {3'b0, 
//								  LEGACYCLR_tmp,
//                          cfg_interrupt_msienable,
//                          cfg_interrupt_mmenable[2:0],
//                          cfg_interrupt_do[7:0],
//                          int_cnt[7:0],
//                          intclr_cnt};

               rd_d_o <= {int_cnt,
                          intclr_cnt};
            end

`ifdef PCIE2_0
            // 4C-4FH : Reg # 19
            // CHG(RW), LTS, TW(RW), TS(RW), A(RW), P(RW), CW, CS, G2S, PG2S, 
            // LILW, LUC, SCE, WCE, LR

            7'b0010011: begin
               if (wr_en_i) begin
                   clr_pl_width_change_err       <= wr_d_i[29];
                   clr_pl_speed_change_err       <= wr_d_i[28];
                   pl_upstream_preemph_src       <= wr_d_i[15];    // P
                   pl_directed_link_auton        <= wr_d_i[14];    // A
                   pl_directed_link_speed_binary <= wr_d_i[13:12]; // TS
                   pl_directed_link_width        <= wr_d_i[9:8];   // TW
                   pl_directed_link_change       <= wr_d_i[1:0];   // CHG
               end else
               begin
                   clr_pl_width_change_err          <= 1'b0;
                   clr_pl_speed_change_err          <= 1'b0;
                   
                   pl_directed_link_change <= clear_directed_speed_change_i ?
                                      0 : pl_directed_link_change;  

               end

               rd_d_o <= { 
                  pl_lane_reversal_mode[1:0],             //LR   31:30
                  pl_width_change_err,                    //WCE     29
                  pl_speed_change_err,                    //SCE     28
                  pl_link_upcfg_capable,                  //LUC     27
                  pl_initial_link_width[2:0],             //LILW 26:24
                  pl_link_partner_gen2_supported,         //PG2S    23
                  pl_link_gen2_capable,                   //G2S     22
                  pl_sel_link_rate_binary[1:0],           //CS   21:20
                  2'b0,                                   //R1   19:18
                  pl_sel_link_width[1:0],                 // CW  17:16
                  pl_upstream_preemph_src,                //P       15
                  pl_directed_link_auton,                 //A       14
                  pl_directed_link_speed_binary[1:0],     //TS   13:12
                  2'b0,                                   //R0   11:10 
                  pl_directed_link_width[1:0],            //TW    9: 8
                  pl_ltssm_state[5:0],                    //LTS   7: 2
                  pl_directed_link_change[1:0]            //CHG   1: 0
                          };
            end
`endif


            // 50-7FH : Reserved
            default: begin

              rd_d_o <= 32'b0;

            end

          endcase

        end

    end
///////////////////////////////////	 
    always @(posedge clk ) begin

        if ( !rst_n ) begin

			 int_cnt <= 16'b0;
        end else begin
          if (init_rst ) 
				int_cnt <= 16'b0;
          else if (mwr_done_i)
				int_cnt <= int_cnt + 1'b1;
        end

    end	 
////////////////////	 
	 
    always @(posedge clk ) begin

        if ( !rst_n ) begin
          intclr_cnt <= 16'b0;
        end else begin

          if (init_rst ) 
            intclr_cnt <= 16'b0;
          else if (cfg_interrupt_legacyclr)
            intclr_cnt <= intclr_cnt + 1'b1;
        end

    end

    /*
     * Memory Write Performance Instrumentation
     */

    always @(posedge clk ) begin

        if ( !rst_n ) begin

          mwr_perf <= 32'b0;

        end else begin

          if (init_rst || mwr_perf_clr)
            mwr_perf <= 32'b0;
          else if (mwr_speed_i)
            mwr_perf <= mwr_perf + 1'b1;
        end

    end

    /*
     * Memory Read Performance Instrumentation
     */

    always @(posedge clk ) begin

        if ( !rst_n ) begin

          mrd_perf <= 32'b0;

        end else begin

          if (init_rst)
            mrd_perf <= 32'b0;
          else if (mrd_start && !mrd_done_o)
            mrd_perf <= mrd_perf + 1'b1;

        end

    end


//Account for 128 bit interface calculation error in GUI
//

    always @(posedge clk ) begin

        if ( !rst_n ) begin
          mrd_perf_post <= 32'b0;
          mwr_perf_post <= 32'b0;
        end else if (interface_type == 4'b0011) begin
           mrd_perf_post <= mrd_perf << 1;
           mwr_perf_post <= mwr_perf << 1;
        end else begin
           mrd_perf_post <= mrd_perf;
           mwr_perf_post <= mwr_perf;
        end

    end



endmodule

