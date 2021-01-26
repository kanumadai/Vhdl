


//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
// Instantiate the module
aurora_v10 instance_name (
    .TX_D(TX_D), 
    .TX_SRC_RDY_N(TX_SRC_RDY_N), 
    .TX_DST_RDY_N(TX_DST_RDY_N), 
    .RX_D(RX_D), 
    .RX_SRC_RDY_N(RX_SRC_RDY_N), 
    .DO_CC(DO_CC), 
    .WARN_CC(WARN_CC), 
    .RXP(RXP), 
    .RXN(RXN), 
    .TXP(TXP), 
    .TXN(TXN), 
    .GTXD4(GTXD4), 
    .HARD_ERR(HARD_ERR), 
    .SOFT_ERR(SOFT_ERR), 
    .CHANNEL_UP(CHANNEL_UP), 
    .LANE_UP(LANE_UP), 
    .USER_CLK(USER_CLK), 
    .SYNC_CLK(SYNC_CLK), 
    .RESET(RESET), 
    .POWER_DOWN(POWER_DOWN), 
    .LOOPBACK(LOOPBACK), 
    .GT_RESET(GT_RESET), 
    .TX_OUT_CLK(TX_OUT_CLK), 
    .TX_LOCK(TX_LOCK)
    );


// INST_TAG_END ------ End INSTANTIATION Template ---------