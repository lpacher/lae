############################################################################
##
## Example project-setup script containing Tcl variables common to both
## implementation (build.tcl) and programming (install.tcl) flows.
##
## Customize projectName, projectDir and topModuleName according to
## the design that you want to map on FPGA.
##
############################################################################

global projectName
global projectDir
global topModuleName
global targetFPGA
global numCpu


######################
##   project name   ##
######################

set projectName {Gates}
#set projectName {RingOscillator}


###############################################################################
##   target project directory (the name can be different from project name)  ##
###############################################################################

#set projectDir $projectName.dir
set projectDir {.}


##############################
##   top-level RTL module   ##
##############################

set topModuleName {Gates}
#set topModuleName {RingOscillator}


###########################################################
##   target Xilinx FPGA device (Arty / Arty A7 boards)   ##
###########################################################

set targetFPGA {xc7a35ticsg324-1L}


##############################
##   number of processors   ##
##############################

##
## **IMPORTANT
##
## By default Vivado implementation flows executed with the 'launch_runs' super-command
## assume to use one single CPU. The '-jobs <integer>' switch can be used to increase
## the number of parallel jobs and therefore speed-up the flow.
##
## Example:
##
## launch_runs synth_1 -jobs 4
##
## The following 'numCpu' Tcl variable can be used to specify the number of jobs according
## to the machine you are working with. Please edit and customize yourself this number
## in order to fit your laptop performance.
##

set numCpu {2}

