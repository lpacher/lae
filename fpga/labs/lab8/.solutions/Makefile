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
RTL_TOP_MODULE := PWM

## specify top-level testbench module (this is the target module for the xelab executable)
SIM_TOP_MODULE := tb_PWM

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

RTL_VLOG_SOURCES := $(RTL_DIR)/PWM.v $(RTL_DIR)/TickCounter.v
SIM_VLOG_SOURCES := $(SIM_DIR)/glbl.v $(SIM_DIR)/ClockGen.v $(SIM_DIR)/tb_PWM.v


## if no VHDL sources, you can either comment the below variables or just leave them empty
#RTL_VHDL_SOURCES :=
#SIM_VHDL_SOURCES :=


## specify optional '-define' statements (Verilog-only)
#VLOG_DEFINES := -define SDF_ANNOTATE


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
VLOG_SOURCES := $(RTL_VLOG_SOURCES) $(SIM_VLOG_SOURCES)
VHDL_SOURCES := $(RTL_VHDL_SOURCES) $(SIM_VHDL_SOURCES)

## GL simulation (optionally with SDF)
#VLOG_SOURCES := $(VLOG_NETLIST) $(SIM_VLOG_SOURCES)
#VHDL_SOURCES := $(SIM_VHDL_SOURCES)


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


################################
##   targets implementation   ##
################################

##
## **NOTE
##
## In order to shorten the main Makefile you can also decide to move
## the implementation of all targets into flow-specific sub-makefiles
## and then include them in this Makefile.
##

## common variables and targets
include scripts/common/Makefile.common

## simulation targets
include scripts/sim/Makefile.sim

## implementation targets
include scripts/build/Makefile.build

## programming targets
include scripts/install/Makefile.install

