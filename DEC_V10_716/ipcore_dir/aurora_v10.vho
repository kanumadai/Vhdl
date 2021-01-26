
-- VHDL Instantiation Created from source file aurora_v10.vhd -- 16:51:12 09/17/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
	COMPONENT aurora_v10
	PORT(
		TX_D : IN std_logic_vector(0 to 31);
		TX_SRC_RDY_N : IN std_logic;
		DO_CC : IN std_logic;
		WARN_CC : IN std_logic;
		RXP : IN std_logic;
		RXN : IN std_logic;
		GTXD4 : IN std_logic;
		USER_CLK : IN std_logic;
		SYNC_CLK : IN std_logic;
		RESET : IN std_logic;
		POWER_DOWN : IN std_logic;
		LOOPBACK : IN std_logic_vector(2 downto 0);
		GT_RESET : IN std_logic;          
		TX_DST_RDY_N : OUT std_logic;
		RX_D : OUT std_logic_vector(0 to 31);
		RX_SRC_RDY_N : OUT std_logic;
		TXP : OUT std_logic;
		TXN : OUT std_logic;
		HARD_ERR : OUT std_logic;
		SOFT_ERR : OUT std_logic;
		CHANNEL_UP : OUT std_logic;
		LANE_UP : OUT std_logic;
		TX_OUT_CLK : OUT std_logic;
		TX_LOCK : OUT std_logic
		);
	END COMPONENT;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
	Inst_aurora_v10: aurora_v10 PORT MAP(
		TX_D => ,
		TX_SRC_RDY_N => ,
		TX_DST_RDY_N => ,
		RX_D => ,
		RX_SRC_RDY_N => ,
		DO_CC => ,
		WARN_CC => ,
		RXP => ,
		RXN => ,
		TXP => ,
		TXN => ,
		GTXD4 => ,
		HARD_ERR => ,
		SOFT_ERR => ,
		CHANNEL_UP => ,
		LANE_UP => ,
		USER_CLK => ,
		SYNC_CLK => ,
		RESET => ,
		POWER_DOWN => ,
		LOOPBACK => ,
		GT_RESET => ,
		TX_OUT_CLK => ,
		TX_LOCK => 
	);



-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file aurora_v10.vhd when simulating
-- the core, aurora_v10. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".
