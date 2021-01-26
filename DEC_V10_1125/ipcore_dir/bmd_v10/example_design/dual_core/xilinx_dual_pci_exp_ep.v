
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
// File       : xilinx_dual_pci_exp_ep.v
//
// Description:  PCI Express Dual Endpoint Core example design top level wrapper.
//
//------------------------------------------------------------------------------
module     xilinx_dual_pci_exp_ep (

                        // PCI Express Fabric Interface

                        pci_exp_txp_primary,
                        pci_exp_txn_primary,
                        pci_exp_rxp_primary,
                        pci_exp_rxn_primary,

                        pci_exp_txp_secondary,
                        pci_exp_txn_secondary,
                        pci_exp_rxp_secondary,
                        pci_exp_rxn_secondary,

                        // System (SYS) Interface

                        sys_clk_p,
                        sys_clk_n,
                        sys_reset_n
                        );//synthesis syn_noclockbuf=1

    //-------------------------------------------------------
    // 1. PCI Express Fabric Interface
    //-------------------------------------------------------

    // Tx
    output    [(1 - 1):0]           pci_exp_txp_primary;
    output    [(1 - 1):0]           pci_exp_txn_primary;

    // Rx
    input     [(1 - 1):0]           pci_exp_rxp_primary;
    input     [(1 - 1):0]           pci_exp_rxn_primary;


    // Tx
    output    [(1 - 1):0]           pci_exp_txp_secondary;
    output    [(1 - 1):0]           pci_exp_txn_secondary;

    // Rx
    input     [(1 - 1):0]           pci_exp_rxp_secondary;
    input     [(1 - 1):0]           pci_exp_rxn_secondary;


    //-------------------------------------------------------
    // 4. System (SYS) Interface
    //-------------------------------------------------------

    input                                             sys_clk_p;
    input                                             sys_clk_n;
    input                                             sys_reset_n;

    wire                                              sys_clk_c;
    wire                                              sys_reset_n_c;


xilinx_pci_exp_primary_ep primary_ep(


        // SYS Inteface
        .sys_clk(sys_clk_c),

        // PCI-Express Interface
        .pci_exp_txn(pci_exp_txn_primary),
        .pci_exp_txp(pci_exp_txp_primary),
        .pci_exp_rxn(pci_exp_rxn_primary),
        .pci_exp_rxp(pci_exp_rxp_primary),
        .sys_reset_n(sys_reset_n_c)
        );

xilinx_pci_exp_secondary_ep secondary_ep(


        // SYS Inteface
        .sys_clk(sys_clk_c),

        // PCI-Express Interface
        .pci_exp_txn(pci_exp_txn_secondary),
        .pci_exp_txp(pci_exp_txp_secondary),
        .pci_exp_rxn(pci_exp_rxn_secondary),
        .pci_exp_rxp(pci_exp_rxp_secondary),
        .sys_reset_n(sys_reset_n_c)
        );



//-------------------------------------------------------
// Virtex5-FX Global Clock Buffer
//-------------------------------------------------------
  IBUFDS refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));  // 100 MHz


  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------

  IBUF sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));


endmodule // XILINX_DUAL_PCI_EXP_EP
