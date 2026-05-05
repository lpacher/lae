##
## Example placement script for a non-project mode Vivado implementation flow.
##
## The script can be also executed standalone from Makefile using:
##
##    % make build/place [mode=gui|tcl|batch]
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

   if { [file exists ${outputsDir}/mapped.dcp] } {

      ## if available, restore previous post-synthesis design-checkpoint
      open_checkpoint -verbose ${outputsDir}/mapped.dcp

      #read_checkpoint ${outputsDir}/mapped.dcp
      #link_design

   } else {

      ## re-run the synthesis flow otherwise
      puts "\n\n**WARN: SYNTHESIS design checkpoint not found! Re-running synthesis flow ...\n\n"

      source ${scriptsDir}/build/syn.tcl
   }
}



if { [catch {


   ###################################
   ## profiling
   set tclStart [clock seconds]
   ###################################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: PLACEMENT\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"


   ##########################
   ##   **SANITY CHECK**   ##
   ##########################

   ## placement/routing flows should be immediately ABORTED of no PACKAGE_PIN and wrong IOSTANDARD are assigned to pins!
   source ${scriptsDir}/build/drc.tcl


   ###########################################
   ##   pre-placement design optimization   ##
   ###########################################

   opt_design -remap

   report_utilization -file ${reportsDir}/post_opt_utilization.rpt


   #######################
   ##   run placement   ##
   #######################

   ## propagate clock latency through clock network to improve skew and timing results
   set_propagated_clock [all_clocks]

   place_design \
      -verbose -timing_summary

   #place_design -no_timing_driven -verbose


   ##########################
   ##   save design data   ##
   ##########################

   ## write a database for the placed design
   write_checkpoint \
      -force ${outputsDir}/placed.dcp

   ## generate post-placement reports
   report_utilization -file ${reportsDir}/post_place_utilization.rpt
   report_timing_summary -file ${reportsDir}/post_place_timing_summary.rpt

   #report_drc

   puts "\n"
   puts "\t=========================================="
   puts "\t   PLACEMENT FLOW SUCCESSFULLY COMPLETED  "
   puts "\t=========================================="
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
   puts "\t================================"
   puts "\t   PLACEMENT FLOW **FAILED** !  "
   puts "\t================================"
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

      set logFile [file normalize ${logDir}/place.log] ;   ## 'make build/place' executed otherwise => place.log
   }

   puts "\n\n**ERROR \[TCL\]: Placement flow did not complete successfully! Force an exit."
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
