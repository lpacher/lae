
## open hardware target in JTAG mode
connect_hw_server -url localhost:3121 -verbose
open_hw_target -jtag_mode on

set jtag_chain [get_property hw_jtag [current_hw_target]]

## be sure to start from IDLE
run_state_hw_jtag RESET
run_state_hw_jtag IDLE

## move from IDLE to IRSHIFT, then shift-in the FUSE_DNA instruction (binary 110010 for standard AMD/Xilinx FPGAs)
scan_ir_hw_jtag 6 -tdi 32

## restart from IDLE
run_state_hw_jtag IDLE

## move from IDLE to DRSHIFT, then shift-in 64 bits of TDI dummy data to clock-out the 64-bits FUSE_DNA on the TDO line
set hex_dna [scan_dr_hw_jtag 64 -tdi 0000000000000000]

## move back to IDLE
run_state_hw_jtag IDLE

## display the DNA code
puts "Device FUSE_DNA: $hex_dna"

