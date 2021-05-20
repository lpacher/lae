#
# Example Vivado init script. Use vivado -init to source the script at Vivado startup.
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#

puts "\nSourcing init file [pwd]/init.tcl\n"


##############################
##   useful Tcl variables   ##
##############################

set RTL_DIR  [pwd]/rtl
set TCL_DIR  [pwd]/scripts
set IPS_DIR  [pwd]/cores
set XDC_DIR  [pwd]/xdc

## program version
set VIVADO_VERSION [version -short]

## append system date and time to reports and saved databases
set DATE [clock format [clock seconds] -format "%Y.%m.%d_%R"]



#########################
##   custom routines   ##
#########################

## custom procedure get the command-line back if working in GUI mode
proc get_console {} {


   if { $::tcl_platform(platform) == "windows" } {

      ## star new cmd.exe prompt on Windows
      exec cmd.exe /k {$::env(USERPROFILE)/login.bat & prompt=[type exit before closing the GUI]% } &

   } else {

      ## start new bash prompt on Linux
      set ::env(PS1) {[type exit before closing the GUI]% }
      exec bash --norc &
   }
}


## custom procedure to open a new terminal in the current working directory (Command Prompt in Windows, GNOME Terminal in Linux)
proc terminal {} {

   if { $::tcl_platform(platform) == "windows" } {

      ## **WARN: exec cannot run the 'start' built-in command, use cmd /c to invoke it
      exec cmd.exe /c start cmd.exe /k "title Command Prompt & call $::env(USERPROFILE)/login.bat & cd [pwd]" &

   } else {

      exec gnome-terminal &
   }
}

