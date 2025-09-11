############################################################################
##
## Improved Tcl script to run the FPGA firmware installation flow using
## the Vivado Hardware Manager in batch (non-interactive) mode.
##
## Command line usage:
##
##   % cp .solutions/install.tcl .
##   % vivado -mode batch -source install.tcl -notrace -log install.log -nojournal
##
## Luca Pacher - pacher@to.infn.it
## Spring 2024
##
############################################################################


## source global variables
source [pwd]/setup.tcl

## programming files (bitstream and raw-binary for the external Quad SPI Flash memory)
set bitFile ${projectDir}/${projectName}.runs/impl_1/${topModuleName}.bit
set binFile ${projectDir}/${projectName}.runs/impl_1/${topModuleName}.bin


## **SANITY CHECK
if { ![file exists $bitFile] } {

   puts "\n\n**ERROR \[TCL\]: $bitFile no such file or directory. Force an exit.\n\n"

   ## script failure
   exit 1
}


###################################
## profiling
set tclStart [clock seconds]
###################################


## open the Hardware Manager
open_hw_manager

## "auto-connect"
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]

## specify the bitstream file
set_property PROGRAM.FILE $bitFile [get_hw_devices xc7a35t_0]

## empty entries
set_property PROBES.FILE {} [get_hw_devices xc7a35t_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7a35t_0]

## program the FPGA
program_hw_devices [get_hw_devices xc7a35t_0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]


##################################################
set tclStop [clock seconds]
set tclSeconds [expr ${tclStop} - ${tclStart} ]
##################################################

## report CPU time
puts "\n**INFO \[TCL\]: Total elapsed-time for [file normalize [info script]]: [format "%.2f" [expr ${tclSeconds}/60.]] minutes\n"

