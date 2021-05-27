
# Practicum 10
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

In this practicum you will experiment with the **Universal Asynchronous Receiver/Transmitter (UART)** protocol on real FPGA hardware.

For this purpose **two sample RTL designs** have been already prepared for you, both implementing a UART transmitter written
in Verilog HDL to **send data from the FPGA to the host computer** through the **on-board USB/UART bridge** available on the
Digilent Arty-A7 board.

The proposed two designs implement the following functionalities:

* send printable **ASCII characters** stored into a ROM through UART
* read the **on-chip temperature** by compiling a **Xilinx A/D Converter (XADC)** IP core and send temperature values through UART

<br />

All HDL and IP sources, scripts and constrains are available in the `.solutions/` directory as usual. Top-level RTL modules
are `uart_ascii.v` and `uart_xadc.v`

For this practicum, **try yourself** to:

* setup the work area
* copy all required sources and scripts from the `.solutions/` directory
* inspect RTL sources
* compile required IP cores from XCI files
* implement the designs on target FPGA
* install and debug the firmware

<br />

Once the firmware has been properly installed you can use the **PuTTY terminal emulator** to open a serial
connection and read data from the FPGA.

Display at the oscilloscope the serial output stream and compare your results with the expected
UART timing specification. For easier debug, it is recommended to trigger on the "busy" signal generated
by the UART transmitter.

Ask to the teacher if you need help.

