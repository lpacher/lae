::
:: Example Windows Command Prompt shell script to run the Xilinx Vivado FPGA implementation
:: flow in batch (non-interactive) mode using Tcl.
::
:: Command line usage:
::
::   windows% copy .solutions/runVivado.bat .
::   windows% call runVivado.bat
::
::
:: Luca Pacher - pacher@to.infn.it
:: Spring 2024
::

@echo off

vivado -mode batch -source build.tcl -notrace -log build.log -nojournal
