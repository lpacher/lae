##
## Implementation constraints for both dac_spi_sawtooth.v and dac_spi_sine.v Verilog examples.
## All pin positions and electrical properties refer to the Digilent Arty-A7 development board.
##
## The complete .xdc for the board can be downloaded from the official Digilent GitHub repository:
##
##    https://github.com/Digilent/Arty/blob/master/Resources/XDC/Arty_Master.xdc
##
## To find actual physical locations of pins on the board, please check board schematics:
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
set_property -dict [list PACKAGE_PIN E3 IOSTANDARD LVCMOS33] [get_ports clk]

## reset on push-button
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports rst]   ; ## BTN0

## DAC configuration bits on slide switches
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports gain] ;       ## SW0
set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33 } [get_ports shutdown] ;   ## SW1

## SPI DAC signals
set_property -dict { PACKAGE_PIN G13  IOSTANDARD LVCMOS33 } [get_ports dac_csn  ] ;   ## JA1
set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS33 } [get_ports dac_sclk ] ;   ## JA2
set_property -dict { PACKAGE_PIN A11  IOSTANDARD LVCMOS33 } [get_ports dac_sdi  ] ;   ## JA3

#set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVCMOS33 } [get_ports dac_csn  ] ;   ## JB1 (no 200 ohm series resistor)
#set_property -dict { PACKAGE_PIN E16  IOSTANDARD LVCMOS33 } [get_ports dac_sclk ] ;   ## JB2 (no 200 ohm series resistor)
#set_property -dict { PACKAGE_PIN D15  IOSTANDARD LVCMOS33 } [get_ports dac_sdi  ] ;   ## JB3 (no 200 ohm series resistor)

## status LED
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports led]   ; ## LD4


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

## constrain the in2reg timing paths (assume approx. 1/2 clock period)
set_input_delay -clock clk100 2.000 [all_inputs]


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

