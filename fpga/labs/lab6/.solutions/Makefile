##
## Example GNU Makefile to automate simulation and implementation flows
## using Xilinx Vivado tools.
##
## Command line usage:
##
##   % make help
##   % make area
##   % make <target> [mode=gui|tcl|batch] [options]
##
## Examples:
##
##   % make compile [hdl=rtl/verilog.v]
##   % make build install [board=Arty|ArtyA7]
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##


#######################################
##   preamble (reserved variables)   ##
#######################################

##
## **IMPORTANT
##
## This is a fully UNIX-compliant Makefile that can run on both Linux and Windows systems.
## On Windows, please ensure that all required Linux executables are available in the search
## path from the Command Prompt. Required executables are:
##
## make.exe bash.exe mkdir.exe echo.exe rm.exe tclsh.exe
##

## 'make' extra flags
MAKEFLAGS += --warn-undefined-variables --debug

## Bash configuration (be picky and exit immediately on any error)
SHELL := bash
.SHELLFLAGS := -e -u -o pipefail -c

## default target
.DEFAULT_GOAL := help


####################################
##   example working area setup   ##
####################################

## main "scratch" working area used to run the flows (default: work/sim for simulations, work/build for implementation)
WORK_DIR := work

## additional useful "clean" directories to store input design data
RTL_DIR := rtl
SIM_DIR := bench
TCL_DIR := scripts
DOC_DIR := doc

## put non-Tcl scripts and programs into a ./bin directory (e.g. Python scripts)
BIN_DIR := bin

## flows-specific directories
IPS_DIR := cores
XDC_DIR := xdc

## extra directories
TEMP_DIR := tmp
TEST_DIR := test
LOG_DIR  := log


##########################################
##   RTL and simulation sources setup   ##
##########################################

## specify top-level RTL (this is used for implementation and firmware installation)
#RTL_TOP_MODULE := DFF
#RTL_TOP_MODULE := RippleCounter4b
RTL_TOP_MODULE := SyncCounter4b

## specify top-level testbench module (this is the target module for the xelab executable)
#SIM_TOP_MODULE := tb_DFF
#SIM_TOP_MODULE := tb_RippleCounter4b
SIM_TOP_MODULE := tb_SyncCounter4b


##
## **NOTE
##
## The Xilinx XSim simulator allows to simulate mixed-language designs (Verilog + VHDL)
## without the need of a commercial license (the free-version of other simulators such
## as ModelSim by Mentor allows to simulate Verilog-only or VHDL-only designs instead).
##


##
## specify RTL sources by hand (more in general can be Verilog + VHDL code)
##

#RTL_VLOG_SOURCES := $(RTL_DIR)/DLATCH.v $(RTL_DIR)/DFF.v
#RTL_VLOG_SOURCES := $(RTL_DIR)/RippleCounter4b.v
RTL_VLOG_SOURCES := $(RTL_DIR)/SyncCounter4b.v

#SIM_VLOG_SOURCES := $(SIM_DIR)/glbl.v $(SIM_DIR)/ClockGen.v $(SIM_DIR)/tb_DLATCH.v
#SIM_VLOG_SOURCES := $(SIM_DIR)/glbl.v $(SIM_DIR)/ClockGen.v $(SIM_DIR)/tb_DFF.v
#SIM_VLOG_SOURCES := $(SIM_DIR)/glbl.v $(SIM_DIR)/ClockGen.v $(SIM_DIR)/tb_RippleCounter4b.v
SIM_VLOG_SOURCES := $(SIM_DIR)/glbl.v $(SIM_DIR)/ClockGen.v $(SIM_DIR)/tb_SyncCounter4b.v

## if no VHDL sources, you can either comment the below variables or just leave them empty
RTL_VHDL_SOURCES :=
SIM_VHDL_SOURCES :=

## specify optional '-define' statements (Verilog-only)
VLOG_DEFINES := -define SDF_ANNOTATE


##
## or automatically find all *.(s)v and *.vhd source files
##

#
#ifneq ($(wildcard $(RTL_DIR)/*.v ),)
#   RTL_VLOG_SOURCES += $(wildcard $(RTL_DIR)/*.v )
#endif
#
#ifneq ($(wildcard $(RTL_DIR)/*.sv ),)
#   RTL_VLOG_SOURCES += $(wildcard $(RTL_DIR)/*.sv )
#endif
#
#ifneq ($(wildcard $(RTL_DIR)/*.vhd ),)
#   RTL_VHDL_SOURCES += $(wildcard $(RTL_DIR)/*.vhd )
#endif
#
#ifneq ($(wildcard $(SIM_DIR)/*.v ),)
#   SIM_VLOG_SOURCES += $(wildcard $(SIM_DIR)/*.v )
#endif
#
#ifneq ($(wildcard $(SIM_DIR)/*.sv ),)
#   SIM_VLOG_SOURCES += $(wildcard $(SIM_DIR)/*.sv )
#endif
#
#ifneq ($(wildcard $(SIM_DIR)/*.vhd ),)
#   SIM_VHDL_SOURCES += $(wildcard $(SIM_DIR)/*.vhd )
#endif
#


############################
##   gate-level netlist   ##
############################

VLOG_NETLIST := $(WORK_DIR)/build/outputs/mapped.v
#VLOG_NETLIST := $(WORK_DIR)/build/outputs/signoff.v


###################################################################
##   group together all Verilog/SystemVerilog and VHDL sources   ##
###################################################################

## RTL simulation
#VLOG_SOURCES := $(RTL_VLOG_SOURCES) $(SIM_VLOG_SOURCES)
#VHDL_SOURCES := $(RTL_VHDL_SOURCES) $(SIM_VHDL_SOURCES)

## GL simulation (optionally with SDF)
VLOG_SOURCES := $(VLOG_NETLIST) $(SIM_VLOG_SOURCES)
VHDL_SOURCES := $(SIM_VHDL_SOURCES)


##########################
##   IP sources setup   ##
##########################

##
## **IMPORTANT
##
## When you compile Xilinx IP cores both Verilog and VHDL gate-level netlists are automatically
## generated for each core. In the following we will always assume to simulate IPs using Verilog
## netlists
##

## as for HDL sources, specify IP netlists by hand or automatically search for all *netlist.v sources
# IPS_SOURCES := $(IPS_DIR)/PLL/PLL_sim_netlist.v

ifneq ($(wildcard $(IPS_DIR)/*/*sim_netlist.v ),)
   IPS_SOURCES += $(wildcard $(IPS_DIR)/*/*sim_netlist.v )
endif


################################################
##   target FPGA device and external memory   ##
################################################

board := Arty
#board := ArtyA7

## default: Artix7 on Digilent Aty/Arty A7 development boards
part  := xc7a35ticsg324-1L

## default: 128 MB Quad SPI Flash on Digilent Arty/Arty A7 development boards (but different chip IDs between Arty And Arty A7)
ifeq ($(board),Arty)
   flash := mt25ql128-spi-x1_x2_x4
else
ifeq ($(board),ArtyA7)
   flash := s25fl128sxxxxxx0-spi-x1_x2_x4
else
   $(error ERROR: Unknown board name $(board))
endif
endif


#########################
##   other variables   ##
#########################

## some useful UNIX aliases
ECHO  := echo -e
RM    := rm -f -v
RMDIR := rm -rf -v
MKDIR := mkdir -p -v


################################
##   Xilinx Vivado settings   ##
################################

## installation check
ifeq ($(shell which vivado 2> /dev/null),)
   @$(error ERROR: No 'vivado' executable found in search path! Force an exit now...)
endif 


##
## **NOTE
##
## There is no Windows equivalent for the Linux & operator to fork in background the execution of a program
## invoked at the command line. Most of Windows programs launched from the Command Prompt by default already 
## start in background leaving the shell alive. Unfortunately this is not the case for the vivado executable. 
## In order to have portable flows between Linux and Windows the proposed solution is to forward the execution
## of 'vivado -mode gui' to tclsh using the Tcl command 'exec' which accepts the usage of the & instead.
##

## by default, run Vivado/XSim flows in GUI mode
#mode ?= gui
#mode ?= tcl
mode ?= batch


##############################################
##   export variables to tclsh and Vivado   ##
##############################################

##
## **NOTE
##
## Use the strip function to avoid interpreting whitespace as a non-empty values
## in case the design uses only one HDL language.
##

## export target device and memory IDs to implementation flows
export XILINX_DEVICE=$(part)
export QFLASH_MEMORY=$(flash)

## export the chosen working directory to all flows
export WORK_DIR

## export HDL variables to xvlog/xvhdl/xelab flows
export RTL_TOP_MODULE
export SIM_TOP_MODULE

ifneq ($(strip $(RTL_VLOG_SOURCES)),)
   export RTL_VLOG_SOURCES
endif

ifneq ($(strip $(SIM_VLOG_SOURCES)),)
   export SIM_VLOG_SOURCES
endif

ifneq ($(strip $(VLOG_SOURCES)),)
   export VLOG_SOURCES
endif

ifneq ($(strip $(VLOG_DEFINES)),)
   export VLOG_DEFINES
endif

ifneq ($(strip $(RTL_VHDL_SOURCES)),)
   export RTL_VHDL_SOURCES
endif

ifneq ($(strip $(SIM_VHDL_SOURCES)),)
   export SIM_VHDL_SOURCES
endif

ifneq ($(strip $(VHDL_SOURCES)),)
   export VHDL_SOURCES
endif

ifneq ($(strip $(IPS_SOURCES)),)
   export IPS_SOURCES
endif


################################
##   targets implementation   ##
################################

##
## **NOTE
##
## Only for reference. In order to shorten the main Makefile you can also decide to move
## the implementation of all targets into flow-specific sub-makefiles and then include them
## in this Makefile.
##
## Example:
##
## include scripts/sim/Makefile.defs
## include scripts/builds/Makefile.defs etc.
##


##
## **IMPORTANT
##
## None of implemented targets are on-disk files with build dependencies!
## Declare each target as PHONY.
##


## default target (if nothing is passed to 'make' just call the 'help' target)
.PHONY : default
default : help


##
## Main help target (automatically generate Makefile documentation).
## Credits: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
##

.PHONY : help
help : ## Command line help

	@$(ECHO) ""
	@$(ECHO) "Usage: make <target> [mode=gui|tcl|batch] [variables]"
	@$(ECHO) ""
	@$(ECHO) "Available targets:"
	@$(ECHO) ""
	@grep -E '^[a-zA-Z_-|/]+ :.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "- make \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@$(ECHO) ""
	@$(ECHO) "Target Xilinx device:            $(XILINX_DEVICE)"
	@$(ECHO) "External Quad SPI Flash memory:  $(QFLASH_MEMORY)"
	@$(ECHO) ""
	@$(ECHO) "Examples:"
	@$(ECHO) ""
	@$(ECHO) "   % make compile [hdl=/path/to/verilog.v|hdl=/path/to/vhdl.vhd]"
	@$(ECHO) "   % make sim"
	@$(ECHO) "   % make build install [board=Arty|ArtyA7]"
	@$(ECHO) ""
##____________________________________________________________________________________________________


##
## working area setup
##

.PHONY : area
area : ## Create a new fresh working area with all necessary directories used in the flows

	@$(MKDIR) $(RTL_DIR)
	@$(MKDIR) $(SIM_DIR)

	@$(MKDIR) $(TCL_DIR)/common
	@$(MKDIR) $(TCL_DIR)/sim
	@$(MKDIR) $(TCL_DIR)/build
	@$(MKDIR) $(TCL_DIR)/install
	@$(MKDIR) $(TCL_DIR)/debug

	@$(MKDIR) $(BIN_DIR)

	@$(MKDIR) $(DOC_DIR)
	@$(MKDIR) $(IPS_DIR)
	@$(MKDIR) $(XDC_DIR)

	@$(MKDIR) $(WORK_DIR)/sim
	@$(MKDIR) $(WORK_DIR)/sim/log
	@$(MKDIR) $(WORK_DIR)/sim/tmp
	@$(MKDIR) $(WORK_DIR)/sim/test
	@$(MKDIR) $(WORK_DIR)/sim/vcd
	@$(MKDIR) $(WORK_DIR)/sim/wdb

	@$(MKDIR) $(WORK_DIR)/build
	@$(MKDIR) $(WORK_DIR)/build/log
	@$(MKDIR) $(WORK_DIR)/build/tmp
	@$(MKDIR) $(WORK_DIR)/build/test
	@$(MKDIR) $(WORK_DIR)/build/outputs
	@$(MKDIR) $(WORK_DIR)/build/reports

	@$(MKDIR) $(TEMP_DIR)
	@$(MKDIR) $(TEST_DIR)

	@$(ECHO) "\n   -- Working area setup completed !\n\n"
##____________________________________________________________________________________________________


##
## IP-generation target
##

## empty variable to optionally specify a Xilinx Core Instance (.xci) configuration file
xci :=

ifneq ($(xci),)
   export XCI_FILE=$(xci)
endif

.PHONY : ip
ip : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/ip.tcl ## Launch Vivado IP flow in GUI mode or compile IP from XCI file (make ip xci=/path/to/IP.xci)

ifeq ($(wildcard $(IPS_DIR)/.*),)
	@$(error ERROR: Missing IPs directory ! Run 'make area' before running the flows.)
else
ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/ip.tcl \
	   -notrace -log $(LOG_DIR)/$@.log -nojournal &" | tclsh -norc
else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/ip.tcl \
	   -notrace -log $(LOG_DIR)/$@.log -nojournal
endif
endif
##_______________________________________________________________________________________


##
## simulation targets
##

## empty variable to optionally specify a single Verilog/SystemVerilog or VHDL file to be compiled
hdl :=

ifneq ($(hdl),)
   export HDL_FILE=$(hdl)
endif

.PHONY : sim/compile
sim/compile : $(TCL_DIR)/sim/compile.tcl ## Parse and compile RTL and simulation sources

ifeq ($(wildcard $(WORK_DIR)/sim/.*),)
	@$(error ERROR: Missing simulation working area $(WORK_DIR)/sim ! Run 'make area' before running the flows.)
else
	@tclsh $(TCL_DIR)/sim/compile.tcl compile
endif
##____________________________________________________________________________________________________


.PHONY : sim/elaborate
sim/elaborate : $(TCL_DIR)/sim/elaborate.tcl ## Elaborate the design

	@tclsh $(TCL_DIR)/sim/elaborate.tcl elaborate
##____________________________________________________________________________________________________


.PHONY : sim/simulate
sim/simulate : $(TCL_DIR)/sim/simulate.tcl $(WORK_DIR)/sim/xsim.dir ## Run simulation executable

	@tclsh $(TCL_DIR)/sim/simulate.tcl simulate $(mode)
##____________________________________________________________________________________________________


.PHONY : compile
compile : sim/compile ## Alias, same as 'make sim/compile'

.PHONY : elaborate
elaborate : sim/elaborate ## Alias, same as 'make sim/elaborate'

.PHONY : simulate
simulate : sim/simulate ## Alias, same as 'make sim/simulate'

.PHONY : sim
sim : sim/compile sim/elaborate sim/simulate ## Alias, same as 'make compile elaborate simulate'
##____________________________________________________________________________________________________


.PHONY : timesim
timesim :

	@export 

##____________________________________________________________________________________________________


##
## Implementation targets (you can also run the flow step-by-step using escaped targets)
##

.PHONY : build
build : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/build.tcl ## Run the full Vivado FPGA implementation flow and generate bitstream (non-project mode)

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/build.tcl \
	   -log $(WORK_DIR)/build/log/build.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/build.tcl \
	   -log $(WORK_DIR)/build/log/build.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


.PHONY : build/import
build/import : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/import.tcl ## Design import and RTL elaboration

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/import.tcl \
	   -log $(WORK_DIR)/build/log/import.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/import.tcl \
	   -log $(WORK_DIR)/build/log/import.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


.PHONY : build/syn
build/syn : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/syn.tcl ## Mapped synthesis

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/syn.tcl \
	   -log $(WORK_DIR)/build/log/syn.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/syn.tcl \
	   -log $(WORK_DIR)/build/log/syn.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


.PHONY : syn
syn : build/syn ## Alias, same as 'make build/syn'
##_______________________________________________________________________________________


.PHONY : build/place
build/place : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/place.tcl ## Placement flow

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/place.tcl \
	   -log $(WORK_DIR)/build/log/place.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/place.tcl \
	   -log $(WORK_DIR)/build/log/place.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


.PHONY : build/route
build/route : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/route.tcl ## Routing flow

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/route.tcl \
	   -log $(WORK_DIR)/build/log/route.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/route.tcl \
	   -log $(WORK_DIR)/build/log/route.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


.PHONY : build/export
build/export : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/build/export.tcl ## Design export

ifeq ($(wildcard $(WORK_DIR)/build/.*),)
	@$(error ERROR: Missing implementation working area $(WORK_DIR)/build ! Run 'make area' before running the flows.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/export.tcl \
	   -log $(WORK_DIR)/build/log/export.log -nojournal -verbose -notrace &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/build/export.tcl \
	   -log $(WORK_DIR)/build/log/export.log -nojournal -verbose -notrace
   endif
endif
##_______________________________________________________________________________________


##
## Programming targets
##

## empty variables to optionally specify input files from the command line, either .bit/.ltx or .bin
bit :=
ltx :=
bin :=

ifneq ($(bit),)
   export BIT_FILE=$(bit)
endif

ifneq ($(ltx),)
   export LTX_FILE=$(ltx)
endif

ifneq ($(bin),)
   export BIN_FILE=$(bin)
endif


.PHONY : hw_manager
hw_manager : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/install/hw_manager.tcl ## Open Vivado Hardware Manager

ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/hw_manager.tcl -notrace \
	   -nolog -nojournal -verbose &" | tclsh -norc
else
	@vivado -mode tcl \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/hw_manager.tcl -notrace \
	   -nolog -nojournal -verbose
endif
##____________________________________________________________________________________________________


.PHONY : install
install : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/install/install.tcl ## Upload bitstream to target FPGA using Vivado Hardware Manager

ifeq ($(mode),gui)

	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/install.tcl \
	   -notrace -log $(WORK_DIR)/build/log/install.log -nojournal &" | tclsh -norc
else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/install.tcl \
	   -notrace -log $(WORK_DIR)/build/log/install.log -nojournal 
endif
##____________________________________________________________________________________________________


.PHONY : install/flash
install/flash : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/install/install_flash.tcl ## Program external Quad SPI Flash memory with FPGA configuration

ifeq ($(mode),gui)

	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/install_flash.tcl \
	   -notrace -log $(WORK_DIR)/build/log/install_flash.log -nojournal &" | tclsh -norc
else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/install/install_flash.tcl \
	   -notrace -log $(WORK_DIR)/build/log/install_flash.log -nojournal
endif
##____________________________________________________________________________________________________


##
## Other targets
##

.PHONY : gui
gui : ## Start Vivado in GUI mode and keep the shell alive

	@echo "exec vivado -mode gui &" | tclsh -norc
##____________________________________________________________________________________________________


## empty variable to optionally specify a design checkpoint (.dcp) to be restored
dcp :=

restore : ## Restore Vivado project from XML project file (.xpr) or design checkpoint (.dcp)

ifeq ($(dcp),)
	@$(error ERROR: Missing design checkpoint to be restored! Usage: 'make restore dcp=/path/to/filename.dcp'.)
else
   ifeq ($(mode),gui)
	@echo "exec vivado -mode gui \
	   -source $(TCL_DIR)/common/init.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace $(dcp) &" | tclsh -norc
   else
	@vivado -mode $(mode) \
	   -source $(TCL_DIR)/common/init.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace $(dcp)
   endif
endif
##____________________________________________________________________________________________________


##
## Cleanup targets
##

.PHONY : sim/clean
sim/clean : ## Delete ALL files from work/sim

	@$(RM)    $(WORK_DIR)/sim/*.log
	@$(RM)    $(WORK_DIR)/sim/*.jou
	@$(RM)    $(WORK_DIR)/sim/*.pb
	@$(RM)    $(WORK_DIR)/sim/*.wdb
	@$(RMDIR) $(WORK_DIR)/sim/log/*
	@$(RMDIR) $(WORK_DIR)/sim/xsim.dir
	@$(RMDIR) $(WORK_DIR)/sim/.Xil
##____________________________________________________________________________________________________


.PHONY : build/clean
build/clean : ## Delete ALL files from work/build

	@$(RMDIR) $(WORK_DIR)/build/log/*
	@$(RMDIR) $(WORK_DIR)/build/reports/*
	@$(RMDIR) $(WORK_DIR)/build/outputs/*
##____________________________________________________________________________________________________


.PHONY : clean
clean : sim/clean build/clean ## Delete ALL temporary and garbage files

	@$(RM) *.pb *.wdb *.log *.jou *.str *xpr *.xml *.bit *.bin
	@$(RMDIR) xsim.dir
	@$(RMDIR) .Xil
##____________________________________________________________________________________________________
