############################################################################
##
## Improved example Tcl script to run the Xilinx Vivado FPGA implementation
## flow in batch (non-interactive) mode using a so-called "Project Mode"
## script.
##
## Command line usage:
##
##   % cp .solutions/build.tcl .
##   % vivado -mode batch -source build.tcl -notrace -log build.log -nojournal
##
## Luca Pacher - pacher@to.infn.it
## Spring 2024
##
############################################################################

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


###################################
## profiling
set tclStart [clock seconds]
###################################


#######################
##   project setup   ##
#######################

#set projectName    {Gates}
#set projectDir     {.}
#set topModuleName  {Gates}
#set targetFPGA     {xc7a35ticsg324-1L}
#set numCpu         {4}

## load global variables common to both FPGA implementation and programming flows from external Tcl script
#source [pwd]/setup.tcl

if { [file exists [pwd]/setup.tcl] } {

   source [pwd]/setup.tcl

} else {

   puts "\n**ERROR \[TCL\]: Project setup script not found! Force an exit.\n"

   ## script failure
   exit 1
}

## CPU setup
set_param general.maxThreads $numCpu


########################################################################
##   create new Vivado project attached to Artix-7 A35T FPGA device   ##
########################################################################

## create new Vivado project targeting the Artix-7 A35T device mounted on Digilent Arty/Arty A7 boards
create_project -verbose -force -part $targetFPGA $projectName $projectDir

## load RTL sources
add_files -norecurse -fileset sources_1 $topModuleName.v
update_compile_order -fileset sources_1

## load design constraints (XDC)
add_files -norecurse -fileset constrs_1 $topModuleName.xdc


########################################################
##   run RTL elaboration and mapped synthesis flows   ##
########################################################

launch_runs synth_1 -jobs $numCpu
wait_on_run synth_1


## **SANITY CHECK
if { [get_property PROGRESS [get_runs synth_1]] != "100%" } {

   puts "\n\n**ERROR \[TCL\]: RTL elaboration and mapped synthesis flows did not complete successfully! Force an exit."
   puts "               Please review and fix the following errors found in the log file.\n"

   puts "------------------------------------------------------------"
   catch {exec grep --color "^ERROR" build.log >@stdout 2>@stdout}
   puts "------------------------------------------------------------\n\n"

   ## script failure
   exit 1
}


############################################################################
##
## **EXTRA
##
## Save post-synthesis Verilog netlist (write_verilog) and SDF (write_sdf)
## for gate-level functional and timing simulations.
##
## Please note that before executing write_verilog/write_sdf commands
## from a Project Mode Tcl script the design has to be "open" using
## the 'open_run' command (same as "Open Synthesized Design" or
## "Open Implemented Design" in the GUI flow).
##
############################################################################

open_run synth_1 -name synth_1

write_verilog -force $projectDir/$projectName.runs/synth_1/mapped.v
write_sdf -force $projectDir/$projectName.runs/synth_1/mapped.sdf

close_design


#######################################################################################################
## run implementation (place-and-route) flows and generate the FPGA configuration file (bitstream)   ##
#######################################################################################################

## setting required to also generate a raw binary file (.bin) to program the external Quad SPI Flash memory
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream -jobs $numCpu
wait_on_run impl_1


## **SANITY CHECK
if { [get_property PROGRESS [get_runs impl_1]] != "100%" } {

   puts "\n\n**ERROR \[TCL\]: Implementation and bitstream generation flows did not complete successfully! Force an exit."
   puts "               Please review and fix the following errors found in the log file.\n"

   puts "------------------------------------------------------------"
   catch {exec grep --color "^ERROR" build.log >@stdout 2>@stdout}
   puts "------------------------------------------------------------\n\n"

   ## script failure
   exit 1
}


## just for easier installation, copy FPGA and memory configuration files into the current working directory
if { [file exists $projectDir/$projectName.runs/impl_1/$topModuleName.bit] } {

   file copy -force $projectDir/$projectName.runs/impl_1/$topModuleName.bit [pwd]/$topModuleName.bit
}

if { [file exists $projectDir/$projectName.runs/impl_1/$topModuleName.bin] } {

   file copy -force $projectDir/$projectName.runs/impl_1/$topModuleName.bin [pwd]/$topModuleName.bin
}


##################################################
set tclStop [clock seconds]
set tclSeconds [expr ${tclStop} - ${tclStart} ]
##################################################

## report CPU time
puts "\n**INFO \[TCL\]: Total elapsed-time for [file normalize [info script]]: [format "%.2f" [expr ${tclSeconds}/60.]] minutes\n"


## **OPTIONAL: run also the firmware-installation flow from the main Vivado Tcl build script
#source install.tcl

