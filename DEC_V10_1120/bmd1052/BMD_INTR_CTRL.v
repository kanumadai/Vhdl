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
//-- Filename: BMD_INTR_CTRL.v
//--
//-- Description: Endpoint Intrrupt Controller
//--
//--------------------------------------------------------------------------------


/// see ug341 page 100
`timescale 1ns/1ns

`define BMD_INTR_RST   			10'b0000000001
`define BMD_INTR_WR_ACT		   10'b0000000010
`define BMD_INTR_RD_ACT  		10'b0000000100
`define BMD_INTR_WR_ACT0	   10'b0000001000
`define BMD_INTR_RD_ACT0  		10'b0000010000
`define BMD_INTR_WR_ACT1  		10'b0000100000
`define BMD_INTR_RD_ACT1  		10'b0001000000
`define BMD_INTR_RD_ACT2  		10'b0010000000
`define BMD_INTR_WR_ACT2  		10'b0100000000
`define BMD_INTR_DUN   			10'b1000000000

module BMD_INTR_CTRL (
                      clk,                   // I
                      rst_n,                 // I

                      init_rst_i,            // I

                      mrd_done_i,            // I
                      mwr_done_i,            // I

                      msi_on,                // I

                      cfg_interrupt_assert_n_o, // O
                      cfg_interrupt_rdy_n_i,    // I
                      cfg_interrupt_n_o,        // O
                      cfg_interrupt_legacyclr,   // I
							 intr_done_o,	//o
							 debug_o	
       
                      );

    input             clk;
    input             rst_n;

    input             init_rst_i;

    input             mrd_done_i;
    input             mwr_done_i;

    input             msi_on;

    output            cfg_interrupt_assert_n_o;
    input             cfg_interrupt_rdy_n_i;
    output            cfg_interrupt_n_o;
    input             cfg_interrupt_legacyclr;
	 
	 output            intr_done_o;
	 output               debug_o; 

    // Local Registers

    reg [9:0]         intr_state;
    reg [9:0]         next_intr_state;
	 
    reg               debug;
	 
    reg               intr_done;	 
	 reg               intr_n;
    reg               intr_assert_n;


    parameter         Tcq = 1;
	 
    assign cfg_interrupt_n_o = intr_n;
    assign cfg_interrupt_assert_n_o = intr_assert_n;
	 
	 
	 assign intr_done_o = intr_done;
    assign debug_o = debug;
//    assign cfg_interrupt_n_o = rd_intr_n  & wr_intr_n;
//    assign cfg_interrupt_assert_n_o = rd_intr_assert_n & wr_intr_assert_n;


    //
    // Read Interrupt Control
    // 


    //
    // Write Interrupt Control
    // 
    always @(intr_state or next_intr_state or mwr_done_i or mrd_done_i or 
				cfg_interrupt_rdy_n_i or cfg_interrupt_legacyclr or msi_on) begin

      case (intr_state) /* synthesis full_case */ /* synthesis parallel_case */

        `BMD_INTR_RST : begin
				intr_done = 1'b0;
				debug = 1'b0;
				intr_n = 1'b1;
            intr_assert_n = 1'b1;
				if (mwr_done_i)	
					next_intr_state = `BMD_INTR_WR_ACT;				
				else if (mrd_done_i)
					next_intr_state = `BMD_INTR_RD_ACT;
				else
					next_intr_state = `BMD_INTR_RST;			 
        end
        `BMD_INTR_RD_ACT : begin		//rd
				intr_n = 1'b0;
            intr_assert_n = 1'b0;
				if (!cfg_interrupt_rdy_n_i) 
               next_intr_state = `BMD_INTR_RD_ACT0;
            else
               next_intr_state = `BMD_INTR_RD_ACT;
        end		  
        `BMD_INTR_WR_ACT : begin
				debug = 1'b1;
				intr_n = 1'b0;
            intr_assert_n = 1'b0;
				if (!cfg_interrupt_rdy_n_i) 
               next_intr_state = `BMD_INTR_WR_ACT0;
            else
               next_intr_state = `BMD_INTR_WR_ACT;
        end
        `BMD_INTR_RD_ACT0 : begin		//rd			 
            intr_n = 1'b1;
            intr_assert_n = 1'b1;
				next_intr_state = `BMD_INTR_RD_ACT1;
			end		  
        `BMD_INTR_WR_ACT0 : begin
//				debug = 1'b0;
				if (msi_on) begin
					intr_n = 1'b1;
					intr_assert_n = 1'b0;
					next_intr_state = `BMD_INTR_DUN;
           end else begin
					intr_n = 1'b1;
					intr_assert_n = 1'b0;
					next_intr_state = `BMD_INTR_WR_ACT1;
				end
			end

//				intr_n = 1'b1;
//				intr_assert_n = 1'b0;
//				next_intr_state = `BMD_INTR_WR_ACT1;
//			end
			
//        `BMD_INTR_RD_ACT1 : begin		//rd
//          if (cfg_interrupt_rdy_n_i)
//				next_intr_state = `BMD_INTR_RD_ACT2;
//          else 
//            next_intr_state = `BMD_INTR_RD_ACT1;
//		  end			
			
        `BMD_INTR_RD_ACT1 : begin		//rd
          if (cfg_interrupt_legacyclr) begin
            intr_n = 1'b0;
            intr_assert_n = 1'b1;
				if (!cfg_interrupt_rdy_n_i) begin
					next_intr_state = `BMD_INTR_DUN;
				end else
					next_intr_state = `BMD_INTR_RD_ACT2;
          end else begin
				intr_n = 1'b1;
            intr_assert_n = 1'b1;
            next_intr_state = `BMD_INTR_RD_ACT1;
          end
		  end
        `BMD_INTR_WR_ACT1 : begin
          if (cfg_interrupt_legacyclr) begin
				debug = 1'b0;
            intr_n = 1'b0;
            intr_assert_n = 1'b1;
				if (!cfg_interrupt_rdy_n_i) 
					next_intr_state = `BMD_INTR_DUN;
				else
					next_intr_state = `BMD_INTR_WR_ACT2;
          end else begin
				debug = 1'b1;
				intr_n = 1'b1;
            intr_assert_n = 1'b0;
            next_intr_state = `BMD_INTR_WR_ACT1;
          end
        end		  
//        `BMD_INTR_WR_ACT1 : begin
//          if (cfg_interrupt_rdy_n_i) 
//				next_intr_state = `BMD_INTR_WR_ACT2;
//          else 
//            next_intr_state = `BMD_INTR_WR_ACT1;
//        end
//		  `BMD_INTR_RD_ACT2 : begin
//		    intr_n = 1'b0;
//          intr_assert_n = 1'b1;
//		  	if (!cfg_interrupt_rdy_n_i) begin
//				debug = 1'b1;
//				next_intr_state = `BMD_INTR_DUN;
//			end else
//				next_intr_state = `BMD_INTR_RD_ACT2;
//        end		  
		  
		  `BMD_INTR_RD_ACT2 : begin
		  	if (!cfg_interrupt_rdy_n_i) begin
				next_intr_state = `BMD_INTR_DUN;
			end else
				next_intr_state = `BMD_INTR_RD_ACT2;
        end
		  `BMD_INTR_WR_ACT2 : begin
		  	 if (!cfg_interrupt_rdy_n_i) 
			    next_intr_state = `BMD_INTR_DUN;
			 else
			    next_intr_state = `BMD_INTR_WR_ACT2;
        end

//		  `BMD_INTR_WR_ACT2 : begin
//			 intr_n = 1'b0;
//          intr_assert_n = 1'b1;
//		  	 if (!cfg_interrupt_rdy_n_i) 
//			    next_intr_state = `BMD_INTR_DUN;
//			 else
//			    next_intr_state = `BMD_INTR_WR_ACT2;
//        end

        `BMD_INTR_DUN : begin
          intr_n = 1'b1;
          intr_assert_n = 1'b1;
			 intr_done = 1'b1;
          next_intr_state = `BMD_INTR_RST;

        end
        
      endcase

    end



    always @(posedge clk ) begin
    
        if ( !rst_n ) begin
          intr_state <=#Tcq `BMD_INTR_RST;
        end else begin
			  if (init_rst_i) 
				  intr_state <= #Tcq`BMD_INTR_RST;
			   else
				 intr_state <= #Tcq next_intr_state;
//			  case (intr_state) /* synthesis full_case */ /* synthesis parallel_case */
//
//			  `BMD_INTR_RST : begin
//					intr_done <= 1'b0;
//					debug_o <= 1'b0;
//					intr_n <= 1'b1;
//					intr_assert_n <= 1'b1;
//					if (mwr_done_i)	
//						intr_state <= `BMD_INTR_WR_ACT;				
//	//				else if (mrd_done_i)
//	//					next_wr_intr_state = `BMD_INTR_RD_ACT;
//					else
//						intr_state <= `BMD_INTR_RST;			 
//			  end
//			  `BMD_INTR_RD_ACT : begin		//rd
//					intr_n <= 1'b0;
//					intr_assert_n <= 1'b0;
//					if (!cfg_interrupt_rdy_n_i) 
//						intr_state <= `BMD_INTR_RD_ACT0;
//					else
//						intr_state <= `BMD_INTR_RD_ACT;
//			  end		  
//			  `BMD_INTR_WR_ACT : begin
//					intr_n <= 1'b0;
//					intr_assert_n <= 1'b0;
//					if (!cfg_interrupt_rdy_n_i) 
//						intr_state <= `BMD_INTR_WR_ACT0;
//					else
//						intr_state <= `BMD_INTR_WR_ACT;
//			  end
//			  `BMD_INTR_RD_ACT0 : begin		//rd			 
//					intr_n <= 1'b1;
//					intr_assert_n <= 1'b1;
//					intr_state <= `BMD_INTR_RD_ACT1;
//				end		  
//			  `BMD_INTR_WR_ACT0 : begin			 
//					intr_n <= 1'b1;
//					intr_assert_n <= 1'b0;
//					intr_state <= `BMD_INTR_WR_ACT1;
//				end
//			  `BMD_INTR_RD_ACT1 : begin		//rd
//				 if (cfg_interrupt_legacyclr) begin
//					intr_n <= 1'b0;
//					intr_assert_n <= 1'b1;
//					if (!cfg_interrupt_rdy_n_i) begin
//						debug_o <= 1'b1;
//						intr_state <= `BMD_INTR_DUN;
//					end else
//						intr_state <= `BMD_INTR_RD_ACT2;
//				 end else begin
//					intr_n <= 1'b1;
//					intr_assert_n <= 1'b1;
//					intr_state <= `BMD_INTR_RD_ACT1;
//				 end
//			  end
//			  `BMD_INTR_WR_ACT1 : begin
//				 if (cfg_interrupt_legacyclr) begin
//					intr_n <= 1'b0;
//					intr_assert_n <= 1'b1;
//					if (!cfg_interrupt_rdy_n_i) 
//						intr_state <= `BMD_INTR_DUN;
//					else
//						intr_state <= `BMD_INTR_RD_ACT2;
//				 end else begin
//					intr_n <= 1'b1;
//					intr_assert_n <= 1'b0;
//					intr_state <= `BMD_INTR_WR_ACT1;
//				 end
//			  end		  
//			  `BMD_INTR_RD_ACT2 : begin
//				if (!cfg_interrupt_rdy_n_i) begin
//					debug_o <= 1'b1;
//					intr_state <= `BMD_INTR_DUN;
//				end else
//					intr_state <= `BMD_INTR_RD_ACT2;
//			  end
//			  `BMD_INTR_WR_ACT2 : begin
//				 if (!cfg_interrupt_rdy_n_i) 
//					 intr_state <= `BMD_INTR_DUN;
//				 else
//					 intr_state <= `BMD_INTR_WR_ACT2;
//			  end
//
//			  `BMD_INTR_DUN : begin
//				 debug_o <=1'b0;
//				 intr_n <= 1'b1;
//				 intr_assert_n <= 1'b1;
//				 intr_done <= 1'b1;
//				 intr_state <= `BMD_INTR_RST;
//			  end
//			endcase
		end
    end

endmodule

