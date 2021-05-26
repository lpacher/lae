
# Final project

The goal of your final project is to generate a **sawtooth waveform** using a commmercial
D/A converter controlled by FPGA.

The proposed device is a **MCP4821 12-bit D/A converter** by Microchip. You can find the
datasheet with all required information in the `doc/datasheets/` directory. The DAC uses
the **Serial Peripheral Interface (SPI)** protocol to load 12-bit input words converted
into an analog voltage.

Copy a previous `Makefile` and all required scripts from another practicum and set up a
suitable working area, then proceed as follows:

* write yourself the RTL code required to control the DAC in order to generate a free-running sawtooth waveform
* verify with a suitable testbench the proper functionality of the implemented SPI protocol
* write yourself Xilinx Design Constraints (XDC) and implement the design on real FPGA hardware
* build the circuit on breadboard and install the FPGA firmware
* debug your results at the oscilloscope

