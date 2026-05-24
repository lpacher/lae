
## open target (same as "Auto Connect")
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]

## get DNA from high-level property
set fuse_dna [get_property REGISTER.EFUSE.FUSE_DNA [current_hw_device]]

## display the DNA code
puts "Device FUSE_DNA: $fuse_dna"
