
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : V5-Block Plus for PCI Express
-- File       : xilinx_dual_pci_exp_ep.vhd
--
-- Description:  PCI Express Dual Endpoint Core example design top level wrapper.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity XILINX_DUAL_PCI_EXP_EP is
generic (FAST_SIMULATION: INTEGER := 0);
port  (

  sys_clk_p         : in std_logic;
  sys_clk_n         : in std_logic;
  sys_reset_n       : in std_logic;

  pci_exp_rxn_primary       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp_primary       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn_primary       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp_primary       : out std_logic_vector((1 - 1) downto 0);

  pci_exp_rxn_secondary       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp_secondary      : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn_secondary       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp_secondary       : out std_logic_vector((1 - 1) downto 0)

);

end XILINX_DUAL_PCI_EXP_EP;

architecture rtl of   XILINX_DUAL_PCI_EXP_EP is


component XILINX_PCI_EXP_PRIMARY_EP
generic (FAST_SIMULATION: INTEGER := 0);
port  (

  sys_clk             : in std_logic;

  sys_reset_n       : in std_logic;

  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)

);
end component;


component XILINX_PCI_EXP_SECONDARY_EP
generic (FAST_SIMULATION: INTEGER := 0);
port  (

  sys_clk             : in std_logic;

  sys_reset_n       : in std_logic;

  pci_exp_rxn       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_rxp       : in std_logic_vector((1 - 1) downto 0);
  pci_exp_txn       : out std_logic_vector((1 - 1) downto 0);
  pci_exp_txp       : out std_logic_vector((1 - 1) downto 0)

);
end component;

signal     sys_clk_c : std_logic;
signal     sys_reset_n_c : std_logic;

signal     unsigned_fast_simulation: unsigned(0 downto 0);
signal     vector_fast_simulation: std_logic_vector(0 downto 0);


begin


-- convert generic FAST_SIMULATION and pass to express core
  unsigned_fast_simulation <= to_unsigned(FAST_SIMULATION,1);
  vector_fast_simulation <= std_logic_vector(unsigned_fast_simulation);

-------------------------------------------------------
-- Virtex5-FX Global Clock Buffer
-------------------------------------------------------
refclk_ibuf : IBUFDS port map (

  O => sys_clk_c,
  I => sys_clk_p,
  IB => sys_clk_n

);



sys_reset_n_ibuf : IBUF port map (

  O => sys_reset_n_c,
  I => sys_reset_n

);

  ---------------------------------------------------------
  -- Primary Ep
  ---------------------------------------------------------
primary_ep : XILINX_PCI_EXP_PRIMARY_EP generic map (

  FAST_SIMULATION => 1

)
port  map (

  sys_clk => sys_clk_c,
  sys_reset_n => sys_reset_n_c,

  pci_exp_rxn => pci_exp_rxn_primary,
  pci_exp_rxp => pci_exp_rxp_primary,
  pci_exp_txn => pci_exp_txn_primary,
  pci_exp_txp => pci_exp_txp_primary

);



  ---------------------------------------------------------
  -- Secondary Ep
  ---------------------------------------------------------
secondary_ep : XILINX_PCI_EXP_SECONDARY_EP generic map (

  FAST_SIMULATION => 1

)
port  map (

  sys_clk => sys_clk_c,
  sys_reset_n => sys_reset_n_c,

  pci_exp_rxn => pci_exp_rxn_secondary,
  pci_exp_rxp => pci_exp_rxp_secondary,
  pci_exp_txn => pci_exp_txn_secondary,
  pci_exp_txp => pci_exp_txp_secondary

);



end; -- XILINX_DUAL_PCI_EXP_EP
