##
## Example Vivado init script. Use this script to define common variables, custom routines etc.
##
## By default Vivado loads a vivado.tcl init script placed in the working directory if invoked
## with the -init option. In order to avoid to put a .tcl file outside the scripts/ directory
## we assume to use -source instead.
##
## Luca Pacher - pacher@to.infn.it
## Spring 2020
##

puts "\nSourcing init file [file normalize [info script]]\n"


global scriptsDir ; set scriptsDir [pwd]/scripts


##############################
##   useful Tcl variables   ##
##############################

global RTL_DIR ; set RTL_DIR  [pwd]/rtl
global TCL_DIR ; set TCL_DIR  [pwd]/scripts
global IPS_DIR ; set IPS_DIR  [pwd]/cores
global XDC_DIR ; set XDC_DIR  [pwd]/xdc

## program version
set VIVADO_VERSION [version -short]

## append system date and time to reports and saved databases
set DATE [clock format [clock seconds] -format "%Y.%m.%d_%R"]


#########################
##   custom routines   ##
#########################

## custom procedure to automatically detect Vivado invocation mode
## (https://forums.xilinx.com/t5/Vivado-TCL-Community/How-to-detect-if-GUI-is-open-from-TCL/td-p/984258)
proc launch_mode {} {

   return ${rdi::mode}
}

## custom procedure to open a new terminal in the current working directory (Command Prompt in Windows, GNOME Terminal in Linux)
proc open_terminal {} {

   if { $::tcl_platform(platform) == "windows" } {

      ## **WARN: exec cannot run the 'start' built-in command, use cmd /c to invoke it
      exec cmd.exe /c start cmd.exe /k "title Command Prompt & call $::env(USERPROFILE)/login.bat & cd [pwd]" &

   } else {

      exec gnome-terminal &
   }
}

####################################################################################
## Credits: https://stackoverflow.com/questions/41737315/can-we-color-code-or-have-colored-display-for-puts-in-tcl
####################################################################################

proc puts_error { "message" } {

   ## RED text message
   puts -nonewline "\033\[1;31m"
   puts "\n**ERROR: $message\033\[0m\n"
}

proc puts_info { "message" } {

   ## GREEN text message
   puts -nonewline "\033\[0;32m"
   puts "\n**INFO: $message\033\[0m\n"
}

proc puts_warn { "message" } {

   ## YELLOW text message
   puts -nonewline "\033\[0;33m"
   puts "\n**WARN: $message\033\[0m\n"
}

proc puts_debug { "message" } {

   ## BLUE text message
   puts -nonewline "\033\[1;34m"
   puts "\n**DEBUG: $message\033\[0m\n"
}

####################################################################################

