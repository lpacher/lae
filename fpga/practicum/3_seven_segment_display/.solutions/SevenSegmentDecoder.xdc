##
## Example implementation constraints for Verilog module SevenSegmentDecoder.
## All pin positions and electrical properties refer to the Digilent Arty
## development board.
##
## Luca Pacher - pacher@to.infn.it
## Spring 2021
##


#############################################
##   physical constraints (port mapping)   ##
#############################################

## slide swiches
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33} [get_ports {BCD[0]} ]
set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33} [get_ports {BCD[1]} ]
set_property -dict { PACKAGE_PIN C10  IOSTANDARD LVCMOS33} [get_ports {BCD[2]} ]
set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS33} [get_ports {BCD[3]} ]

## JA header mapping (200 ohm series resistor on each pin)
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports segA] ;   ## JA[1]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports segB] ;   ## JA[2]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports segC] ;   ## JA[3]
set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports segD] ;   ## JA[4]
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports segE] ;   ## JA[7]
set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports segF] ;   ## JA[8]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports segG] ;   ## JA[9]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports DP  ] ;   ## JA[10]

## general-purpose standard LEDs
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]   ; ## LD4
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]   ; ## LD5
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]   ; ## LD6
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]   ; ## LD7


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO         [current_design]
set_property CONFIG_VOLTAGE 3.3  [current_design]


############################
##   timing constraints   ##
############################

## this is a pure combinational block, only constrain a maximum delay of 10 ns between input and output ports
#set_max_delay 10 -from [all_inputs] -to [all_outputs]

## alternatively, disable timing checks from all inputs to all outputs
set_false_path -from [all_inputs] -to [all_outputs]


################################
##   additional constraints   ##
################################

##
## additional XDC statements to optimize the memory configuration file (.bin)
## to program the external 128 Mb Quad Serial Peripheral Interface (SPI) flash
## memory in order to automatically load the FPGA configuration at power-up
##

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4  [current_design]


################################
##   additional constraints   ##
################################

##
## additional XDC statements to optimize the memory configuration file (.bin)
## to program the external 128 Mb Quad Serial Peripheral Interface (SPI) flash
## memory in order to automatically load the FPGA configuration at power-up
##

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4  [current_design]

