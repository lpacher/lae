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
#set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports LED]   ; ## LD4
#set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports LED]   ; ## LD5
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports LED]   ; ## LD6
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports LED] ;   ## LD7

## **EXERCISE: probe the divided clock at the oscilloscope on pin JA1
#set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports LED]


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


############################
##   timing constraints   ##
############################

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]

## constrain the reg2out timing path (assume approx. 1/2 clock period)
set_output_delay -clock clk100 5.000 [get_ports LED]


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

