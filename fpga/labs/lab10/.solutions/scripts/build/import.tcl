##
## Example design-import script for a non-project mode Vivado implementation flow.
## Creates new in-memory project, parse all RTL and IP sources and elaborate the
## design hierarchy.
##
## The script can be also executed standalone from Makefile using:
##
##    % make build/import [mode=gui|tcl|batch]
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##


################################################################
## **DEBUG
puts "\nINFO: \[TCL\] Running [file normalize [info script]]\n"
################################################################


if { [catch {


   ###################################
   ## profiling
   set tclStart [clock seconds]
   ###################################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: DESIGN IMPORT\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"


   ####################################
   ##   variables and preferences)   ##
   ####################################

   ## load common variables and preferences
   source ${scriptsDir}/common/variables.tcl
   source ${scriptsDir}/common/part.tcl

   ## load flow-specific variables and preferences
   source ${scriptsDir}/build/variables.tcl


   ##########################################################
   ##   create in-memory project (non-project mode flow)   ##
   ##########################################################

   create_project -in_memory -part ${targetXilinxDevice} ;   ## **REM: target device defined in common/part.tcl script

   set_part ${targetXilinxDevice}
   set_property top ${::env(RTL_TOP_MODULE)} [current_fileset]


   ##########################################################
   ##   RTL sources setup (project-dependent parameters)   ##
   ##########################################################

   ## **LEGACY: only for reference (now moved into Makefile)

   #
   #set RTL_RTL_VHDL_SOURCES [glob -nocomplain ${RTL_DIR}/*.vhd]
   #set RTL_RTL_VLOG_SOURCES [concat [glob -nocomplain ${RTL_DIR}/*.v] [glob -nocomplain ${RTL_DIR}/*.sv]]
   #set IP_SOURCES       [glob -nocomplain ${IPS_DIR}/*/*.xci]
   #

   ## top-level design module
   set RTL_TOP_MODULE ${::env(RTL_TOP_MODULE)} ; puts "\n**INFO: Top-level RTL module is ${RTL_TOP_MODULE}\n"


   ##
   ## Verilog/SystemVerilog sources
   ##

   set rtlVlogSources {}

   if { [info exists ::env(RTL_VLOG_SOURCES)] } {

      foreach src [split $::env(RTL_VLOG_SOURCES) " "] {

         lappend rtlVlogSources [file normalize ${src} ]
      }
   }


   ##
   ## VHDL sources
   ##

   set rtlVhdlSources {}

   if { [info exists ::env(RTL_VHDL_SOURCES)] } {

      foreach src [split $::env(RTL_VHDL_SOURCES) " "] {

         lappend rtlVhdlSources [file normalize ${src} ]
      }
   }


   ##
   ## IP sources
   ##

   set xciSources {}

   if { [info exists ::env(IPS_SOURCES)] } {

      foreach src [split $::env(IPS_SOURCES) " "] {

         ## **IMPORTANT: the "source" file specified for the IP in the Makefile is the VERILOG NETLIST, not the .xci ! Get the .xci !
         regsub "_sim_netlist.v" ${src} ".xci" src

         lappend xciSources [file normalize ${src} ]
      }
   }


   ######################################
   ##   load RTL sources into memory   ##
   ######################################

   puts "\n**INFO: Parsing RTL sources ...\n"

   if { [llength ${rtlVlogSources}] != 0 } {

      foreach src ${rtlVlogSources} {

         if { [file exists ${src}] } {

            ## SystemVerilog file (.sv) detected, use read_verilog -sv
            if { [file extension ${src} ] == ".sv" } {

               puts "Parsing SystemVerilog source file ${src} ..." ; read_verilog -sv ${src}

            } else {

               ## standard Verilog file (.v) otherwise
               puts "Parsing Verilog source file ${src} ..." ; read_verilog ${src}
            }

         ## file DOES NOT exists otherwise
         } else {

            puts "**ERROR: ${src} not found!"

            ## script failure
            exit 1
         }
      }
   }

   if { [llength ${rtlVhdlSources}] != 0 } {

      foreach src ${rtlVhdlSources} {

         if { [file exists ${src}] } {

            if { [expr [file extension ${src} ] == ".vhd" || [file extension ${src} ] == ".vhdl"] } {

               ## VHDL file (.vhd or .vhdl) detected
               puts "Parsing VHDL source file ${src} ..." ; read_vhdl -vhdl2008 ${src}

            } else {

               puts "\n**ERROR: Unknown file extension [file extension ${src} ]. Force an exit..."

               ## script failure
               exit 1
            }

         ## file DOES NOT exists otherwise
         } else {

            puts "**ERROR: ${src} not found!"

            ## script failure
            exit 1
         }
      }
   }


   #####################################
   ##   load IP sources into memory   ##
   #####################################

   puts "\n**INFO: Parsing IP sources ...\n"

   if { [llength ${xciSources}] != 0 } {

      foreach src ${xciSources} {

         puts "\n\nLoading Xilinx Core Instance (XCI) IP configuration file ${src} ..." ; read_ip ${src}

         ## verify if a design-checkpoint exists for the IP, re-compile the IP otherwise
         if { ![file exists [string map {.xci .dcp} [get_files ${src}] ]] } {

            ## re-generate output products and Out-Of Context (OOC) design checkpoint (.dcp)
            generate_target all -force -verbose [get_files ${src}]
            synth_ip -force [get_files ${src}]
         }
      }
   }


   #########################
   ##   RTL elaboration   ##
   #########################

   puts "#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n# FLOW INFO: RTL ELABORATION\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n#\n"

   ##
   ## **IMPORTANT
   ##
   ## This is not a true "synthesis" flow, Vivado just "elaborates" RTL input sources and IPs
   ## and generates a first "interpretation" of the code in form of a schematic containing
   ## the design hierarchy, along with "identifying" main functionalities implemented in the
   ## RTL such as latches/registers, simple boolean operations, buffers etc.
   ##
   ## This "RTL schematic" can be useful for debug purposes, but the actaul "mapping" of the
   ## code into real FPGA primitives comes later in the flow.
   ##


   puts "\n\n**INFO: \[TCL\] Elaborating RTL design...\n"

   ## elaborate RTL sources
   synth_design \
      -name                rtl_1                 \
      -top                 ${RTL_TOP_MODULE}     \
      -part                ${targetXilinxDevice} \
      -flatten_hierarchy   none                  \
      -rtl                                       \
      -rtl_skip_ip                               \
      -rtl_skip_constraints


   ## if running in GUI mode you can also save to PDF the RTL schematic for later debug or project documentation
   if { ${rdi::mode} eq "gui" } {

      #show_schematic [concat [get_cells] [get_ports]]
      write_schematic -force -format pdf -scope all -orientation landscape ${outputsDir}/rtl_schematic.pdf
   }

   puts "\n"
   puts "\t=============================================="
   puts "\t   DESIGN-IMPORT FLOW SUCCESSFULLY COMPLETED  "
   puts "\t=============================================="
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
   puts "\t===================================="
   puts "\t   DESIGN-IMPORT FLOW **FAILED** !  "
   puts "\t===================================="
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

      set logFile [file normalize ${logDir}/import.log] ;   ## 'make build/import' executed otherwise => import.log
   }

   puts "\n\n**ERROR \[TCL\]: Design import and elaboration flows did not complete successfully! Force an exit."
   puts "               Please review and fix all errors found in the log file.\n"

   ## script failure
   if { ${rdi::mode} eq "gui" } {

      ## keep the GUI session alive
      return -code break

   } else {

      puts "------------------------------------------------------------"
      catch {exec grep --color "^ERROR" ${logFile} >@stdout 2>@stdout}
      puts "------------------------------------------------------------\n\n"

      exit 1
   }
}
