##
## Example implementation constraints for the Inverter module. 
##
## Luca Pacher - pacher@to.infn.it
## Spring 2021
##


################################
##   electrical constraints   ##
################################

## voltage configurations
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


#############################################
##   physical constraints (port mapping)   ##
#############################################

set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports X ] ;   ## SW0
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports ZN] ;   ## LD4


############################
##   timing constraints   ##
############################

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

