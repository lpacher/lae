###########################################################################
#
# Example Tcl script to run the FPGA firmware installation flow using
# the Vivado Hardware Manager in batch (non-interactive) mode.
#
# Command line usage:
#
#   % cp .solutions/install.tcl .
#   % vivado -mode batch -source install.tcl -notrace -log install.log -nojournal
#
# Luca Pacher - pacher@to.infn.it
# Spring 2024
#
###########################################################################


## open the Hardware Manager
open_hw_manager

## "auto-connect"
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]

## specify the bitstream file
set_property PROGRAM.FILE {Inverter.runs/impl_1/Inverter.bit} [get_hw_devices xc7a35t_0]

## empty entries
set_property PROBES.FILE {} [get_hw_devices xc7a35t_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7a35t_0]

## program the FPGA
program_hw_devices [get_hw_devices xc7a35t_0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]

puts "FPGA successfully programmed!"
