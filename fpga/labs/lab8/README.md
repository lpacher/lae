
# Lab 8 Instructions
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/labs)]

## Contents

* [**Introduction**](#introduction)
* [**Lab aims**](#lab-aims)
* [**Navigate to the lab directory**](#navigate-to-the-lab-directory)
* [**Setting up the work area**](#setting-up-the-work-area)
* [**Copy simulation scripts**](#copy-simulation-scripts)
* [**RTL coding**](#rtl-coding)
* [**Simulate the design**](#simulate-the-design)
* [**Implement the design on target FPGA**](#implement-the-design-on-target-fpga)
* [**Exercises**](#exercises)
* [**Further readings**](#further-readings)

<br />
<!--------------------------------------------------------------------->

## Introduction
[**[Contents]**](#contents)

In this lab we implement a **parameterizable Pulse-Width Modulation (PWM) generator** using a simple free-running counter and a binary comparator in Verilog.
This is the "digital" equivalent of feeding to an analog comparator (e.g. an operational amplifier working in open-loop configuration) a sowtooth waveform
compared with a fixed DC threshold voltage to generate a **variable duty-cycle square wave**.

The PWM technique is very popular in electronics. As an example it can be used to:

* implement a 1-bit D/A converter to generate a programmable DC voltage
* generate sinusoidal or sowtooth waveforms
* control DC motors
* control switching power regulators

You will also play with PWM using _Arduino_ in the second part of the course.

<br />
<!--------------------------------------------------------------------->


## Lab aims
[**[Contents]**](#contents)

This lab should exercise the following concepts:

* understand the working principle of Pulse Width Modulation (PWM)
* introduce the Verilog replication operator
* implement a binary comparator in Verilog
* learn how to pre-place and configure I/O buffers in RTL

<br />
<!--------------------------------------------------------------------->


## Navigate to the lab directory
[**[Contents]**](#contents)

Open a **terminal** window and change to the `lab8/` directory:

```
% cd Desktop/lae/fpga/labs/lab8
```

<br />

List the content of the directory:

```
% ls -l
% ls -la
```

<br />
<!--------------------------------------------------------------------->


## Setting up the work area
[**[Contents]**](#contents)

Copy from the `.solutions/` directory the main `Makefile` already prepared for you:

```
% cp .solutions/Makefile .
```

<br />

Create a new fresh working area:

```
% make area
```

<br />
<!--------------------------------------------------------------------->


## Copy simulation scripts
[**[Contents]**](#contents)

Copy from the `.solutions/` directory all **Tcl simulation scripts** already prepared for you:

```
% cp .solutions/scripts/sim/*.tcl   scripts/sim/
```
<br />

>
> **REMINDER**
>
> On Windows systems, use the native `copy` **DOS** command to avoid issues with path separators:
>
> ```
> % copy .solutions\scripts\sim\*.tcl   scripts\sim\
> ```
>

<br />
<!--------------------------------------------------------------------->


## RTL coding
[**[Contents]**](#contents)

With your **text editor** application create create the main Verilog module `rtl/PWM.v` with the following content:

```verilog
//
// Example parameterizable N-bit Pulse-Width Modulation (PWM) generator in Verilog.
//


`timescale 1ns / 100ps

module PWM #(parameter integer THRESHOLD_NBITS = 4) (


   input  wire clk,
   input  wire [THRESHOLD_NBITS-1:0] threshold,     // programmable threshold, determines the duty-cycle of the PWM output waveform
   output wire pwm_out

   ) ;


   /////////////////////////////////
   //   tick counter (optional)   //
   /////////////////////////////////

   wire enable ;

   TickCounter #(.MAX(1)) TickCounter_inst ( .clk(clk), .tick(enable) ) ;   // with MAX = 1 the "tick" is always high, same as running at 100 MHz


   //////////////////////////////
   //   free-running counter   //
   //////////////////////////////

   reg [THRESHOLD_NBITS-1:0] pwm_count = {THRESHOLD_NBITS{1'b0}} ;   // use the replication operator to initialize all FF outputs to 1'b0, but you can also simply use 'b0

   always @(posedge clk) begin

      if (enable)

         // simple implementation, count from 0 to 111 ... 11, then pwm_out = 0 when threshold = 0, but pwm_out != 1 when threshold = 111 ... 11
         pwm_count <= pwm_count + 1'b1 ;

   end   // always


   ///////////////////////////
   //   binary comparator   //
   ///////////////////////////

   wire pwm_comb ;

   // PWM output: logic 1 if pwm_count < threshold, 0 otherwise
   assign pwm_comb = ( pwm_count < threshold ) ? 1'b1 : 1'b0 ;        // binary comparator (pure combinationational block using conditional assignment)


   /////////////////////////////////////////////////////////////////////////////
   //   **EXAMPLE: pre-placed RTL output buffer with detailed configuration   //
   /////////////////////////////////////////////////////////////////////////////

   //
   // Pre-place and configure a Xilinx FPGA output buffer OBUF primitive already in RTL.
   //
   // SLEW => "SLOW" (default) or "FAST"
   // DRIVE => 2, 4, 6, 8, 12(default), 16 or 24. Allowed values for LVCMOS33 IOSTANDARD are: 4, 6, 8, 12(default) or 16
   //
   // Ref. also to Xilinx official documentation:
   //
   //   Vivado Design Suite Properties Reference Guide (UG912)
   //   Vivado Design Suite 7 Series FPGA and Zynq-7000 SoC Libraries Guide (UG953)
   //

   OBUF  #(.IOSTANDARD("LVCMOS33"), .DRIVE(12), .SLEW("FAST")) pwm_comb_rtlbuf (.I(pwm_comb), .O(pwm_out)) ;   // **REMINDER: requires glbl.v compiled and elaborated along with other sources

endmodule
```

<br />

Save the source code once done. Compile the file to check for syntax errors:

```
% make compile hdl=rtl/PWM.v
```

<br />

Copy from the `.solutions/` directory the `TickCounter.v` module used in the previous code to optionally slow-down the PWM counter:

```
% cp .solutions/rtl/TickCounter.v  rtl/
```

<br />

>
> This is another example of a **GOOD** FPGA design practice. For complex FPGA
> digital designs in fact it is always recommended to know how to program/fine-tune
> the I/O interface with the external PCB (e.g.  set I/O termination for LVDS RX/TX,
> add pull-up/pull-down for selected signals, program slew rate/drive-strength etc).
> This can be done by writing a dedicated I/O code that "wraps" the FPGA core logic
> (similarly to a "padframe" that instantiates I/O cells in digital-on-top ASIC
> design flows).

<br />
<!--------------------------------------------------------------------->


## Simulate the design
[**[Contents]**](#contents)

Simulation sources have been already prepared for you, copy from the `.solutions/` directory the following **testbench sources**:

```
% cp .solutions/bench/ClockGen.v   bench/
% cp .solutions/bench/glbl.v       bench/
% cp .solutions/bench/tb_PWM.v     bench/
```

<br />

For less typing:

```
% cp .solutions/bench/*.v   bench/
```

<br />

Inspect the simple testbench code `bench/tb_PWM.v`, then compile, elaborate and simulate the design with

```
% make compile
% make elaborate
% make simulate
```

or simply type

```
% make sim
```

<br />

Observe the **variable duty-cycle waveform** generated by the circuit. Debug your simulation results.
Close the simulator graphical interface once happy.

<br />
<!--------------------------------------------------------------------->


## Implement the design on target FPGA
[**[Contents]**](#contents)

Try to run the FPGA implementation flow using a **Non Project mode** Tcl flow targeting the Digilent Arty A7 development board.
For this purpose we assume a 4-bit threshold in order to map threshold bits to 4x slide-switches as available on the Arty board.

Copy from the `.solutions/` directory all implementation Tcl scripts already prepared for you:

```
% cp .solutions/scripts/build/*.tcl  scripts/build/
```

<br />

Additionally, copy the following common scripts required to run the implementation flow:

```
% cp .solutions/scripts/common/variables.tcl  scripts/common/
% cp .solutions/scripts/common/init.tcl       scripts/common/
% cp .solutions/scripts/common/part.tcl       scripts/common/
```

<br />

Verify that all required scripts are in place:

```
% ls -l scripts/common/
% ls -l scripts/build/
```

<br />

Copy from the `.solutions/` directory also the main **Xilinx Design Constraints (XDC)** file used to implement the design
on real FPGA hardware:

```
% cp .solutions/xdc/PWM.xdc   xdc/
```

<br />

Inspect the content of the file at the command line:

```
% cat xdc/PWM.xdc
```

<br />

Finally, run the implementation flow in _Non Project_ mode using `make` as follows:

```
% make build
```

<br />

Explore implementation results in the Vivado graphical interface. Exit from Vivado once happy:

```
exit
```

<br />
<!--------------------------------------------------------------------->


## Exercises
[**[Contents]**](#contents)

<br />

**EXERCISE 1**

Modify the implementation of the PWM in order to have:

* the PWM output always OFF when the threshold value is 0
* the PWM output always ON when the threshold value is set to the maximum, that is `11111 ... 11` (e.g. 255 for an 8-bit PWM counter)

In order to to this we have to force the roll-over of the counter when it reaches MAX-1, that is `11111 ... 10` as follows:

```verilog
always @(posedge clk) begin

   if (enable) begin

      if( pwm_count == {THRESHOLD_NBITS{1'b1}} -1 )
         pwm_count <= 'b0 ;

      else
         pwm_count <= pwm_count + 1'b1 ;

   end   // if
end   // always
````

<br />

Implement this change and try to re-simulate the design from scratch. Verify with the original testbench that with a threshold value `8hFF` the PWM ouput signal
remains always high.

With this implementation the functionality of the PWM generator resembles the one provided by _Arduino_ PWM pins that you will use in the second part of the course.

<br />

**EXERCISE 2**

Copy the `.solutions/scripts/common/ip.tcl` script into the `scripts/common/` directory.

Compile with the **Vivado IP flow** a Phase-Locked Loop (PLL) IP core from the _Clocking Wizard_ in order to filter the jitter on the external input clock fed to the core logic:

```
% make ip
```

<br />

Instantiate the IP in the RTL and try to re-simulate and re-implement the design from scratch.

<br />
<!--------------------------------------------------------------------->


## Further readings
[**[Contents]**](#contents)

* _<https://en.wikipedia.org/wiki/Pulse-width_modulation>_
* _<https://learn.sparkfun.com/tutorials/pulse-width-modulation/all>_
* _<https://www.electronics-tutorials.ws/blog/pulse-width-modulation.html>_
* _<https://circuitdigest.com/tutorial/what-is-pwm-pulse-width-modulation>_


