##
## Example custom Tcl-based simulation flow to run XSim simulation flows interactively [SIMULATION step]
##
## This script is a port in Tcl (with extensions) of the default simulate.bat (simulate.sh)
## script automatically generated by Vivado when running HDL simulations is project-mode.
## The flow also supports the possibility to invoke the XSim executable from Makefile either
## in GUI mode or in tcl/batch modes in case you need to run simulations without looking
## at waveforms.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##


####################################################################################################
##
## **NOTE
##
## Vivado extensively supports scripts-based flows either in so called "project" or "non-project"
## modes. Indeed, there is no "non-project mode" Tcl simulation flow. A "non-project" simulation flow
## is actually a true "batch flow" and requires to call standalone xvlog/xvhdl, xelab and xsim executables
## from the command-line, from a shell script or inside a GNU Makefile.
##
## However in "non-project mode" the simulation can't be re-invoked from the XSim GUI using
## Run > Relaunch Simulation (or using the relaunch_sim command) after RTL or testbench changes,
## thus requiring to exit from XSim and re-build the simulation from scratch. This happens because
## the XSim standalone flow doesn't keep track of xvlog/xvhdl and xelab flows.
##
## In order to be able to "relaunch" a simulation from the GUI you necessarily have to create a project
## in Vivado or to use a "project mode" Tcl script to automate the simulation.
## The overhead of creating an in-memory project is low compared to the benefits of fully automated
## one-step compilation/elaboration/simulation and re-launch features.
##
## This **CUSTOM** Tcl-based simulation flow basically reproduces all compilation/elaboration/simulation
## steps that actually Vivado performs "under the hood" for you without notice in project-mode.
## Most important, this custom flow is **PORTABLE** across Linux/Windows systems and allows
## to "relaunch" a simulation after RTL or testbench changes from the XSim Tcl console without
## the need of creating a project.
##
## Ref. also to  https://www.edn.com/improve-fpga-project-management-test-by-eschewing-the-ide
##
####################################################################################################


proc simulate { {mode "gui"} } {


   #########################################################
   ##   simulation executable to be launched (required)   ##
   #########################################################

   ##
   ## **IMPORTANT
   ##
   ## The elaboration flow (elaborate.tcl) forces xelab to generate a simulation
   ## executable ("snapshot" according to Xilinx terminology) with the same name
   ## of the top-level module used for simulations (testbench).
   ## The SIM_TOP_MODULE environment variable exported by Makefile is therefore
   ## mandatory to run also the simulation step.
   ##

   if { [info exists ::env(SIM_TOP_MODULE)] } {

      set xelabTop ${::env(SIM_TOP_MODULE)}

   } else {

      puts "\n**ERROR \[TCL\]: Unknown top-level module from design elaboration! Force an exit.\n\n"

      ## script failure
      exit 1
   }


   #########################################
   ##   move to simulation working area   ##
   #########################################

   ## **IMPORTANT: assume to run the flow inside WORK_DIR/sim (the WORK_DIR environment variable is exported by Makefile)

   if { [info exists ::env(WORK_DIR)] } {

      cd ${::env(WORK_DIR)}/sim

   } else {


      puts "**WARN \[TCL\]: WORK_DIR environment variable not defined, assuming ./work/sim to run simulation flows."

      if { ![file exists work] } { file mkdir work/sim }
      cd work/sim
   }


   #############################################
   ##   launch the xsim executable from Tcl   ##
   #############################################

   ## log directory
   set logDir  [pwd]/../../log ; if { ![file exists ${logDir}] } { file mkdir ${logDir} }

   ## log file
   set logFile ${logDir}/simulate.log

   ## delete the previous log file if exists
   if { [file exists ${logFile}] } {

      file delete ${logFile}
   }


   ##
   ## **NOTE
   ##
   ## When you invoke the 'xsim' executable there is no '-mode' command line switch to choose
   ## between GUI, Tcl or batch modes. Without '-gui' XSim simply runs in interactive mode
   ## without the graphical interface.
   ##
   ## If you want to run a true "batch simulation" you have to use '-onfinish quit' when invoking
   ## the 'xsim' executable at the command line. In the following we propose a custom flow to
   ## keep using the 'mode' Makefile variable as used to launch Vivado.
   ##

   if { ${mode} == "gui" } {

      puts "**INFO: \[TCL\] Running simulation in GUI mode\n\n"

      exec xsim ${xelabTop} -gui -wdb ${xelabTop}.wdb \
         -onerror stop -stats -tclbatch [pwd]/../../scripts/sim/run.tcl -log ${logFile} &

   } elseif { ${mode} == "tcl" } {

      puts "**INFO: \[TCL\] Running simulation in TCL mode\n\n"

      exec xsim ${xelabTop} -wdb ${xelabTop}.wdb \
         -onerror stop -stats -tclbatch [pwd]/../../scripts/sim/run.tcl -log ${logFile} >@stdout 2>@stdout

   } elseif { ${mode} == "batch" } {

      puts "**INFO: \[TCL\] Running simulation in BATCH mode\n\n"

      exec xsim ${xelabTop} -wdb ${xelabTop}.wdb -onfinish quit \
         -onerror stop -stats -tclbatch [pwd]/../../scripts/sim/run.tcl -log ${logFile} >@stdout 2>@stdout

   } else {

      puts "\n\n**ERROR: \[TCL\] Invalid option ${mode}. Please use 'mode=gui|tcl|batch' when invoking 'make simulate' at the command line."
      puts "               Force an exit.\n\n"

      ## script failure
      exit 1
   }
}


## optionally, run the Tcl procedure when the script is executed by tclsh from Makefile
if { ${argc} > 0 } {

   if { [lindex ${argv} 0] eq "simulate" } {

      puts "\n**INFO: \[TCL\] Running [file normalize [info script]]"

      if { [llength ${argv}] == 2 } {

         set mode [lindex ${argv} 1] ;   ## mode=gui|tcl|batch specified in Makefile
         simulate ${mode}

      } else { 

         ## run in GUI mode otherwise (default)
         simulate
      }

   } else {

      ## invalid script argument, exit with non-zero error code
      puts "**ERROR \[TCL\]: Unknow option [lindex ${argv} 0]"

      ## script failure
      exit 1

   }
}
