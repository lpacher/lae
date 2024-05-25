##
## Implementation constraints for the PLL_wrapper.v Verilog example.
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
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]

## reset on BTN0
set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVCMOS33 } [get_ports rst]

## clock MUX selection bits
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports { sel[0] }] ;   ## SW0
set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33 } [get_ports { sel[1] }] ;   ## SW1

## PLL output clock
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports pll_clk] ;   ## JA1 - 200 ohm series resistance
#set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVCMOS33 } [get_ports pll_clk] ;   ## JB1 - NO termination resistance

## PLL locked status flag
set_property -dict { PACKAGE_PIN N17  IOSTANDARD LVCMOS33 } [get_ports pll_locked] ;   ## IO41

## **EXERCISE: drive a general-purpose standard LED to easily identify the PLL status
#set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports LED_locked] ;   ## LD4


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

## disable timing checks for all reg2out paths
set_false_path -to [all_outputs]


####################
##   exceptions   ##
####################

## force placement and routing flows to complete despite we are trying to fit 4x different clock signals into one CLB
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets bufgmux_out*]


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

