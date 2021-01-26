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
//-- Filename: BMD_64_TX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Transmit Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_CPLD_FMT_TYPE   7'b10_01010
`define BMD_64_MWR_FMT_TYPE    7'b10_00000
`define BMD_64_MWR64_FMT_TYPE  7'b11_00000
`define BMD_64_MRD_FMT_TYPE    7'b00_00000
`define BMD_64_MRD64_FMT_TYPE  7'b01_00000

`define BMD_64_TX_RST_STATE    				19'b0000000000000000001
`define BMD_64_TX_CPLD_QW1     				19'b0000000000000000010
`define BMD_64_TX_CPLD_WIT     				19'b0000000000000000100
`define BMD_64_TX_MWR_QW1      				19'b0000000000000001000
`define BMD_64_TX_MWR_RATE_SEL 				19'b0000000000000010000	
`define BMD_64_TX_MWR_QWN      				19'b0000000000000100000
`define BMD_64_TX_MRD_QW1      				19'b0000000000001000000
`define BMD_64_TX_MRD_QWN      				19'b0000000000010000000
`define BMD_64_TX_MWR_LENGTH_CHECK			19'b0000000000100000000
`define BMD_64_TX_MWR_RDFIFO_DATA_LDW		19'b0000000001000000000
`define BMD_64_TX_MWR_RDFIFO_LAST_DATA		19'b0000000010000000000
`define BMD_64_TX_MWR_LAST_DW					19'b0000000100000000000
`define BMD_64_TX_MWR_LAST_QW					19'b0000001000000000000
`define BMD_64_TX_MWR_RDFIFO_DATA_HDW		19'b0000010000000000000
`define BMD_64_TX_MWR_QW0						19'b0000100000000000000
`define BMD_64_TX_MWR_STOPMODE_CHECK		19'b0001000000000000000
`define BMD_64_TX_MWR_RDFIFO_LISTDATA1 	19'b0010000000000000000
`define BMD_64_TX_MWR_RDFIFO_LISTDATA2		19'b0100000000000000000		
`define BMD_64_TX_MWR_RDFIFO_HEADER			19'b1000000000000000000


`define LISTDATA_TLP_INT			8'b00110010		//when tx 50 listmode TLPs,asser the mwr_done

module BMD_TX_ENGINE (

                        clk,
                        rst_n,

                        trn_td,
                        trn_trem_n,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tdst_dsc_n,
                        trn_tbuf_av,			//no use

                        req_compl_i,    
                        compl_done_o,  

                        req_tc_i,     
                        req_td_i,    
                        req_ep_i,   
                        req_attr_i,
                        req_len_i,         
                        req_rid_i,        
                        req_tag_i,       
                        req_be_i,
                        req_addr_i,     

                        // BMD Read Access
//                        rd_addr_o,   //no use
                        rd_be_o,    
                        rd_data_i,

                        // Initiator Reset          
                        init_rst_i,
                        // Write Initiator

                        mwr_start_i,
                        mwr_int_dis_i,
                        mwr_len_o,				//edited by lee
                        mwr_tag_i,
                        mwr_lbe_i,
                        mwr_fbe_i,
                        mwr_addr_i,
                        mwr_data_i,
                        mwr_count_i,
                        mwr_done_o,
                        mwr_tlp_tc_i,
                        mwr_phant_func_dis1_i,
                        mwr_relaxed_order_i,
                        mwr_nosnoop_i,
                        mwr_wrr_cnt_i,
								mwr_speed_o,
								
                        // Read Initiator

                        mrd_start_i,
                        mrd_int_dis_i,
                        mrd_len_i,
                        mrd_tag_i,
                        mrd_lbe_i,
                        mrd_fbe_i,
                        mrd_addr_i,
//                        mrd_count_i,
                        mrd_done_i,
                        mrd_tlp_tc_i,
                        mrd_phant_func_dis1_i,
                        mrd_relaxed_order_i,
                        mrd_nosnoop_i,
//                        mrd_wrr_cnt_i,
//                        cur_mrd_count_o,

                        cfg_msi_enable_i,
                        cfg_interrupt_n_o,
                        cfg_interrupt_assert_n_o,
                        cfg_interrupt_rdy_n_i,
                        cfg_interrupt_legacyclr,

                        completer_id_i,
                        cfg_ext_tag_en_i,
                        cfg_bus_mstr_enable_i,
                        cfg_phant_func_en_i,
                        cfg_phant_func_supported_i,
								
								debug_o_1,
								debug_o_2,
								//connect the GTX-RX fifo    

								fifo_rd_en_o,
								fifo_rd_data_i,
								fifo_empty_i,									
										
								listdata_cnt_o,
								
								acq_stop_out,
								acq_start_i,
								acq_stop_i,
								stop_mode_i,	
								acq_time_i,
								acq_count_i,	
								
								data_count_i		//fifo data count i		

                        );

    input               clk;
    input               rst_n;
	 
 //fifo 
    output              fifo_rd_en_o;	 
    input  [31:0]       fifo_rd_data_i;
    input               fifo_empty_i;
   
    output              debug_o_1;
	 output              debug_o_2;
    
	 output [63:0]       trn_td;
    output [7:0]        trn_trem_n;
    output              trn_tsof_n;
    output              trn_teof_n;
    output              trn_tsrc_rdy_n;
    output              trn_tsrc_dsc_n;
    input               trn_tdst_rdy_n;
    input               trn_tdst_dsc_n;
    input [5:0]         trn_tbuf_av;

    input               req_compl_i;
    output              compl_done_o;

    input [2:0]         req_tc_i;
    input               req_td_i;
    input               req_ep_i;
    input [1:0]         req_attr_i;
    input [9:0]         req_len_i;
    input [15:0]        req_rid_i;
    input [7:0]         req_tag_i;
    input [7:0]         req_be_i;
    input [10:0]        req_addr_i;
    
//    output [6:0]        rd_addr_o;
    output [3:0]        rd_be_o;
    input  [31:0]       rd_data_i;

    input               init_rst_i;

    input               mwr_start_i;
    input               mwr_int_dis_i;
    output  [31:0]      mwr_len_o;
    input  [7:0]        mwr_tag_i;
    input  [3:0]        mwr_lbe_i;
    input  [3:0]        mwr_fbe_i;
    input  [31:0]       mwr_addr_i;
    input  [31:0]       mwr_data_i;
    input  [31:0]       mwr_count_i;
    output              mwr_done_o;
    input  [2:0]        mwr_tlp_tc_i;
    input               mwr_phant_func_dis1_i;
    input               mwr_relaxed_order_i;
    input               mwr_nosnoop_i;
    input  [7:0]        mwr_wrr_cnt_i;
	 output              mwr_speed_o	;

    input               mrd_start_i;
    input               mrd_int_dis_i;
    input  [31:0]       mrd_len_i;
    input  [7:0]        mrd_tag_i;
    input  [3:0]        mrd_lbe_i;
    input  [3:0]        mrd_fbe_i;
    input  [31:0]       mrd_addr_i;
//    input  [31:0]       mrd_count_i;
    input               mrd_done_i;
    input  [2:0]        mrd_tlp_tc_i;
    input               mrd_phant_func_dis1_i;
    input               mrd_relaxed_order_i;
    input               mrd_nosnoop_i;
//    input  [7:0]        mrd_wrr_cnt_i;

//    output [15:0]       cur_mrd_count_o;

    input               cfg_msi_enable_i;
    output              cfg_interrupt_n_o;
    output              cfg_interrupt_assert_n_o;
    input               cfg_interrupt_rdy_n_i;
    input               cfg_interrupt_legacyclr;

    input [15:0]        completer_id_i;
    input               cfg_ext_tag_en_i;
    input               cfg_bus_mstr_enable_i;

    input               cfg_phant_func_en_i;
    input [1:0]         cfg_phant_func_supported_i;

	 output [31:0]       listdata_cnt_o;
	 
	 output					acq_stop_out;	
	 
	 input					acq_start_i; 
	 input					acq_stop_i;
	 input [1:0]			stop_mode_i;	
	 input [31:0]			acq_time_i;
	 input [31:0]			acq_count_i;	 
	 
	 input [12:0]			data_count_i;

    // Local registers

	reg [31:0]				header_7e7e7e;
	reg [31:0]				list_length_DW;
	reg [31:0]				user_data_h_DW;
	reg [31:0]				user_data_l_DW;
	reg [31:0]				user_length_DW;	
	reg [9:0]				TX_LENGTH;		
	reg                  fifo_rd_en_o;


    reg [63:0]          trn_td;
    reg [7:0]           trn_trem_n;
    reg                 trn_tsof_n;
    reg                 trn_teof_n;
    reg                 trn_tsrc_rdy_n;
    reg                 trn_tsrc_dsc_n;
 
    reg [11:0]          byte_count;
    reg [06:0]          lower_addr;

    reg                 req_compl_q;  
	 
    reg [18:0]          bmd_64_tx_state;
	 
    reg                 last_list_data;
    reg                 one_pack_done;	 
	 
    reg                 compl_done_o;
    reg                 mwr_done_o;

    reg                 mwr_done;
	 
    reg                 mrd_done;
    reg                 mwr_speed_o;


    reg [15:0]          cur_wr_count;
    reg [15:0]          cur_rd_count;
   
    reg [15:0]          list_cnt;
    reg [31:0]          t_mwr_addr;
  
    reg [11:0]          t_mwr_addr_offset;  
	 
    reg [12:0]          mwr_len_byte;
    reg [12:0]          mrd_len_byte;

    reg  [7:0]          tmrd_wrr_cnt;
////
	 reg  	            time_over_cnt_clr;
	 reg  	            time_over_cnt_en;
	 reg  	            time_over_cnt_end;
	 reg  	            time_over;	 
    reg  [31:0]         time_over_cnt;
////
    reg  [31:0]         listdata_cnt_o;
	 reg  [31:0]         listdata_cnt;
////	 
	reg						acq_count_out;
   reg  [31:0]          acq_time;		
   reg  [31:0]          acq_count;	
	reg						acq_start;
	reg						acq_stop;	
	reg						acq_stop_wait;		
	reg	[1:0] 			stop_mode;	
	
   reg  [31:0]          acq_timer_cnt;	
   reg  [31:0]          acq_timer_1s_cnt;	
	reg						acq_timer_1s_cnt_clr;
	reg						acq_timer_1s_cnt_en;		
	reg	      			acq_time_out;	
	reg	      			acq_time_out_tmp;	
	reg	      			acq_stop_out;	
	
   reg  [23:0]          rate_sel_cnt;
   reg  	               rate_sel_cnt_en;
   reg  	               pack_length_sel_done;	
	reg [31:0]				pack_length_DW;
	
////	 
	 reg                 mwr_start;	 
////	 

    // Local wires

    wire 					intr_done;	
	 wire						debug_o;	 
	 
	 wire                fifo_empty;
    wire [31:0]         fifo_rd_data;	
	 
	 wire						debug_o_1 = fifo_rd_en_o;
	 wire						debug_o_2 = fifo_empty;
    
	 wire [15:0]         cur_mrd_count_o = cur_rd_count;
    wire                cfg_bm_en = cfg_bus_mstr_enable_i;
    wire [31:0]         mwr_addr  = mwr_addr_i;
    wire [31:0]         mrd_addr  = mrd_addr_i;
    wire [31:0]         mwr_data_i_sw = {mwr_data_i[07:00],
                                         mwr_data_i[15:08],
                                         mwr_data_i[23:16],
                                         mwr_data_i[31:24]};

    wire  [2:0]         mwr_func_num = (!mwr_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_wr_count[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_wr_count[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_wr_count[10:8]} : 3'b000) : 3'b000;

//    wire  [2:0]         mrd_func_num = (!mrd_phant_func_dis1_i && cfg_phant_func_en_i) ? 
//                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
//                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_rd_count[8], 2'b00} : 
//                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_rd_count[9:8], 1'b0} : 
//                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_rd_count[10:8]} : 3'b000) : 3'b000;


//    assign mwr_start = mwr_start_i;
    /*
     * Present address and byte enable to memory module
     */
    assign fifo_rd_data = 	fifo_rd_data_i;
    assign fifo_empty 	=  fifo_empty_i;
	 
//    assign rd_addr_o = req_addr_i[10:2];
    assign rd_be_o 		=   req_be_i[3:0];
    assign mwr_len_o 	=   {22'b0,TX_LENGTH};
    /*
     * Calculate byte count based on byte enable
     */

    always @ (rd_be_o) begin

      casex (rd_be_o[3:0])
      
        4'b1xx1 : byte_count = 12'h004;
        4'b01x1 : byte_count = 12'h003;
        4'b1x10 : byte_count = 12'h003;
        4'b0011 : byte_count = 12'h002;
        4'b0110 : byte_count = 12'h002;
        4'b1100 : byte_count = 12'h002;
        4'b0001 : byte_count = 12'h001;
        4'b0010 : byte_count = 12'h001;
        4'b0100 : byte_count = 12'h001;
        4'b1000 : byte_count = 12'h001;
        4'b0000 : byte_count = 12'h001;

      endcase

    end

    /*
     * Calculate lower address based on  byte enable
     */

    always @ (rd_be_o or req_addr_i) begin

      casex (rd_be_o[3:0])
      
        4'b0000 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxxx1 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxx10 : lower_addr = {req_addr_i[4:0], 2'b01};
        4'bx100 : lower_addr = {req_addr_i[4:0], 2'b10};
        4'b1000 : lower_addr = {req_addr_i[4:0], 2'b11};

      endcase

    end

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          req_compl_q <= 1'b0;

        end else begin 

          req_compl_q <= req_compl_i;

        end

    end

    /*
     *  Interrupt Controller
     */

    BMD_INTR_CTRL BMD_INTR_CTRL  (

      .clk(clk),                                     // I
      .rst_n(rst_n),                                 // I

      .init_rst_i(init_rst_i),                       // I

      .mrd_done_i(mrd_done_i & !mrd_int_dis_i),      // I
      .mwr_done_i(mwr_done_o & !mwr_int_dis_i),      // I

      .msi_on(cfg_msi_enable_i),                     // I

      .cfg_interrupt_rdy_n_i(cfg_interrupt_rdy_n_i), // I
      .cfg_interrupt_assert_n_o(cfg_interrupt_assert_n_o), // O
      .cfg_interrupt_n_o(cfg_interrupt_n_o),        // O
      .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr), // I
		.intr_done_o(intr_done),
		.debug_o(debug_o)
    );


    /*
     *  Tx State Machine 
     */

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          trn_tsof_n        				<= 1'b1;
          trn_teof_n        				<= 1'b1;
          trn_tsrc_rdy_n   				<= 1'b1;
          trn_tsrc_dsc_n    				<= 1'b1;
          trn_td            				<= 64'b0;
          trn_trem_n        				<= 8'b0;
			 
			 user_length_DW        			<= 30'b0;
			 list_length_DW		         <= 32'b0;
			 t_mwr_addr        				<= 32'b0;
			 t_mwr_addr_offset 				<= 12'h080;	
			 last_list_data 					<= 1'b0;
			 one_pack_done 						<= 1'b0;
			 
			 listdata_cnt 						<= 32'b0;
			 listdata_cnt_o 					<= 32'b0;	
          
			 compl_done_o     	 			<= 1'b0;
          mwr_done_o        				<= 1'b0;
			 mwr_done			  				<= 1'b0;
			 
			 mwr_speed_o						<= 1'b0;
          mrd_done          				<= 1'b0;
			 list_cnt        					<= 16'b0;
          cur_wr_count      				<= 16'b0;
          cur_rd_count      				<= 16'b1;
			 TX_LENGTH							<= 10'b0;	
			 fifo_rd_en_o      				<= 1'b0;
			 
			 time_over_cnt_clr	  			<= 1'b0;
			 time_over_cnt_en	  				<= 1'b0;
			 time_over     	  				<= 1'b0;	
			 
			 mwr_start							<= 1'b0;
			 acq_count							<= 32'b0;	
			 acq_count_out						<= 1'b0;
			 acq_stop							<= 1'b0;
			 acq_start							<= 1'b0;
			 stop_mode							<= 2'b0;		
			 acq_time_out_tmp					<= 1'b0;	
			 acq_stop_out			  			<= 1'b0;
			 acq_stop_wait			  	<= 1'b0;	
          bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

        end else begin 
         
          if (init_rst_i ) begin

            trn_tsof_n        <= 1'b1;
            trn_teof_n        <= 1'b1;
            trn_tsrc_rdy_n    <= 1'b1;
            trn_tsrc_dsc_n    <= 1'b1;
            trn_td            <= 64'b0;
            trn_trem_n        <= 8'b0;
				
				user_length_DW        		<= 30'b0;
				list_length_DW			      <= 32'b0;
			   t_mwr_addr_offset 			<= 12'h080;	   
				last_list_data 				<= 1'b0;
				one_pack_done 					<= 1'b0;
				
				listdata_cnt 					<= 32'b0;				
				listdata_cnt_o 				<= 32'b0;	
				
            compl_done_o      <= 1'b0;
            mwr_done_o        <= 1'b0;
				mwr_done			  	<= 1'b0;
				
			   mwr_speed_o			<= 1'b0;
            mrd_done          <= 1'b0;

 			   list_cnt        	<= 16'b0; 				
            cur_wr_count      <= 16'b0;
            cur_rd_count      <= 16'b1;
			   TX_LENGTH			<= 10'b0;									
				fifo_rd_en_o		<= 1'b0;
				
				time_over_cnt_clr	<= 1'b0;
				time_over_cnt_en	<= 1'b0;
				time_over     	  	<= 1'b0;									
				acq_count			<= 32'b0;			
				acq_count_out		<= 1'b0;
				acq_stop	   		<= 1'b0;
				acq_start			<= 1'b0;
				stop_mode			<= 2'b0;		
				acq_time_out_tmp	<= 1'b0;	
				acq_stop_out		<= 1'b0;
				acq_stop_wait		<= 1'b0;	
			   mwr_start			<= 1'b0;
            bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

          end
			 //start dma wr,also start acq
			if (acq_start_i ) begin
				acq_start<= 1'b1;
				acq_count<=acq_count_i;
				stop_mode<= stop_mode_i;
			end
			if (mwr_start_i ) begin
				mwr_start<= 1'b1;
			end			
			if ((acq_start) && !time_over_cnt_en)
				time_over_cnt_en	 <= 1'b1;
			else if (!acq_start) begin
				time_over_cnt_en	 <= 1'b0;
				time_over_cnt_clr	  	<= 1'b1;
		   end 
/////////////////			
			if (acq_stop_i)
				acq_stop_wait			  	<= 1'b1;	
				
			if (acq_stop_wait && one_pack_done) begin
				acq_stop			  	<= 1'b1;	
				acq_stop_wait			  	<= 1'b0;	
			end 
				
			if (acq_time_out && one_pack_done) begin
				acq_stop			  	<= 1'b1;	
			end 	
				
			if (acq_stop_out)
				acq_stop_out			  	<= 1'b0;
////////////////////////										 
			if (intr_done)
				mwr_done			  	<= 1'b0;
			
			if (time_over_cnt_end) begin
				time_over_cnt_clr	  	<= 1'b1;
				time_over_cnt_en	  	<= 1'b0;
				time_over      	  	<= 1'b1;
				
				trn_tsof_n        <= 1'b1;
				trn_teof_n        <= 1'b0;
				trn_tsrc_rdy_n    <= 1'b0;
				trn_trem_n        <= 8'h00; 
				bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;
			end 
			if (acq_time_out_tmp)
				acq_time_out_tmp	<= 1'b0;	
				
			if (time_over_cnt_clr)
				time_over_cnt_clr  <= 1'b0;	
										
          case ( bmd_64_tx_state ) 

            `BMD_64_TX_RST_STATE : begin
				   mwr_done_o			<= 1'b0;
               compl_done_o       <= 1'b0;
				  if (mrd_done_i)
					  mrd_done <= 1'b0;
					
              // PIO read completions always get highest priority
///CPLD
              if (req_compl_q && 
                  !compl_done_o &&
                  !trn_tdst_rdy_n &&
                  trn_tdst_dsc_n	) begin

                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_CPLD_FMT_TYPE, 
                                      {1'b0}, 
                                      req_tc_i, 
                                      {4'b0}, 
                                      req_td_i, 
                                      req_ep_i, 
                                      req_attr_i, 
                                      {2'b0}, 
                                      req_len_i,
                                      completer_id_i, 
                                      {3'b0}, 
                                      {1'b0}, 
                                      byte_count };
                trn_trem_n        <= 8'b0;

                bmd_64_tx_state   <= `BMD_64_TX_CPLD_QW1;
////Mrd					 
					end else if (mrd_start_i && 
                           !mrd_done &&
                           !trn_tdst_rdy_n &&
                           trn_tdst_dsc_n && 
                           cfg_bm_en 
									) begin
             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_MRD_FMT_TYPE, 
                                      {1'b0}, 
                                      mrd_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mrd_relaxed_order_i, mrd_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      mrd_len_i[9:0],
                                      completer_id_i[15:3],
													{3'b000}, 
//                                      cfg_ext_tag_en_i ? cur_rd_count[7:0] : {3'b0, cur_rd_count[4:0]},
												  {8'b0},
                                      (mrd_len_i[9:0] == 1'b1) ? 4'b0 : mrd_lbe_i,
                                      mrd_fbe_i};
                trn_trem_n        <= 8'b0;
                bmd_64_tx_state   <= `BMD_64_TX_MRD_QW1;
//mwr					
				   end else if ((!mrd_start_i) &&
									 mwr_start &&
									(!mwr_done) &&
                           (!fifo_empty ) &&
									acq_start &&
									!acq_stop &&
									!acq_count_out &&
									!time_over
									) begin
						trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
						trn_tsrc_rdy_n    <= 1'b1;
												
						mwr_speed_o			<= 1'b1;
						
						if (list_cnt == 16'b0) begin							
							bmd_64_tx_state   <= `BMD_64_TX_MWR_RATE_SEL;	
						end else begin
							fifo_rd_en_o     <= 1'b1;						
							bmd_64_tx_state   <= `BMD_64_TX_MWR_RDFIFO_LISTDATA1;							
						end

					end else if ((!mrd_start_i) &&
									mwr_start &&
									(acq_start) && 
									(!mwr_done) && 
									(acq_stop ||
									acq_count_out ||
									time_over)
									) begin
						trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
						trn_tsrc_rdy_n    <= 1'b1;
												
						if ((stop_mode==2'b01 && acq_time_out) || 
							(stop_mode ==2'b10 && acq_count_out) ||
							 stop_mode ==2'b11 && !time_over)
							header_7e7e7e		<= 32'h22_7e_7e_7e;			//cmd code is 22h,PET_ACK
						else 
							header_7e7e7e		<= 32'h23_7e_7e_7e;			//cmd code is 23h,PET_NACK
						
						user_data_h_DW		<= 32'h00_00_00_00;		   //cmd length is 0 bytes
						TX_LENGTH      	<= 10'h2;
						user_length_DW		<= 30'h0;
						t_mwr_addr 			<= mwr_addr;
						acq_stop				<= 1'b0;
						acq_stop_out		<= 1'b1;
						acq_count_out		<= 1'b0;
						if (acq_time_out)
							acq_time_out_tmp	<= 1'b1;
						acq_start			<= 1'b0;
						time_over   	  	<= 1'b0;
						bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;	
						
					end else begin
                  trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
                  trn_tsrc_rdy_n    <= 1'b1;
                  trn_tsrc_dsc_n    <= 1'b1;
                  trn_td            <= 32'b0;
						bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;
					end
				end	
				
				`BMD_64_TX_MWR_RATE_SEL : begin	
					if (pack_length_sel_done) begin	
						list_length_DW<=pack_length_DW;	
						bmd_64_tx_state   <= `BMD_64_TX_MWR_STOPMODE_CHECK;
					end else
						bmd_64_tx_state   <= `BMD_64_TX_MWR_RATE_SEL;

				end				
				`BMD_64_TX_MWR_STOPMODE_CHECK : begin	
					if (list_length_DW>=acq_count && stop_mode== 2'b10) begin
						list_length_DW <= acq_count;	
					end 						
					bmd_64_tx_state   <= `BMD_64_TX_MWR_RDFIFO_HEADER;	
				end
				
				`BMD_64_TX_MWR_RDFIFO_LISTDATA1 : begin
					if (!fifo_empty) begin
						//header_7e7e7e, the real data is listmode data;
						header_7e7e7e<= {fifo_rd_data[7:0],fifo_rd_data[15:8],fifo_rd_data[23:16],fifo_rd_data[31:24]};	
						if (list_length_DW == 1'b1) begin
							t_mwr_addr			<= t_mwr_addr + t_mwr_addr_offset;
							last_list_data		<= 1'b1;
							TX_LENGTH      	<= 10'b1;
							fifo_rd_en_o     	<= 1'b0;
							one_pack_done		<= 1'b1;
							bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;
						end else begin
							list_length_DW <= list_length_DW - 2'h2;						
							bmd_64_tx_state  <= `BMD_64_TX_MWR_RDFIFO_LISTDATA2;				
						end
					end
				end
				`BMD_64_TX_MWR_RDFIFO_LISTDATA2 : begin
					if (!fifo_empty) begin
						//user_data_h_DW, the real data is listmode data;
						user_data_h_DW<= {fifo_rd_data[7:0],fifo_rd_data[15:8],fifo_rd_data[23:16],fifo_rd_data[31:24]};	
						fifo_rd_en_o     <= 1'b0;
						t_mwr_addr			<= t_mwr_addr + t_mwr_addr_offset;
						if (list_length_DW <= 8'h1e) begin
							user_length_DW 	<= list_length_DW[9:0];
							TX_LENGTH      	<= list_length_DW[9:0]+2'h2;
							one_pack_done		<= 1'b1;							
							bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;
						end else begin
							user_length_DW 	<= 30'h1e;	//30
							TX_LENGTH      	<= 10'h20;	//32							
							list_length_DW <= list_length_DW - 8'h1e;
							list_cnt	<= list_cnt + 1'b1;	
							bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;
						end 
					end else
						bmd_64_tx_state  <= `BMD_64_TX_MWR_RDFIFO_LISTDATA2;	
				end
				//one_pack_done means that there were several tlps have be send.
				`BMD_64_TX_MWR_RDFIFO_HEADER : begin	
					header_7e7e7e<= 32'h80_7e_7e_7e;  //pet_listmode
					//header_length
					user_data_h_DW		<= {list_length_DW[7:0],list_length_DW[15:8],list_length_DW[23:16],list_length_DW[31:24]};
					t_mwr_addr 			<= mwr_addr;
				   if (stop_mode==2'b10)
						acq_count <= acq_count - list_length_DW;
							
					if (list_length_DW <= 8'h1e) begin		// the data of the tlp is less than 32 DWs
						user_length_DW      <= list_length_DW[9:0];
						TX_LENGTH      	  <= list_length_DW[9:0]+2'h2;
						one_pack_done			<= 1'b1;
					end else begin
						user_length_DW      	<= 30'h1e;
						TX_LENGTH      		<= 10'h20;																	
						list_length_DW <= list_length_DW - 8'h1e;
						list_cnt	<= list_cnt + 1'b1;	
					end
					bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;			
					
				end

				`BMD_64_TX_MWR_QW0 : begin		
              if (!trn_tdst_rdy_n &&
                   trn_tdst_dsc_n && 
                   cfg_bm_en) begin             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_MWR_FMT_TYPE, 
                                      {1'b0}, 
                                      mwr_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mwr_relaxed_order_i, mwr_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      TX_LENGTH,
                                      completer_id_i[15:3],
													{3'b000}, 
//                                      cfg_ext_tag_en_i ? list_cnt[7:0] : {3'b0, list_cnt[4:0]},
													{8'b0},
                                      (TX_LENGTH == 1'b1) ? 4'b0 : mwr_lbe_i,
                                      mwr_fbe_i};
                trn_trem_n        <= 8'b0;	

					bmd_64_tx_state   <= `BMD_64_TX_MWR_QW1; 
              end else  begin
                  trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
                  trn_tsrc_rdy_n    <= 1'b1;
                  trn_tsrc_dsc_n    <= 1'b1;
                  trn_td            <= 64'b0;
                  trn_trem_n        <= 8'b0;
						bmd_64_tx_state   <= `BMD_64_TX_MWR_QW0;
              end
            end

            `BMD_64_TX_CPLD_QW1 : begin
              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { req_rid_i, 
                                      req_tag_i, 
                                      {1'b0}, 
                                      lower_addr,
                                      rd_data_i };
                trn_trem_n       <= 8'h00;
                compl_done_o     <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_QW1;

            end

            `BMD_64_TX_CPLD_WIT : begin

              if ( (!trn_tdst_rdy_n) || (!trn_tdst_dsc_n) ) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_tsrc_dsc_n   <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

            end
            `BMD_64_TX_MRD_QW1 : begin
              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td         <= {{mrd_addr_i[31:2], 2'b00}, 32'hd0_da_d0_da};
                trn_trem_n     <= 8'h0F;

					mrd_done<=1'b1;
                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n   <= 1'b0;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_MRD_QW1;

            end
				
         `BMD_64_TX_MWR_QW1 : begin
              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin                
                trn_td           <= {{t_mwr_addr[31:2], 2'b00}, header_7e7e7e};               
               
					 if (last_list_data)	begin
						last_list_data		<= 1'b0;
						trn_tsof_n       <= 1'b1;
						trn_teof_n       <= 1'b0;
						trn_tsrc_rdy_n   <= 1'b0; 
						trn_trem_n       <= 8'h00;
						time_over_cnt_clr <= 1'b1;
						time_over_cnt_en  <= 1'b0;						
						if (one_pack_done) begin	
							mwr_done_o		  	<= 1'b1;
							mwr_done			  	<= 1'b1;
							mwr_speed_o		  	<= 1'b0;
							one_pack_done		<= 1'b0;
							mwr_start   		<= 1'b0;
							list_cnt				<= 16'b0;
							if (acq_count==32'b0 && stop_mode== 2'b10)
								acq_count_out <= 1'b1;		
						end 
						bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;	
					 end else begin
						trn_tsof_n       <= 1'b1;
						trn_teof_n       <= 1'b1;
						trn_tsrc_rdy_n   <= 1'b0; 
						trn_trem_n       <= 8'hff;
						 if (user_length_DW == 1'b0)  
							  bmd_64_tx_state            <= `BMD_64_TX_MWR_LAST_DW; 
						 else if (user_length_DW == 1'b1) begin
							  fifo_rd_en_o					  <=	1'b1;
							  bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_LAST_DATA; 	
						 end else begin	  
							  fifo_rd_en_o					  <=	1'b1;
							  bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_LDW; 
						 end 
					  end
              end else if (!trn_tdst_dsc_n) begin
                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;				///?????
                trn_tsrc_dsc_n     <= 1'b0;
              end else begin
					 trn_tsrc_rdy_n   <= 1'b1;
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QW1;
				  end
         end

			`BMD_64_TX_MWR_LAST_DW : begin
            if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
               trn_td<={user_data_h_DW , 32'h00000000};
               trn_tsof_n       <= 1'b1;
               trn_teof_n       <= 1'b0;
               trn_tsrc_rdy_n   <= 1'b0;
               trn_trem_n       <= 8'h0f; // 8-bit
					time_over_cnt_clr <= 1'b1;
					time_over_cnt_en  <= 1'b0;
					if (one_pack_done) begin	
						mwr_done_o		  	<= 1'b1;
						mwr_done			  	<= 1'b1;
						mwr_speed_o		  	<= 1'b0;
						one_pack_done		<= 1'b0;
						mwr_start   		<= 1'b0;
						list_cnt				<= 16'b0;						
						if (acq_count==32'b0 && stop_mode== 2'b10)
							acq_count_out <= 1'b1;
					end 
               bmd_64_tx_state            <= `BMD_64_TX_RST_STATE;
            end else begin
					trn_tsrc_rdy_n   <= 1'b1;
               bmd_64_tx_state            <= `BMD_64_TX_MWR_LAST_DW;
				end 
         end 
			`BMD_64_TX_MWR_RDFIFO_LAST_DATA : begin
            if (!fifo_empty) begin
               user_data_l_DW  <= {fifo_rd_data[7:0],fifo_rd_data[15:8],fifo_rd_data[23:16],fifo_rd_data[31:24]};
//					user_data_l_DW  <= fifo_rd_data;
               fifo_rd_en_o       <= 1'b0;
					
					if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
						trn_td<={user_data_h_DW , 
									fifo_rd_data[7:0],
									fifo_rd_data[15:8],
									fifo_rd_data[23:16],
									fifo_rd_data[31:24]};
						trn_tsof_n       <= 1'b1;
						trn_teof_n       <= 1'b0;
						trn_tsrc_rdy_n   <= 1'b0;
						trn_trem_n       <= 8'h00; // 8-bit
						time_over_cnt_clr <= 1'b1;
						time_over_cnt_en  <= 1'b0;
						if (one_pack_done) begin	
							mwr_done_o		  	<= 1'b1;
							mwr_done			  	<= 1'b1;
							mwr_speed_o			<= 1'b0;
							one_pack_done		<= 1'b0;
							mwr_start   		<= 1'b0;
							list_cnt				<= 16'b0;							
							if (acq_count==32'b0 && stop_mode== 2'b10)
								acq_count_out <= 1'b1;		

						end 	
						bmd_64_tx_state            <= `BMD_64_TX_RST_STATE;
					end else begin
						trn_tsrc_rdy_n   <= 1'b1;
						bmd_64_tx_state            <= `BMD_64_TX_MWR_LAST_QW;
					end
            end else begin
					trn_tsrc_rdy_n   <= 1'b1;
               bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_LAST_DATA;
				end
           end 
            
			`BMD_64_TX_MWR_LAST_QW : begin
            if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
               trn_td<={user_data_h_DW , user_data_l_DW};
               trn_tsof_n       <= 1'b1;
               trn_teof_n       <= 1'b0;
               trn_tsrc_rdy_n   <= 1'b0;
               trn_trem_n       <= 8'h00; // 8-bit
					time_over_cnt_clr <= 1'b1;
					time_over_cnt_en  <= 1'b0;
					if (one_pack_done) begin	
						mwr_done_o		  	<= 1'b1;
						mwr_done			  	<= 1'b1;
						mwr_speed_o			<= 1'b0;
						one_pack_done		<= 1'b0;
						mwr_start   		<= 1'b0;
						list_cnt				<= 16'b0;						
						if (acq_count==32'b0 && stop_mode== 2'b10)
								acq_count_out <= 1'b1;		

					end 
					bmd_64_tx_state            <= `BMD_64_TX_RST_STATE;
            end else
               bmd_64_tx_state            <= `BMD_64_TX_MWR_LAST_QW;            
           end 
			  
        `BMD_64_TX_MWR_RDFIFO_DATA_LDW : begin
            if (!fifo_empty) begin
               user_data_l_DW     <= {fifo_rd_data[7:0],fifo_rd_data[15:8],fifo_rd_data[23:16],fifo_rd_data[31:24]};
//					user_data_l_DW  	 <= fifo_rd_data;					
					if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
						trn_td			  <={user_data_h_DW ,
													fifo_rd_data[7:0],
													fifo_rd_data[15:8],
													fifo_rd_data[23:16],
													fifo_rd_data[31:24]};
						trn_tsof_n       <= 1'b1;
						trn_teof_n       <= 1'b1;
						trn_tsrc_rdy_n   <= 1'b0;
						trn_trem_n       <= 8'hff; // 8-bit
						user_length_DW	  <= user_length_DW - 2'h2;
						fifo_rd_en_o     <= 1'b1;						
						bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_HDW;
					end else begin
						trn_tsrc_rdy_n   <= 1'b1;
						fifo_rd_en_o       <= 1'b0;	
						user_length_DW		 <= user_length_DW - 1'b1;
						bmd_64_tx_state            <= `BMD_64_TX_MWR_QWN;
					end	
            end else begin
					trn_tsrc_rdy_n   <= 1'b1;
               bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_LDW;
				end
         end   
			
			`BMD_64_TX_MWR_QWN : begin
            if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
               trn_td			  <={user_data_h_DW , user_data_l_DW};
               trn_tsof_n       <= 1'b1;
               trn_teof_n       <= 1'b1;
               trn_tsrc_rdy_n   <= 1'b0;
               trn_trem_n       <= 8'hff; // 8-bit
					user_length_DW	  <= user_length_DW - 1'b1;
					fifo_rd_en_o     <= 1'b1;
               bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_HDW;
            end else begin	
					trn_tsrc_rdy_n   <= 1'b1;
               bmd_64_tx_state            <= `BMD_64_TX_MWR_QWN;
            end 
			 end
  			`BMD_64_TX_MWR_RDFIFO_DATA_HDW : begin
            if (!fifo_empty) begin
               user_data_h_DW  <= {fifo_rd_data[7:0],fifo_rd_data[15:8],fifo_rd_data[23:16],fifo_rd_data[31:24]};
//               user_data_h_DW  <= fifo_rd_data;
					if (user_length_DW == 1'b0) begin
					   fifo_rd_en_o       <= 1'b0;
						if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin
							trn_td<={fifo_rd_data[7:0],
										fifo_rd_data[15:8],
										fifo_rd_data[23:16],
										fifo_rd_data[31:24] , 
										32'h00000000};
							trn_tsof_n       <= 1'b1;
							trn_teof_n       <= 1'b0;
							trn_tsrc_rdy_n   <= 1'b0;
							trn_trem_n       <= 8'h0f; // 8-bit
							time_over_cnt_clr <= 1'b1;
							time_over_cnt_en  <= 1'b0;
							if (one_pack_done) begin	
								mwr_done_o		  	<= 1'b1;
								mwr_done			  	<= 1'b1;
								mwr_speed_o			<= 1'b0;
								one_pack_done		<= 1'b0;
								mwr_start   		<= 1'b0;
								list_cnt				<= 16'b0;								
								if (acq_count==32'b0 && stop_mode== 2'b10)
									acq_count_out <= 1'b1;		

							end 	
							bmd_64_tx_state            <= `BMD_64_TX_RST_STATE;	
						end else begin
							trn_tsrc_rdy_n   <= 1'b1;
							bmd_64_tx_state            <= `BMD_64_TX_MWR_LAST_DW;
						end
					end else if (user_length_DW == 1'b1) begin	
						trn_tsrc_rdy_n   <= 1'b1;
						bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_LAST_DATA;
					end else begin
						trn_tsrc_rdy_n   <= 1'b1;
						bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_LDW;
					end 							
            end else begin
					trn_tsrc_rdy_n   <= 1'b1;
					bmd_64_tx_state            <= `BMD_64_TX_MWR_RDFIFO_DATA_HDW;
				end
          end    
          endcase

        end

    end
//11101110011010110010100000		-62500000	-500ms
////when the fifo is overwrote ,the cnt 
    always @(posedge clk ) begin

        if ( !rst_n ) begin
          time_over_cnt <= 32'b0;
			 time_over_cnt_end <= 1'b0;
        end else begin
          if (init_rst_i || time_over_cnt_clr )
				 time_over_cnt <= 32'b0;
          else if (time_over_cnt_en)
             time_over_cnt <= time_over_cnt + 1'b1;
			 if (time_over_cnt == 32'h03B9ACA0)
				 time_over_cnt_end <= 1'b1;
			 else
				 time_over_cnt_end  <= 1'b0;
        end
    end
//1
////time stop mode ,timer
    always @(posedge clk ) begin

        if ( !rst_n ) begin
          acq_timer_cnt <= 32'b0;
			 acq_timer_1s_cnt <= 32'b0;
			 acq_timer_1s_cnt_en  <= 1'b0;
			 acq_time_out		<=1'b0;
			 acq_time			<= 32'b0;
        end else begin
          if (init_rst_i ) begin
				 acq_timer_1s_cnt <= 32'b0;
				 acq_timer_1s_cnt_en  <= 1'b0;
				 acq_timer_cnt <= 32'b0;
				 acq_time_out		<=1'b0;		
				 acq_time			<= 32'b0;
          end 
			 if (stop_mode_i==2'b01 && acq_start_i) begin
				 acq_timer_1s_cnt_en  <= 1'b1;
				 acq_time <= acq_time_i;
			 end
			 
			 if (acq_timer_1s_cnt_en && acq_timer_1s_cnt < 32'h07735940 )
             acq_timer_1s_cnt <= acq_timer_1s_cnt + 1'b1;
			 else if (acq_timer_1s_cnt ==32'h07735940 )	begin 		//125000000,1s; 62500000,1s->32'h03B9ACA0
				 acq_timer_1s_cnt <= 32'b0;
				 acq_timer_cnt <= acq_timer_cnt + 1'b1;
			 end 
			 if (acq_timer_cnt == acq_time && stop_mode==2'b01) begin
				acq_time_out		<=1'b1;
				acq_timer_cnt 		<= 32'b0;
				acq_timer_1s_cnt_en  <= 1'b0;					
			 end	
			 if (acq_time_out_tmp) 
				 acq_time_out		<=1'b0;			 
        end
    end
	 
    always @(posedge clk ) begin

        if ( !rst_n ) begin
          rate_sel_cnt_en<= 1'b0;
			 rate_sel_cnt <= 24'b0;
			 pack_length_sel_done<=1'b0;
			 pack_length_DW<=32'h00_00_0e_fe;
        end else begin
          if (init_rst_i ) begin
				 rate_sel_cnt_en<= 1'b0;
				 rate_sel_cnt <= 24'b0;
			    pack_length_sel_done<=1'b0;
				 pack_length_DW<=32'h00_00_0e_fe;
          end

			 if (acq_start_i)
				rate_sel_cnt_en<= 1'b1;
			 if (acq_stop_out) begin
				rate_sel_cnt_en<= 1'b0;
				rate_sel_cnt <= 24'b0;
				pack_length_sel_done<=1'b0;
			 end 
			 
        	 if (rate_sel_cnt < 24'h01E848 && rate_sel_cnt_en )			//0.001s
				rate_sel_cnt <= rate_sel_cnt + 1'b1;
			 if (rate_sel_cnt == 24'h01E848) begin
				pack_length_sel_done<=1'b1;
				if (data_count_i <= 1)			//data rate 1kps
					pack_length_DW<=32'h00_00_01_3e;		//318
				else if (data_count_i <= 8)	//data rate 8kps
					pack_length_DW<=32'h00_00_06_3e;		//1658
				else if (data_count_i <= 16)	//data rate 16kps
					pack_length_DW<=32'h00_00_0e_fe;		//3838
				else									//data rate over 16kps
					pack_length_DW<=32'h00_00_1f_3e;		//7998
			 end
		end
		  
    end
endmodule // BMD_64_TX_ENGINE

