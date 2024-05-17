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


######################
##   project name   ##
######################

set projectName {SevenSegmentDecoder}


###############################################################################
##   target project directory (the name can be different from project name)  ##
###############################################################################

#set projectDir $projectName.dir
#set projectDir [pwd]

set projectDir {.}


##############################
##   top-level RTL module   ##
##############################

set topModuleName {SevenSegmentDecoder}


###########################################################
##   target Xilinx FPGA device (Arty / Arty A7 boards)   ##
###########################################################

set targetFPGA xc7a35ticsg324-1L
