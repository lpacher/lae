##
## Implementation constraints for the CounterBCD_4digit_display.v Verilog example.
## All pin positions and electrical properties refer to the Digilent Arty-A7
## development board.
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
## Spring 2021
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
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports clk]

## reset on BTN0
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports rst] ;   ## BTN0

## count-enable on slide switch SW0
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33}  [get_ports en] ;  ## SW0

set_property -dict {PACKAGE_PIN B8  IOSTANDARD LVCMOS33} [get_ports button] ;  ## BTN3


## JA header mapping (200 ohm series resistor on each pin)
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS33 } [get_ports segA ] ;   ## JA[1]
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports segB ] ;   ## JA[2]
set_property -dict { PACKAGE_PIN B18  IOSTANDARD LVCMOS33 } [get_ports segC ] ;   ## JA[3]
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports segD ] ;   ## JA[4]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports segE ] ;   ## JA[5]
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports segF ] ;   ## JA[6]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports segG ] ;   ## JA[7]

## anodes on JC header
set_property -dict { PACKAGE_PIN U12  IOSTANDARD LVCMOS33 } [get_ports { anode[0] } ] ;   ## JC[1]
set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports { anode[1] } ] ;   ## JC[2]
set_property -dict { PACKAGE_PIN V10  IOSTANDARD LVCMOS33 } [get_ports { anode[2] } ] ;   ## JC[3]
set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS33 } [get_ports { anode[3] } ] ;   ## JC[4]


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


##
## **WARNING
##
## The load capacitance is used during power analysis when running the report_power
## command, but it's not used during timing analysis
##
#set_load 10 [all_outputs] -verbose


############################
##   timing constraints   ##
############################

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]


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

