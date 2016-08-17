
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1
#    set_property BOARD_PART digilentinc.com:zybo:part0:1.0 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set Dir [ create_bd_port -dir O Dir ]
  set Dir_1 [ create_bd_port -dir O Dir_1 ]
  set Dir_2 [ create_bd_port -dir O Dir_2 ]
  set Dir_3 [ create_bd_port -dir O Dir_3 ]
  set Dir_4 [ create_bd_port -dir O Dir_4 ]
  set Enable [ create_bd_port -dir O Enable ]
  set Enable_1 [ create_bd_port -dir O Enable_1 ]
  set Enable_2 [ create_bd_port -dir O Enable_2 ]
  set Enable_3 [ create_bd_port -dir O Enable_3 ]
  set Enable_4 [ create_bd_port -dir O Enable_4 ]
  set Pulse [ create_bd_port -dir O Pulse ]
  set Pulse_1 [ create_bd_port -dir O Pulse_1 ]
  set Pulse_2 [ create_bd_port -dir O Pulse_2 ]
  set Pulse_3 [ create_bd_port -dir O Pulse_3 ]
  set Pulse_4 [ create_bd_port -dir O Pulse_4 ]
  set chan_A [ create_bd_port -dir I chan_A ]
  set chan_A_1 [ create_bd_port -dir I chan_A_1 ]
  set chan_A_2 [ create_bd_port -dir I chan_A_2 ]
  set chan_A_3 [ create_bd_port -dir I chan_A_3 ]
  set chan_A_4 [ create_bd_port -dir I chan_A_4 ]
  set chan_A_5 [ create_bd_port -dir I chan_A_5 ]
  set chan_B [ create_bd_port -dir I chan_B ]
  set chan_B_1 [ create_bd_port -dir I chan_B_1 ]
  set chan_B_2 [ create_bd_port -dir I chan_B_2 ]
  set chan_B_3 [ create_bd_port -dir I chan_B_3 ]
  set chan_B_4 [ create_bd_port -dir I chan_B_4 ]
  set chan_B_5 [ create_bd_port -dir I chan_B_5 ]
  set chan_nA [ create_bd_port -dir I chan_nA ]
  set chan_nA_1 [ create_bd_port -dir I chan_nA_1 ]
  set chan_nA_2 [ create_bd_port -dir I chan_nA_2 ]
  set chan_nA_3 [ create_bd_port -dir I chan_nA_3 ]
  set chan_nA_4 [ create_bd_port -dir I chan_nA_4 ]
  set chan_nA_5 [ create_bd_port -dir I chan_nA_5 ]
  set chan_nB [ create_bd_port -dir I chan_nB ]
  set chan_nB_1 [ create_bd_port -dir I chan_nB_1 ]
  set chan_nB_2 [ create_bd_port -dir I chan_nB_2 ]
  set chan_nB_3 [ create_bd_port -dir I chan_nB_3 ]
  set chan_nB_4 [ create_bd_port -dir I chan_nB_4 ]
  set chan_nB_5 [ create_bd_port -dir I chan_nB_5 ]
  set reset_rtl [ create_bd_port -dir I -type rst reset_rtl ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset_rtl
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {125000000} \
CONFIG.PHASE {0.000} \
 ] $sys_clock

  # Create instance: IP_Enc_Struct_6, and set properties
  set IP_Enc_Struct_6 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_6 ]

  # Create instance: IP_Enc_Struct_7, and set properties
  set IP_Enc_Struct_7 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_7 ]

  # Create instance: IP_Enc_Struct_8, and set properties
  set IP_Enc_Struct_8 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_8 ]

  # Create instance: IP_Enc_Struct_9, and set properties
  set IP_Enc_Struct_9 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_9 ]

  # Create instance: IP_Enc_Struct_10, and set properties
  set IP_Enc_Struct_10 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_10 ]

  # Create instance: IP_Enc_Struct_11, and set properties
  set IP_Enc_Struct_11 [ create_bd_cell -type ip -vlnv xilinx.com:user:IP_Enc_Struct:3.0 IP_Enc_Struct_11 ]

  # Create instance: IP_PWM_Struct_0, and set properties
  set IP_PWM_Struct_0 [ create_bd_cell -type ip -vlnv xilinx.com:Fontys:IP_PWM_Struct:2.1 IP_PWM_Struct_0 ]

  # Create instance: IP_PWM_Struct_1, and set properties
  set IP_PWM_Struct_1 [ create_bd_cell -type ip -vlnv xilinx.com:Fontys:IP_PWM_Struct:2.1 IP_PWM_Struct_1 ]

  # Create instance: IP_PWM_Struct_2, and set properties
  set IP_PWM_Struct_2 [ create_bd_cell -type ip -vlnv xilinx.com:Fontys:IP_PWM_Struct:2.1 IP_PWM_Struct_2 ]

  # Create instance: IP_PWM_Struct_3, and set properties
  set IP_PWM_Struct_3 [ create_bd_cell -type ip -vlnv xilinx.com:Fontys:IP_PWM_Struct:2.1 IP_PWM_Struct_3 ]

  # Create instance: IP_PWM_Struct_4, and set properties
  set IP_PWM_Struct_4 [ create_bd_cell -type ip -vlnv xilinx.com:Fontys:IP_PWM_Struct:2.1 IP_PWM_Struct_4 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.2 clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.CLKOUT1_JITTER {638.166} \
CONFIG.CLKOUT1_PHASE_ERROR {713.417} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {20.48} \
CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
CONFIG.MMCM_CLKFBOUT_MULT_F {60.375} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {33.500} \
CONFIG.MMCM_DIVCLK_DIVIDE {11} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_0

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_ENABLE {0} \
CONFIG.PCW_EN_CLK1_PORT {0} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {10} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_I2C0_I2C0_IO {<Select>} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_16_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {fast} \
CONFIG.PCW_MIO_17_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {fast} \
CONFIG.PCW_MIO_18_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {fast} \
CONFIG.PCW_MIO_19_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {fast} \
CONFIG.PCW_MIO_1_PULLUP {disabled} \
CONFIG.PCW_MIO_1_SLEW {fast} \
CONFIG.PCW_MIO_20_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {fast} \
CONFIG.PCW_MIO_21_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {fast} \
CONFIG.PCW_MIO_22_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {fast} \
CONFIG.PCW_MIO_23_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {fast} \
CONFIG.PCW_MIO_24_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {fast} \
CONFIG.PCW_MIO_25_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {fast} \
CONFIG.PCW_MIO_26_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {fast} \
CONFIG.PCW_MIO_27_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {fast} \
CONFIG.PCW_MIO_28_PULLUP {disabled} \
CONFIG.PCW_MIO_28_SLEW {fast} \
CONFIG.PCW_MIO_29_PULLUP {disabled} \
CONFIG.PCW_MIO_29_SLEW {fast} \
CONFIG.PCW_MIO_2_SLEW {fast} \
CONFIG.PCW_MIO_30_PULLUP {disabled} \
CONFIG.PCW_MIO_30_SLEW {fast} \
CONFIG.PCW_MIO_31_PULLUP {disabled} \
CONFIG.PCW_MIO_31_SLEW {fast} \
CONFIG.PCW_MIO_32_PULLUP {disabled} \
CONFIG.PCW_MIO_32_SLEW {fast} \
CONFIG.PCW_MIO_33_PULLUP {disabled} \
CONFIG.PCW_MIO_33_SLEW {fast} \
CONFIG.PCW_MIO_34_PULLUP {disabled} \
CONFIG.PCW_MIO_34_SLEW {fast} \
CONFIG.PCW_MIO_35_PULLUP {disabled} \
CONFIG.PCW_MIO_35_SLEW {fast} \
CONFIG.PCW_MIO_36_PULLUP {disabled} \
CONFIG.PCW_MIO_36_SLEW {fast} \
CONFIG.PCW_MIO_37_PULLUP {disabled} \
CONFIG.PCW_MIO_37_SLEW {fast} \
CONFIG.PCW_MIO_38_PULLUP {disabled} \
CONFIG.PCW_MIO_38_SLEW {fast} \
CONFIG.PCW_MIO_39_PULLUP {disabled} \
CONFIG.PCW_MIO_39_SLEW {fast} \
CONFIG.PCW_MIO_3_SLEW {fast} \
CONFIG.PCW_MIO_40_PULLUP {disabled} \
CONFIG.PCW_MIO_40_SLEW {fast} \
CONFIG.PCW_MIO_41_PULLUP {disabled} \
CONFIG.PCW_MIO_41_SLEW {fast} \
CONFIG.PCW_MIO_42_PULLUP {disabled} \
CONFIG.PCW_MIO_42_SLEW {fast} \
CONFIG.PCW_MIO_43_PULLUP {disabled} \
CONFIG.PCW_MIO_43_SLEW {fast} \
CONFIG.PCW_MIO_44_PULLUP {disabled} \
CONFIG.PCW_MIO_44_SLEW {fast} \
CONFIG.PCW_MIO_45_PULLUP {disabled} \
CONFIG.PCW_MIO_45_SLEW {fast} \
CONFIG.PCW_MIO_47_PULLUP {disabled} \
CONFIG.PCW_MIO_48_PULLUP {disabled} \
CONFIG.PCW_MIO_49_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {fast} \
CONFIG.PCW_MIO_50_DIRECTION {inout} \
CONFIG.PCW_MIO_50_PULLUP {disabled} \
CONFIG.PCW_MIO_51_DIRECTION {inout} \
CONFIG.PCW_MIO_51_PULLUP {disabled} \
CONFIG.PCW_MIO_52_PULLUP {disabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_PULLUP {disabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_SLEW {fast} \
CONFIG.PCW_MIO_6_SLEW {fast} \
CONFIG.PCW_MIO_8_SLEW {fast} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE {1} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {1} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.176} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.159} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.162} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.187} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.073} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.034} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.03} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.082} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K128M16 JT-125} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 46} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {11} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins IP_Enc_Struct_6/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins IP_Enc_Struct_7/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins IP_Enc_Struct_8/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins IP_Enc_Struct_9/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins IP_Enc_Struct_10/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M05_AXI [get_bd_intf_pins IP_Enc_Struct_11/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins IP_PWM_Struct_0/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins IP_PWM_Struct_1/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M08_AXI [get_bd_intf_pins IP_PWM_Struct_2/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M09_AXI [get_bd_intf_pins IP_PWM_Struct_3/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M10_AXI [get_bd_intf_pins IP_PWM_Struct_4/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M10_AXI]

  # Create port connections
  connect_bd_net -net IP_PWM_Struct_0_Dir [get_bd_ports Dir] [get_bd_pins IP_PWM_Struct_0/Dir]
  connect_bd_net -net IP_PWM_Struct_0_Enable [get_bd_ports Enable] [get_bd_pins IP_PWM_Struct_0/Enable]
  connect_bd_net -net IP_PWM_Struct_0_Pulse [get_bd_ports Pulse] [get_bd_pins IP_PWM_Struct_0/Pulse]
  connect_bd_net -net IP_PWM_Struct_1_Dir [get_bd_ports Dir_1] [get_bd_pins IP_PWM_Struct_1/Dir]
  connect_bd_net -net IP_PWM_Struct_1_Enable [get_bd_ports Enable_1] [get_bd_pins IP_PWM_Struct_1/Enable]
  connect_bd_net -net IP_PWM_Struct_1_Pulse [get_bd_ports Pulse_1] [get_bd_pins IP_PWM_Struct_1/Pulse]
  connect_bd_net -net IP_PWM_Struct_2_Dir [get_bd_ports Dir_2] [get_bd_pins IP_PWM_Struct_2/Dir]
  connect_bd_net -net IP_PWM_Struct_2_Enable [get_bd_ports Enable_2] [get_bd_pins IP_PWM_Struct_2/Enable]
  connect_bd_net -net IP_PWM_Struct_2_Pulse [get_bd_ports Pulse_2] [get_bd_pins IP_PWM_Struct_2/Pulse]
  connect_bd_net -net IP_PWM_Struct_3_Dir [get_bd_ports Dir_3] [get_bd_pins IP_PWM_Struct_3/Dir]
  connect_bd_net -net IP_PWM_Struct_3_Enable [get_bd_ports Enable_3] [get_bd_pins IP_PWM_Struct_3/Enable]
  connect_bd_net -net IP_PWM_Struct_3_Pulse [get_bd_ports Pulse_3] [get_bd_pins IP_PWM_Struct_3/Pulse]
  connect_bd_net -net IP_PWM_Struct_4_Dir [get_bd_ports Dir_4] [get_bd_pins IP_PWM_Struct_4/Dir]
  connect_bd_net -net IP_PWM_Struct_4_Enable [get_bd_ports Enable_4] [get_bd_pins IP_PWM_Struct_4/Enable]
  connect_bd_net -net IP_PWM_Struct_4_Pulse [get_bd_ports Pulse_4] [get_bd_pins IP_PWM_Struct_4/Pulse]
  connect_bd_net -net chan_A_1_1 [get_bd_ports chan_A_1] [get_bd_pins IP_Enc_Struct_6/chan_A]
  connect_bd_net -net chan_A_2_1 [get_bd_ports chan_A_2] [get_bd_pins IP_Enc_Struct_7/chan_A]
  connect_bd_net -net chan_A_3_1 [get_bd_ports chan_A_3] [get_bd_pins IP_Enc_Struct_9/chan_A]
  connect_bd_net -net chan_A_4 [get_bd_ports chan_A] [get_bd_pins IP_Enc_Struct_8/chan_A]
  connect_bd_net -net chan_A_4_1 [get_bd_ports chan_A_4] [get_bd_pins IP_Enc_Struct_10/chan_A]
  connect_bd_net -net chan_A_5_1 [get_bd_ports chan_A_5] [get_bd_pins IP_Enc_Struct_11/chan_A]
  connect_bd_net -net chan_B_1_1 [get_bd_ports chan_B_1] [get_bd_pins IP_Enc_Struct_6/chan_B]
  connect_bd_net -net chan_B_2_1 [get_bd_ports chan_B_2] [get_bd_pins IP_Enc_Struct_7/chan_B]
  connect_bd_net -net chan_B_3_1 [get_bd_ports chan_B_3] [get_bd_pins IP_Enc_Struct_9/chan_B]
  connect_bd_net -net chan_B_4 [get_bd_ports chan_B] [get_bd_pins IP_Enc_Struct_8/chan_B]
  connect_bd_net -net chan_B_4_1 [get_bd_ports chan_B_4] [get_bd_pins IP_Enc_Struct_10/chan_B]
  connect_bd_net -net chan_B_5_1 [get_bd_ports chan_B_5] [get_bd_pins IP_Enc_Struct_11/chan_B]
  connect_bd_net -net chan_nA_1 [get_bd_ports chan_nA] [get_bd_pins IP_Enc_Struct_6/chan_nA]
  connect_bd_net -net chan_nA_1_1 [get_bd_ports chan_nA_1] [get_bd_pins IP_Enc_Struct_7/chan_nA]
  connect_bd_net -net chan_nA_2_1 [get_bd_ports chan_nA_2] [get_bd_pins IP_Enc_Struct_8/chan_nA]
  connect_bd_net -net chan_nA_3_1 [get_bd_ports chan_nA_3] [get_bd_pins IP_Enc_Struct_9/chan_nA]
  connect_bd_net -net chan_nA_4_1 [get_bd_ports chan_nA_4] [get_bd_pins IP_Enc_Struct_10/chan_nA]
  connect_bd_net -net chan_nA_5_1 [get_bd_ports chan_nA_5] [get_bd_pins IP_Enc_Struct_11/chan_nA]
  connect_bd_net -net chan_nB_1 [get_bd_ports chan_nB] [get_bd_pins IP_Enc_Struct_6/chan_nB]
  connect_bd_net -net chan_nB_1_1 [get_bd_ports chan_nB_1] [get_bd_pins IP_Enc_Struct_7/chan_nB]
  connect_bd_net -net chan_nB_2_1 [get_bd_ports chan_nB_2] [get_bd_pins IP_Enc_Struct_8/chan_nB]
  connect_bd_net -net chan_nB_3_1 [get_bd_ports chan_nB_3] [get_bd_pins IP_Enc_Struct_9/chan_nB]
  connect_bd_net -net chan_nB_4_1 [get_bd_ports chan_nB_4] [get_bd_pins IP_Enc_Struct_10/chan_nB]
  connect_bd_net -net chan_nB_5_1 [get_bd_ports chan_nB_5] [get_bd_pins IP_Enc_Struct_11/chan_nB]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins IP_Enc_Struct_10/clk] [get_bd_pins IP_Enc_Struct_11/clk] [get_bd_pins IP_Enc_Struct_6/clk] [get_bd_pins IP_Enc_Struct_7/clk] [get_bd_pins IP_Enc_Struct_8/clk] [get_bd_pins IP_Enc_Struct_9/clk] [get_bd_pins IP_PWM_Struct_0/clk] [get_bd_pins IP_PWM_Struct_1/clk] [get_bd_pins IP_PWM_Struct_2/clk] [get_bd_pins IP_PWM_Struct_3/clk] [get_bd_pins IP_PWM_Struct_4/clk] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins IP_Enc_Struct_10/s00_axi_aclk] [get_bd_pins IP_Enc_Struct_11/s00_axi_aclk] [get_bd_pins IP_Enc_Struct_6/s00_axi_aclk] [get_bd_pins IP_Enc_Struct_7/s00_axi_aclk] [get_bd_pins IP_Enc_Struct_8/s00_axi_aclk] [get_bd_pins IP_Enc_Struct_9/s00_axi_aclk] [get_bd_pins IP_PWM_Struct_0/s00_axi_aclk] [get_bd_pins IP_PWM_Struct_1/s00_axi_aclk] [get_bd_pins IP_PWM_Struct_2/s00_axi_aclk] [get_bd_pins IP_PWM_Struct_3/s00_axi_aclk] [get_bd_pins IP_PWM_Struct_4/s00_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/M08_ACLK] [get_bd_pins processing_system7_0_axi_periph/M09_ACLK] [get_bd_pins processing_system7_0_axi_periph/M10_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_rtl] [get_bd_pins IP_Enc_Struct_10/nrst] [get_bd_pins IP_Enc_Struct_11/nrst] [get_bd_pins IP_Enc_Struct_6/nrst] [get_bd_pins IP_Enc_Struct_7/nrst] [get_bd_pins IP_Enc_Struct_8/nrst] [get_bd_pins IP_Enc_Struct_9/nrst] [get_bd_pins clk_wiz_0/reset]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins IP_Enc_Struct_10/s00_axi_aresetn] [get_bd_pins IP_Enc_Struct_11/s00_axi_aresetn] [get_bd_pins IP_Enc_Struct_6/s00_axi_aresetn] [get_bd_pins IP_Enc_Struct_7/s00_axi_aresetn] [get_bd_pins IP_Enc_Struct_8/s00_axi_aresetn] [get_bd_pins IP_Enc_Struct_9/s00_axi_aresetn] [get_bd_pins IP_PWM_Struct_0/s00_axi_aresetn] [get_bd_pins IP_PWM_Struct_1/s00_axi_aresetn] [get_bd_pins IP_PWM_Struct_2/s00_axi_aresetn] [get_bd_pins IP_PWM_Struct_3/s00_axi_aresetn] [get_bd_pins IP_PWM_Struct_4/s00_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M08_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M09_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M10_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_10/s00_axi/reg0] SEG_IP_Enc_Struct_10_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_11/s00_axi/reg0] SEG_IP_Enc_Struct_11_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C20000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_6/s00_axi/reg0] SEG_IP_Enc_Struct_6_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_7/s00_axi/reg0] SEG_IP_Enc_Struct_7_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C40000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_8/s00_axi/reg0] SEG_IP_Enc_Struct_8_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C50000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_Enc_Struct_9/s00_axi/reg0] SEG_IP_Enc_Struct_9_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C60000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_PWM_Struct_0/s00_axi/reg0] SEG_IP_PWM_Struct_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C70000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_PWM_Struct_1/s00_axi/reg0] SEG_IP_PWM_Struct_1_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C80000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_PWM_Struct_2/s00_axi/reg0] SEG_IP_PWM_Struct_2_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C90000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_PWM_Struct_3/s00_axi/reg0] SEG_IP_PWM_Struct_3_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43CA0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs IP_PWM_Struct_4/s00_axi/reg0] SEG_IP_PWM_Struct_4_reg0

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port Enable -pg 1 -y 1540 -defaultsOSRD
preplace port Dir -pg 1 -y 1520 -defaultsOSRD
preplace port chan_nB_2 -pg 1 -y 560 -defaultsOSRD
preplace port Pulse_3 -pg 1 -y 2040 -defaultsOSRD
preplace port chan_A -pg 1 -y 80 -defaultsOSRD
preplace port DDR -pg 1 -y 370 -defaultsOSRD
preplace port chan_nB_3 -pg 1 -y 820 -defaultsOSRD
preplace port Pulse_4 -pg 1 -y 2230 -defaultsOSRD
preplace port chan_B -pg 1 -y 100 -defaultsOSRD
preplace port chan_nB_4 -pg 1 -y 1070 -defaultsOSRD
preplace port reset_rtl -pg 1 -y 910 -defaultsOSRD
preplace port chan_nB_5 -pg 1 -y 1300 -defaultsOSRD
preplace port chan_B_1 -pg 1 -y 300 -defaultsOSRD
preplace port chan_B_2 -pg 1 -y 520 -defaultsOSRD
preplace port Dir_1 -pg 1 -y 1730 -defaultsOSRD
preplace port Pulse -pg 1 -y 1500 -defaultsOSRD
preplace port chan_A_1 -pg 1 -y 280 -defaultsOSRD
preplace port chan_B_3 -pg 1 -y 780 -defaultsOSRD
preplace port sys_clock -pg 1 -y 890 -defaultsOSRD
preplace port Dir_2 -pg 1 -y 1890 -defaultsOSRD
preplace port chan_nA_1 -pg 1 -y 320 -defaultsOSRD
preplace port chan_B_4 -pg 1 -y 1030 -defaultsOSRD
preplace port chan_A_2 -pg 1 -y 500 -defaultsOSRD
preplace port Dir_3 -pg 1 -y 2060 -defaultsOSRD
preplace port Enable_1 -pg 1 -y 1750 -defaultsOSRD
preplace port chan_nA_2 -pg 1 -y 540 -defaultsOSRD
preplace port chan_B_5 -pg 1 -y 1240 -defaultsOSRD
preplace port chan_A_3 -pg 1 -y 760 -defaultsOSRD
preplace port Dir_4 -pg 1 -y 2250 -defaultsOSRD
preplace port Enable_2 -pg 1 -y 1910 -defaultsOSRD
preplace port chan_nA_3 -pg 1 -y 800 -defaultsOSRD
preplace port chan_nA -pg 1 -y 120 -defaultsOSRD
preplace port chan_A_4 -pg 1 -y 1010 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 390 -defaultsOSRD
preplace port Enable_3 -pg 1 -y 2080 -defaultsOSRD
preplace port chan_nA_4 -pg 1 -y 1050 -defaultsOSRD
preplace port chan_nB -pg 1 -y 140 -defaultsOSRD
preplace port chan_A_5 -pg 1 -y 1260 -defaultsOSRD
preplace port Enable_4 -pg 1 -y 2270 -defaultsOSRD
preplace port chan_nA_5 -pg 1 -y 1280 -defaultsOSRD
preplace port Pulse_1 -pg 1 -y 1710 -defaultsOSRD
preplace port chan_nB_1 -pg 1 -y 340 -defaultsOSRD
preplace port Pulse_2 -pg 1 -y 1870 -defaultsOSRD
preplace inst IP_Enc_Struct_6 -pg 1 -lvl 3 -y 60 -defaultsOSRD
preplace inst IP_Enc_Struct_7 -pg 1 -lvl 3 -y 320 -defaultsOSRD
preplace inst rst_processing_system7_0_100M -pg 1 -lvl 1 -y 130 -defaultsOSRD
preplace inst IP_Enc_Struct_10 -pg 1 -lvl 3 -y 1110 -defaultsOSRD
preplace inst IP_Enc_Struct_8 -pg 1 -lvl 3 -y 600 -defaultsOSRD
preplace inst IP_Enc_Struct_11 -pg 1 -lvl 3 -y 1360 -defaultsOSRD
preplace inst IP_Enc_Struct_9 -pg 1 -lvl 3 -y 860 -defaultsOSRD
preplace inst IP_PWM_Struct_0 -pg 1 -lvl 3 -y 1560 -defaultsOSRD
preplace inst IP_PWM_Struct_1 -pg 1 -lvl 3 -y 1730 -defaultsOSRD
preplace inst IP_PWM_Struct_2 -pg 1 -lvl 3 -y 1890 -defaultsOSRD
preplace inst IP_PWM_Struct_3 -pg 1 -lvl 3 -y 2060 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 2 -y 900 -defaultsOSRD
preplace inst IP_PWM_Struct_4 -pg 1 -lvl 3 -y 2250 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 2 -y 170 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 1 -y 460 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 1 3 NJ -160 NJ -160 NJ
preplace netloc processing_system7_0_axi_periph_M09_AXI 1 2 1 960
preplace netloc IP_PWM_Struct_0_Enable 1 3 1 NJ
preplace netloc IP_PWM_Struct_3_Pulse 1 3 1 N
preplace netloc chan_A_1_1 1 0 3 NJ 280 NJ 490 910
preplace netloc chan_nB_2_1 1 0 3 NJ 610 NJ 600 NJ
preplace netloc chan_B_2_1 1 0 3 NJ 630 NJ 630 1100
preplace netloc processing_system7_0_axi_periph_M03_AXI 1 2 1 1130
preplace netloc processing_system7_0_axi_periph_M00_AXI 1 2 1 900
preplace netloc processing_system7_0_axi_periph_M08_AXI 1 2 1 980
preplace netloc IP_PWM_Struct_3_Dir 1 3 1 N
preplace netloc IP_PWM_Struct_2_Pulse 1 3 1 N
preplace netloc processing_system7_0_axi_periph_M07_AXI 1 2 1 1000
preplace netloc processing_system7_0_M_AXI_GP0 1 1 1 510
preplace netloc IP_PWM_Struct_1_Enable 1 3 1 NJ
preplace netloc chan_nA_2_1 1 0 3 NJ 600 NJ 590 NJ
preplace netloc IP_PWM_Struct_1_Pulse 1 3 1 N
preplace netloc processing_system7_0_axi_periph_M05_AXI 1 2 1 NJ
preplace netloc IP_PWM_Struct_4_Enable 1 3 1 NJ
preplace netloc chan_nB_1_1 1 0 3 NJ 320 NJ 520 NJ
preplace netloc chan_nA_1_1 1 0 3 NJ 310 NJ 550 NJ
preplace netloc processing_system7_0_FCLK_RESET0_N 1 0 2 60 40 460
preplace netloc chan_nB_3_1 1 0 3 NJ 820 NJ 820 NJ
preplace netloc chan_nA_3_1 1 0 3 NJ 800 NJ 800 NJ
preplace netloc chan_B_4_1 1 0 3 NJ 1030 NJ 1030 NJ
preplace netloc sys_clock_1 1 0 2 NJ 890 NJ
preplace netloc processing_system7_0_axi_periph_M02_AXI 1 2 1 1140
preplace netloc IP_PWM_Struct_1_Dir 1 3 1 NJ
preplace netloc IP_PWM_Struct_0_Dir 1 3 1 NJ
preplace netloc chan_nA_1 1 0 3 NJ 0 NJ 510 NJ
preplace netloc IP_PWM_Struct_4_Pulse 1 3 1 N
preplace netloc chan_B_3_1 1 0 3 NJ 780 NJ 780 1100
preplace netloc chan_B_4 1 0 3 NJ 10 NJ 560 N
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 1 2 580 580 1090
preplace netloc processing_system7_0_axi_periph_M06_AXI 1 2 1 1020
preplace netloc IP_PWM_Struct_2_Dir 1 3 1 NJ
preplace netloc chan_A_5_1 1 0 3 NJ 1260 NJ 1260 NJ
preplace netloc chan_A_4_1 1 0 3 NJ 1010 NJ 1010 NJ
preplace netloc processing_system7_0_FIXED_IO 1 1 3 NJ -150 NJ -150 NJ
preplace netloc chan_nB_4_1 1 0 3 NJ 1070 NJ 1070 NJ
preplace netloc chan_nA_4_1 1 0 3 NJ 1050 NJ 1050 NJ
preplace netloc chan_A_4 1 0 3 NJ 30 NJ 540 N
preplace netloc clk_wiz_0_clk_out1 1 2 1 1050
preplace netloc processing_system7_0_axi_periph_M10_AXI 1 2 1 940
preplace netloc IP_PWM_Struct_3_Enable 1 3 1 N
preplace netloc chan_B_5_1 1 0 3 NJ 1240 NJ 1240 NJ
preplace netloc chan_A_3_1 1 0 3 NJ 760 NJ 760 1110
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 1 1 500
preplace netloc processing_system7_0_FCLK_CLK0 1 0 3 50 -10 550 570 1080
preplace netloc IP_PWM_Struct_4_Dir 1 3 1 NJ
preplace netloc chan_nB_5_1 1 0 3 NJ 1300 NJ 1300 NJ
preplace netloc chan_A_2_1 1 0 3 NJ 620 NJ 620 1030
preplace netloc processing_system7_0_axi_periph_M04_AXI 1 2 1 1120
preplace netloc processing_system7_0_axi_periph_M01_AXI 1 2 1 1150
preplace netloc IP_PWM_Struct_2_Enable 1 3 1 NJ
preplace netloc chan_nA_5_1 1 0 3 NJ 1280 NJ 1280 NJ
preplace netloc chan_nB_1 1 0 3 NJ 20 NJ 530 NJ
preplace netloc IP_PWM_Struct_0_Pulse 1 3 1 1400
preplace netloc chan_B_1_1 1 0 3 NJ 300 NJ 500 950
preplace netloc reset_rtl_1 1 0 3 NJ 910 NJ 840 900
levelinfo -pg 1 -10 260 740 1290 1770 -top -170 -bot 2330
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


