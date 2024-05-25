################################################################################
##
## Implementation constraints for LED_blink.v Verilog module.
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
## board reference schematics :
##
##    https://reference.digilentinc.com/_media/arty:arty_sch.pdf
##
## Luca Pacher - pacher@to.infn.it
## Spring 2020
##
################################################################################


###############
##   units   ##
###############

## just for reference, these are already default units
#set_units -time          ns
#set_units -voltage       V
#set_units -power         mW
#set_units -capacitance   pF


#############################################
##   physical constraints (port mapping)   ##
#############################################

## on-board 100 MHz clock
set_property -dict [list PACKAGE_PIN E3 IOSTANDARD LVCMOS33] [get_ports clk]

## standard LEDs
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports LED] ;   ## LD4
#set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports LED] ;   ## LD5
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports LED] ;   ## LD6
#set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports LED] ;   ## LD7

## **DEBUG: probe the divided clock at the oscilloscope
set_property -dict { PACKAGE_PIN F5  IOSTANDARD LVCMOS33 } [get_ports LED_probe] ;  ## A0 (chipKIT header)

## **EXERCISE: add an external count-enable control (e.g. slide-switch)
#set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports enable] ;   ## SW0

## **EXERCISE: drive 7-segment display module as in practicum #3 (JA header mapping with 200 ohm series resistor on each pin)
#set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports segA] ;   ## JA[1]
#set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports segB] ;   ## JA[2]
#set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports segC] ;   ## JA[3]
#set_property -dict { PACKAGE_PIN D12  IOSTANDARD LVCMOS33 } [get_ports segD] ;   ## JA[4]
#set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports segE] ;   ## JA[5]
#set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports segF] ;   ## JA[6]
#set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports segG] ;   ## JA[7]
#set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports DP  ] ;   ## JA[8]


############################
##   timing constraints   ##
############################

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]

## constrain reg2out timing paths (assume approx. 1/2 clock period)
set_output_delay -clock clk100 5.000 [all_outputs]


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

