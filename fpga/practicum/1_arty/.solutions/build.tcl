###########################################################################
#
# A first example Tcl script to run the Xilinx Vivado FPGA implementation
# flow in batch (non-interactive) mode using a so-called "Project Mode"
# script.
#
# Command line usage:
#
#   % cp .solutions/build.tcl .
#   % vivado -mode batch -source build.tcl -notrace -log build.log -nojournal
#
# Luca Pacher - pacher@to.infn.it
# Spring 2024
#
###########################################################################

##
## **IMPORTANT
##
## By default Vivado only outputs to the console (stdout) the log file for
## those jobs that are explicitly "waited on" with the 'wait_on_run' command.
##
## That is, you can certainly run the full flow in batch mode using a Project
## Mode Tcl script with a "single click" equivalent 
##
##    launch_runs impl_1 -to write_bitstream
##
## HOWEVER Vivado will launch the flow in background and then it will exit
## without tracing what's happening (the contents of the log files) in the
## console. 
##
## In order to get both synthesis and implementation jobs logged and traced
## in the console we have to at first launch the job with 'launch_run' and
## then to "wait" on the run with the 'wait_on_run' command.
##


## create new Vivado project targeting the Artix-7 A35T device mounted on Digilent Arty/Arty A7 boards
create_project -verbose -force -part xc7a35ticsg324-1L Inverter

## load RTL sources
add_files -norecurse -fileset sources_1 Inverter.v
update_compile_order -fileset sources_1

## load design constraints (XDC)
add_files -norecurse -fileset constrs_1 Inverter.xdc

## run RTL elaboration and mapped synthesis flows
launch_runs synth_1
wait_on_run synth_1

## setting required to also generate a raw binary file (.bin) to program the external Quad SPI Flash memory
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

## run implementation (place-and-route) flows and generate the FPGA configuration file (bitstream)
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

## just for easier installation, copy FPGA and memory configuration files into the current working directory
if { [file exists Inverter.runs/impl_1/Inverter.bit] } { file copy -force Inverter.runs/impl_1/Inverter.bit [pwd]/Inverter.bit }
if { [file exists Inverter.runs/impl_1/Inverter.bin] } { file copy -force Inverter.runs/impl_1/Inverter.bin [pwd]/Inverter.bin }

puts "FPGA implementation flow completed!"

## **OPTIONAL: run also the firmware-installation flow from the main Vivado Tcl build script
#source install.tcl

