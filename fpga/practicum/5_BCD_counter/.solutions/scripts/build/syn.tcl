##
## Example synthesis script for a Non-Project Mode Vivado implementation flow.
## Parse all Xilinx Design Constraints (XDC) files and map the RTL into real
## FPGA device primitives. At the end of the flow save a design-checkpoint
## of the design for later restore and debug.
##
## The script can be also executed standalone from Makefile using:
##
##    % make build/syn [mode=gui|tcl|batch]
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

   ## **WARN: you can't save a "checkpoint" until the design is synthesized, thus no .dcp database to restore here
   source ${scriptsDir}/build/import.tcl
}


if { [catch {


   ###################################
   ## profiling
   set tclStart [clock seconds]
   ###################################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: SYNTHESIS\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"


   ##################################
   ##   parse design constraints   ##
   ##################################

   puts "\n-- Parsing design constraints..."

   if { [llength [glob -nocomplain [pwd]/xdc/*.xdc]] != 0 } {

      foreach src [glob -nocomplain [pwd]/xdc/*.xdc] {

         puts "\n\nLoading Xilinx Design Constraint (XDC) source file ${src} ...\n" ; read_xdc -unmanaged ${src}
      }

   } else {

      puts "\nERROR: No constraints specified for FPGA implementation! Force an exit."

      ## script failure
      return -code error
   }


   ##########################
   ##   mapped synthesis   ##
   ##########################

   ## synthesize the design
   synth_design \
      -top                 ${RTL_TOP_MODULE}     \
      -part                ${targetXilinxDevice} \
      -flatten_hierarchy   full                  \
      -name                syn_1



   #########################################
   ##   generate post-synthesis reports   ##
   #########################################

   ## utilization report
   report_utilization -file ${reportsDir}/post_syn_utilization.rpt

   ## timing-summary report
   report_timing_summary -max_paths 100 -warn_on_violation -file ${reportsDir}/post_syn_timing_summary.rpt


   ####################################
   ##   save synthesis output data   ##
   ####################################

   ##
   ## **NOTE
   ##
   ## For setting up and running GL + SDF simulations ref. to the
   ## following article:
   ##
   ##    https://support.xilinx.com/s/article/63988?language=en_US
   ##

   ## save post-synthesis SDF for post-synthesis gate-level simulations
   write_sdf -mode timesim -force ${outputsDir}/mapped.sdf

   set sdfFileAbsolutePath [file normalize ${outputsDir}/mapped.sdf]
   puts "Successfully generated SDF file ${sdfFileAbsolutePath}"

   ## save post-synthesis Verilog netlist for post-synthesis functional/timing gate-level simulations
   #write_verilog -mode timesim -sdf_anno true -force ${outputsDir}/mapped.v -sdf_file [file normalize ${outputsDir}/mapped.sdf]
   write_verilog -mode funcsim -force ${outputsDir}/mapped.v

   ##################################################################################################################
   ## **EXTRA: automatically append $sdf_annotate() task within `ifdef SDF_ANNOTATE/`endif check

   exec sed -i {/endmodule/,$d} ${outputsDir}/mapped.v ;   #deletes everything after the first 'endmodule' (match included)

   exec echo ""                                                                            >> ${outputsDir}/mapped.v
   exec echo "`ifdef SDF_ANNOTATE"                                                         >> ${outputsDir}/mapped.v
   exec echo "  initial \$sdf_annotate(\"${sdfFileAbsolutePath}\",,,,\"tool_control\");"   >> ${outputsDir}/mapped.v
   exec echo "`endif"                                                                      >> ${outputsDir}/mapped.v
   exec echo ""                                                                            >> ${outputsDir}/mapped.v
   exec echo "endmodule"                                                                   >> ${outputsDir}/mapped.v
   exec echo ""                                                                            >> ${outputsDir}/mapped.v

   ##################################################################################################################

   puts "Successfully generated Verilog netlist [file normalize ${outputsDir}/mapped.v]"

   ## write a database for the synthesized design
   write_checkpoint -force ${outputsDir}/mapped.dcp

   ## if running in GUI mode, save to PDF the gate-level schematic for later debug or project documentation
   if { ${rdi::mode} eq "gui" } {

      show_schematic [concat [get_cells] [get_ports]]
      write_schematic -force -format pdf -scope all -orientation landscape ${outputsDir}/syn_schematic.pdf
   }

   puts "\n"
   puts "\t=========================================="
   puts "\t   SYNTHESIS FLOW SUCCESSFULLY COMPLETED  "
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
   puts "\t   SYNTHESIS FLOW **FAILED** !  "
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

      set logFile [file normalize ${logDir}/syn.log] ;   ## 'make build/syn' executed otherwise => syn.log
   }

   puts "\n\n**ERROR \[TCL\]: Mapped synthesis flow did not complete successfully! Force an exit."
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
