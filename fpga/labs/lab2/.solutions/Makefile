##===========================================================================
##
## Improved Makefile example to automate the Xilinx XSim simulation flow.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##
##===========================================================================

## list of Verilog sources to be compiled
SOURCES := Gates.v tb_Gates.v
#SOURCES := GatesTruthTable.v tb_Gates.v
#SOURCES := GatesPrimitives.v tb_Gates.v
#SOURCES := RingOscillator.v tb_RingOscillator.v


## top-level module (testbench)
TOP := tb_Gates
#TOP := tb_RingOscillator


## some useful aliases
RM    := rm -f -v
RMDIR := rm -rf -v
ECHO  := echo -e


## choose here if you want to run XSim in gui|tcl|batch mode
mode ?= gui
#mode ?= tcl
#mode ?= batch


################################
##   targets implementation   ##
################################

## command-line help
.PHONY: help
help:
	@$(ECHO) "\n------------------------------------"
	@$(ECHO) "\nAvailable targets:\n"
	@$(ECHO) "- help         Command-line help"
	@$(ECHO) "- compile      Parse and compile RTL and simulation sources (xvlog)"
	@$(ECHO) "- elaborate    Elaborate the design (xelab)"
	@$(ECHO) "- simulate     Run the simulation executable (xsim)"
	@$(ECHO) "- sim          Alias, same as make compile elaborate simulate"
	@$(ECHO) "- waves        Load pre-existing waveform database into simulator"
	@$(ECHO) "- clean        Clean-up the working directory\n"
	@$(ECHO) "------------------------------------\n"
##____________________________________________________________________________________________________


## compile Verilog sources (xvlog)
.PHONY: compile
compile: $(SOURCES)
	@$(RM) compile.log
	@xvlog $(SOURCES) -log compile.log
##____________________________________________________________________________________________________


## elaborate the design (xelab)
.PHONY: elaborate
elaborate: compile.log
	@$(RM) elaborate.log
	@xelab -debug all work.$(TOP) -log elaborate.log
##____________________________________________________________________________________________________


## run the simulation executable (xsim)
.PHONY: simulate
simulate: elaborate.log xsim.dir/work.$(TOP) run.tcl
	@$(RM) simulate.log
	@$(ECHO) "source -notrace run.tcl" > xsim.tcl
ifeq ($(mode),batch)
	@xsim -tclbatch xsim.tcl work.$(TOP) -wdb $(TOP).wdb -log simulate.log -onfinish quit
else ifeq ($(mode),tcl)
	@xsim -tclbatch xsim.tcl work.$(TOP) -wdb $(TOP).wdb -log simulate.log -onfinish stop
else
	@$(ECHO) "exec xsim -gui -tclbatch xsim.tcl work.$(TOP) -wdb $(TOP).wdb -log simulate.log &" | tclsh -norc
endif
##____________________________________________________________________________________________________


## one-step compilation/elaboration/simulation
.PHONY: sim
sim: compile elaborate simulate
##____________________________________________________________________________________________________


## load waveforms into XSim GUI
.PHONY: waves
waves:
	@$(ECHO) "exec xsim -gui $(TOP).wdb -nolog &" | tclsh -norc
##____________________________________________________________________________________________________


## delete all log files and simulation outputs
.PHONY: clean
clean:
	@$(RM) *.log *.jou *.pb *.wdb *.str *.txt
	@$(RMDIR) xsim.dir .Xil
##____________________________________________________________________________________________________
