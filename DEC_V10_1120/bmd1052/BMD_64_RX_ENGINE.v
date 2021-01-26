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
//-- Filename: BMD_64_RX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Receive Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_RX_RST            			15'b000000000000001
`define BMD_64_RX_MEM_RD32_QW1   			15'b000000000000010
`define BMD_64_RX_MEM_RD32_WT    			15'b000000000000100
`define BMD_64_RX_MEM_WR32_QW1   			15'b000000000001000
`define BMD_64_RX_MEM_WR32_WT    			15'b000000000010000
`define BMD_64_RX_CPL_QW1        			15'b000000000100000
`define BMD_64_RX_CPLD_QW1       			15'b000000001000000
`define BMD_64_RX_CPLD_QWN       			15'b000000010000000
`define BMD_64_RX_CPLD_QWN_2ND   			15'b000000100000000
`define BMD_64_RX_CPLD_QWN_LAST  			15'b000001000000000

`define BMD_64_RX_SEND_PET_PROTOCOL_L  	15'b000010000000000
`define BMD_64_RX_SEND_PET_PROTOCOL_DW0   15'b000100000000000
`define BMD_64_RX_SEND_PET_PROTOCOL_DW1  	15'b001000000000000
`define BMD_64_RX_SEND_PET_START			   15'b010000000000000
`define BMD_64_RX_SEND_PET_CMD			   15'b100000000000000
`define BMD_WR_FIFO_STATE_RST 			   15'b100000000000001
`define BMD_64_RX_SEND_PET_LENGTH		   15'b100000000000010

`define BMD_MEM_RD32_FMT_TYPE    7'b00_00000
`define BMD_MEM_WR32_FMT_TYPE    7'b10_00000
`define BMD_CPL_FMT_TYPE         7'b00_01010
`define BMD_CPLD_FMT_TYPE        7'b10_01010

module BMD_RX_ENGINE (

                        clk,
                        rst_n,

                        /*
                         * Initiator reset
                         */

                        init_rst_i,

                        /*
                         * Receive local link interface from PCIe core
                         */
                    
                        trn_rd,  
                        trn_rrem_n,
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rbar_hit_n,

                        /*
                         * Memory Read data handshake with Completion 
                         * transmit unit. Transmit unit reponds to 
                         * req_compl assertion and responds with compl_done
                         * assertion when a Completion w/ data is transmitted. 
                         */

                        req_compl_o,
                        compl_done_i,

                        addr_o,                    // Memory Read Address

                        req_tc_o,                  // Memory Read TC
                        req_td_o,                  // Memory Read TD
                        req_ep_o,                  // Memory Read EP
                        req_attr_o,                // Memory Read Attribute
                        req_len_o,                 // Memory Read Length (1DW)
                        req_rid_o,                 // Memory Read Requestor ID
                        req_tag_o,                 // Memory Read Tag
                        req_be_o,                  // Memory Read Byte Enables

                        /* 
                         * Memory interface used to save 1 DW data received 
                         * on Memory Write 32 TLP. Data extracted from
                         * inbound TLP is presented to the Endpoint memory
                         * unit. Endpoint memory unit reacts to wr_en_o
                         * assertion and asserts wr_busy_i when it is 
                         * processing written information.
                         */

                        wr_be_o,                   // Memory Write Byte Enable
                        wr_data_o,                 // Memory Write Data
                        wr_en_o,                   // Memory Write Enable
                        wr_busy_i,                  // Memory Write Busy

                        /*
                         * Completion no Data
                         */

                        cpl_ur_found_o,
                        cpl_ur_tag_o,

                        /*
                         * Completion with Data
                         */
                        
                        cpld_malformed_o,
								cpld_done_o ,
								
								list_sync_i,
								
								fifo_wr_data_o ,
								fifo_wr_en_o,

								acq_stop_in,
								acq_stop_to_rst_txfifo_o,
								
                        acq_param_dw0_i,
								acq_param_dw1_i,
								
								acq_start_i,
								acq_init_i,
								acq_stop_i,
								mrd_start_i, 
								mwr_start_i 								

                       );

    input              clk;
    input              rst_n;

    input              init_rst_i;

//fifo
    output [31:0]      fifo_wr_data_o;
    output				  fifo_wr_en_o;	 

    input [63:0]       trn_rd;
    input [7:0]        trn_rrem_n;
    input              trn_rsof_n;
    input              trn_reof_n;
    input              trn_rsrc_rdy_n;
    input              trn_rsrc_dsc_n;
    output             trn_rdst_rdy_n;
    input [6:0]        trn_rbar_hit_n;
 
    output             req_compl_o;
    input              compl_done_i;

    output [10:0]      addr_o;

    output [2:0]       req_tc_o;
    output             req_td_o;
    output             req_ep_o;
    output [1:0]       req_attr_o;
    output [9:0]       req_len_o;
    output [15:0]      req_rid_o;
    output [7:0]       req_tag_o;
    output [7:0]       req_be_o;

    output [7:0]       wr_be_o;
    output [31:0]      wr_data_o;
    output             wr_en_o;
    input              wr_busy_i;

    output [7:0]       cpl_ur_found_o;
    output [7:0]       cpl_ur_tag_o;

    output             cpld_malformed_o;
	 output             cpld_done_o;
	 
    input [31:0]       acq_param_dw0_i;
    input [31:0]       acq_param_dw1_i;	 
	
	 input					acq_start_i;	
	 input					acq_init_i;
	 input					acq_stop_i; 
	 input					mwr_start_i;
	 input					mrd_start_i; 	
	 
	 input					acq_stop_in;
	 output					acq_stop_to_rst_txfifo_o; 	
	 
	 input					list_sync_i;
	 
    // Local wire

//    wire   [31:0]      cpld_data_i_sw = {cpld_data_i[07:00],
//                                         cpld_data_i[15:08],
//                                         cpld_data_i[23:16],
//                                         cpld_data_i[31:24]};

    // Local Registers
    reg                fifo_wr_en_o;
    reg [31:0]         fifo_wr_data_o;
    reg [31:0]         fifo_wr_data_low;
    reg                fifo_wr_en_a;
    reg [31:0]         fifo_wr_data_a;	 
    reg                fifo_busy;
	 
    reg [14:0]         bmd_64_rx_state;
	 
    reg [14:0]         wr_fifo_state;
	 
    reg                trn_rdst_rdy_n;
    reg                req_compl_o;

    reg [2:0]          req_tc_o;
    reg                req_td_o;
    reg                req_ep_o;
    reg [1:0]          req_attr_o;
    reg [9:0]          req_len_o;
    reg [15:0]         req_rid_o;
    reg [7:0]          req_tag_o;
    reg [7:0]          req_be_o;

    reg [10:0]         addr_o;
    reg [7:0]          wr_be_o;
    reg [31:0]         wr_data_o;
    reg                wr_en_o;

    reg [7:0]          cpl_ur_found_o;
    reg [7:0]          cpl_ur_tag_o;

    reg                cpld_malformed_o;

//    reg [9:0]          cpld_real_size;
    reg           	  cpld_done_o;
    reg [6:0]          cpld_real_size;
    reg [6:0]          cpld_tlp_size;
	 
	 reg [31:0]         cmd_length; 
    reg [31:0]         acq_param_dw0; 
    reg [31:0]         acq_param_dw1; 
	 
    reg                mwr_start;
    reg                mrd_start;	 
	 reg 		           acq_stop;
    reg           	  acq_init;	 
    reg                acq_start;
	 
    reg                wr_cmd_length;
	 reg 		           wr_cmd_done;
    reg [3:0]       	  cmd_step;	
	 
	 reg 		           acq_stop_to_rst_txfifo_o;	
	 reg [7:0]          rst_txfifo_delay_cnt;	 
    reg 		           list_sync;
	 
	 
    always @ ( posedge clk ) begin
              
        if (!rst_n ) begin

          bmd_64_rx_state   <= `BMD_64_RX_RST;

          trn_rdst_rdy_n <= 1'b0;

          req_compl_o    <= 1'b0;

          req_tc_o       <= 2'b0;
          req_td_o       <= 1'b0;
          req_ep_o       <= 1'b0;
          req_attr_o     <= 2'b0;
          req_len_o      <= 10'b0;
          req_rid_o      <= 16'b0;
          req_tag_o      <= 8'b0;
          req_be_o       <= 8'b0;
          addr_o         <= 11'b0;

          wr_be_o        <= 8'b0;
          wr_data_o      <= 31'b0;
          wr_en_o        <= 1'b0;
          
		 
          cpl_ur_found_o   <= 8'b0;
          cpl_ur_tag_o     <= 8'b0;

          cpld_malformed_o <= 1'b0;
		    cpld_done_o      <= 1'b0;
          cpld_real_size   <= 7'b0;
          cpld_tlp_size    <= 7'b0;

			 fifo_busy		   <= 1'b0;
			 fifo_wr_en_o		<= 1'b0;
			 fifo_wr_data_o  <= 32'b0;
			 fifo_wr_data_low <= 32'b0;
			 		 
			 wr_cmd_length		<= 1'b0;
			 cmd_step 		   <= 4'b0;
			 wr_cmd_done		<= 1'b0;	
			 mrd_start <= 1'b0;
			 acq_stop_to_rst_txfifo_o<=1'b0;	
			 list_sync<=1'b0;	
			 rst_txfifo_delay_cnt<= 8'h0;
        end else begin

        if (init_rst_i) begin

          bmd_64_rx_state  <= `BMD_64_RX_RST;

          cpl_ur_found_o   <= 8'b0;
          cpl_ur_tag_o     <= 8'b0;
   
          cpld_malformed_o <= 1'b0;
		    cpld_done_o      <= 1'b0;
          cpld_real_size   <= 7'b0;
          cpld_tlp_size    <= 7'b0;
			 
			 fifo_busy		   <= 1'b0;
			 fifo_wr_en_o		<= 1'b0;
			 fifo_wr_data_o  <= 32'b0;
			 fifo_wr_data_low <= 32'b0;
			 	 
			 wr_cmd_length		<= 1'b0;
			 cmd_step 		   <= 4'b0;
			 wr_cmd_done		<= 1'b0;	
			 mrd_start 			<= 1'b0;
			 list_sync			<=1'b0;	
			 rst_txfifo_delay_cnt<= 8'h0;
         end
		  	if (acq_start_i) begin
				acq_param_dw0<=acq_param_dw0_i;
				acq_param_dw1<=acq_param_dw1_i;
				acq_start <= 1'b1;				
			end
			/////////////////////
			//when stop,the fifo is reset until the da has receive the PET_STOP cmd.
			if (acq_stop_to_rst_txfifo_o) begin
				rst_txfifo_delay_cnt<=rst_txfifo_delay_cnt + 1'b1;	
			end	
			
			if (rst_txfifo_delay_cnt == 8'hff) begin
				rst_txfifo_delay_cnt<= 8'h0;
				acq_stop_to_rst_txfifo_o<=1'b0;	
			end	
			////////////////////
		  	if (mrd_start_i) begin
				mrd_start <= 1'b1;		
			end		
			if (cpld_done_o)
				mrd_start <= 1'b0;
			
		   if (acq_stop_in) begin				
				acq_stop_to_rst_txfifo_o<=1'b1;
				acq_stop <= 1'b1;
			end 
		   if (acq_init_i) 
				acq_init <= 1'b1;	

			if (list_sync_i)
				list_sync<=1'b1;			
				
         case (bmd_64_rx_state)

           `BMD_64_RX_RST : begin
//				 wr_en_o        <= 1'b0;
				 fifo_wr_en_o		<= 1'b0;	
				 cpld_done_o      <= 1'b0;	
				 fifo_busy	      <= 1'b0;					 
             if ((!trn_rsof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin
            
               case (trn_rd[62:56]) 

                 `BMD_MEM_RD32_FMT_TYPE : begin

                   if (trn_rd[41:32] == 10'b1) begin
    
                     req_tc_o     <= trn_rd[54:52];  
                     req_td_o     <= trn_rd[47];
                     req_ep_o     <= trn_rd[46]; 
                     req_attr_o   <= trn_rd[45:44]; 
                     req_len_o    <= trn_rd[41:32]; 
                     req_rid_o    <= trn_rd[31:16]; 
                     req_tag_o    <= trn_rd[15:08]; 
                     req_be_o     <= trn_rd[07:00];

                     bmd_64_rx_state <= `BMD_64_RX_MEM_RD32_QW1;
    
                   end else
                     bmd_64_rx_state <= `BMD_64_RX_RST;

                 end
             
                 `BMD_MEM_WR32_FMT_TYPE : begin
    
                   if (trn_rd[41:32] == 10'b1) begin
    
                     wr_be_o      <= trn_rd[07:00];
//							wr_data_size <= trn_rd[41:32];	//bytes
                     bmd_64_rx_state <= `BMD_64_RX_MEM_WR32_QW1;
                    
                   end else
                     bmd_64_rx_state <= `BMD_64_RX_RST;
    
                 end
    
                 `BMD_CPL_FMT_TYPE : begin
    
                   if (trn_rd[15:12] != 3'b000) begin
    
                     cpl_ur_found_o <= cpl_ur_found_o + 1'b1;
                     bmd_64_rx_state   <= `BMD_64_RX_CPL_QW1;
    
                   end else
                     bmd_64_rx_state   <= `BMD_64_RX_RST;
    
                 end
    
                 `BMD_CPLD_FMT_TYPE : begin
                   
                   cpld_tlp_size    <= trn_rd[38:32];
                   cpld_real_size   <= 7'b0;
                   bmd_64_rx_state  <= `BMD_64_RX_CPLD_QW1;
                   
                 end
                 
                 default : begin
    
                   bmd_64_rx_state   <= `BMD_64_RX_RST;
    
                 end
              
               endcase
				 end else if (acq_init && !mrd_start) begin
					fifo_wr_en_o<=1'b1;
					fifo_wr_data_o<=32'h7e_7e_7e_00;//PET_INIT;
					cmd_length<= 32'b0;
					acq_init<= 1'b0;						
					bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_CMD;
				 end else if (acq_start && !mrd_start) begin
					fifo_wr_en_o<=1'b1;						
					fifo_wr_data_o<=32'h7e_7e_7e_20;//PET_PROTOCOL;						
					bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_L;
					acq_start<= 1'b0;						
				 end else if (acq_stop && !mrd_start) begin
					fifo_wr_en_o<=1'b1;
					fifo_wr_data_o<=32'h7e_7e_7e_02;//PET_STOP;
					cmd_length<= 32'b0;
					acq_stop<= 1'b0;							
					bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_CMD;
				end else if (list_sync && !mrd_start) begin
					fifo_wr_en_o<=1'b1;
					fifo_wr_data_o<=32'h7e_7e_7e_55;//PET_LIST_SYNC;
					cmd_length<= 32'b0;
					list_sync<= 1'b0;							
					bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_CMD;	
				end else
               bmd_64_rx_state   <= `BMD_64_RX_RST;

           end
           `BMD_64_RX_SEND_PET_PROTOCOL_L : begin
					fifo_wr_data_o<=32'h8;	//2DWs,8Bytes
               bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW0;
           end			  
           `BMD_64_RX_SEND_PET_PROTOCOL_DW0 : begin
					fifo_wr_data_o<=acq_param_dw0;
               bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW1;
           end			
           `BMD_64_RX_SEND_PET_PROTOCOL_DW1 : begin
					fifo_wr_data_o<=acq_param_dw1;
               bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_START;
           end		
           `BMD_64_RX_SEND_PET_START : begin
					fifo_wr_data_o<=32'h7e_7e_7e_01;//PET_START;
					cmd_length<= 32'h0;
               bmd_64_rx_state   <= `BMD_64_RX_SEND_PET_CMD;
           end				  
           `BMD_64_RX_SEND_PET_CMD : begin
					fifo_wr_data_o<=cmd_length;					
               bmd_64_rx_state   <= `BMD_64_RX_RST;
           end
          `BMD_64_RX_MEM_RD32_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               addr_o            <= trn_rd[44:34];
               req_compl_o       <= 1'b1;
               trn_rdst_rdy_n    <= 1'b1;
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_WT;

             end else
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_QW1;

           end

           `BMD_64_RX_MEM_RD32_WT: begin

             if (compl_done_i) begin
					trn_rdst_rdy_n    <= 1'b0;
					req_compl_o       <= 1'b0;
               bmd_64_rx_state   <= `BMD_64_RX_RST;
             end else
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_WT;
				end
           `BMD_64_RX_CPL_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               cpl_ur_tag_o     <= trn_rd[47:40];
               bmd_64_rx_state  <= `BMD_64_RX_RST;

             end else
               bmd_64_rx_state  <= `BMD_64_RX_CPL_QW1;

           end
			  `BMD_64_RX_MEM_WR32_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               addr_o           <= trn_rd[44:34];
               wr_data_o        <= trn_rd[31:00];
               wr_en_o          <= 1'b1;
               trn_rdst_rdy_n   <= 1'b1;
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_WT;

             end else
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_QW1;

           end

           `BMD_64_RX_MEM_WR32_WT: begin
             wr_en_o          <= 1'b0;
             if (!wr_busy_i) begin
				   trn_rdst_rdy_n   <= 1'b0;
               bmd_64_rx_state  <= `BMD_64_RX_RST;
             end else
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_WT;
			  	end		  
           `BMD_64_RX_CPLD_QW1 : begin
             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               cpld_real_size  <= cpld_real_size  + 1'b1;

               if (cpld_tlp_size != 1'b1)
                 cpld_malformed_o <= 1'b1;
               if (trn_rrem_n != 8'h00)
                 cpld_malformed_o <= 1'b1;

               bmd_64_rx_state  <= `BMD_64_RX_RST;

             end else if ((!trn_rsrc_rdy_n) && 
                          (!trn_rdst_rdy_n)) begin

               cpld_real_size   <= cpld_real_size  + 1'b1;
					fifo_wr_data_o<={trn_rd[07:00],trn_rd[15:08],trn_rd[23:16],trn_rd[31:24]};
					fifo_wr_en_o<=1'b1;
					fifo_busy	      <= 1'b1;	
               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;

             end else
               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QW1;
           end
   
			  `BMD_64_RX_CPLD_QWN : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin
               if (trn_rrem_n == 8'h0F) begin
                 cpld_real_size   <= cpld_real_size  + 1'h1;
                 if (cpld_tlp_size  != cpld_real_size  + 1'h1) begin
                   cpld_malformed_o <= 1'b1;
						 fifo_wr_en_o<=1'b0;
						 bmd_64_rx_state  <= `BMD_64_RX_RST;
					  end else begin
						  fifo_wr_data_o<={trn_rd[39:32],trn_rd[47:40],trn_rd[55:48],trn_rd[63:56]};
						  fifo_wr_en_o<=1'b1;
						  cpld_done_o<=1'b1;
						  bmd_64_rx_state  <= `BMD_64_RX_RST;
					  end 
               end else if (trn_rrem_n == 8'h00) begin
                 cpld_real_size   <= cpld_real_size  + 2'h2;
                 if (cpld_tlp_size  != cpld_real_size  + 2'h2) begin
						 bmd_64_rx_state  <= `BMD_64_RX_RST;
                   cpld_malformed_o <= 1'b1;
						 fifo_wr_en_o<=1'b0;
					  end else begin
						  fifo_wr_data_o<={trn_rd[39:32],trn_rd[47:40],trn_rd[55:48],trn_rd[63:56]};
						  fifo_wr_data_low<= {trn_rd[07:00],trn_rd[15:08],trn_rd[23:16],trn_rd[31:24]};
						  fifo_wr_en_o<=1'b1;
						  cpld_done_o<=1'b1;
						  trn_rdst_rdy_n <= 1'b1;
						  bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN_LAST;
					  end 
               end 
             end else if ((!trn_rsrc_rdy_n) && 
                          (!trn_rdst_rdy_n)) begin
					fifo_wr_data_o<={trn_rd[39:32],trn_rd[47:40],trn_rd[55:48],trn_rd[63:56]};
					fifo_wr_data_low<={trn_rd[07:00],trn_rd[15:08],trn_rd[23:16],trn_rd[31:24]};
					fifo_wr_en_o<=1'b1;
					trn_rdst_rdy_n <= 1'b1;
               cpld_real_size   <= cpld_real_size  + 2'h2;
               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN_2ND;

             end else begin
					fifo_wr_en_o<=1'b0;
               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QWN;
				 end 
           end
			`BMD_64_RX_CPLD_QWN_2ND : begin
				fifo_wr_en_o<=1'b1;
				fifo_wr_data_o<=fifo_wr_data_low;
				bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;					
				trn_rdst_rdy_n <= 1'b0;
			end
			`BMD_64_RX_CPLD_QWN_LAST : begin
				bmd_64_rx_state  <= `BMD_64_RX_RST;					
				trn_rdst_rdy_n <= 1'b0;
				fifo_wr_en_o<=1'b1;
				fifo_wr_data_o<=fifo_wr_data_low;
				cpld_done_o<=1'b0;
			end
			
         endcase

      end   

    end  


//    always @ ( posedge clk ) begin
//              
//      if (!rst_n ) begin
//
//			 fifo_wr_en_o		<= 1'b0;
//			 acq_init		   <= 1'b0;
//			 mrd_start 		   <= 1'b0;
//			 mwr_start 		   <= 1'b0;	
//			 acq_start			<= 1'b0;			 
//			 acq_stop		   <= 1'b0;			 
//			 acq_param_dw0 	<= 32'b0;
//			 acq_param_dw1 	<= 32'b0;
//			 fifo_wr_en_o		<= 1'b0;
//			 fifo_wr_data_o  <= 32'b0;
//			 wr_fifo_state   <= `BMD_WR_FIFO_STATE_RST;
//      end else begin
//        if (init_rst_i) begin
//			 fifo_wr_en_o		<= 1'b0;
//			 acq_init		   <= 1'b0;
//			 mrd_start 		   <= 1'b0;
//			 mwr_start 		   <= 1'b0;	
//			 acq_stop		   <= 1'b0;		
//			 acq_start			<= 1'b0;	 
//			 acq_param_dw0 	<= 32'b0;
//			 acq_param_dw1 	<= 32'b0;
//			 fifo_wr_en_o		<= 1'b0;
//			 fifo_wr_data_o  <= 32'b0;
//			 wr_fifo_state   <= `BMD_WR_FIFO_STATE_RST;
//        end else begin
//		  	if (acq_start_i) begin
//				acq_param_dw0<=acq_param_dw0_i;
//				acq_param_dw1<=acq_param_dw1_i;
//				acq_start <= 1'b1;		
//			end
//		  	if (mrd_start_i) begin
//				mrd_start <= 1'b1;		
//			end			
//		   if (acq_stop_i) 
//				acq_stop <= 1'b1;
//		   if (acq_init_i) 
//				acq_init <= 1'b1;	
//		   if (acq_stop_in) begin
//				acq_stop<= 1'b1;	
//				mwr_start<= 1'b0;	
//				mrd_start<= 1'b0;	
//				acq_start<= 1'b0;
//			end
//		   if (cpld_done_o) 
//				mrd_start <= 1'b0;				
//		  
//          case (wr_fifo_state) 
//				
//            `BMD_WR_FIFO_STATE_RST : begin
//					if (acq_init && !mrd_start && !fifo_busy) begin
//						fifo_wr_en_o<=1'b1;
//						fifo_wr_data_o<=32'h7e_7e_7e_00;//PET_INIT;
//						cmd_length<= 32'b0;	
//						acq_init<= 1'b0;
//						acq_stop<= 1'b0;	
//						mwr_start<= 1'b0;	
//						mrd_start<= 1'b0;	
//						acq_start<= 1'b0;
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_CMD;
////					 end else if (acq_start && !mrd_start && !fifo_busy ) begin
////						fifo_wr_en_o<=1'b1;
////						fifo_wr_data_o<=32'h7e_7e_7e_01;//PET_START;	
////						cmd_length<= 32'h0;	
////						acq_start<= 1'b0;	
////						wr_fifo_state   <= `BMD_64_RX_SEND_PET_CMD;
//					 end else if (acq_start && !mrd_start && !fifo_busy ) begin
//						fifo_wr_en_o<=1'b1;
//						fifo_wr_data_o<=32'h7e_7e_7e_20;//PET_PROTOCOL;	
////						cmd_length<= 32'h0;	
//						acq_start<= 1'b0;	
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_L;
//
//					 end else if (acq_stop && !mrd_start && !fifo_busy) begin
//						fifo_wr_en_o<=1'b1;
//						fifo_wr_data_o<=32'h7e_7e_7e_02;//PET_STOP;
//						cmd_length<= 32'b0;	
//						acq_stop<= 1'b0;	
//						mwr_start<= 1'b0;	
//						mrd_start<= 1'b0;	
//						acq_start<= 1'b0;
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_CMD;
//					end else begin
//						fifo_wr_en_o<=fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;
//					end
//            end
//          `BMD_64_RX_SEND_PET_PROTOCOL_L : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b1;
//						fifo_wr_data_o<=32'h8;	//cmd_length   2DW;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW0;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_L;
//					end
//			   end			  
//           `BMD_64_RX_SEND_PET_PROTOCOL_DW0 : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b1;
//						fifo_wr_data_o<=acq_param_dw0;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW1;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW0;
//					end
//           end			
//           `BMD_64_RX_SEND_PET_PROTOCOL_DW1 : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b1;
//						fifo_wr_data_o<=acq_param_dw1;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_START;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_PROTOCOL_DW1;
//					end
//           end		
//           `BMD_64_RX_SEND_PET_START : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b1;
//						fifo_wr_data_o<=32'h7e_7e_7e_01;//PET_START;	
//						cmd_length<= 32'h0;
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_CMD;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_START;
//					end
//           end				  
//           `BMD_64_RX_SEND_PET_CMD : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b1;
//						fifo_wr_data_o<=cmd_length;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_LENGTH;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_64_RX_SEND_PET_CMD;
//					end
//           end
//			  `BMD_64_RX_SEND_PET_LENGTH : begin
//					if (!fifo_busy) begin
//						fifo_wr_en_o  <= 1'b0;				
//						wr_fifo_state   <= `BMD_WR_FIFO_STATE_RST;
//					end else begin
//						fifo_wr_en_o  <= fifo_wr_en_a;
//						fifo_wr_data_o<=fifo_wr_data_a;					
//						wr_fifo_state   <= `BMD_WR_FIFO_STATE_RST;
//					end
//           end
//          endcase
//
//        end
//
//      end
//	end
//


	 
//           `BMD_64_RX_CPLD_QW1 : begin
// 				bmd_64_rx_state_q <= bmd_64_rx_state;
//             trn_rd_q          <= trn_rd;
//             trn_rrem_n_q      <= trn_rrem_n;
//             trn_reof_n_q      <= trn_reof_n;
//             trn_rsrc_rdy_n_q  <= trn_rsrc_rdy_n;
//
//             if ((!trn_reof_n) && 
//                 (!trn_rsrc_rdy_n) && 
//                 (!trn_rdst_rdy_n)) begin
//
//               cpld_real_size  <= cpld_real_size  + 1'b1;
//
//               if (cpld_tlp_size != 1'b1)
//                 cpld_malformed_o <= 1'b1;
//               if (trn_rrem_n != 8'h00)
//                 cpld_malformed_o <= 1'b1;
//
//               bmd_64_rx_state  <= `BMD_64_RX_RST;
//
//             end else if ((!trn_rsrc_rdy_n) && 
//                          (!trn_rdst_rdy_n)) begin
//
//               cpld_real_size   <= cpld_real_size  + 1'b1;
//               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;
//
//             end else
//               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QW1;
//
//           end

//           `BMD_64_RX_CPLD_QWN : begin
//
//             bmd_64_rx_state_q <= bmd_64_rx_state;
//             trn_rd_q          <= trn_rd;
//             trn_rrem_n_q      <= trn_rrem_n;
//             trn_reof_n_q      <= trn_reof_n;
//             trn_rsrc_rdy_n_q  <= trn_rsrc_rdy_n;
//
//             if ((!trn_reof_n) && 
//                 (!trn_rsrc_rdy_n) && 
//                 (!trn_rdst_rdy_n)) begin
//
//               if (trn_rrem_n == 8'h0F) begin
//
//                 cpld_real_size   <= cpld_real_size  + 1'h1;
//                 if (cpld_tlp_size  != cpld_real_size  + 1'h1)
//                   cpld_malformed_o <= 1'b1;
//
//               end else begin
//
//                 cpld_real_size   <= cpld_real_size  + 2'h2;
//                 if (cpld_tlp_size  != cpld_real_size  + 2'h2)
//                   cpld_malformed_o <= 1'b1;
//
//               end 
//               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN_last;
//					trn_rdst_rdy_n <= 1'b1;
////					bmd_64_rx_state  <= `BMD_64_RX_RST;
//					
//
//             end else if ((!trn_rsrc_rdy_n) && 
//                          (!trn_rdst_rdy_n)) begin
//
//               cpld_real_size   <= cpld_real_size  + 2'h2;
//               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN_2nd;
//					
//					trn_rdst_rdy_n <= 1'b1;
//             end else
//               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QWN;
//
//           end
//			`BMD_64_RX_CPLD_QWN_2nd : begin
//				bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;					
//				trn_rdst_rdy_n <= 1'b0;
//			end
//			`BMD_64_RX_CPLD_QWN_last : begin
//				bmd_64_rx_state  <= `BMD_64_RX_RST;					
//				trn_rdst_rdy_n <= 1'b0;
//			end
//			
//         endcase
//
//      end   
//
//    end       

//    always @ ( posedge clk ) begin
//              
//      if (!rst_n ) begin
//
//			 fifo_wr_en_o		<= 1'b0;
//			 fifo_wr_data_o  <= 32'b0;
//			 fifo_wr_data_low <= 32'b0;
//      end else begin
//
//        if (init_rst_i) begin
//			 fifo_wr_en_o		<= 1'b0;
//			 fifo_wr_data_o  <= 32'b0;
//			 fifo_wr_data_low <= 32'b0;
//        end else begin
//			 fifo_wr_en_o		<= 1'b0;
//          case (bmd_64_rx_state_q)
//
//            `BMD_64_RX_MEM_WR32_QW1 : begin
////
////              if (cpld_data_err_o == 1'b0)
////                if (trn_rd_q[31:00] != cpld_data_i_sw)
////                  cpld_data_err_o <= 1'b1;
////												
//					if (trn_rd_q[63:34] == 30'h0000000a) begin
//						fifo_wr_data_o<=trn_rd_q[31:00];
//						fifo_wr_en_o<=1'b1;
//					end else
//						fifo_wr_en_o<=1'b0;
//            end
//
//            `BMD_64_RX_MEM_WR32_QWN : begin
//
//              if (!trn_reof_n_q) begin
//  
//                if (trn_rrem_n_q == 8'h0F) begin
//  
////                  if (cpld_data_err_o == 1'b0)
////                    if (trn_rd_q[63:32] != cpld_data_i_sw)
////                      cpld_data_err_o <= 1'b1;
//							 
//						fifo_wr_data_o<=trn_rd_q[63:32];
//						fifo_wr_en_o<=1'b1;
//	 
//							 
//                 
//                end else if (trn_rrem_n_q == 8'h00) begin
//  
////                   if (cpld_data_err_o == 1'b0)
////                     if (trn_rd_q != {cpld_data_i_sw, cpld_data_i_sw})
////                       cpld_data_err_o <= 1'b1;
//						
//						fifo_wr_data_o<=trn_rd_q[63:32];
//						fifo_wr_data_low<= trn_rd_q[31:0];
//						fifo_wr_en_o<=1'b1;
//  
//  
//  
//                end else  // Invalid remainder
////                   cpld_data_err_o <= 1'b1;
//						 fifo_wr_en_o<=1'b0;
//              end else begin
////  
////                if (cpld_data_err_o == 1'b0)
////                  if (trn_rd_q != {cpld_data_i_sw, cpld_data_i_sw})
////                    cpld_data_err_o <= 1'b1;
//						fifo_wr_data_o<=trn_rd_q[63:32];
//						fifo_wr_data_low<= trn_rd_q[31:0];
//						fifo_wr_en_o<=1'b1;
//              end
//
//            end
//				`BMD_64_RX_MEM_WR32_QWN_2nd : begin
//
//					fifo_wr_en_o<=1'b1;
//					fifo_wr_data_o<=fifo_wr_data_low;
//				end	
//				
//				`BMD_64_RX_MEM_WR32_QWN_last : begin
//					if (trn_rrem_n_q == 8'h00) begin
//						fifo_wr_en_o<=1'b1;
//						fifo_wr_data_o<=fifo_wr_data_low;
//					end else
//						fifo_wr_en_o<=1'b0;
//					
//				end 
//          endcase
//
//        end
//
//      end
//
//    end


endmodule // BMD_64_RX_ENGINE
