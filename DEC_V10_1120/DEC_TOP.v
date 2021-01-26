module  DEC_TOP
(

  input                                          reset_n,
  input                                          clkin,
			  //SFP Module  
  input                                          SFP_RX_P, 
  input  		                                  SFP_RX_N,
  output                                         SFP_TX_P,
  output                                         SFP_TX_N,
  
//  output                                         SFP_LOS,
  output                                         SFP_iic_sda,
  output                                         SFP_iic_scl,
  output                                         SFP_tx_en,  
 //GTX REF_CLK  
  input                                          MGTCLK_P,
  input                                          MGTCLK_N,
  
  output [7:0]                                   leds,
  output                                         refclkout,
//PCIe interface	  
  input                                          sys_clk_p,
  input                                          sys_clk_n,  
  	  
  input  [(1 - 1):0]                             pci_exp_rxn,
  input  [(1 - 1):0]                             pci_exp_rxp,  
  output [(1 - 1):0]                             pci_exp_txn,
  output [(1 - 1):0]                             pci_exp_txp

);			 
		  
wire [12:0] 				data_count;
wire [31:0] 				rx_din;			  
wire [31:0] 				tx_dout;			  
wire [31:0] 				rx_dout;			  
wire [31:0] 				tx_din;				  
wire [31:0] 				clk_cnt;		

wire 			 				tx_rd_en;		
wire 			 				tx_empty;		
wire 			 				fifo_rst;		
wire 			 				rx_rd_en;		
wire 			 				rx_empty;		
wire 			 				rst_txfifo;		
wire 			 				txfifo_rst;	

wire 			 				pci_rst;		
wire 			 				rx_wr_clk;		
wire 			 				rx_wr_en;		
wire 			 				tx_rd_clk;		
wire 			 				tx_wr_en;		
wire 			 				tx_full;		
wire 			 				rx_full;		
wire 			 				aurora_reset;		
wire 			 				inreset;		
wire 			 				aurora_clkout;		
wire 			 				aurora_rst_o;	
wire 			 				sys_reset_n;	

wire [31:0] 				fifo_1_data;	
wire 			 				fifo_1_full;	
wire 			 				fifo_0_empty;	

  IBUF sys_reset_n_ibuf (.O(sys_reset_n), .I(reset_n));		  
			  
xilinx_pci_exp_ep pcie (
	.sys_clk_p( sys_clk_p),
	.sys_clk_n (sys_clk_n),
		
	.sys_reset_n  ( sys_reset_n),
	
	.aurora_offline ( aurora_rst_o),

//	.refclkout   ( open),
   .rst_o			 (pci_rst),
   .rst_txfifo_o	 (rst_txfifo),
	.debug_o_1	 ( leds[1]),		//leds(5),
	.debug_o_2	 ( leds[0]),
//RX fifo ,write part  ,data from the pcie,and write into the rx fifo
   .wr_clk  ( rx_wr_clk),
   .din_o  ( rx_din),
   .wr_en_o  ( rx_wr_en),
//TX fifo, read part  ,read data from the tx fifo and write into the pcie.  
   .rd_clk  ( tx_rd_clk),  
   .rd_en_o  ( tx_rd_en),
   .dout_i  ( tx_dout),
   .empty_i  ( tx_empty),
   .data_count_i ( data_count),	
//-----------------

   .pci_exp_rxn  ( pci_exp_rxn),
   .pci_exp_rxp  ( pci_exp_rxp),
   .pci_exp_txn  ( pci_exp_txn),
   .pci_exp_txp  ( pci_exp_txp)
);
fifo_32_2k RX_FIFO(
	.rst  ( inreset),
//RX fifo write part
    .wr_clk  ( rx_wr_clk),
    .din  ( rx_din),
    .wr_en  ( rx_wr_en),
	 .full  ( rx_full),
//RX fifo, read part   
    .rd_clk  ( aurora_clkout),   
    .rd_en  ( rx_rd_en),
    .dout ( rx_dout),
    .empty  ( rx_empty)
);
//fifo_32_16k TX_FIFO(
//	.rst  ( txfifo_rst),	
////TX fifo write part
//   .wr_clk  ( aurora_clkout),
//    .din  ( tx_din),
//    .wr_en  ( tx_wr_en),
//	 .full  (tx_full),
////TX fifo, read part    
//    .rd_clk  ( tx_rd_clk),  
//    .rd_en  (tx_rd_en),
//    .dout  ( tx_dout),
//    .empty  ( tx_empty),
//	 .rd_data_count  ( data_count)
//);
fifo_32_64k TX_FIFO_1(
	 .rst  ( txfifo_rst),	
//TX fifo write part
    .wr_clk  ( tx_rd_clk),
    .din  ( fifo_1_data),
    .wr_en  ( ~fifo_0_empty),
	 .full  (fifo_1_full),
//TX fifo, read part    
    .rd_clk  ( tx_rd_clk),  
    .rd_en  (tx_rd_en),
    .dout  ( tx_dout),
    .empty  ( tx_empty),
	 .rd_data_count  ( data_count)
);
fifo_32_64k TX_FIFO_0(
	 .rst  ( txfifo_rst),	
//TX fifo write part
    .wr_clk  ( aurora_clkout),
    .din  ( tx_din),
    .wr_en  ( tx_wr_en),
	 .full  (tx_full),
//TX fifo, read part    
    .rd_clk  ( tx_rd_clk),  
    .rd_en  (~fifo_1_full),
    .dout  ( fifo_1_data),
    .empty  ( fifo_0_empty)
	 
);

 aurora_module aurora(
	.reset			 (aurora_reset),
   .init_clk     (clkin),
   .clk_out      (aurora_clkout),
   .reset_out    (aurora_rst_o),
//WRITE TO TX FIFO;	
//	.m_axis_tready			 ( 		open),	
	.m_axis_tvalid			 ( tx_wr_en),
	.m_axis_tdata			 (	tx_din),
//READ FROM RX FIFO
	.s_axis_tvalid			 ( ~rx_empty),
	.s_axis_tdata			 (	rx_dout),
	.s_axis_tready			 (	rx_rd_en),

//SFP Module
	.SFP_RX_P		 (SFP_RX_P),
	.SFP_RX_N 	 (SFP_RX_N),
	.SFP_TX_P 	 (SFP_TX_P),
	.SFP_TX_N		 (SFP_TX_N),

//GTX REF_CLK
	.GTXQ1_P		 ( MGTCLK_P),
	.GTXQ1_N  	 ( MGTCLK_N),
//LED----
	.LED_tx		 ( leds[7]),
	.LED_rx		 ( leds[6])
	);
	
assign aurora_reset = ~sys_reset_n;
//assign pci_rst_i =  reset_n;		// on board hard reset
//				or (not aurora_rst_o);			-- aurora reset
assign inreset =  (pci_rst || 			// reg soft reset
				(~sys_reset_n));  //	||				// on board hard reset
//				 aurora_rst_o);			// aurora reset
assign txfifo_rst = (inreset || rst_txfifo);
assign leds[5] = pci_rst;
assign leds[4] = inreset;
assign leds[3] = tx_rd_en;
assign leds[2] = tx_empty;
//leds(0)<= tx_empty;
//leds(0)<= tx_rd_en;
assign refclkout = tx_full;


assign SFP_iic_sda = 1'b0;
assign SFP_iic_scl =1'b0;
assign SFP_tx_en =1'b1;
		
endmodule 		