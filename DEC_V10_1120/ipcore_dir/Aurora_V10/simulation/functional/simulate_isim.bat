REM
REM (c) Copyright 2010 - 2011 Xilinx, Inc. All rights reserved.
REM
REM This file contains confidential and proprietary information
REM of Xilinx, Inc. and is protected under U.S. and
REM international copyright and other intellectual property
REM laws.
REM
REM DISCLAIMER
REM This disclaimer is not a license and does not grant any
REM rights to the materials distributed herewith. Except as
REM otherwise provided in a valid license issued to you by
REM Xilinx, and to the maximum extent permitted by applicable
REM law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
REM WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
REM AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
REM BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
REM INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
REM (2) Xilinx shall not be liable (whether in contract or tort,
REM including negligence, or under any other theory of
REM liability) for any loss or damage of any kind or nature
REM related to, arising under or in connection with these
REM materials, including for any direct, or any indirect,
REM special, incidental, or consequential loss or damage
REM (including loss of data, profits, goodwill, or any type of
REM loss or damage suffered as a result of any action brought
REM by a third party) even if such damage or loss was
REM reasonably foreseeable or Xilinx had been advised of the
REM possibility of the same.
REM
REM CRITICAL APPLICATIONS
REM Xilinx products are not designed or intended to be fail-
REM safe, or for use in any application requiring fail-safe
REM performance, such as life-support or safety devices or
REM systems, Class III medical devices, nuclear facilities,
REM applications related to the deployment of airbags, or any
REM other applications that could lead to death, personal
REM injury, or severe property or environmental damage
REM (individually and collectively, "Critical
REM Applications"). Customer assumes the sole risk and
REM liability of any use of Xilinx products in Critical
REM Applications, subject only to applicable laws and
REM regulations governing limitations on product liability.
REM
REM THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
REM PART OF THIS FILE AT ALL TIMES.
REM 
REM 
REM SIMULATE_ISIM.BAT 
REM
REM
REM Description: A .bat file to run a simulation using the Aurora_V10_example_design module, 
REM              an example design which instantiates Aurora_V10.
REM

REM Create work directory 
mkdir work
REM Compile common sourcesthe glbl module, used to simulate global powerup features of the FPGA
vlogcomp -work work %XILINX%\verilog\src\glbl.v
REM Compile testbench source
vlogcomp -work work ..\..\simulation\demo_tb.v
REM Compile the HDL for the Device Under Test
REM AXI Shim modules
vlogcomp -work work ..\..\src\Aurora_V10_axi_to_ll.v
vlogcomp -work work ..\..\src\Aurora_V10_ll_to_axi.v
REM Aurora Lane Modules  
vlogcomp -work work ..\..\src\Aurora_V10_chbond_count_dec_4byte.v
vlogcomp -work work ..\..\src\Aurora_V10_err_detect_4byte.v
vlogcomp -work work ..\..\src\Aurora_V10_lane_init_sm_4byte.v
vlogcomp -work work ..\..\src\Aurora_V10_sym_dec_4byte.v
vlogcomp -work work ..\..\src\Aurora_V10_sym_gen_4byte.v
vlogcomp -work work ..\..\src\Aurora_V10_aurora_lane_4byte.v
REM Global Logic Modules
vlogcomp -work work ..\..\src\Aurora_V10_channel_err_detect.v
vlogcomp -work work ..\..\src\Aurora_V10_channel_init_sm.v
vlogcomp -work work ..\..\src\Aurora_V10_idle_and_ver_gen.v
vlogcomp -work work ..\..\src\Aurora_V10_global_logic.v 
REM TX Streaming User Interface modules
vlogcomp -work work ..\..\src\Aurora_V10_tx_stream.v
REM RX Streaming User Interface modules
vlogcomp -work work ..\..\src\Aurora_V10_rx_stream.v
REM Top Level Modules and wrappers
vlogcomp -work work ..\..\example_design\clock_module\Aurora_V10_clock_module.v
vlogcomp -work work ..\..\example_design\cc_manager\Aurora_V10_standard_cc_module.v
vlogcomp -work work ..\..\example_design\gt\Aurora_V10_transceiver_wrapper.v
vlogcomp -work work ..\..\example_design\gt\Aurora_V10_gtx.v
vlogcomp -work work ..\..\example_design\Aurora_V10.v
vlogcomp -work work ..\..\example_design\traffic_gen_check\Aurora_V10_frame_check.v
vlogcomp -work work ..\..\example_design\traffic_gen_check\Aurora_V10_frame_gen.v    
vlogcomp -work work ..\..\example_design\Aurora_V10_reset_logic.v
vlogcomp -work work ..\..\example_design\Aurora_V10_example_design.v
REM Begin the test
fuse work.EXAMPLE_TB work.glbl -L unisims_ver -L secureip -o example_tb.exe
REM To run in batch mode, invoke the following command without -gui option
example_tb.exe -gui -tclbatch wave_isim.tcl -wdb wave_isim  
