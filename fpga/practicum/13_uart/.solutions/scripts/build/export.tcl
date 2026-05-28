##
## Example design-export script for a non-project mode Vivado implementation flow.
## Generate FPGA and memory configuration files, export final Verilog gate-level
## netlist and back-annoted net delay (SDF) for signoff gate-level timing simulations.
##
## The script can be also executed standalone from Makefile using:
##
##    % make build/export [mode=gui|tcl|batch]
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

   if { [file exists ${outputsDir}/routed.dcp] } {

      ## if available, restore previous post-routing design-checkpoint
      open_checkpoint -verbose ${outputsDir}/routed.dcp

      #read_checkpoint ${outputsDir}/routed.dcp
      #link_design

   } else {

      ## re-run the routing flow otherwise
      puts "\n\n**WARN: ROUTED design checkpoint not found! Re-running routing flow ...\n\n"

      source ${scriptsDir}/build/route.tcl
   }
}


if { [catch {


   ###################################
   ## profiling
   set tclStart [clock seconds]
   ###################################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: EXPORT\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"


   ##############################################################################
   ##   export gate-level netlist and SDF for **SIGNOFF** timing simulations   ##
   ##############################################################################

   ##
   ## **NOTE
   ##
   ## For setting up and running GL + SDF simulations ref. to the
   ## following article:
   ##
   ##    https://support.xilinx.com/s/article/63988?language=en_US
   ##

   ## save final post-routing SDF for **SIGNOFF** gate-level simulations
   write_sdf -mode timesim -force ${outputsDir}/signoff.sdf

   set sdfFileAbsolutePath [file normalize ${outputsDir}/signoff.sdf]

   puts "Successfully generated SDF file ${sdfFileAbsolutePath}"

   ## save final post-routing Verilog netlist for **SIGNOFF** functional/timing gate-level simulations
   #write_verilog -mode timesim -sdf_anno true -force ${outputsDir}/signoff.v -sdf_file [file normalize ${outputsDir}/signoff.sdf]
   write_verilog -mode funcsim -force ${outputsDir}/signoff.v

   ##################################################################################################################
   ## **EXTRA: automatically append $sdf_annotate() task within `ifdef SDF_ANNOTATE/`endif check

   exec sed -i {/endmodule/,$d} ${outputsDir}/signoff.v ;   #deletes everything after the first 'endmodule' (match included)

   exec echo ""                                                                            >> ${outputsDir}/signoff.v
   exec echo "`ifdef SDF_ANNOTATE"                                                         >> ${outputsDir}/signoff.v
   exec echo "  initial \$sdf_annotate(\"${sdfFileAbsolutePath}\",,,,\"tool_control\");"   >> ${outputsDir}/signoff.v
   exec echo "`endif"                                                                      >> ${outputsDir}/signoff.v
   exec echo ""                                                                            >> ${outputsDir}/signoff.v
   exec echo "endmodule"                                                                   >> ${outputsDir}/signoff.v
   exec echo ""                                                                            >> ${outputsDir}/signoff.v

   ##################################################################################################################

   puts "Successfully generated Verilog netlist [file normalize ${outputsDir}/signoff.v]"


   ############################
   ##   generate bitstream   ##
   ############################

   puts "\n\nINFO: \[TCL\] Write bitsream...\n"

   ##
   ## **IMPORTANT
   ##
   ## In order to be able to write the FPGA configuration into a dedicated
   ## external memory you must generate a pure BINARY (.bin) file, not
   ## only the BIT (.bit) file.
   ##


   ## optimize the programming of the Quad SPI Flash
   set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
   set_property CONFIG_MODE SPIx4               [current_design]


   ## generate FPGA and memory configuration files
   write_bitstream \
      -verbose -force -bin_file ${outputsDir}/[get_property top [current_design]].bit


   puts "\n"
   puts "\t======================================="
   puts "\t   EXPORT FLOW SUCCESSFULLY COMPLETED  "
   puts "\t======================================="
   puts "\n"


   ###################################
   set tclStop [clock seconds]
   set seconds [expr ${tclStop} - ${tclStart} ]
   ###################################

   ## profiling
   puts "\nINFO: \[TCL\] Total elapsed-time for [file normalize [info script]]: [format "%.2f" [expr $seconds/60.]] minutes\n"

   ## normal exit
   #exit 0

## errors catched otherwise... abort the flow!
}]} {

   puts "\n"
   puts "\t============================="
   puts "\t   EXPORT FLOW **FAILED** !  "
   puts "\t============================="
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

      set logFile [file normalize ${logDir}/export.log] ;   ## 'make build/export' executed otherwise => export.log
   }

   puts "\n\n**ERROR \[TCL\]: Export flow did not complete successfully! Force an exit."
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
