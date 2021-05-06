##
## Example Tcl script to run the Vivado FPGA implementation flow in Project Mode using Tcl.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##

## profiling
set tclStart [clock seconds]


################################################
##   create Vivado project attached to Arty   ##
################################################

## top-level RTL module
set TOP  SevenSegmentDecoder

## target FPGA device
set PART xc7a35ticsg324-1L


## input sources
set RTL_SOURCES SevenSegmentDecoder.v
set XDC_SOURCES SevenSegmentDecoder.xdc

create_project -force -part ${PART} ${TOP} -verbose


##################################
##   load RTL and constraints   ##
##################################

#
# **NOTE
# By default, "sources_1", "constrs_1" and "sim_1" filesets are automatically created with the project
#

add_files \
   -norecurse -fileset sources_1 ${RTL_SOURCES}

update_compile_order -fileset sources_1

add_files \
   -norecurse -fileset constrs_1 ${XDC_SOURCES}


##############################################
##   run RTL to bitstream generation flow   ##
##############################################

##
## **IMPORTANT
##
## In order to be able to program the external Quad SPI Flash memory the raw
## binary file (.bin) must be generated along with the bitsream (.bit) !
##
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream 


## report CPU time
set tclStop [clock seconds]
set tclSeconds [expr ${tclStop} - ${tclStart} ]

puts "\nTotal elapsed-time for [file normalize [info script]]: [format "%.2f" [expr ${tclSeconds}/60.]] minutes\n"
