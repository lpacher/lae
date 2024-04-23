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

## ring oscillator output
#set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports clk] ;   ## JA1 - 200 ohm series resistance
set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVCMOS33 } [get_ports clk] ;   ## JB1 - NO termination resistance


############################
##   timing constraints   ##
############################

## disable all timing paths
set_false_path -from [all_inputs] -to [all_outputs]


####################
##   exceptions   ##
####################

set_property DONT_TOUCH TRUE [get_nets w* ]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets w* ]
