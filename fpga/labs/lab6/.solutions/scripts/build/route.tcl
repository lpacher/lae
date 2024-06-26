##
## Example routing script for a non-project mode Vivado implementation flow.
##
## The script can be also executed standalone from Makefile using:
##
##    % make build/route [mode=gui|tcl|batch]
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##


################################################################
## **DEBUG
puts "\nINFO: \[TCL\] Running [file normalize [info script]]\n"
################################################################


## save/restore flow
if { [current_project -quiet] eq "" } {

   ## load common variables and preferences
   source ${scriptsDir}/common/variables.tcl
   source ${scriptsDir}/common/part.tcl

   ## load flow-specific variables and preferences
   source ${scriptsDir}/build/variables.tcl

   if { [file exists ${outputsDir}/placed.dcp] } {

      ## if available, restore previous post-placement design-checkpoint
      open_checkpoint -verbose ${outputsDir}/placed.dcp

      #read_checkpoint ${outputsDir}/placed.dcp
      #link_design

   } else {

      ## re-run the placement flow otherwise
      puts "\n\n**WARN: PLACED design checkpoint not found! Re-running placement flow ...\n\n"

      source ${scriptsDir}/build/place.tcl
   }
}


if { [catch {


   ###################################
   ## profiling
   set tclStart [clock seconds]
   ###################################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: ROUTING\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"


   #################################################
   ##   post-placement optimization (if needed)   ##
   #################################################

   ## optionally run post-placement optimization if there are timing violations after placement
   if { [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0 } {

      puts "\n**WARN: Setup timing violations found in the design! Running post-placement optimization...\n" 

      phys_opt_design -verbose
   }


   #################
   ##   routing   ##
   #################

   ## route the design
   route_design \
      -verbose -timing_summary

   #route_design -no_timing_driven -verbose


   ##########################
   ##   save design data   ##
   ##########################

   ## write a database for the placed design
   write_checkpoint \
      -force ${outputsDir}/routed.dcp


   ## generate post-routing reports
   report_utilization \
      -file ${reportsDir}/post_routing_utilization.rpt

   report_timing_summary \
      -file ${reportsDir}/post_routing_timing_summary.rpt

   report_power \
      -file ${reportsDir}/post_routing_power.rpt

   report_drc \
      -file ${reportsDir}/post_routing_drc.rpt


   if { ${rdi::mode} eq "gui" } {

      show_schematic [concat [get_cells] [get_ports]]
      #write_schematic -force -format pdf -scope all -orientation landscape ${outputsDir}/route_schematic.pdf
   }


   puts "\n"
   puts "\t========================================"
   puts "\t   ROUTING FLOW SUCCESSFULLY COMPLETED  "
   puts "\t========================================"
   puts "\n"


   ###################################
   set tclStop [clock seconds]
   set seconds [expr ${tclStop} - ${tclStart} ]
   ###################################

   ## profiling
   puts "\n**INFO: \[TCL\] Total elapsed-time for [file normalize [info script]]: [format "%.2f" [expr $seconds/60.]] minutes.\n"

   ## normal exit
   #exit 0

## errors catched otherwise... abort the flow!
}]} {

   puts "\n"
   puts "\t=============================="
   puts "\t   ROUTING FLOW **FAILED** !  "
   puts "\t=============================="
   puts "\n"


   ###################################
   set tclStop [clock seconds]
   set seconds [expr ${tclStop} - ${tclStart} ]
   ###################################

   ## profiling
   puts "\n**INFO: \[TCL\] Total elapsed-time for [file normalize [info script]]: [format "%.2f" [expr $seconds/60.]] minutes.\n"


   if { [file exists ${logDir}/build.log] } {

      set logFile [file normalize ${logDir}/build.log] ;   ## 'make build' executed => build.log 

   } else {

      set logFile [file normalize ${logDir}/route.log] ;   ## 'make build/route' executed otherwise => route.log
   }

   puts "\n\n**ERROR \[TCL\]: Routing flow did not complete successfully! Force an exit."
   puts "               Please review and fix all errors found in the log file.\n"

   ## script failure
   if { ${rdi::mode} eq "gui" } {

      return -code break

   } else {

      puts "------------------------------------------------------------"
      catch {exec grep --color "^ERROR" ${logFile} >@stdout 2>@stdout}
      puts "------------------------------------------------------------\n\n"

      exit 1
   }
}
