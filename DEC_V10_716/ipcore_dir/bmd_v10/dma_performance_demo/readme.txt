*******************************************************************************
** © Copyright 2009 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        readme.txt Version: 1.0  
**  /   /        Date Last Modified: November 16, 2009 
** /___/   /\    Date Created: 	November 16, 2009
** \   \  /  \   Associated Filename: xapp1052.zip
**  \___\/\___\ 
** 
*******************************************************************************
**
**  Disclaimer: 
**
**		          This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


For instructions on installing and using the BMD reference demonstration design
refer to xapp1052.pdf

Known Issues

Item 1: On some Windows based systems 
it has been observed that if the driver is already
loaded when the system boots up, Windows may appear to hang.
The problem appears to be a conflict between the driver
and some USB drivers. The problem is that the USB drivers
stop working and if you have the mouse or keyboard 
plugged into these USB ports they become unresponsive.
This makes it appear the system is hung, but in reality
its just the USB port that is not working. Recommendation
is to try a different USB port. We found this would
solve the issue. This has been seen on an x58 and P55
machine.

Item 2: The x8 implementation for the Block Plus core
On ML555 has difficulty meeting timing. It may be
Necessary to use SmartXplorer to close timing. If using
The v1.12 or v1.11 core see Answer Record 33709 for 
new wrapper file that will help in timing closure.
http://www.xilinx.com/support/answers/33709.htm

Item 3: The Linux driver is only proven to work on
Fedora Core 10. It has not been tested on other 
Linux versions.

Web Support
http://www.xilinx.com/support

WebCase Support:
http://www.xilinx.com/support/clearexpress/websupport.htm

Technical Support Contact:
http://www.xilinx.com/support/services/contact_info.htm

