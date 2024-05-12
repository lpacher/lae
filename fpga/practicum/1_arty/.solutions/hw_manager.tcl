###########################################################################
#
# Simply launch Vivado Hardware Manager from Tcl console.
#
# Command line usage:
#
#   % cp .solutions/hw_manager.tcl .
#   % vivado -mode tcl -source hw_manager.tcl
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#
###########################################################################

## if Vivado is launched in Tcl mode, change default prompt
if { $rdi::mode == "tcl" } {

   global tcl_prompt1
   set tcl_prompt1 {puts -nonewline "hw_manager% "}
}

## **IMPORTANT: the legacy 'open_hw' Tcl command is now DEPRECATED
#open_hw_manager

