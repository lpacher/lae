##============================================================================
## Example Tcl script to program the external Quad-SPI Flash memory using
## the Vivado Hardware Manager in batch (non-interactive) mode.
##
## Command line usage:
##
##   % cp .solutions/install_flash.tcl .
##   % vivado -mode batch -source install_flash.tcl -notrace -log install_flash.log -nojournal
##
## Luca Pacher - pacher@to.infn.it
## Spring 2024
##============================================================================

## open the Hardware Manager
open_hw_manager

## "auto-connect"
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]

## identify Quad SPI Flash external memory (same as "Add Configuration Memory Device..." in the GUI)
create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev [lindex [get_cfgmem_parts {mt25ql128-spi-x1_x2_x4} ] 0] ;    #legacy Arty board, use s25fl128sxxxxxx0-spi-x1_x2_x4 for new Arty A7

## specify programming options
set_property PROGRAM.BLANK_CHECK  0 [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.ERASE        1 [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.CFG_PROGRAM  1 [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.VERIFY       1 [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.CHECKSUM     0 [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]

refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]

## specify the memory file
set_property PROGRAM.ADDRESS_RANGE           {use_file}                          [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.FILES                   {Inverter.runs/impl_1/Inverter.bit} [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION  {pull-none}                         [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]

## program the external Quad-SPI Flash memory
create_hw_bitstream -hw_device [lindex [get_hw_devices xc7a35t_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [lindex [get_hw_devices xc7a35t_0] 0]]
program_hw_devices [lindex [get_hw_devices xc7a35t_0] 0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]
program_hw_cfgmem -hw_cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a35t_0] 0]]

## close current hardware target
close_hw_target [current_hw_target]

## disconnect from hardware server
disconnect_hw_server [current_hw_server]

puts "External Quad-SPI Flash memory successfully programmed!"
