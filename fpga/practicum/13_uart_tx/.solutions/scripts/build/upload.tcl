
#-----------------------------------------------------------------------------------------------------
#                               University of Torino - Department of Physics
#                                   via Giuria 1 10125, Torino, Italy
#-----------------------------------------------------------------------------------------------------
# [Filename]       upload.tcl
# [Project]        Advanced Electronics Laboratory course
# [Author]         Luca Pacher - pacher@to.infn.it
# [Language]       Tcl/Xilinx Vivado Tcl commands
# [Created]        May 18, 2020
# [Modified]       -
# [Description]    Standalone bitstream download script using Xilinx Vivado Hardware Manager Tcl commands
# [Notes]          The script is executed with:
#
#                     linux% make upload
#
#                  Alternatively, source the script at the Vivado command prompt:
#
#                     vivado% source ./scripts/impl/upload.tcl
#
# [Version]        1.0
# [Revisions]      18.05.2020 - Created
#-----------------------------------------------------------------------------------------------------


if { [lindex $argv 0] == {} } {

   puts "\n **ERROR: The script requires a top-level module !"
   puts "Please specify top-level module name and retry."

   ## force an exit
   exit 1

} else {

   ## top-level design module
   set RTL_TOP_MODULE  [lindex $argv 0] ; puts "\n**INFO: Top-level RTL module is ${RTL_TOP_MODULE}\n"

}


cd work/impl

## bitstream file
set OUT_DIR  [pwd]/results
set BITFILE  ${OUT_DIR}/bitstream/${RTL_TOP_MODULE}.bit


## server setup (local machine) 
set SERVER   localhost
set PORT     3121


## connect to the server
open_hw
connect_hw_server -url ${SERVER}:${PORT} -verbose
puts "Current hardware server set to [get_hw_servers]"


## specify target FPGA
## manually
#current_hw_target  [get_hw_targets */xilinx_tcf/Digilent/210319788446A]

## automatically
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]


## specify bitstream file
set_property  PROGRAM.FILE  ${BITFILE}  [lindex [get_hw_devices] 0]


## specify JTAG TCK frequency (Hz)
#set_property  PARAM.FREQUENCY  125000  [get_hw_targets */xilinx_tcf/Digilent/210319788783A]


## download the firmware to target FPGA
program_hw_devices  [lindex [get_hw_devices] 0]


## terminate the connection when done
disconnect_hw_server  [current_hw_server]

