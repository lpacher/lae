##
## A first Makefile example to automate the Xilinx XSim simulation flow.
##
## Luca Pacher - pacher@to.infn.it
## Fall 2020
##

## list of Verilog sources to be compiled
SOURCES := Inverter.v tb_Inverter.v


## top-level module (testbench)
TOP := tb_Inverter


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
#simulate :
#	@xsim -gui -tclbatch run.tcl $(TOP) -log $@.log


## same as before, but keep alive the shell under Windows!
simulate :
	@echo "exec xsim -gui -tclbatch run.tcl $(TOP) -log $@.log &" | tclsh -norc


## one-step compilation/elaboration/simulation
sim : compile elaborate simulate


## delete all log files and simulation outputs
clean :
	@$(RM) *.log *.jou *.pb *.wdb *.wcfg
	@$(RMDIR) xsim.dir .Xil


## none of the above implemented targets are on-disk files, declare them as PHONY
.PHONY : compile elaborate simulate sim clean
