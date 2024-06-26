################################################################################
##
## Example implementation constraints for the RingOscillator.v Verilog module.
## All pin positions and electrical properties refer to the Digilent Arty-A7
## development board.
##
## Additional dont_touch and Xilinx-specific implementation constraints are
## required to properly map the inverter chain into real hardware.
##
##
## Luca Pacher - pacher@to.infn.it
## Spring 2024
##
################################################################################


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


#############################################
##   physical constraints (port mapping)   ##
#############################################

## enable/disable slide-switch
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports start] ;  # SW0

## status LED
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports led]   ;  # LD4

## auxiliary output to display 'start' also at the oscilloscope
set_property -dict { PACKAGE_PIN F5  IOSTANDARD LVCMOS33 } [get_ports start_probe] ;  # A0 (chipKIT header)

## ring oscillator output
#set_property PACKAGE_PIN G13 [get_ports clk] ;   # JA1 - 200 ohm series resistance
#set_property PACKAGE_PIN E15 [get_ports clk] ;   # JB1 - NO termination resistance
set_property PACKAGE_PIN D5  [get_ports clk] ;   # A5 (chipKIT header)

set_property IOSTANDARD LVCMOS33 [get_ports clk]


############################
##   timing constraints   ##
############################

## disable timing checks from all inputs to all outputs
set_false_path -from [all_inputs] -to [all_outputs]


####################
##   exceptions   ##
####################

#set_property DONT_TOUCH TRUE [get_nets w* ]
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets w* ]


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

