
set lpwd [pwd]

set scriptDir [file dirname [file normalize [info script]]] ;   #returns /path/to/lab/bin
set labDir [file normalize $scriptDir/../ ]

file mkdir $labDir/work/sim
cd $labDir/work/sim

## compile
exec xvlog $labDir/bench/tb_NormalDistribution.v -include $labDir/bench >@stdout 2>@stdout

## elaborate
exec xelab -debug all work.tb_NormalDistribution >@stdout 2>@stdout

## run simulation executable
exec echo "add_wave /*" >  run.tcl
exec echo "run all"     >> run.tcl
exec xsim -gui -tclbatch run.tcl work.tb_NormalDistribution &

cd $lpwd

