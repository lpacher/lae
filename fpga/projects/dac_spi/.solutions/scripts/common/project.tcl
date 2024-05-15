#
# Example Tcl script to create a Vivado project. The project name is passed
# as Tcl argument when Vivado is invoked from the command line.
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#

#
# **NOTE
#
# The resulting directories tree is :
#
# ./work/impl/${projectName}.xpr 
# ./work/impl/${projectName}.cache/
# ./work/impl/${projectName}.hw/
# ./work/impl/${projectName}.ip_user_files/
# ./work/impl/${projectName}.sim/
# ./work/impl/${projectName}.srcs/
#


if { [lindex $argv 0] == {} } {

   puts "\n **ERROR: The script requires a project name !"
   puts "Please specify a project name and retry."

   ## force an exit
   exit 1

} else {

   ## project name
   set projectName [lindex $argv 0]

   ## project directory
   set projectDir  [pwd]/work/impl ; file mkdir ${projectDir}

   ## target FPGA (Digilent Arty-7 board)
   set targetFpga {xc7a35ticsg324-1L}      ; ## **NOTE: if the design uses IPs compiled targeting a specific device, the part has to match the project !

   ## create a new project
   create_project -force -part ${targetFpga} ${projectName} ${projectDir} -verbose

   puts "\nSuccessfully created new Vivado project ${projectName} attached to ${targetFpga} device."
   puts "Project XML file is [pwd]/work/impl/${projectName}.xpr\n\n"

}
