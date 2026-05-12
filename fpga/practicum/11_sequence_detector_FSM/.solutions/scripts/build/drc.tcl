################################################################################
##
## Example Tcl script to run a custom Design Rule Check (DRC) during the FPGA
## implementation flow in Xilinx Vivado.
##
## This custom check searches for unconstrained I/O ports and rises and error
## in case top-level RTL I/O ports have been not assigned to a physical FPGA
## pin (that is, if the PACKAGE_PIN property is missing for >= 1 ports).
##
## Luca Pacher - pacher@to.infn.it
## Spring 2024
## 
################################################################################


set_property SEVERITY {Error} [get_drc_checks UCIO-1]

proc report_unconstrained_io {} {

   ## this Tcl list should remain EMPTY if no unconstrained I/O are detected! 
   set uio {}

   ## loop over all top-level RTL ports and check the PACKAGE_PIN property
   foreach p [get_ports] {

      if { [get_property PACKAGE_PIN [get_ports $p]] eq "" } {

         lappend uio $p

         puts "ERROR \[TCL\]: Top-level port $p has no PACKAGE_PIN physical mapping!"
      }
   }

   if { [llength $uio] >= 1 } {

      ## generate DRC report
      report_drc -checks {UCIO-1}

      puts "\n\n**ERROR \[TCL\]: Unconstrained I/O ports detected! Force an exit now."
      puts "               Please review and fix the XDC file.\n"

      ## script failure
      return -code error
   }
}


## run the custom check
report_unconstrained_io
