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


## compile Verilog sources (xvlog)
compile : $(SOURCES)
	@xvlog $(SOURCES) -log $@.log


## elaborate the design (xelab)
elaborate :
	@xelab -debug all $(TOP) -log $@.log


## run the simulation (xsim)
simulate : xsim.dir/work.$(TOP)
	@echo "exec xsim -gui -tclbatch run.tcl work.$(TOP) -wdb $(TOP).wdb -log $@.log &" | tclsh -norc


## one-step compilation/elaboration/simulation
sim : compile elaborate simulate


## load waveforms into XSim GUI
waves :
	@echo "exec xsim -gui $(TOP).wdb -nolog &" | tclsh -norc


## delete all log files and simulation outputs
clean :
	@$(RM) *.log *.jou *.pb *.wdb *.wcfg
	@$(RMDIR) xsim.dir .Xil


## none of the above implemented targets are on-disk files, declare them as PHONY
.PHONY : compile elaborate simulate sim clean 
