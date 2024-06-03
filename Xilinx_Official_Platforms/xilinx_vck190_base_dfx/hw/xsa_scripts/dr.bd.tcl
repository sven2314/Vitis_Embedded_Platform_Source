#******************************************************************************
# Copyright (C) 2020-2022 Xilinx, Inc. All rights reserved.
# Copyright (C) 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#******************************************************************************

proc create_hier_cell_VitisRegion { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_VitisRegion() - Empty argument(s)!"}
    return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
    return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
    return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 AIE_CTRL_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 DDR_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 DDR_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 DDR_2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 DDR_3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 LPDDR_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 LPDDR_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 LPDDR_2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 LPDDR_3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 PL_CTRL_S_AXI


  # Create pins
  create_bd_pin -dir I -type clk ExtClk
  create_bd_pin -dir I -type rst ExtReset
  create_bd_pin -dir O -type intr Interrupt
  create_bd_pin -dir O -type intr Interrupt1

  # Create instance: ConfigNoc, and set properties
  set ConfigNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc ConfigNoc ]
  set_property -dict [ list \
    CONFIG.MC_IP_TIMEPERIOD0_FOR_OP {1250} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
    ] $ConfigNoc

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CATEGORY {aie} \
    ] [get_bd_intf_pins /VitisRegion/ConfigNoc/M00_AXI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /VitisRegion/ConfigNoc/S00_INI]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
    ] [get_bd_pins /VitisRegion/ConfigNoc/aclk0]

  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_0 ]
  set_property -dict [ list \
     CONFIG.CLKOUT2_DIVIDE {20.000000} \
     CONFIG.CLKOUT3_DIVIDE {10.000000} \
     CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
     CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
     CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
     CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
     CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
     CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {104.167,156.25,312.5,78.125,208.33,416.67,625} \
     CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
     CONFIG.CLKOUT_USED {true,true,true,true,true,true,true} \
     CONFIG.JITTER_SEL {Min_O_Jitter} \
     CONFIG.RESET_TYPE {ACTIVE_LOW} \
     CONFIG.USE_LOCKED {true} \
     CONFIG.USE_PHASE_ALIGNMENT {true} \
     CONFIG.USE_RESET {true} \
     ] $clk_wizard_0

  # Create instance: psr_100mh, and set properties
  set psr_104mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_104mhz ]

  # Create instance: psr_150mh, and set properties
  set psr_156mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_156mhz ]

  # Create instance: psr_312.5mh, and set properties
  set psr_312mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_312mhz ]

  # Create instance: psr_75mh, and set properties
  set psr_78mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_78mhz ]

  # Create instance: psr_200mh, and set properties
  set psr_208mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_208mhz ]

  # Create instance: psr_400mh, and set properties
  set psr_416mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_416mhz ]

  # Create instance: psr_600mh, and set properties
  set psr_625mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset psr_625mhz ]

  # Create instance: smartconnect_1, and set properties
  set icn_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_1 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_1

  set icn_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_2 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_2

  set to_delete_kernel_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip to_delete_kernel_ctrl_0 ]
  set_property -dict [ list \
      CONFIG.INTERFACE_MODE {SLAVE} \
      CONFIG.PROTOCOL {AXI4LITE} \
      ] $to_delete_kernel_ctrl_0

  set to_delete_kernel_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip to_delete_kernel_ctrl_1 ]
  set_property -dict [ list \
      CONFIG.INTERFACE_MODE {SLAVE} \
      CONFIG.PROTOCOL {AXI4LITE} \
      ] $to_delete_kernel_ctrl_1

  set to_delete_kernel_ctrl_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip to_delete_kernel_ctrl_2 ]
  set_property -dict [ list \
      CONFIG.INTERFACE_MODE {SLAVE} \
      CONFIG.PROTOCOL {AXI4LITE} \
      ] $to_delete_kernel_ctrl_2

  set to_delete_kernel_ctrl_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip to_delete_kernel_ctrl_3 ]
  set_property -dict [ list \
      CONFIG.INTERFACE_MODE {SLAVE} \
      CONFIG.PROTOCOL {AXI4LITE} \
      ] $to_delete_kernel_ctrl_3

  set icn_ctrl_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_3 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_3

  set icn_ctrl_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_4 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_4

  set icn_ctrl_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_5 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_5

  # Create instance: IsoRegDynamic, and set properties
  set IsoRegDynamic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice IsoRegDynamic ]
  set_property -dict [ list \
    CONFIG.ADDR_WIDTH {44} \
    CONFIG.ARUSER_WIDTH {16} \
    CONFIG.AWUSER_WIDTH {16} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {0} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {16} \
    CONFIG.MAX_BURST_LENGTH {256} \
    CONFIG.NUM_READ_OUTSTANDING {1} \
    CONFIG.NUM_READ_THREADS {1} \
    CONFIG.NUM_WRITE_OUTSTANDING {1} \
    CONFIG.NUM_WRITE_THREADS {1} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.REG_AR {0} \
    CONFIG.REG_AW {0} \
    CONFIG.REG_B {0} \
    CONFIG.REG_R {0} \
    CONFIG.REG_W {0} \
    CONFIG.RUSER_BITS_PER_BYTE {0} \
    CONFIG.RUSER_WIDTH {4} \
    CONFIG.SUPPORTS_NARROW_BURST {1} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
    CONFIG.WUSER_WIDTH {4} \
    ] $IsoRegDynamic

  # Create instance: DDRNoc, and set properties
  set DDRNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc DDRNoc ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_SI {4} \
    ] $DDRNoc

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/DDRNoc/M00_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/DDRNoc/M01_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/DDRNoc/M02_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/DDRNoc/M03_INI]

  set_property -dict [list CONFIG.CONNECTIONS {M00_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/DDRNoc/S00_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M01_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/DDRNoc/S01_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M02_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/DDRNoc/S02_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M03_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/DDRNoc/S03_AXI]
  set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S03_AXI:S02_AXI:S00_AXI:S01_AXI}] [get_bd_pins /VitisRegion/DDRNoc/aclk0]


  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1
  set_property -dict [list CONFIG.NUM_PORTS {32} CONFIG.IN0_WIDTH {1}] [get_bd_cells xlconcat_1]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2
  set_property -dict [list CONFIG.NUM_PORTS {31} CONFIG.IN0_WIDTH {1}] [get_bd_cells xlconcat_2]
  # Create instance: LPDDRNoc, and set properties
  set LPDDRNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc LPDDRNoc ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_SI {4} \
    ] $LPDDRNoc

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/LPDDRNoc/M00_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/LPDDRNoc/M01_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/LPDDRNoc/M02_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /VitisRegion/LPDDRNoc/M03_INI]

  set_property -dict [list CONFIG.CONNECTIONS {M00_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/LPDDRNoc/S00_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M01_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/LPDDRNoc/S01_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M02_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/LPDDRNoc/S02_AXI]
  set_property -dict [list CONFIG.CONNECTIONS {M03_INI { read_bw {128} write_bw {128}} }] [get_bd_intf_pins /VitisRegion/LPDDRNoc/S03_AXI]
  set_property -dict [list CONFIG.ASSOCIATED_BUSIF {S03_AXI:S02_AXI:S00_AXI:S01_AXI}] [get_bd_pins /VitisRegion/LPDDRNoc/aclk0]

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine ai_engine_0 ]
  set_property -dict [ list \
    CONFIG.CLK_NAMES {} \
    CONFIG.FIFO_TYPE_MI_AXIS {} \
    CONFIG.FIFO_TYPE_SI_AXIS {} \
    CONFIG.NAME_MI_AXIS {} \
    CONFIG.NAME_SI_AXIS {} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.AIE_CORE_REF_CTRL_FREQMHZ {1250} \
    CONFIG.NUM_MI_AXI {0} \
    CONFIG.NUM_MI_AXIS {0} \
    CONFIG.NUM_SI_AXIS {0} \
    ] $ai_engine_0

  set_property -dict [ list \
    CONFIG.CATEGORY {NOC} \
    ] [get_bd_intf_pins /VitisRegion/ai_engine_0/S00_AXI]


  # Create interface connections
  connect_bd_intf_net -intf_net AIE_CTRL_INI_1 [get_bd_intf_pins AIE_CTRL_INI] [get_bd_intf_pins ConfigNoc/S00_INI]
  connect_bd_intf_net -intf_net ConfigNoc_M00_AXI [get_bd_intf_pins ConfigNoc/M00_AXI] [get_bd_intf_pins ai_engine_0/S00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins LPDDR_3] [get_bd_intf_pins LPDDRNoc/M03_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins DDR_3] [get_bd_intf_pins DDRNoc/M03_INI]
  connect_bd_intf_net -intf_net DDRNoc_M00_INI [get_bd_intf_pins DDR_0] [get_bd_intf_pins DDRNoc/M00_INI]
  connect_bd_intf_net -intf_net DDRNoc_M01_INI [get_bd_intf_pins DDR_1] [get_bd_intf_pins DDRNoc/M01_INI]
  connect_bd_intf_net -intf_net DDRNoc_M02_INI [get_bd_intf_pins DDR_2] [get_bd_intf_pins DDRNoc/M02_INI]
  connect_bd_intf_net -intf_net LPDDRNoc_M00_INI [get_bd_intf_pins LPDDR_0] [get_bd_intf_pins LPDDRNoc/M00_INI]
  connect_bd_intf_net -intf_net LPDDRNoc_M01_INI [get_bd_intf_pins LPDDR_1] [get_bd_intf_pins LPDDRNoc/M01_INI]
  connect_bd_intf_net -intf_net LPDDRNoc_M02_INI [get_bd_intf_pins LPDDR_2] [get_bd_intf_pins LPDDRNoc/M02_INI]
  connect_bd_intf_net -intf_net PL_CTRL_S_AXI_1         [get_bd_intf_pins PL_CTRL_S_AXI]                 [get_bd_intf_pins IsoRegDynamic/S_AXI]
  connect_bd_intf_net -intf_net IsoRegDynam_M_AXI       [get_bd_intf_pins IsoRegDynamic/M_AXI]           [get_bd_intf_pins icn_ctrl_1/S00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_1_M00_AXI      [get_bd_intf_pins icn_ctrl_2/S00_AXI]            [get_bd_intf_pins icn_ctrl_1/M00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_1_M01_AXI      [get_bd_intf_pins icn_ctrl_3/S00_AXI]            [get_bd_intf_pins icn_ctrl_1/M01_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_1_M02_AXI      [get_bd_intf_pins icn_ctrl_4/S00_AXI]            [get_bd_intf_pins icn_ctrl_1/M02_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_1_M03_AXI      [get_bd_intf_pins icn_ctrl_5/S00_AXI]            [get_bd_intf_pins icn_ctrl_1/M03_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_2_M00_AXI      [get_bd_intf_pins to_delete_kernel_ctrl_0/S_AXI] [get_bd_intf_pins icn_ctrl_2/M00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_3_M00_AXI      [get_bd_intf_pins to_delete_kernel_ctrl_1/S_AXI] [get_bd_intf_pins icn_ctrl_3/M00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_4_M00_AXI      [get_bd_intf_pins to_delete_kernel_ctrl_2/S_AXI] [get_bd_intf_pins icn_ctrl_4/M00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_5_M00_AXI      [get_bd_intf_pins to_delete_kernel_ctrl_3/S_AXI] [get_bd_intf_pins icn_ctrl_5/M00_AXI]
  connect_bd_net                                        [get_bd_pins Interrupt]                          [get_bd_pins xlconcat_1/dout]
  connect_bd_net                                        [get_bd_pins Interrupt1]                         [get_bd_pins xlconcat_2/dout]

  # Create port connections
  connect_bd_net -net PlClocks_clk_out1 [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins psr_104mhz/slowest_sync_clk] [get_bd_pins icn_ctrl_1/aclk] [get_bd_pins icn_ctrl_2/aclk] [get_bd_pins icn_ctrl_3/aclk] [get_bd_pins to_delete_kernel_ctrl_0/aclk ] [get_bd_pins to_delete_kernel_ctrl_1/aclk ] [get_bd_pins icn_ctrl_4/aclk] [get_bd_pins icn_ctrl_5/aclk] [get_bd_pins to_delete_kernel_ctrl_2/aclk ] [get_bd_pins to_delete_kernel_ctrl_3/aclk ]
  connect_bd_net -net clk_wizard_0_clk_out2 [get_bd_pins clk_wizard_0/clk_out2] [get_bd_pins psr_156mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out3 [get_bd_pins clk_wizard_0/clk_out3] [get_bd_pins psr_312mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out4 [get_bd_pins clk_wizard_0/clk_out4] [get_bd_pins psr_78mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out5 [get_bd_pins clk_wizard_0/clk_out5] [get_bd_pins psr_208mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out6 [get_bd_pins clk_wizard_0/clk_out6] [get_bd_pins psr_416mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out7 [get_bd_pins clk_wizard_0/clk_out7] [get_bd_pins psr_625mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_locked [get_bd_pins clk_wizard_0/locked] [get_bd_pins psr_104mhz/dcm_locked] [get_bd_pins psr_156mhz/dcm_locked] [get_bd_pins psr_208mhz/dcm_locked] [get_bd_pins psr_416mhz/dcm_locked] [get_bd_pins psr_625mhz/dcm_locked] [get_bd_pins psr_78mhz/dcm_locked] [get_bd_pins psr_312mhz/dcm_locked]
  connect_bd_net -net ai_engine_0_s00_axi_aclk [get_bd_pins ConfigNoc/aclk0] [get_bd_pins ai_engine_0/s00_axi_aclk]
  connect_bd_net -net icn_ctrl_1_aclk1 [get_bd_pins ExtClk] [get_bd_pins icn_ctrl_1/aclk1] [get_bd_pins IsoRegDynamic/aclk] [get_bd_pins clk_wizard_0/clk_in1] [get_bd_pins LPDDRNoc/aclk0] [get_bd_pins DDRNoc/aclk0]
  connect_bd_net -net ext_aresetn_1 [get_bd_pins ExtReset] [get_bd_pins IsoRegDynamic/aresetn] [get_bd_pins clk_wizard_0/resetn] [get_bd_pins psr_104mhz/ext_reset_in] [get_bd_pins psr_156mhz/ext_reset_in] [get_bd_pins psr_312mhz/ext_reset_in] [get_bd_pins psr_78mhz/ext_reset_in] [get_bd_pins psr_208mhz/ext_reset_in] [get_bd_pins psr_416mhz/ext_reset_in] [get_bd_pins psr_625mhz/ext_reset_in]
  connect_bd_net -net psr_104mhz_peripheral_aresetn [get_bd_pins psr_104mhz/peripheral_aresetn] [get_bd_pins icn_ctrl_1/aresetn] [get_bd_pins icn_ctrl_2/aresetn] [get_bd_pins icn_ctrl_3/aresetn] [get_bd_pins to_delete_kernel_ctrl_0/aresetn] [get_bd_pins to_delete_kernel_ctrl_1/aresetn] [get_bd_pins icn_ctrl_4/aresetn] [get_bd_pins icn_ctrl_5/aresetn] [get_bd_pins to_delete_kernel_ctrl_3/aresetn] [get_bd_pins to_delete_kernel_ctrl_3/aresetn]

  set_property -dict [list APERTURES {{0xA700_0000 144M}}] [get_bd_intf_pins PL_CTRL_S_AXI]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
    set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
    return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
    return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set CH0_DDR4_0_0  [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_dimm1 ]

  set sys_clk0_0    [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr4_dimm1_sma_clk ]

  set ch0_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c0 ]

  set ch0_lpddr4_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c1 ]

  set ch1_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c0 ]

  set ch1_lpddr4_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c1 ]

  set lpddr4_sma_clk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk1 ]
  set_property -dict [ list \
    CONFIG.FREQ_HZ {200000000} \
    ] $lpddr4_sma_clk1

  set lpddr4_sma_clk2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk2 ]
  set_property -dict [ list \
    CONFIG.FREQ_HZ {200000000} \
    ] $lpddr4_sma_clk2

  set_property CONFIG.FREQ_HZ 200000000 [get_bd_intf_ports /ddr4_dimm1_sma_clk]

  # Create instance: IsoReset, and set properties
  set IsoReset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset IsoReset ]

  # Create instance: VitisRegion
  create_hier_cell_VitisRegion [current_bd_instance .] VitisRegion

  # Create instance: noc_ddr, and set properties
  set noc_ddr [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 noc_ddr ]
  set_property -dict [ list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.CH0_DDR4_0_BOARD_INTERFACE {ddr4_dimm1} \
    CONFIG.sys_clk0_BOARD_INTERFACE {ddr4_dimm1_sma_clk} \
    CONFIG.MC_BA_WIDTH {2} \
    CONFIG.MC_BG_WIDTH {2} \
    CONFIG.MC_CHAN_REGION0 {DDR_LOW0} \
    CONFIG.MC_CHAN_REGION1 {DDR_LOW1} \
    CONFIG.MC_COMPONENT_WIDTH {x8} \
    CONFIG.MC_CONFIG_NUM {config17} \
    CONFIG.MC_DATAWIDTH {64} \
    CONFIG.MC_DDR4_2T {Disable} \
    CONFIG.MC_F1_LPDDR4_MR1 {0x0000} \
    CONFIG.MC_F1_LPDDR4_MR2 {0x0000} \
    CONFIG.MC_F1_TRCD {13750} \
    CONFIG.MC_F1_TRCDMIN {13750} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_INPUT_FREQUENCY0 {200.000} \
    CONFIG.MC_INTERLEAVE_SIZE {128} \
    CONFIG.MC_MEMORY_DEVICETYPE {UDIMMs} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_MEMORY_TIMEPERIOD0 {625} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_PRE_DEF_ADDR_MAP_SEL {ROW_COLUMN_BANK} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {16} \
    CONFIG.MC_TRC {45750} \
    CONFIG.MC_TRCD {13750} \
    CONFIG.MC_TRCDMIN {13750} \
    CONFIG.MC_TRCMIN {45750} \
    CONFIG.MC_TRP {13750} \
    CONFIG.MC_TRPMIN {13750} \
    CONFIG.NUM_SI {0} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {8} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.LOGO_FILE {data/noc_mc.png}
  ] $noc_ddr

  set_property -dict [ list \
    CONFIG.CONNECTIONS {MC_0 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S00_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_1 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S01_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_2 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S02_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_3 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S03_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_0 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S04_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_1 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S05_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_2 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S06_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_3 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_ddr/S07_INI]

  # Create instance: noc_lpddr, and set properties
  set noc_lpddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 noc_lpddr ]
  set_property -dict [ list \
    CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_c0} \
    CONFIG.CH0_LPDDR4_1_BOARD_INTERFACE {ch0_lpddr4_c1} \
    CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_c0} \
    CONFIG.CH1_LPDDR4_1_BOARD_INTERFACE {ch1_lpddr4_c1} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH1} \
    CONFIG.MC_CHAN_REGION1 {NONE} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NSI {8} \
    CONFIG.NUM_SI {0} \
    CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_sma_clk1} \
    CONFIG.sys_clk1_BOARD_INTERFACE {lpddr4_sma_clk2} \
    ] $noc_lpddr

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S00_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_1 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S01_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_2 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S02_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    CONFIG.CONNECTIONS {MC_3 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S03_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_0 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S04_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_1 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S05_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_2 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S06_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    CONFIG.CONNECTIONS {MC_3 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
    ] [get_bd_intf_pins /noc_lpddr/S07_INI]


  # Create instance: CIPS_0, and set properties
  set CIPS_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips CIPS_0 ]
  set_property -dict [ list \
    CONFIG.DESIGN_MODE {1} \
    CONFIG.BOOT_MODE {Custom} \
    CONFIG.CLOCK_MODE {Custom} \
    CONFIG.DDR_MEMORY_MODE {Custom} \
    CONFIG.DEBUG_MODE {Custom} \
    CONFIG.DEVICE_INTEGRITY_MODE {Custom} \
    CONFIG.IO_CONFIG_MODE {Custom} \
    CONFIG.PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
    CONFIG.PS_PL_CONNECTIVITY_MODE {Custom} \
    CONFIG.PS_PMC_CONFIG {SMON_ALARMS Set_Alarms_On SMON_ENABLE_TEMP_AVERAGING 0 SMON_TEMP_AVERAGING_SAMPLES 8 PS_MIO7 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO9 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO19 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO21 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL disable} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO37 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA high} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} PMC_MIO11 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO26 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO27 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO28 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO29 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PL_SEM_GPIO_ENABLE 0 PMC_ALT_REF_CLK_FREQMHZ 33.333 PMC_BANK_0_IO_STANDARD LVCMOS1.8 PMC_BANK_1_IO_STANDARD LVCMOS1.8 PMC_CIPS_MODE ADVANCE PMC_CORE_SUBSYSTEM_LOAD 0.0 PMC_CRP_CFU_REF_CTRL_ACT_FREQMHZ 394.444427 PMC_CRP_CFU_REF_CTRL_DIVISOR0 3 PMC_CRP_CFU_REF_CTRL_FREQMHZ 400 PMC_CRP_CFU_REF_CTRL_SRCSEL PPLL PMC_CRP_DFT_OSC_REF_CTRL_ACT_FREQMHZ 400 PMC_CRP_DFT_OSC_REF_CTRL_DIVISOR0 3 PMC_CRP_DFT_OSC_REF_CTRL_FREQMHZ 400 PMC_CRP_DFT_OSC_REF_CTRL_SRCSEL PPLL PMC_CRP_EFUSE_REF_CTRL_ACT_FREQMHZ 100.000000 PMC_CRP_EFUSE_REF_CTRL_FREQMHZ 100.000000 PMC_CRP_EFUSE_REF_CTRL_SRCSEL IRO_CLK/4 PMC_CRP_HSM0_REF_CTRL_ACT_FREQMHZ 32.870369 PMC_CRP_HSM0_REF_CTRL_DIVISOR0 36 PMC_CRP_HSM0_REF_CTRL_FREQMHZ 33.334 PMC_CRP_HSM0_REF_CTRL_SRCSEL PPLL PMC_CRP_HSM1_REF_CTRL_ACT_FREQMHZ 131.481476 PMC_CRP_HSM1_REF_CTRL_DIVISOR0 9 PMC_CRP_HSM1_REF_CTRL_FREQMHZ 133.334 PMC_CRP_HSM1_REF_CTRL_SRCSEL PPLL PMC_CRP_I2C_REF_CTRL_ACT_FREQMHZ 99.999992 PMC_CRP_I2C_REF_CTRL_DIVISOR0 10 PMC_CRP_I2C_REF_CTRL_FREQMHZ 100 PMC_CRP_I2C_REF_CTRL_SRCSEL NPLL PMC_CRP_LSBUS_REF_CTRL_ACT_FREQMHZ 147.916656 PMC_CRP_LSBUS_REF_CTRL_DIVISOR0 8 PMC_CRP_LSBUS_REF_CTRL_FREQMHZ 150 PMC_CRP_LSBUS_REF_CTRL_SRCSEL PPLL PMC_CRP_NOC_REF_CTRL_ACT_FREQMHZ 999.999939 PMC_CRP_NOC_REF_CTRL_FREQMHZ 1000 PMC_CRP_NOC_REF_CTRL_SRCSEL NPLL PMC_CRP_NPI_REF_CTRL_ACT_FREQMHZ 295.833313 PMC_CRP_NPI_REF_CTRL_DIVISOR0 4 PMC_CRP_NPI_REF_CTRL_FREQMHZ 300 PMC_CRP_NPI_REF_CTRL_SRCSEL PPLL PMC_CRP_NPLL_CTRL_CLKOUTDIV 4 PMC_CRP_NPLL_CTRL_FBDIV 120 PMC_CRP_NPLL_CTRL_SRCSEL REF_CLK PMC_CRP_NPLL_TO_XPD_CTRL_DIVISOR0 1 PMC_CRP_OSPI_REF_CTRL_ACT_FREQMHZ 200 PMC_CRP_OSPI_REF_CTRL_DIVISOR0 4 PMC_CRP_OSPI_REF_CTRL_FREQMHZ 200 PMC_CRP_OSPI_REF_CTRL_SRCSEL PPLL PMC_CRP_PL0_REF_CTRL_ACT_FREQMHZ 99.999992 PMC_CRP_PL0_REF_CTRL_DIVISOR0 10 PMC_CRP_PL0_REF_CTRL_FREQMHZ 100 PMC_CRP_PL0_REF_CTRL_SRCSEL NPLL PMC_CRP_PL1_REF_CTRL_ACT_FREQMHZ 100 PMC_CRP_PL1_REF_CTRL_DIVISOR0 3 PMC_CRP_PL1_REF_CTRL_FREQMHZ 334 PMC_CRP_PL1_REF_CTRL_SRCSEL NPLL PMC_CRP_PL2_REF_CTRL_ACT_FREQMHZ 100 PMC_CRP_PL2_REF_CTRL_DIVISOR0 3 PMC_CRP_PL2_REF_CTRL_FREQMHZ 334 PMC_CRP_PL2_REF_CTRL_SRCSEL NPLL PMC_CRP_PL3_REF_CTRL_ACT_FREQMHZ 100 PMC_CRP_PL3_REF_CTRL_DIVISOR0 3 PMC_CRP_PL3_REF_CTRL_FREQMHZ 334 PMC_CRP_PL3_REF_CTRL_SRCSEL NPLL PMC_CRP_PL5_REF_CTRL_FREQMHZ 400 PMC_CRP_PPLL_CTRL_CLKOUTDIV 2 PMC_CRP_PPLL_CTRL_FBDIV 71 PMC_CRP_PPLL_CTRL_SRCSEL REF_CLK PMC_CRP_PPLL_TO_XPD_CTRL_DIVISOR0 1 PMC_CRP_QSPI_REF_CTRL_ACT_FREQMHZ 295.833313 PMC_CRP_QSPI_REF_CTRL_DIVISOR0 4 PMC_CRP_QSPI_REF_CTRL_FREQMHZ 300 PMC_CRP_QSPI_REF_CTRL_SRCSEL PPLL PMC_CRP_SDIO0_REF_CTRL_ACT_FREQMHZ 200 PMC_CRP_SDIO0_REF_CTRL_DIVISOR0 6 PMC_CRP_SDIO0_REF_CTRL_FREQMHZ 200 PMC_CRP_SDIO0_REF_CTRL_SRCSEL PPLL PMC_CRP_SDIO1_REF_CTRL_ACT_FREQMHZ 199.999985 PMC_CRP_SDIO1_REF_CTRL_DIVISOR0 5 PMC_CRP_SDIO1_REF_CTRL_FREQMHZ 200 PMC_CRP_SDIO1_REF_CTRL_SRCSEL NPLL PMC_CRP_SD_DLL_REF_CTRL_ACT_FREQMHZ 1183.333252 PMC_CRP_SD_DLL_REF_CTRL_DIVISOR0 1 PMC_CRP_SD_DLL_REF_CTRL_FREQMHZ 1200 PMC_CRP_SD_DLL_REF_CTRL_SRCSEL PPLL PMC_CRP_SWITCH_TIMEOUT_CTRL_ACT_FREQMHZ 1.000000 PMC_CRP_SWITCH_TIMEOUT_CTRL_DIVISOR0 100 PMC_CRP_SWITCH_TIMEOUT_CTRL_FREQMHZ 1 PMC_CRP_SWITCH_TIMEOUT_CTRL_SRCSEL IRO_CLK/4 PMC_CRP_SYSMON_REF_CTRL_ACT_FREQMHZ 295.833313 PMC_CRP_SYSMON_REF_CTRL_FREQMHZ 295.833313 PMC_CRP_SYSMON_REF_CTRL_SRCSEL NPI_REF_CLK PMC_CRP_TEST_PATTERN_REF_CTRL_ACT_FREQMHZ 200 PMC_CRP_TEST_PATTERN_REF_CTRL_DIVISOR0 6 PMC_CRP_TEST_PATTERN_REF_CTRL_FREQMHZ 200 PMC_CRP_TEST_PATTERN_REF_CTRL_SRCSEL PPLL PMC_CRP_USB_SUSPEND_CTRL_ACT_FREQMHZ 0.200000 PMC_CRP_USB_SUSPEND_CTRL_DIVISOR0 500 PMC_CRP_USB_SUSPEND_CTRL_FREQMHZ 0.2 PMC_CRP_USB_SUSPEND_CTRL_SRCSEL IRO_CLK/4 PMC_EXTERNAL_TAMPER {{ENABLE 0} {IO None}} PMC_GPIO0_MIO_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 25}}} PMC_GPIO1_MIO_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26 .. 51}}} PMC_GPIO_EMIO_PERIPHERAL_ENABLE 0 PMC_GPIO_EMIO_WIDTH_HDL 64 PMC_HSM0_CLK_ENABLE 1 PMC_HSM1_CLK_ENABLE 1 PMC_I2CPMC_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 46 .. 47}}} PMC_MIO_EN_FOR_PL_PCIE 0 PMC_NOC_PMC_ADDR_WIDTH 64 PMC_NOC_PMC_DATA_WIDTH 128 PMC_OSPI_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 0 .. 11}} {MODE Single}} PMC_PL_ALT_REF_CLK_FREQMHZ 33.333 PMC_PMC_NOC_ADDR_WIDTH 64 PMC_PMC_NOC_DATA_WIDTH 128 PMC_QSPI_COHERENCY 0 PMC_QSPI_FBCLK {{ENABLE 1} {IO {PMC_MIO 6}}} PMC_QSPI_PERIPHERAL_DATA_MODE x4 PMC_QSPI_PERIPHERAL_ENABLE 1 PMC_QSPI_PERIPHERAL_MODE {Dual Parallel} PMC_QSPI_ROUTE_THROUGH_FPD 0 PMC_REF_CLK_FREQMHZ 33.333333 PMC_SD0 {{CD_ENABLE 0} {CD_IO PMC_MIO 24} {POW_ENABLE 0} {POW_IO PMC_MIO 17} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 17}} {WP_ENABLE 0} {WP_IO PMC_MIO 25}} PMC_SD0_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 13 .. 25}} PMC_SD1 {{CD_ENABLE 1} {CD_IO {PMC_MIO 28}} {POW_ENABLE 1} {POW_IO {PMC_MIO 51}} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 1}} {WP_ENABLE 0} {WP_IO PMC_MIO 1}} PMC_SD1_COHERENCY 0 PMC_SD1_DATA_TRANSFER_MODE 8Bit PMC_SD1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26 .. 36}}} PMC_SD1_ROUTE_THROUGH_FPD 0 PMC_SD1_SLOT_TYPE {SD 3.0} PMC_SD1_SPEED_MODE {high speed} PMC_SHOW_CCI_SMMU_SETTINGS 0 PMC_SMAP_PERIPHERAL {{ENABLE 0} {IO 32 Bit}} PMC_TAMPER_EXTMIO_ENABLE 0 PMC_TAMPER_GLITCHDETECT_ENABLE 0 PMC_TAMPER_JTAGDETECT_ENABLE 0 PMC_TAMPER_TEMPERATURE_ENABLE 0 PMC_TAMPER_TRIGGER_REGISTER 0 PMC_TAMPER_VCCINTAUX_ENABLE 0 PMC_TAMPER_VCCINTFPD_ENABLE 0 PMC_TAMPER_VCCINTLPD_ENABLE 0 PMC_TAMPER_VCCINTLPD_ERASE_RESPONSE {SYS INTERRUPT} PMC_TAMPER_VCCINTPLAUXPL_ENABLE 0 PMC_TAMPER_VCCINTSOC_ENABLE 0 PMC_TAMPER_VCCIODIOB_ENABLE 0 PMC_USE_CFU_SEU 0 PMC_USE_NOC_PMC_AXI0 0 PMC_USE_PL_PMC_AUX_REF_CLK 0 PMC_USE_PMC_NOC_AXI0 1 POWER_REPORTING_MODE Custom PSPMC_MANUAL_CLK_ENABLE 0 PS_BANK_2_IO_STANDARD LVCMOS1.8 PS_BANK_3_IO_STANDARD LVCMOS1.8 PS_BOARD_INTERFACE Custom PS_CAN0_CLK {{ENABLE 0} {IO {PMC_MIO 0}}} PS_CAN1_CLK {{ENABLE 0} {IO {PMC_MIO 0}}} PS_CAN1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 40 .. 41}}} PS_CRF_ACPU_CTRL_ACT_FREQMHZ 1350.000000 PS_CRF_ACPU_CTRL_DIVISOR0 1 PS_CRF_ACPU_CTRL_FREQMHZ 1350 PS_CRF_ACPU_CTRL_SRCSEL APLL PS_CRF_APLL_CTRL_CLKOUTDIV 2 PS_CRF_APLL_CTRL_FBDIV 81 PS_CRF_APLL_CTRL_SRCSEL REF_CLK PS_CRF_APLL_TO_XPD_CTRL_DIVISOR0 1 PS_CRF_DBG_FPD_CTRL_ACT_FREQMHZ 394.444427 PS_CRF_DBG_FPD_CTRL_DIVISOR0 3 PS_CRF_DBG_FPD_CTRL_FREQMHZ 400 PS_CRF_DBG_FPD_CTRL_SRCSEL PPLL PS_CRF_DBG_TRACE_CTRL_ACT_FREQMHZ 300 PS_CRF_DBG_TRACE_CTRL_DIVISOR0 3 PS_CRF_DBG_TRACE_CTRL_FREQMHZ 300 PS_CRF_DBG_TRACE_CTRL_SRCSEL PPLL PS_CRF_FPD_LSBUS_CTRL_ACT_FREQMHZ 150.000000 PS_CRF_FPD_LSBUS_CTRL_DIVISOR0 9 PS_CRF_FPD_LSBUS_CTRL_FREQMHZ 150 PS_CRF_FPD_LSBUS_CTRL_SRCSEL APLL PS_CRF_FPD_TOP_SWITCH_CTRL_ACT_FREQMHZ 824.999939 PS_CRF_FPD_TOP_SWITCH_CTRL_DIVISOR0 1 PS_CRF_FPD_TOP_SWITCH_CTRL_FREQMHZ 825 PS_CRF_FPD_TOP_SWITCH_CTRL_SRCSEL RPLL PS_CRL_CAN0_REF_CTRL_ACT_FREQMHZ 100 PS_CRL_CAN0_REF_CTRL_DIVISOR0 12 PS_CRL_CAN0_REF_CTRL_FREQMHZ 100 PS_CRL_CAN0_REF_CTRL_SRCSEL PPLL PS_CRL_CAN1_REF_CTRL_ACT_FREQMHZ 99.999992 PS_CRL_CAN1_REF_CTRL_DIVISOR0 10 PS_CRL_CAN1_REF_CTRL_FREQMHZ 100 PS_CRL_CAN1_REF_CTRL_SRCSEL NPLL PS_CRL_CPM_TOPSW_REF_CTRL_ACT_FREQMHZ 824.999939 PS_CRL_CPM_TOPSW_REF_CTRL_DIVISOR0 2 PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ 825 PS_CRL_CPM_TOPSW_REF_CTRL_SRCSEL RPLL PS_CRL_CPU_R5_CTRL_ACT_FREQMHZ 591.666626 PS_CRL_CPU_R5_CTRL_DIVISOR0 2 PS_CRL_CPU_R5_CTRL_FREQMHZ 600 PS_CRL_CPU_R5_CTRL_SRCSEL PPLL PS_CRL_DBG_LPD_CTRL_ACT_FREQMHZ 394.444427 PS_CRL_DBG_LPD_CTRL_DIVISOR0 3 PS_CRL_DBG_LPD_CTRL_FREQMHZ 400 PS_CRL_DBG_LPD_CTRL_SRCSEL PPLL PS_CRL_DBG_TSTMP_CTRL_ACT_FREQMHZ 394.444427 PS_CRL_DBG_TSTMP_CTRL_DIVISOR0 3 PS_CRL_DBG_TSTMP_CTRL_FREQMHZ 400 PS_CRL_DBG_TSTMP_CTRL_SRCSEL PPLL PS_CRL_GEM0_REF_CTRL_ACT_FREQMHZ 124.999992 PS_CRL_GEM0_REF_CTRL_DIVISOR0 8 PS_CRL_GEM0_REF_CTRL_FREQMHZ 125 PS_CRL_GEM0_REF_CTRL_SRCSEL NPLL PS_CRL_GEM1_REF_CTRL_ACT_FREQMHZ 124.999992 PS_CRL_GEM1_REF_CTRL_DIVISOR0 8 PS_CRL_GEM1_REF_CTRL_FREQMHZ 125 PS_CRL_GEM1_REF_CTRL_SRCSEL NPLL PS_CRL_GEM_TSU_REF_CTRL_ACT_FREQMHZ 249.999985 PS_CRL_GEM_TSU_REF_CTRL_DIVISOR0 4 PS_CRL_GEM_TSU_REF_CTRL_FREQMHZ 250 PS_CRL_GEM_TSU_REF_CTRL_SRCSEL NPLL PS_CRL_I2C0_REF_CTRL_ACT_FREQMHZ 100 PS_CRL_I2C0_REF_CTRL_DIVISOR0 12 PS_CRL_I2C0_REF_CTRL_FREQMHZ 100 PS_CRL_I2C0_REF_CTRL_SRCSEL PPLL PS_CRL_I2C1_REF_CTRL_ACT_FREQMHZ 99.999992 PS_CRL_I2C1_REF_CTRL_DIVISOR0 10 PS_CRL_I2C1_REF_CTRL_FREQMHZ 100 PS_CRL_I2C1_REF_CTRL_SRCSEL NPLL PS_CRL_IOU_SWITCH_CTRL_ACT_FREQMHZ 249.999985 PS_CRL_IOU_SWITCH_CTRL_DIVISOR0 4 PS_CRL_IOU_SWITCH_CTRL_FREQMHZ 250 PS_CRL_IOU_SWITCH_CTRL_SRCSEL NPLL PS_CRL_LPD_LSBUS_CTRL_ACT_FREQMHZ 149.999985 PS_CRL_LPD_LSBUS_CTRL_DIVISOR0 11 PS_CRL_LPD_LSBUS_CTRL_FREQMHZ 150 PS_CRL_LPD_LSBUS_CTRL_SRCSEL RPLL PS_CRL_LPD_TOP_SWITCH_CTRL_ACT_FREQMHZ 591.666626 PS_CRL_LPD_TOP_SWITCH_CTRL_DIVISOR0 2 PS_CRL_LPD_TOP_SWITCH_CTRL_FREQMHZ 600 PS_CRL_LPD_TOP_SWITCH_CTRL_SRCSEL PPLL PS_CRL_PSM_REF_CTRL_ACT_FREQMHZ 394.444427 PS_CRL_PSM_REF_CTRL_DIVISOR0 3 PS_CRL_PSM_REF_CTRL_FREQMHZ 400 PS_CRL_PSM_REF_CTRL_SRCSEL PPLL PS_CRL_RPLL_CTRL_CLKOUTDIV 2 PS_CRL_RPLL_CTRL_FBDIV 99 PS_CRL_RPLL_CTRL_SRCSEL REF_CLK PS_CRL_RPLL_TO_XPD_CTRL_DIVISOR0 2 PS_CRL_SPI0_REF_CTRL_ACT_FREQMHZ 200 PS_CRL_SPI0_REF_CTRL_DIVISOR0 6 PS_CRL_SPI0_REF_CTRL_FREQMHZ 200 PS_CRL_SPI0_REF_CTRL_SRCSEL PPLL PS_CRL_SPI1_REF_CTRL_ACT_FREQMHZ 200 PS_CRL_SPI1_REF_CTRL_DIVISOR0 6 PS_CRL_SPI1_REF_CTRL_FREQMHZ 200 PS_CRL_SPI1_REF_CTRL_SRCSEL PPLL PS_CRL_TIMESTAMP_REF_CTRL_ACT_FREQMHZ 99.999992 PS_CRL_TIMESTAMP_REF_CTRL_DIVISOR0 10 PS_CRL_TIMESTAMP_REF_CTRL_FREQMHZ 100 PS_CRL_TIMESTAMP_REF_CTRL_SRCSEL NPLL PS_CRL_UART0_REF_CTRL_ACT_FREQMHZ 99.999992 PS_CRL_UART0_REF_CTRL_DIVISOR0 10 PS_CRL_UART0_REF_CTRL_FREQMHZ 100 PS_CRL_UART0_REF_CTRL_SRCSEL NPLL PS_CRL_UART1_REF_CTRL_ACT_FREQMHZ 100 PS_CRL_UART1_REF_CTRL_DIVISOR0 12 PS_CRL_UART1_REF_CTRL_FREQMHZ 100 PS_CRL_UART1_REF_CTRL_SRCSEL PPLL PS_CRL_USB0_BUS_REF_CTRL_ACT_FREQMHZ 19.999998 PS_CRL_USB0_BUS_REF_CTRL_DIVISOR0 50 PS_CRL_USB0_BUS_REF_CTRL_FREQMHZ 20 PS_CRL_USB0_BUS_REF_CTRL_SRCSEL NPLL PS_CRL_USB3_DUAL_REF_CTRL_ACT_FREQMHZ 20 PS_CRL_USB3_DUAL_REF_CTRL_DIVISOR0 60 PS_CRL_USB3_DUAL_REF_CTRL_FREQMHZ 10 PS_CRL_USB3_DUAL_REF_CTRL_SRCSEL PPLL PS_DDRC_ENABLE 1 PS_DDR_RAM_HIGHADDR_OFFSET 0x800000000 PS_DDR_RAM_LOWADDR_OFFSET 0x80000000 PS_ENABLE_HSDP 0 PS_ENET0_MDIO {{ENABLE 1} {IO {PS_MIO 24 .. 25}}} PS_ENET0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 11}}} PS_ENET1_MDIO {{ENABLE 0} {IO PMC_MIO 50 .. 51}} PS_ENET1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 12 .. 23}}} PS_EN_AXI_STATUS_PORTS 0 PS_EN_PORTS_CONTROLLER_BASED 0 PS_EXPAND_CORESIGHT 0 PS_EXPAND_FPD_SLAVES 0 PS_EXPAND_GIC 0 PS_EXPAND_LPD_SLAVES 0 PS_FPD_INTERCONNECT_LOAD 0.0 PS_FTM_CTI_IN0 0 PS_FTM_CTI_IN1 0 PS_FTM_CTI_IN2 0 PS_FTM_CTI_IN3 0 PS_FTM_CTI_OUT0 0 PS_FTM_CTI_OUT1 0 PS_FTM_CTI_OUT2 0 PS_FTM_CTI_OUT3 0 PS_GEM0_COHERENCY 0 PS_GEM0_ROUTE_THROUGH_FPD 0 PS_GEM1_COHERENCY 0 PS_GEM1_ROUTE_THROUGH_FPD 0 PS_GEM_TSU {{ENABLE 0} {IO PS_MIO 24}} PS_GEM_TSU_CLK_PORT_PAIR 0 PS_GEN_IPI0_ENABLE 1 PS_GEN_IPI0_MASTER A72 PS_GEN_IPI1_ENABLE 1 PS_GEN_IPI1_MASTER A72 PS_GEN_IPI2_ENABLE 1 PS_GEN_IPI2_MASTER A72 PS_GEN_IPI3_ENABLE 1 PS_GEN_IPI3_MASTER A72 PS_GEN_IPI4_ENABLE 1 PS_GEN_IPI4_MASTER A72 PS_GEN_IPI5_ENABLE 1 PS_GEN_IPI5_MASTER A72 PS_GEN_IPI6_ENABLE 1 PS_GEN_IPI6_MASTER A72 PS_GEN_IPI_PMCNOBUF_ENABLE 1 PS_GEN_IPI_PMCNOBUF_MASTER PMC PS_GEN_IPI_PMC_ENABLE 1 PS_GEN_IPI_PMC_MASTER PMC PS_GEN_IPI_PSM_ENABLE 1 PS_GEN_IPI_PSM_MASTER PSM PS_GPIO2_MIO_PERIPHERAL {{ENABLE 0} {IO {PS_MIO 0 .. 25}}} PS_GPIO_EMIO_PERIPHERAL_ENABLE 0 PS_HSDP0_REFCLK 0 PS_HSDP1_REFCLK 0 PS_HSDP_EGRESS_TRAFFIC JTAG PS_HSDP_INGRESS_TRAFFIC JTAG PS_HSDP_MODE NONE PS_HSDP_SAME_EGRESS_AS_INGRESS_TRAFFIC 1 PS_HSDP_SAME_INGRESS_EGRESS_TRAFFIC JTAG PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 44 .. 45}}} PS_I2CSYSMON_PERIPHERAL {{ENABLE 0} {IO PS_MIO 23 .. 25}} PS_LPDMA0_COHERENCY 0 PS_LPDMA0_ROUTE_THROUGH_FPD 1 PS_LPDMA1_COHERENCY 0 PS_LPDMA1_ROUTE_THROUGH_FPD 1 PS_LPDMA2_COHERENCY 0 PS_LPDMA2_ROUTE_THROUGH_FPD 1 PS_LPDMA3_COHERENCY 0 PS_LPDMA3_ROUTE_THROUGH_FPD 1 PS_LPDMA4_COHERENCY 0 PS_LPDMA4_ROUTE_THROUGH_FPD 1 PS_LPDMA5_COHERENCY 0 PS_LPDMA5_ROUTE_THROUGH_FPD 1 PS_LPDMA6_COHERENCY 0 PS_LPDMA6_ROUTE_THROUGH_FPD 1 PS_LPDMA7_COHERENCY 0 PS_LPDMA7_ROUTE_THROUGH_FPD 1 PS_LPD_DMA_CHANNEL_ENABLE {{CH0 0} {CH1 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0}} PS_LPD_DMA_CH_TZ {{CH0 NonSecure} {CH1 NonSecure} {CH2 NonSecure} {CH3 NonSecure} {CH4 NonSecure} {CH5 NonSecure} {CH6 NonSecure} {CH7 NonSecure}} PS_LPD_DMA_ENABLE 0 PS_LPD_INTERCONNECT_LOAD 0.0 PS_M_AXI_GP4_DATA_WIDTH 128 PS_NOC_PS_CCI_DATA_WIDTH 128 PS_NOC_PS_NCI_DATA_WIDTH 128 PS_NOC_PS_PCI_DATA_WIDTH 128 PS_NOC_PS_PMC_DATA_WIDTH 128 PS_NUM_F2P0_INTR_INPUTS 1 PS_NUM_F2P1_INTR_INPUTS 1 PS_NUM_FABRIC_RESETS 1 PS_OCM_ACTIVE_BLOCKS 0 PS_PCIE1_PERIPHERAL_ENABLE 0 PS_PCIE2_PERIPHERAL_ENABLE 0 PS_PCIE_EP_RESET1_IO None PS_PCIE_EP_RESET2_IO None PS_PCIE_PERIPHERAL_ENABLE 0 PS_PCIE_RESET {{ENABLE 0} {IO {PS_MIO 18 .. 19}}} PS_PCIE_ROOT_RESET1_IO None PS_PCIE_ROOT_RESET1_POLARITY {Active Low} PS_PCIE_ROOT_RESET2_IO None PS_PCIE_ROOT_RESET2_POLARITY {Active Low} PS_PL_CONNECTIVITY_MODE Custom PS_PL_DONE 0 PS_PMCPL_CLK0_BUF 1 PS_PMCPL_CLK1_BUF 1 PS_PMCPL_CLK2_BUF 1 PS_PMCPL_CLK3_BUF 1 PS_PMCPL_IRO_CLK_BUF 1 PS_PMU_PERIPHERAL_ENABLE 0 PS_PS_ENABLE 0 PS_PS_NOC_CCI_DATA_WIDTH 128 PS_PS_NOC_NCI_DATA_WIDTH 128 PS_PS_NOC_PCI_DATA_WIDTH 128 PS_PS_NOC_PMC_DATA_WIDTH 128 PS_PS_NOC_RPU_DATA_WIDTH 128 PS_R5_ACTIVE_BLOCKS 0 PS_R5_LOAD 0.0 PS_RPU_COHERENCY 0 PS_SLR_TYPE master PS_SMON_PL_PORTS_ENABLE 0 PS_S_AXI_ACE_DATA_WIDTH 128 PS_S_AXI_ACP_DATA_WIDTH 128 PS_TCM_ACTIVE_BLOCKS 0 PS_TRACE_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 30 .. 47}} PS_TRISTATE_INVERTED 0 PS_TTC0_CLK {{ENABLE 0} {IO PS_MIO 6}} PS_TTC0_PERIPHERAL_ENABLE 0 PS_TTC0_REF_CTRL_ACT_FREQMHZ 100 PS_TTC0_REF_CTRL_FREQMHZ 100 PS_TTC0_WAVEOUT {{ENABLE 0} {IO PS_MIO 7}} PS_TTC1_CLK {{ENABLE 0} {IO PS_MIO 12}} PS_TTC1_PERIPHERAL_ENABLE 0 PS_TTC1_REF_CTRL_ACT_FREQMHZ 100 PS_TTC1_REF_CTRL_FREQMHZ 100 PS_TTC1_WAVEOUT {{ENABLE 0} {IO PS_MIO 13}} PS_TTC2_CLK {{ENABLE 0} {IO PS_MIO 2}} PS_TTC2_PERIPHERAL_ENABLE 0 PS_TTC2_REF_CTRL_ACT_FREQMHZ 100 PS_TTC2_REF_CTRL_FREQMHZ 100 PS_TTC2_WAVEOUT {{ENABLE 0} {IO PS_MIO 3}} PS_TTC3_CLK {{ENABLE 0} {IO PS_MIO 16}} PS_TTC3_PERIPHERAL_ENABLE 0 PS_TTC3_REF_CTRL_ACT_FREQMHZ 100 PS_TTC3_REF_CTRL_FREQMHZ 100 PS_TTC3_WAVEOUT {{ENABLE 0} {IO PS_MIO 17}} PS_TTC_APB_CLK_TTC0_SEL APB PS_TTC_APB_CLK_TTC1_SEL APB PS_TTC_APB_CLK_TTC2_SEL APB PS_TTC_APB_CLK_TTC3_SEL APB PS_UART0_BAUD_RATE 115200 PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 42 .. 43}}} PS_UART0_RTS_CTS {{ENABLE 0} {IO PS_MIO 2 .. 3}} PS_UART1_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 4 .. 5}} PS_UART1_RTS_CTS {{ENABLE 0} {IO PMC_MIO 6 .. 7}} PS_UNITS_MODE Custom PS_USB3_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 13 .. 25}}} PS_USB_COHERENCY 0 PS_USB_ROUTE_THROUGH_FPD 0 PS_USE_ACE_LITE 0 PS_USE_APU_EVENT_BUS 0 PS_USE_APU_INTERRUPT 0 PS_USE_AXI4_EXT_USER_BITS 0 PS_USE_BSCAN_USER1 0 PS_USE_BSCAN_USER2 0 PS_USE_BSCAN_USER3 0 PS_USE_BSCAN_USER4 0 PS_USE_CAPTURE 0 PS_USE_CLK 0 PS_USE_DEBUG_TEST 0 PS_USE_DIFF_RW_CLK_S_AXI_FPD 0 PS_USE_DIFF_RW_CLK_S_AXI_GP2 0 PS_USE_DIFF_RW_CLK_S_AXI_LPD 0 PS_USE_ENET0_PTP 0 PS_USE_ENET1_PTP 0 PS_USE_FIFO_ENET0 0 PS_USE_FIFO_ENET1 0 PS_USE_FIXED_IO 0 PS_USE_FPD_AXI_NOC0 1 PS_USE_FPD_AXI_NOC1 1 PS_USE_FPD_CCI_NOC 1 PS_USE_FPD_CCI_NOC0 0 PS_USE_FPD_CCI_NOC1 0 PS_USE_FPD_CCI_NOC2 0 PS_USE_FPD_CCI_NOC3 0 PS_USE_FTM_GPI 0 PS_USE_FTM_GPO 0 PS_USE_HSDP_PL 0 PS_USE_M_AXI_FPD 1 PS_USE_M_AXI_LPD 0 PS_USE_NOC_FPD_AXI0 0 PS_USE_NOC_FPD_AXI1 0 PS_USE_NOC_FPD_CCI0 0 PS_USE_NOC_FPD_CCI1 0 PS_USE_NOC_LPD_AXI0 1 PS_USE_NOC_PS_PCI_0 0 PS_USE_NOC_PS_PMC_0 0 PS_USE_NPI_CLK 0 PS_USE_NPI_RST 0 PS_USE_PL_FPD_AUX_REF_CLK 0 PS_USE_PL_LPD_AUX_REF_CLK 0 PS_USE_PMC 0 PS_USE_PMCPL_CLK0 1 PS_USE_PMCPL_CLK1 0 PS_USE_PMCPL_CLK2 0 PS_USE_PMCPL_CLK3 0 PS_USE_PMCPL_IRO_CLK 0 PS_USE_PSPL_IRQ_FPD 0 PS_USE_PSPL_IRQ_LPD 0 PS_USE_PSPL_IRQ_PMC 0 PS_USE_PS_NOC_PCI_0 0 PS_USE_PS_NOC_PCI_1 0 PS_USE_PS_NOC_PMC_0 0 PS_USE_PS_NOC_PMC_1 0 PS_USE_RPU_EVENT 0 PS_USE_RPU_INTERRUPT 0 PS_USE_RTC 0 PS_USE_SMMU 0 PS_USE_STARTUP 0 PS_USE_STM 0 PS_USE_S_ACP_FPD 0 PS_USE_S_AXI_ACE 0 PS_USE_S_AXI_FPD 0 PS_USE_S_AXI_GP2 0 PS_USE_S_AXI_LPD 0 PS_USE_TRACE_ATB 0 PS_WDT0_REF_CTRL_ACT_FREQMHZ 100 PS_WDT0_REF_CTRL_FREQMHZ 100 PS_WDT0_REF_CTRL_SEL NONE PS_WDT1_REF_CTRL_ACT_FREQMHZ 100 PS_WDT1_REF_CTRL_FREQMHZ 100 PS_WDT1_REF_CTRL_SEL NONE PS_WWDT0_CLK {{ENABLE 0} {IO PMC_MIO 0}} PS_WWDT0_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 0 .. 5}} PS_WWDT1_CLK {{ENABLE 0} {IO PMC_MIO 6}} PS_WWDT1_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 6 .. 11}} SEM_NPI_SCAN 0 SEM_TIME_INTERVAL_BETWEEN_SCANS 0 SMON_ENABLE_INT_VOLTAGE_MONITORING 0 AURORA_LINE_RATE_GPBS 12.5 BOOT_MODE Custom BOOT_SECONDARY_PCIE_ENABLE 0 CLOCK_MODE Custom COHERENCY_MODE Custom DDR_MEMORY_MODE Custom DEBUG_MODE Custom DESIGN_MODE 0 DEVICE_INTEGRITY_MODE Custom DIS_AUTO_POL_CHECK 0 GT_REFCLK_MHZ 156.25 INIT_CLK_MHZ 125 INV_POLARITY 0 IO_CONFIG_MODE Custom PERFORMANCE_MODE Custom PMC_MIO0 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO1 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO10 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO14 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO15 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO16 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO17 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO18 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO19 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO2 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO20 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO21 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO22 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO23 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO25 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO3 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO30 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO31 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO32 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO33 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO34 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO35 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO36 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO38 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO39 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO4 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO40 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO41 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO42 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO43 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO44 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO45 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO46 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO47 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO48 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO49 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO5 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO50 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO51 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PMC_MIO8 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO9 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PMC_MIO_TREE_PERIPHERALS {QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#Loopback Clk#QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD1/eMMC1#SD1/eMMC1#SD1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#GPIO 1###CAN 1#CAN 1#UART 0#UART 0#I2C 1#I2C 1#i2c_pmc#i2c_pmc####SD1/eMMC1#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 0#Enet 0} PMC_MIO_TREE_SIGNALS qspi0_clk#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_io[0]#qspi0_cs_b#qspi_lpbk#qspi1_cs_b#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#qspi1_clk#usb2phy_reset#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_tx_data[2]#ulpi_tx_data[3]#ulpi_clk#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#ulpi_dir#ulpi_stp#ulpi_nxt#clk#dir1/data[7]#detect#cmd#data[0]#data[1]#data[2]#data[3]#sel/data[4]#dir_cmd/data[5]#dir0/data[6]#gpio_1_pin[37]###phy_tx#phy_rx#rxd#txd#scl#sda#scl#sda####buspwr/rst#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem0_mdc#gem0_mdio PS_A72_ACTIVE_BLOCKS 0 PS_A72_LOAD 0.0 PS_CAN0_PERIPHERAL {{ENABLE 0} {IO PMC_MIO 8 .. 9}} PS_I2C0_PERIPHERAL {{ENABLE 0} {IO PS_MIO 2 .. 3}} PS_IRQ_USAGE {{CH0 1} {CH1 0} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} PS_MIO0 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO1 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO10 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO14 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO15 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO16 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO17 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO18 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO2 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO20 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO22 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO23 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO25 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO3 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO4 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO5 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Unassigned}} PS_MIO6 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_MIO8 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Unassigned}} PS_M_AXI_FPD_DATA_WIDTH 128 PS_SPI0 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO PMC_MIO 15} {GRP_SS1_ENABLE 0} {GRP_SS1_IO PMC_MIO 14} {GRP_SS2_ENABLE 0} {GRP_SS2_IO PMC_MIO 13} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO PMC_MIO 12 .. 17}} PS_SPI1 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO PS_MIO 9} {GRP_SS1_ENABLE 0} {GRP_SS1_IO PS_MIO 8} {GRP_SS2_ENABLE 0} {GRP_SS2_IO PS_MIO 7} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO PS_MIO 6 .. 11}} SEM_ERROR_HANDLE_OPTIONS {Detect & Correct} SEM_MEM_GOLDEN_ECC 0 SEM_MEM_GOLDEN_ECC_SW 0 SEM_MEM_SCAN 0 SMON_INTERFACE_TO_USE None SMON_MEAS0 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_103}} SMON_MEAS1 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_104}} SMON_MEAS10 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_206}} SMON_MEAS100 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS101 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS102 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS103 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS104 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS105 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS106 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS107 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS108 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS109 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS11 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_103}} SMON_MEAS110 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS111 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS112 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS113 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS114 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS115 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS116 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS117 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS118 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS119 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS12 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_104}} SMON_MEAS120 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS121 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS122 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS123 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS124 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS125 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS126 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS127 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS128 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS129 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS13 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_105}} SMON_MEAS130 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS131 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS132 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS133 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS134 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS135 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS136 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS137 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS138 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS139 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS14 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_106}} SMON_MEAS140 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS141 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS142 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS143 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS144 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS145 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS146 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS147 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS148 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS149 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS15 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_200}} SMON_MEAS150 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS151 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS152 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS153 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS154 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS155 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS156 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS157 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS158 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS159 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS16 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_201}} SMON_MEAS160 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS161 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS162 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS163 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS164 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS165 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS166 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS167 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS168 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS169 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS17 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_202}} SMON_MEAS170 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS171 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS172 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS173 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS174 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS175 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS18 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_203}} SMON_MEAS19 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_204}} SMON_MEAS2 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_105}} SMON_MEAS20 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_205}} SMON_MEAS21 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCC_206}} SMON_MEAS22 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_103}} SMON_MEAS23 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_104}} SMON_MEAS24 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_105}} SMON_MEAS25 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_106}} SMON_MEAS26 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_200}} SMON_MEAS27 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_201}} SMON_MEAS28 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_202}} SMON_MEAS29 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_203}} SMON_MEAS3 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_106}} SMON_MEAS30 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_204}} SMON_MEAS31 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_205}} SMON_MEAS32 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVTT_206}} SMON_MEAS33 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCAUX}} SMON_MEAS34 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCAUX_PMC}} SMON_MEAS35 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCAUX_SMON}} SMON_MEAS36 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCINT}} SMON_MEAS37 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_306}} SMON_MEAS38 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_406}} SMON_MEAS39 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_500}} SMON_MEAS4 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_200}} SMON_MEAS40 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_501}} SMON_MEAS41 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_502}} SMON_MEAS42 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 4 V unipolar} {NAME VCCO_503}} SMON_MEAS43 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_700}} SMON_MEAS44 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_701}} SMON_MEAS45 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_702}} SMON_MEAS46 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_703}} SMON_MEAS47 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_704}} SMON_MEAS48 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_705}} SMON_MEAS49 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_706}} SMON_MEAS5 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_201}} SMON_MEAS50 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_707}} SMON_MEAS51 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_708}} SMON_MEAS52 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_709}} SMON_MEAS53 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_710}} SMON_MEAS54 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCCO_711}} SMON_MEAS55 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_BATT}} SMON_MEAS56 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_PMC}} SMON_MEAS57 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_PSFP}} SMON_MEAS58 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_PSLP}} SMON_MEAS59 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_RAM}} SMON_MEAS6 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_202}} SMON_MEAS60 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VCC_SOC}} SMON_MEAS61 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME VP_VN}} SMON_MEAS62 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS63 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS64 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS65 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS66 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS67 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS68 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS69 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS7 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_203}} SMON_MEAS70 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS71 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS72 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS73 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS74 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS75 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS76 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS77 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS78 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS79 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS8 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_204}} SMON_MEAS80 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS81 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS82 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS83 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS84 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS85 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS86 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS87 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS88 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS89 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS9 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE 2 V unipolar} {NAME GTY_AVCCAUX_205}} SMON_MEAS90 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS91 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS92 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS93 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS94 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS95 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS96 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS97 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS98 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEAS99 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 0} {MODE None} {NAME GT_AVAUX_PKG_103}} SMON_MEASUREMENT_COUNT 62 SMON_MEASUREMENT_LIST BANK_VOLTAGE:GTY_AVTT-GTY_AVTT_103,GTY_AVTT_104,GTY_AVTT_105,GTY_AVTT_106,GTY_AVTT_200,GTY_AVTT_201,GTY_AVTT_202,GTY_AVTT_203,GTY_AVTT_204,GTY_AVTT_205,GTY_AVTT_206#VCC-GTY_AVCC_103,GTY_AVCC_104,GTY_AVCC_105,GTY_AVCC_106,GTY_AVCC_200,GTY_AVCC_201,GTY_AVCC_202,GTY_AVCC_203,GTY_AVCC_204,GTY_AVCC_205,GTY_AVCC_206#VCCAUX-GTY_AVCCAUX_103,GTY_AVCCAUX_104,GTY_AVCCAUX_105,GTY_AVCCAUX_106,GTY_AVCCAUX_200,GTY_AVCCAUX_201,GTY_AVCCAUX_202,GTY_AVCCAUX_203,GTY_AVCCAUX_204,GTY_AVCCAUX_205,GTY_AVCCAUX_206#VCCO-VCCO_306,VCCO_406,VCCO_500,VCCO_501,VCCO_502,VCCO_503,VCCO_700,VCCO_701,VCCO_702,VCCO_703,VCCO_704,VCCO_705,VCCO_706,VCCO_707,VCCO_708,VCCO_709,VCCO_710,VCCO_711|DEDICATED_PAD:VP-VP_VN|SUPPLY_VOLTAGE:VCC-VCC_BATT,VCC_PMC,VCC_PSFP,VCC_PSLP,VCC_RAM,VCC_SOC#VCCAUX-VCCAUX,VCCAUX_PMC,VCCAUX_SMON#VCCINT-VCCINT SMON_OT {{THRESHOLD_LOWER -55} {THRESHOLD_UPPER 125}} SMON_REFERENCE_SOURCE Internal SMON_TEMP_THRESHOLD 0 SMON_USER_TEMP {{THRESHOLD_LOWER 0} {THRESHOLD_UPPER 125} {USER_ALARM_TYPE window}} SMON_VAUX_CH0 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH0}} SMON_VAUX_CH1 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH1}} SMON_VAUX_CH10 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH10}} SMON_VAUX_CH11 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH11}} SMON_VAUX_CH12 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH12}} SMON_VAUX_CH13 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH13}} SMON_VAUX_CH14 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH14}} SMON_VAUX_CH15 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH15}} SMON_VAUX_CH2 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH2}} SMON_VAUX_CH3 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH3}} SMON_VAUX_CH4 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH4}} SMON_VAUX_CH5 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH5}} SMON_VAUX_CH6 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH6}} SMON_VAUX_CH7 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH7}} SMON_VAUX_CH8 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH8}} SMON_VAUX_CH9 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 0} {AVERAGE_EN 0} {ENABLE 0} {IO_N PMC_MIO1_500} {IO_P PMC_MIO0_500} {MODE 1 V unipolar} {NAME VAUX_CH9}} SMON_VAUX_IO_BANK MIO_BANK0 SMON_VOLTAGE_AVERAGING_SAMPLES None SPP_PSPMC_FROM_CORE_WIDTH 12000 SPP_PSPMC_TO_CORE_WIDTH 12000 SUBPRESET1 Custom USE_UART0_IN_DEVICE_BOOT 0 } \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
    ] $CIPS_0

  set icn_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect icn_ctrl_0 ]
  set_property -dict [ list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
    ] $icn_ctrl_0
  
  set axi_intc_cascaded_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_cascaded_1 ]
  set_property -dict [ list \
    CONFIG.C_IRQ_CONNECTION {1} \
    CONFIG.C_ASYNC_INTR  {0xFFFFFFFF} \
    ] $axi_intc_cascaded_1

  set axi_intc_parent [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_parent ]
  set_property -dict [ list \
    CONFIG.C_IRQ_CONNECTION {1} \
    CONFIG.C_ASYNC_INTR  {0xFFFFFFFF} \
    CONFIG.C_CASCADE_MASTER {1} \
    CONFIG.C_EN_CASCADE_MODE {1} \
    ] $axi_intc_parent

  set dfx_decoupler [create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler]
  set_property -dict [list CONFIG.ALL_PARAMS {HAS_SIGNAL_CONTROL 0 HAS_SIGNAL_STATUS 0 HAS_AXI_LITE 1 INTF {intf_0 {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0 MODE slave} intf_1 {ID 1 VLNV xilinx.com:signal:interrupt_rtl:1.0 MODE master} intf_2 {ID 2 VLNV xilinx.com:signal:interrupt_rtl:1.0 MODE master} intf_3 {ID 3 VLNV xilinx.com:signal:clock_rtl:1.0 MODE slave} intf_4 {ID 4 VLNV xilinx.com:signal:reset_rtl:1.0 MODE slave}}}] $dfx_decoupler

  # Create instance: ps_noc, and set properties
  set ps_noc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc ps_noc ]
  set_property -dict [ list \
    CONFIG.MC_PER_RD_INTVL {0} \
    CONFIG.NUM_CLKS {8} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {9} \
    CONFIG.NUM_NSI {0} \
    CONFIG.NUM_SI {8} \
    ] $ps_noc

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    ] [get_bd_intf_pins /ps_noc/M01_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    ] [get_bd_intf_pins /ps_noc/M02_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    ] [get_bd_intf_pins /ps_noc/M03_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {auto} \
    ] [get_bd_intf_pins /ps_noc/M04_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {load} \
    ] [get_bd_intf_pins /ps_noc/M08_INI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M08_INI { read_bw {128} write_bw {128}} M04_INI { read_bw {128} write_bw {128}} M00_INI { read_bw {128} write_bw {128}}} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_cci} \
    ] [get_bd_intf_pins /ps_noc/S00_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M01_INI { read_bw {128} write_bw {128}} M05_INI { read_bw {128} write_bw {128}} M08_INI { read_bw {128} write_bw {128}}} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_cci} \
    ] [get_bd_intf_pins /ps_noc/S01_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M02_INI { read_bw {128} write_bw {128}} M06_INI { read_bw {128} write_bw {128}} M08_INI { read_bw {128} write_bw {128}}} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_cci} \
    ] [get_bd_intf_pins /ps_noc/S02_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M07_INI { read_bw {128} write_bw {128}} M03_INI { read_bw {128} write_bw {128}} M08_INI { read_bw {128} write_bw {128}}} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_cci} \
    ] [get_bd_intf_pins /ps_noc/S03_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M00_INI { read_bw {5} write_bw {5}} } \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_nci} \
    ] [get_bd_intf_pins /ps_noc/S04_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M00_INI { read_bw {5} write_bw {5}} } \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_nci} \
    ] [get_bd_intf_pins /ps_noc/S05_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M00_INI { read_bw {5} write_bw {5}} } \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_rpu} \
    ] [get_bd_intf_pins /ps_noc/S06_AXI]

  set_property -dict [ list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.CONNECTIONS {M08_INI { read_bw {128} write_bw {128}} M04_INI { read_bw {5} write_bw {5}} M00_INI { read_bw {5} write_bw {5}}} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {ps_pmc} \
    ] [get_bd_intf_pins /ps_noc/S07_AXI]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
    ] [get_bd_pins /ps_noc/aclk0]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
    ] [get_bd_pins /ps_noc/aclk1]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
    ] [get_bd_pins /ps_noc/aclk2]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
    ] [get_bd_pins /ps_noc/aclk3]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
    ] [get_bd_pins /ps_noc/aclk4]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
    ] [get_bd_pins /ps_noc/aclk5]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S06_AXI} \
    ] [get_bd_pins /ps_noc/aclk6]

  set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S07_AXI} \
    ] [get_bd_pins /ps_noc/aclk7]

  set clk_wizard_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_1 ]
  set_property -dict [ list \
    CONFIG.CLKOUT2_DIVIDE {20.000000} \
    CONFIG.CLKOUT3_DIVIDE {10.000000} \
    CONFIG.CLKOUT_DRIVES {BUFG} \
    CONFIG.CLKOUT_DYN_PS {None} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT_PORT {clk_out1} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT_USED {true} \
    CONFIG.JITTER_SEL {Min_O_Jitter} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_PHASE_ALIGNMENT {true} \
    CONFIG.USE_RESET {true} \
    CONFIG.PRIM_IN_FREQ.VALUE_SRC USER \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    ] $clk_wizard_1
  
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
  set_property -dict [list CONFIG.NUM_PORTS {2} CONFIG.IN0_WIDTH.VALUE_SRC USER CONFIG.IN0_WIDTH {31}] [get_bd_cells xlconcat_0]

  # Create interface connections
  connect_bd_intf_net -intf_net ShellSide_M_AXI [get_bd_intf_pins icn_ctrl_0/S00_AXI]          [get_bd_intf_pins CIPS_0/M_AXI_FPD]
  connect_bd_intf_net -intf_net dfx_decoupler_M_AXI  [get_bd_intf_pins dfx_decoupler/rp_intf_0] [get_bd_intf_pins VitisRegion/PL_CTRL_S_AXI]
  connect_bd_intf_net  -intf_net icn_ctrl_0_M02_AXI [get_bd_intf_pins icn_ctrl_0/M02_AXI]    [get_bd_intf_pins dfx_decoupler/s_axi_reg]
  connect_bd_intf_net -intf_net icn_ctrl_0_M00_AXI [get_bd_intf_pins dfx_decoupler/s_intf_0] [get_bd_intf_pins icn_ctrl_0/M00_AXI]
  connect_bd_intf_net -intf_net icn_ctrl_0_M01_AXI [get_bd_intf_pins icn_ctrl_0/M01_AXI] [get_bd_intf_pins axi_intc_parent/s_axi]
  connect_bd_intf_net -intf_net icn_ctrl_0_M03_AXI [get_bd_intf_pins icn_ctrl_0/M03_AXI] [get_bd_intf_pins axi_intc_cascaded_1/s_axi]
  connect_bd_intf_net -intf_net VitisRegion_DDR_0 [get_bd_intf_pins VitisRegion/DDR_0] [get_bd_intf_pins noc_ddr/S04_INI]
  connect_bd_intf_net -intf_net VitisRegion_DDR_1 [get_bd_intf_pins VitisRegion/DDR_1] [get_bd_intf_pins noc_ddr/S05_INI]
  connect_bd_intf_net -intf_net VitisRegion_DDR_2 [get_bd_intf_pins VitisRegion/DDR_2] [get_bd_intf_pins noc_ddr/S06_INI]
  connect_bd_intf_net -intf_net VitisRegion_LPDDR_0 [get_bd_intf_pins VitisRegion/LPDDR_0] [get_bd_intf_pins noc_lpddr/S04_INI]
  connect_bd_intf_net -intf_net VitisRegion_LPDDR_1 [get_bd_intf_pins VitisRegion/LPDDR_1] [get_bd_intf_pins noc_lpddr/S05_INI]
  connect_bd_intf_net -intf_net VitisRegion_LPDDR_2 [get_bd_intf_pins VitisRegion/LPDDR_2] [get_bd_intf_pins noc_lpddr/S06_INI]
  connect_bd_intf_net -intf_net VitisRegion_M03_INI1 [get_bd_intf_pins VitisRegion/LPDDR_3] [get_bd_intf_pins noc_lpddr/S07_INI]
  connect_bd_intf_net -intf_net VitisRegion_M03_INI2 [get_bd_intf_pins VitisRegion/DDR_3] [get_bd_intf_pins noc_ddr/S07_INI]
  connect_bd_intf_net -intf_net axi_noc_0_CH0_LPDDR4_0  [get_bd_intf_ports ch0_lpddr4_c0]                [get_bd_intf_pins noc_lpddr/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net axi_noc_0_CH0_LPDDR4_1  [get_bd_intf_ports ch0_lpddr4_c1]                [get_bd_intf_pins noc_lpddr/CH0_LPDDR4_1]
  connect_bd_intf_net -intf_net axi_noc_0_CH1_LPDDR4_0  [get_bd_intf_ports ch1_lpddr4_c0]                [get_bd_intf_pins noc_lpddr/CH1_LPDDR4_0]
  connect_bd_intf_net -intf_net axi_noc_0_CH1_LPDDR4_1  [get_bd_intf_ports ch1_lpddr4_c1]                [get_bd_intf_pins noc_lpddr/CH1_LPDDR4_1]
  connect_bd_intf_net -intf_net noc_ddr_CH0_DDR4_0 [get_bd_intf_ports ddr4_dimm1] [get_bd_intf_pins noc_ddr/CH0_DDR4_0]
  connect_bd_intf_net                                   [get_bd_intf_ports ddr4_dimm1_sma_clk]           [get_bd_intf_pins noc_ddr/sys_clk0]
  connect_bd_intf_net -intf_net lpddr4_sma_clk1_1       [get_bd_intf_ports lpddr4_sma_clk1]              [get_bd_intf_pins noc_lpddr/sys_clk0]
  connect_bd_intf_net -intf_net lpddr4_sma_clk2_1       [get_bd_intf_ports lpddr4_sma_clk2]              [get_bd_intf_pins noc_lpddr/sys_clk1]
  connect_bd_intf_net -intf_net ps_cips_FPD_AXI_NOC_0 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_0] [get_bd_intf_pins ps_noc/S04_AXI]
  connect_bd_intf_net -intf_net ps_cips_FPD_AXI_NOC_1 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_1] [get_bd_intf_pins ps_noc/S05_AXI]
  connect_bd_intf_net -intf_net ps_cips_IF_PS_NOC_CCI_0 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_0] [get_bd_intf_pins ps_noc/S00_AXI]
  connect_bd_intf_net -intf_net ps_cips_IF_PS_NOC_CCI_1 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_1] [get_bd_intf_pins ps_noc/S01_AXI]
  connect_bd_intf_net -intf_net ps_cips_IF_PS_NOC_CCI_2 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_2] [get_bd_intf_pins ps_noc/S02_AXI]
  connect_bd_intf_net -intf_net ps_cips_IF_PS_NOC_CCI_3 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_3] [get_bd_intf_pins ps_noc/S03_AXI]
  connect_bd_intf_net -intf_net ps_cips_NOC_LPD_AXI_0 [get_bd_intf_pins CIPS_0/LPD_AXI_NOC_0] [get_bd_intf_pins ps_noc/S06_AXI]
  connect_bd_intf_net -intf_net ps_cips_PMC_NOC_AXI_0 [get_bd_intf_pins CIPS_0/PMC_NOC_AXI_0] [get_bd_intf_pins ps_noc/S07_AXI]
  connect_bd_intf_net -intf_net ps_noc_M00_INI [get_bd_intf_pins noc_ddr/S00_INI] [get_bd_intf_pins ps_noc/M00_INI]
  connect_bd_intf_net -intf_net ps_noc_M01_INI [get_bd_intf_pins noc_ddr/S01_INI] [get_bd_intf_pins ps_noc/M01_INI]
  connect_bd_intf_net -intf_net ps_noc_M02_INI [get_bd_intf_pins noc_ddr/S02_INI] [get_bd_intf_pins ps_noc/M02_INI]
  connect_bd_intf_net -intf_net ps_noc_M03_INI [get_bd_intf_pins noc_ddr/S03_INI] [get_bd_intf_pins ps_noc/M03_INI]
  connect_bd_intf_net -intf_net ps_noc_M04_INI [get_bd_intf_pins noc_lpddr/S00_INI] [get_bd_intf_pins ps_noc/M04_INI]
  connect_bd_intf_net -intf_net ps_noc_M05_INI [get_bd_intf_pins noc_lpddr/S01_INI] [get_bd_intf_pins ps_noc/M05_INI]
  connect_bd_intf_net -intf_net ps_noc_M06_INI [get_bd_intf_pins noc_lpddr/S02_INI] [get_bd_intf_pins ps_noc/M06_INI]
  connect_bd_intf_net -intf_net ps_noc_M07_INI [get_bd_intf_pins noc_lpddr/S03_INI] [get_bd_intf_pins ps_noc/M07_INI]
  connect_bd_intf_net -intf_net ps_noc_M08_INI [get_bd_intf_pins VitisRegion/AIE_CTRL_INI] [get_bd_intf_pins ps_noc/M08_INI]
  connect_bd_net                               [get_bd_pins axi_intc_parent/irq] [get_bd_pins CIPS_0/pl_ps_irq0]
  connect_bd_net                               [get_bd_pins VitisRegion/Interrupt] [get_bd_pins dfx_decoupler/rp_intf_1_INTERRUPT]
  connect_bd_net                               [get_bd_pins dfx_decoupler/s_intf_1_INTERRUPT] [get_bd_pins axi_intc_cascaded_1/intr]
  connect_bd_net                               [get_bd_pins VitisRegion/Interrupt1] [get_bd_pins dfx_decoupler/rp_intf_2_INTERRUPT]
  connect_bd_net                               [get_bd_pins dfx_decoupler/s_intf_2_INTERRUPT] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_intc_cascaded_1_irq  [get_bd_pins axi_intc_cascaded_1/irq] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net xlconcat_0_dout          [get_bd_pins axi_intc_parent/intr] [get_bd_pins xlconcat_0/dout]

  # Create port connections
  connect_bd_net -net CIPS_0_pl_clk0 [get_bd_pins CIPS_0/pl0_ref_clk] [get_bd_pins clk_wizard_1/clk_in1]
  connect_bd_net -net CtrlReset_peripheral_aresetn [get_bd_pins dfx_decoupler/s_intf_4_RST] [get_bd_pins IsoReset/peripheral_aresetn] [get_bd_pins axi_intc_parent/s_axi_aresetn] [get_bd_pins icn_ctrl_0/aresetn] [get_bd_pins dfx_decoupler/intf_0_arstn] [get_bd_pins dfx_decoupler/s_axi_reg_aresetn] [get_bd_pins axi_intc_cascaded_1/s_axi_aresetn]
  connect_bd_net -net ps_cips_fpd_axi_noc_axi0_clk [get_bd_pins CIPS_0/fpd_axi_noc_axi0_clk] [get_bd_pins ps_noc/aclk4]
  connect_bd_net -net ps_cips_fpd_axi_noc_axi1_clk [get_bd_pins CIPS_0/fpd_axi_noc_axi1_clk] [get_bd_pins ps_noc/aclk5]
  connect_bd_net -net ps_cips_lpd_axi_noc_clk [get_bd_pins CIPS_0/lpd_axi_noc_clk] [get_bd_pins ps_noc/aclk6]
  connect_bd_net -net ps_cips_pl0_resetn [get_bd_pins IsoReset/ext_reset_in] [get_bd_pins CIPS_0/pl0_resetn] [get_bd_pins clk_wizard_1/resetn]
  connect_bd_net -net clk_wizard_1_locked [get_bd_pins clk_wizard_1/locked] [get_bd_pins IsoReset/dcm_locked]
  connect_bd_net -net clk_wizard_1_clk_out1 [get_bd_pins dfx_decoupler/s_intf_3_CLK] [get_bd_pins IsoReset/slowest_sync_clk] [get_bd_pins CIPS_0/m_axi_fpd_aclk] [get_bd_pins clk_wizard_1/clk_out1] [get_bd_pins axi_intc_parent/s_axi_aclk] [get_bd_pins icn_ctrl_0/aclk] [get_bd_pins dfx_decoupler/intf_0_aclk] [get_bd_pins dfx_decoupler/aclk] [get_bd_pins axi_intc_cascaded_1/s_axi_aclk] 
  connect_bd_net -net ps_cips_pmc_axi_noc_axi0_clk [get_bd_pins CIPS_0/pmc_axi_noc_axi0_clk] [get_bd_pins ps_noc/aclk7]
  connect_bd_net -net ps_cips_ps_ps_noc_cci_axi0_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi0_clk] [get_bd_pins ps_noc/aclk0]
  connect_bd_net -net ps_cips_ps_ps_noc_cci_axi1_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi1_clk] [get_bd_pins ps_noc/aclk1]
  connect_bd_net -net ps_cips_ps_ps_noc_cci_axi2_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi2_clk] [get_bd_pins ps_noc/aclk2]
  connect_bd_net -net ps_cips_ps_ps_noc_cci_axi3_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi3_clk] [get_bd_pins ps_noc/aclk3]
  connect_bd_net -net dfx_decoupler_clk_out [get_bd_pins dfx_decoupler/rp_intf_3_CLK] [get_bd_pins VitisRegion/ExtClk]
  connect_bd_net -net dfx_decoupler_reset_out [get_bd_pins dfx_decoupler/rp_intf_4_RST] [get_bd_pins VitisRegion/ExtReset]

  # Create address segments
  assign_bd_address -offset 0xA4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs axi_intc_cascaded_1/S_AXI/Reg] -force
  assign_bd_address -offset 0xA5000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs axi_intc_parent/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0]  [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/LPD_AXI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_ddr/S03_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_ddr/S02_INI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_ddr/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0]  [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/LPD_AXI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_1] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_AXI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_ddr/S03_INI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_ddr/S02_INI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_ddr/S01_INI/C1_DDR_LOW1] -force
  assign_bd_address -offset 0x800000000 -range 0x180000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_ddr/S00_INI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0]  [get_bd_addr_segs VitisRegion/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs VitisRegion/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs VitisRegion/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs VitisRegion/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs VitisRegion/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x050000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_0] [get_bd_addr_segs noc_lpddr/S00_INI/C0_DDR_CH1x2] -force
  assign_bd_address -offset 0x050000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_2] [get_bd_addr_segs noc_lpddr/S02_INI/C2_DDR_CH1x2] -force
  assign_bd_address -offset 0x050000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_1] [get_bd_addr_segs noc_lpddr/S01_INI/C1_DDR_CH1x2] -force
  assign_bd_address -offset 0x050000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces CIPS_0/FPD_CCI_NOC_3] [get_bd_addr_segs noc_lpddr/S03_INI/C3_DDR_CH1x2] -force
  assign_bd_address -offset 0x050000000000 -range 0x000200000000 -target_address_space [get_bd_addr_spaces CIPS_0/PMC_NOC_AXI_0]  [get_bd_addr_segs noc_lpddr/S00_INI/C0_DDR_CH1x2] -force
  assign_bd_address -offset 0xA6000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs dfx_decoupler/s_axi_reg/Reg] -force
  assign_bd_address -offset 0xA7000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs VitisRegion/to_delete_kernel_ctrl_0/S_AXI/Reg] -force
  assign_bd_address -offset 0xA8000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs VitisRegion/to_delete_kernel_ctrl_1/S_AXI/Reg] -force
  assign_bd_address -offset 0xA9000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs VitisRegion/to_delete_kernel_ctrl_2/S_AXI/Reg] -force
  assign_bd_address -offset 0xAA000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces CIPS_0/M_AXI_FPD] [get_bd_addr_segs VitisRegion/to_delete_kernel_ctrl_3/S_AXI/Reg] -force

  # Restore current instance
  current_bd_instance $oldCurInst
}

#Create DFX BD
proc create_dfx {} {
  set curdesign [current_bd_design]

  #Creating Reference BD for BDC
  create_bd_design -cell [get_bd_cells /VitisRegion] VitisRegion
  current_bd_design $curdesign
  set new_cell [create_bd_cell -type container -reference VitisRegion VitisRegion_temp]
  replace_bd_cell [get_bd_cells /VitisRegion] $new_cell
  delete_bd_objs  [get_bd_cells /VitisRegion]
  set_property name VitisRegion $new_cell

  # Calling address apreture dict creation for dfx
  set intfApertureSet [dict create \
    DDR_0 {{0x0 2G} {0x800000000 6G}} \
    DDR_1 {{0x0 2G} {0x800000000 6G}} \
    DDR_2 {{0x0 2G} {0x800000000 6G}} \
    DDR_3 {{0x0 2G} {0x800000000 6G}} \
    LPDDR_0 {{0x50000000000 8G}} \
    LPDDR_1 {{0x50000000000 8G}} \
    LPDDR_2 {{0x50000000000 8G}} \
    LPDDR_3 {{0x50000000000 8G}} \
    PL_CTRL_S_AXI {{0xA7000000 144M}}]

  current_bd_design [get_bd_designs VitisRegion]
  foreach {intf aperture} ${intfApertureSet} {
    set_property APERTURES ${aperture} [get_bd_intf_ports /${intf}]
    set_property HDL_ATTRIBUTE.LOCKED TRUE [get_bd_intf_ports /${intf}]
  }
  current_bd_design ${curdesign}

  #setting DFX property on Vitis Region
  set_property -dict [list CONFIG.LOCK_PROPAGATE {true} CONFIG.ENABLE_DFX {true}] [get_bd_cells VitisRegion]
}

#Calling to create BD design
create_root_design ""
regenerate_bd_layout
save_bd_design
validate_bd_design
create_dfx
