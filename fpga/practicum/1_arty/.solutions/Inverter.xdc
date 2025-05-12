################################################################################
##
## Example implementation constraints for the Inverter.v Verilog module. 
##
## All pin positions and electrical properties refer to the
## Digilent Arty-A7 development board.
##
## The complete .xdc for the board can be downloaded from the
## official Digilent GitHub repository at :
## 
##    https://github.com/Digilent/Arty/blob/master/Resources/XDC/Arty_Master.xdc
##
## To find actual physical locations of pins on the board, please check
## board reference schematics:
##
##    https://reference.digilentinc.com/_media/arty:arty_sch.pdf
##
##
## Luca Pacher - pacher@to.infn.it
## Spring 2021
##
################################################################################


#############################################
##   physical constraints (port mapping)   ##
#############################################

set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports X ] ;   ## SW0
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports ZN] ;   ## LD4 (standard LED)

## alternatively, each property can be specified into a single statement
#set_property PACKAGE_PIN A8       [get_ports X ]
#set_property PACKAGE_PIN H5       [get_ports X ]
#
#set_property IOSTANDARD LVCMOS33  [get_ports X ]
#set_property IOSTANDARD LVCMOS33  [get_ports ZN]
#
#set_property IOSTANDARD LVCMOS33  [concat [all_inputs] [all_outputs]]


############################
##   timing constraints   ##
############################

## this is a pure combinational block, only constrain a maximum delay of 10 ns between input and output ports
#set_max_delay 10 -from [all_inputs] -to [all_outputs] -verbose

## alternatively, disable timing checks from all inputs to all outputs
set_false_path -from [all_inputs] -to [all_outputs]


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


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

