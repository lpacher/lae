##===========================================================================
##
## A first Makefile example to automate the Xilinx XSim simulation flow.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##
##===========================================================================

## list of Verilog sources to be compiled
SOURCES := Inverter.v tb_Inverter.v


## top-level module (testbench)
TOP := tb_Inverter


## some useful aliases
RM    := rm -f -v
RMDIR := rm -rf -v


## compile Verilog sources (xvlog)
compile : $(SOURCES)
	@xvlog $(SOURCES) -log compile.log


## elaborate the design (xelab)
elaborate: compile.log
	@xelab -debug all work.$(TOP) -log elaborate.log


## run the simulation (xsim)
#simulate: elaborate.log xsim.dir/work.$(TOP)
#	@xsim -gui -tclbatch run.tcl work.$(TOP) -log $@.log


## same as before, but keep alive the shell under Windows!
simulate: elaborate.log xsim.dir/work.$(TOP) run.tcl
	@echo "source -notrace run.tcl" > xsim.tcl
	@echo "exec xsim -gui -tclbatch xsim.tcl work.$(TOP) -wdb $(TOP).wdb -log simulate.log &" | tclsh -norc


## one-step compilation/elaboration/simulation
sim: compile elaborate simulate


## load waveforms into XSim GUI
waves:
	@echo "exec xsim -gui $(TOP).wdb -nolog &" | tclsh -norc


## delete all log files and simulation outputs
clean:
	@$(RM) *.log *.jou *.pb *.wdb *.str
	@$(RMDIR) xsim.dir .Xil


## none of the above implemented targets are on-disk files, declare them as PHONY
.PHONY : compile elaborate simulate sim clean
