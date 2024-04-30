
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

