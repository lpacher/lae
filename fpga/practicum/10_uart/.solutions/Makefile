#
# Sample Makefile to test tools installation and setup.
#
# Luca Pacher - pacher@to.infn.it
# May 8, 2020
#

#######################################
##   preamble (reserved variables)   ##
#######################################

#
# **IMPORTANT
#
# This is a fully UNIX-compliant Makefile that can run on both Linux and Windows systems.
# On Windows, please ensure that all required Linux executables are available in the search
# path from the Command Prompt. Required executables are :
#
# make.exe bash.exe mkdir.exe echo.exe rm.exe tclsh.exe
#


## 'make' extra flags
MAKEFLAGS += --warn-undefined-variables --debug

## Bash configuration (be picky and exit immediately on any error)
SHELL := bash
.SHELLFLAGS := -e -u -o pipefail -c



##############################
##   top-level RTL module   ##
##############################

#
# **NOTE
#
# By default all rtl/*.v and bench/*.v sources are parsed and compiled using xvlog,
# then tb_$(dut) is considered as testbench module when xelab is invoked for elaboration.
#

## for simulation
dut := uart_tx

## for implementation
#dut := xadc_uart_tx




############################
##   working area setup   ##
############################

## main "scratch" working area used to run the flows (work/sim for simulations, work/impl for implementation)
WORK_DIR := work


## additional useful "clean" directories to store input design data
RTL_DIR := rtl
SIM_DIR := bench
TCL_DIR := scripts
LOG_DIR := logs

## put non-Tcl scripts and programs into a ./bin directory (e.g. Python scripts)
BIN_DIR := bin

## flows-specific directories
IPS_DIR := cores
XDC_DIR := xdc
SDF_DIR := sdf
RPT_DIR := reports

## extra directories
TEMP_DIR := tmp
TEST_DIR := test


## some useful UNIX aliases
ECHO  := echo -e
RM    := rm -f -v
RMDIR := rm -rf -v
MKDIR := mkdir -p -v


################################
##   Xilinx Vivado settings   ##
################################

## by default, run in Tcl mode (faster, then call start_gui from Tcl scripts when GUI is needed)
mode ?= tcl
#mode=gui


################################
##   targets implementation   ##
################################


## default target
.PHONY : default
default : help


## creates a new fresh working area with all necessary directories used in the flows
.PHONY : area
area :

	@$(MKDIR) $(RTL_DIR)
	@$(MKDIR) $(SIM_DIR)
	@$(MKDIR) $(TCL_DIR)/common
	@$(MKDIR) $(TCL_DIR)/sim
	@$(MKDIR) $(TCL_DIR)/impl
	@$(MKDIR) $(LOG_DIR)
	@$(MKDIR) $(IPS_DIR)
	@$(MKDIR) $(XDC_DIR)
	@$(MKDIR) $(SDF_DIR)
	@$(MKDIR) $(RPT_DIR)
	@$(MKDIR) $(BIN_DIR)
	@$(MKDIR) $(WORK_DIR)/sim
	@$(MKDIR) $(WORK_DIR)/impl

	@$(MKDIR) $(TEMP_DIR)
	@$(MKDIR) $(TEST_DIR)


	@$(ECHO) "\n   -- Working area setup completed !\n\n"
##_______________________________________________________________________________________


## parse and compile all Verilog sources
.PHONY : compile
compile : $(WORK_DIR)/sim

	@cd $(WORK_DIR)/sim ; tclsh ../../scripts/sim/$@.tcl
##_______________________________________________________________________________________


## elaborate the design
.PHONY : elaborate
elaborate :

	@cd $(WORK_DIR)/sim ; export RTL_TOP_MODULE=$(dut) ; tclsh ../../scripts/sim/$@.tcl
##_______________________________________________________________________________________


## run simulation executable
.PHONY : simulate
simulate :

	@cd $(WORK_DIR)/sim ; export RTL_TOP_MODULE=$(dut) ; tclsh ../../scripts/sim/$@.tcl
##_______________________________________________________________________________________


## one-step compilation, elaboration and simulation (same as make compile elaborate simulate)
.PHONY : sim
sim : compile elaborate simulate
##_______________________________________________________________________________________


## create fresh Vivado project attached to Arty7 device
.PHONY : project
project : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/project.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace -tclargs $(dut)
##_______________________________________________________________________________________


## restore Vivado project from XML project file (.xpr) or design checkpoint (.dcp)
restore : 

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace $(db) 
##_______________________________________________________________________________________


## launch IP flow in GUI mode
.PHONY : ip
ip : cores $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/ip.tcl

	@vivado -mode gui -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal
##_______________________________________________________________________________________


## run Vivado FPGA implementation flow in non-project mode
.PHONY : xflow
xflow : $(WORK_DIR)/impl $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/xflow.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace -tclargs $(dut)
##_______________________________________________________________________________________


## alias, same as 'make xflow'
.PHONY : bit
bit : xflow
##_______________________________________________________________________________________


## launch Vivado GUI and open the Hardware Manager
.PHONY :
hm : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/hm.tcl

	@vivado -mode gui -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal
##_______________________________________________________________________________________


## upload bitstream to target FPGA using Hardware Manager
.PHONY : upload
upload : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/upload.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal -tclargs $(dut)
##_______________________________________________________________________________________


## program external Quad Flash memory
.PHONY : flash
flash : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/flash.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal -tclargs $(dut)
##_______________________________________________________________________________________


## delete all log files and temporary files
.PHONY : clean
clean :

	@$(RM) *.log *.jou *.pb *.wdb $(LOG_DIR)/*
	@$(RMDIR) xsim.dir .Xil
	@$(RMDIR) work/sim/*
	@$(RMDIR) work/impl/*
##_______________________________________________________________________________________


## command line help 
.PHONY : help
help :

	@$(ECHO) ""
	@$(ECHO) "\nUsage: make <target> [dut=ModuleName] [mode=gui|tcl|batch] [db=/path/to/project.xpr | db=/path/to/project.dcp]"
	@$(ECHO) ""
	@$(ECHO) "Available targets:"
	@$(ECHO) ""
	@$(ECHO) " - make help        Command-line help"
	@$(ECHO) " - make area        Creates new fresh working area"
	@$(ECHO) " - make compile     Parse and compile Verilog sources"
	@$(ECHO) " - make elaborate   Elaborate design" 
	@$(ECHO) " - make simulate    Run simulation executable"
	@$(ECHO) " - make sim         Alias, one step compilation, elaboration and simulation"
	@$(ECHO) " - make project     Creates new fresh project attached to Arty7 device"
	@$(ECHO) " - make restore     Restore Vivado project from XML project file (.xpr) or design checkpoint (.dcp)"
	@$(ECHO) " - make ip          Customize and compile IP cores for your design"
	@$(ECHO) " - make xflow       Run Vivado FPGA implementation flow in non-project mode"
	@$(ECHO) " - make bit         Alias, same as make xflow"
	@$(ECHO) " - make hm          Launch Vivado in GUI mode and open the Hardware Manager"
	@$(ECHO) " - make upload      Upload bitsream to target FPGA using Hardware Manager"
	@$(ECHO) " - make flash       Program external Quad Flash memory" 
	@$(ECHO) " - make clean       Delete all log files and temporary files\n"
##_______________________________________________________________________________________

