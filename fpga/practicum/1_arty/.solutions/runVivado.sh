#!/bin/bash

#
# Example Linux Bash shell script to run the Xilinx Vivado FPGA implementation
# flow in batch (non-interactive) mode using Tcl.
#
# Command line usage:
#
#   linux% cp .solutions/runVivado.sh .
#   linux% chmod +x runVivado.sh
#   linux% ./runVivado.sh          (or simply 'source runVivado.sh' without x-permissions)
#
#
# Luca Pacher - pacher@to.infn.it
# Spring 2024
#

vivado -mode batch -source build.tcl -notrace -log build.log -nojournal
