##
## A first Makefile example to automate the Xilinx XSim simulation flow.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##

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

## compile Verilog sources (xvlog)
compile: $(SOURCES)
	@$(RM) compile.log
	@xvlog $(SOURCES) -log compile.log


## elaborate the design (xelab)
elaborate: compile.log
	@$(RM) elaborate.log
	@xelab -debug all work.$(TOP) -log elaborate.log


## run the simulation (xsim)
simulate: elaborate.log xsim.dir/work.$(TOP) run.tcl
	@$(RM) simulate.log
	@$(ECHO) "source -notrace run.tcl" > xsim.tcl
	@$(ECHO) "exec xsim -gui -tclbatch xsim.tcl work.$(TOP) -wdb $(TOP).wdb -log simulate.log &" | tclsh -norc


## one-step compilation/elaboration/simulation
sim: compile elaborate simulate


## load waveforms into XSim GUI
waves:
	@$(ECHO) "exec xsim -gui $(TOP).wdb -nolog &" | tclsh -norc


## delete all log files and simulation outputs
clean:
	@$(RM) *.log *.jou *.pb *.wdb *.wcfg
	@$(RMDIR) xsim.dir .Xil


## none of the above implemented targets are on-disk files, declare them as PHONY
.PHONY: compile elaborate simulate sim clean
