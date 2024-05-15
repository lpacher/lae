
# Practicum 2
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

## Contents

* [**Introduction**](#introduction)
* [**Practicum aims**](#practicum-aims)
* [**Navigate to the practicum directory**](#navigate-to-the-practicum-directory)
* [**Map and debug fundamental logic gates**](#map-and-debug-fundamental-logic-gates)
* [**Run FPGA implementation and programming flows from Makefile**](#run-fpga-implementation-and-programming-flows-from-makefile)
* [**Restore a design checkpoint in Vivado**](#restore-a-design-checkpoint-in-vivado)
* [**Implement a parameterized ring-oscillator**](#implement-a-parameterized-ring-oscillator)
* [**Exercises**](#exercises)


<br />
<!--------------------------------------------------------------------->


## Introduction
[**[Contents]**](#contents)

<p align="justify">
In this practicum you are going to implement and debug fundamental <b>logic gates</b> such
as AND, NAND, OR, NOR, XOR and XNOR as already discussed in <code>lab2</code> and <code>lab5</code>.
For this purpose you will use simple <b>slide switches</b> and <b>general-purpose LEDs</b>
available on the <i>Digilent Arty Board</i>.
</p>

<p align="justify">
Additionally you will implement and verify a <b>parameterized ring-oscillator</b> circuit.
Despite the circuit is pretty simple to be coded in Verilog you will need
additional <code>dont_touch</code> <b>synthesis directives</b> and <b>special timing constraints</b>
in order to properly map the RTL code on real FPGA hardware.
</p>

<br />
<!--------------------------------------------------------------------->


## Practicum aims
[**[Contents]**](#contents)

This practicum should exercise the following concepts:

* review Verilog bitwise operators and gate-primitives
* implement and debug fundamental logic operators on real FPGA hardware
* use improved _Project Mode_ Tcl scripts and `Makefile` to run the flows in batch mode
* restore a design checkpoint in Vivado
* implement a ring-oscillator circuit on real FPGA hardware
* introduce the usage of _synthesis pragmas_ in RTL
* identify and fix timing-loop issues in combinational circuits
* review and understand the differece between _Auto_ and _Normal_ trigger modes at the oscilloscope
* debug termination issues

<br />
<!--------------------------------------------------------------------->


## Navigate to the practicum directory
[**[Contents]**](#contents)

As a first step, open a **terminal** window and change to the practicum directory:

<pre>
% cd Desktop/lae/fpga/practicum/2_gates
</pre>

<br />

List the content of the directory:


<pre><code>
% ls -l
% ls -l .solutions
</code></pre>


<br />
<!--------------------------------------------------------------------->


## Map and debug fundamental logic gates
[**[Contents]**](#contents)

The circuit that you are going to implement and debug is shown in figure.

<br />

<img src="doc/pictures/GatesFPGA.png" alt="drawing" width="850"/>

<br />

<blockquote><b>NOTE</b>

<p align="justify">
As you can inspect from board schematics general-purpose <b>RGB LEDs</b> are connected to the main 5V supply
voltage through inverters implemented with BJT transistors, while general-purpose <b>standard LEDs</b> simply
connect to ground with 330 $\Omega$ series limiting resistors.
</p>

<p align="justify">
The circuit schematic depicted in figure is therefore a simplified reference circuit diagram. 
</p>

![](./doc/pictures/LEDs_schematic.png)

</blockquote>

<br />



To save time, copy from the `.solutions/` directory the `Gates.v` source file already
discussed in `lab2` and `lab5` as follows:

```
% cp .solutions/Gates.v .
```

<br />

In order to map the Verilog code on real FPGA hardware you also need to write a **constraints file**
using a **Xilinx Design Constraints (XDC) script**. Create therefore with your **text-editor** application
a new source file named `Gates.xdc` as follows:

```
% gedit Gates.xdc &   (for Linux users)

% n++ Gates.xdc       (for Windows users)
```

<br />

Copy from the `.solutions/` directory the reference XDC file for the Arty board:

```
% cp .solutions/arty_all.xdc .
```

<br />

Try to **write yourself design constraints** required to implement the design on the actual board.
In the following you can find useful information to help you in writing the code.

<br />

<!-- horizontal divider -->
---

<br />

**PHYSICAL CONSTRAINTS (PORT MAPPING)**

As a first step you have to write **pin constraints** required to map `A` and `B` Verilog
inputs to slide-witches **SWO** and **SW1** and to map `Z[0]` ... `Z[5]` Verilog outputs
to general-purpose LEDs as in figure. Use the main `arty_all.xdc` as a reference
for the syntax.

```
set_property -dict { PACKAGE_PIN <FPGA pin> IOSTANDARD LVCMOS33 } [get_ports <HDL port name> ]
```

<br />

As already discussed in the introductory practicum each HDL top-level port
needs both an FPGA physical pin name and the I/O voltage to be specified
in the constraints file by setting `PACKAGE_PIN` and `IOSTANDARD` properties.

The above syntax uses one single `set_property` statement to assign both 
`PACKAGE_PIN` and `IOSTANDARD` in form of a "dictionary", that is a list
of _(key,value)_ pairs.

Alternatively you can set `PACKAGE_PIN` and `IOSTANDARD` properties
using two independent statements targeting the same HDL top-level port:

```
set_property PACKAGE_PIN <FPGA pin> [get_ports <HDL port name> ]
set_property IOSTANDARD LVCMOS33 [get_ports <HDL port name> ]
```

<br />

<blockquote>

<p><b>IMPORTANT</b></p>

<p align="justify">
Since everything in Tcl at the end is considered a string you need a way to </b>evaluate</b> Tcl commands.
Square brackets <code>[ ]</code> are used for this purpose to indicate "command evaluation".
As you might expect this introduces issues when working with <b>signal buses</b> in Verilog
that also use <code>[ ]</code> to access bus items. This happens also if you use <code>std_logic_vector</code>
ports in VHDL, because square brackets are used in XDC to access bus items despite the chosen HDL language used
for the top-level module.
</p>

<p align="justify">
Usually in the XDC file we use <code>get_ports</code> to map top-level RTL ports into physical FPGA pins,
however in case of HDL signals declared as buses we have to prevent <code>[ ]</code> to be used for command
evaluation. This is done by <b>adding curly brackets</b> <code>{ }</code> around the signal name.
</p>

As an example,

```
get_ports Z[0]
```

<br />

<p align="justify">
would rise an error, because <code>[0]</code> for Tcl means "evaluate" what is between <code>[</code>
and <code>]</code> (nothing in this case).
The following command works fine instead, because curly brackets <code>{ }</code> means "this is just a string":
</p>

```
get_ports {Z[0]}
```

</blockquote>


<br /><br />

**TIMING CONSTRAINTS**

Since this is a pure **combinational circuit** timing constraints are relaxed. A first possibility
is to require some **maximum delay** between inputs and outputs using the `set_max_delay` constraint.

As an example, you can constrain a max. 10 ns delay between any input to any output
with the following syntax:

```
set_max_delay 10 -from [all_inputs] -to [all_outputs]
```

<br />

You can also play with the delay value and verify the effect in Vivado **timing reports**.

Alternatively you can simply **disable all timing checks** with `set_false_path` as follows:


```
set_false_path -from [all_inputs] -to [all_outputs]
```

<br /><br />

**ELECTRICAL CONSTRAINTS**

You can re-use same electrical constraints from the introductory practicum:


```
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
```

<br />

Optionally you can include the following additional XDC statements to **optimize the memory configuration file (.bin)**
to program the external 128 MB Quad Serial Peripheral Interface (SPI) flash memory in order to automatically load
the FPGA configuration at power-up:

```
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4                [current_design]
```

<br />

---
<!-- horizontal divider -->

<br />

Once ready, open Vivado in graphical mode with

```
% vivado -mode gui &                               (for Linux users)

% echo "exec vivado -mode gui &" | tclsh -norc     (for Windows users)
```

<br />

and try to run the FPGA implementation flow in _Project Mode_ up to bitstream generation:

* create into the current directory a new project named `Gates` targeting the `xc7a35ticsg324-1L` FPGA device
* add the `Gates.v` Verilog file to the project
* add `Gates.xdc` design constraints to the project
* run elaboration and inspect the RTL schematic
* run synthesis and inspect the post-synthesis schematic
* run implementation and inspect place-and-route results into the _Device_ view
* generate the bitstream

<br />

>
> **QUESTION**
>
> Which FPGA device primitives have been used to map the design on real hardware ?
>
>   \____________________________________________________________________________________________________
>

<br />

After the implementation flow has successfully completed **locate the bitstream file**
to be used for firmware installation.

For this purpose remind that when running Vivado in _Project Mode_  by default both bitstream (.bit) and
raw-binary (.bin) programming files are written by Vivado into the `*.runs/impl_1/` directory automatically
created by the tool as part of the project tree setup.

Verify at the end of the flow that the bitstream file has been properly generated:

```
% ls -lh ./Gates.runs/impl_1/ | grep .bit
```

<br />

>
> **QUESTION**
>
> Which is the on-disk size of the bitstream file ?
>
>   \____________________________________________________________________________________________________
>

<br />

Program the FPGA using the Vivado _Hardware Manager_ as discussed in the introductory practicum
and debug the expected functionality of the firmware by playing with slide-switches and LEDs
on the board.

<br />
<!--------------------------------------------------------------------->


## Run FPGA implementation and programming flows from Makefile
[**[Contents]**](#contents)

In the introductory practicum we already explored the possibility to run both FPGA implementation and programming flows
in batch mode using Tcl scripts and a `Makefile`.

For this practicum improved _Project Mode_ Tcl scripts and `Makefile` have been already prepared for you.
Copy into the current directory the following sources:

```
% cp .solutions/Makefile    .
% cp .solutions/setup.tcl   .
% cp .solutions/build.tcl   .
% cp .solutions/install.tcl .
```

<br />

Once all scripts are in place try to re-run all flows from scratch using the `make` utility as follows:

```
% make clean
% make build
% make install
```

<br />

Explore the content of the updated scripts with your preferred text editor or using basic
command-line utilities `cat`, `more` or `more`.

```
% cat Makefile
% cat setup.tcl
% less build.tcl
% less install.tcl
```

<br />

As you can notice the proposed updated flow uses a new `setup.tcl` to specify Tcl variables
that are common to both implementation and programming flows such as the project name
and directory, the top-level RTL module and the target FPGA device.

According to our initial coding conventions for the moment our basic projects only
contain one single Verilog file `ModuleName.v` and one XDC file `ModuleName.xdc`.
Therefore a single `topModuleName` Tcl variable is enough to specify `$topModuleName.v`
and `$topModuleName.xdc` input files and to have a more portable flow.

Later in the course we will export all project information as environment variables from `Makefile`
in a more convenient way.

<br />
<!--------------------------------------------------------------------->


## Restore a design checkpoint in Vivado
[**[Contents]**](#contents)

When running Vivado in _Project Mode_ a so-called **design checkpoint (DCP)** file
is automatically saved for you by Vivado at each major step of the flow (synthesis, placement and routing).

A design checkpoint is a Vivado-specific **binary database** with file extension `.dcp` that
represents a "snapshot" of the entire design at a particular stage of the flow.
As an example, a post-synthesis database contains the synthesized netlist and design constraints, while
a placed or a routed database contains also additional information related to the physical
implementation of the design.

Explore all design checkpoint files that are part of the Vivado project tree:

```
% ls -lh ./Gates.runs/*/* | grep .dcp
```

<br />

By using design checkpoints you can later **restore** a design project back into Vivado.

Try to restore the "routed" design checkpoint automatically generated for you
by the `make build` flow. Start a new Vivado session in GUI mode with
the new `make gui` target:

```
% make gui
```

<br />

Then go through **File > Checkpoint > Open...** and restore the `Gates.runs/impl_1/Gates_routed.dcp` database.

Observe the equivalent command in the Tcl console:

```
open_checkpoint ./Gates.runs/impl_1/Gates_routed.dcp
```

<br />

Explore the design in the graphical interface. Exit Vivado once happy.

A second possibility is to automatically load a design checkpoint by passing
the name of the database as main argument when executing `vivado` at the commad line.

As an example, try to restore the post-synthesis design checkpoint with the following command:

```
% vivado -mode gui ./Gates.runs/synth_1/Gates.dcp
```

<br />

Explore the design in the graphical interface. Exit Vivado before moving
to the ring-oscillator implementation.

<br />
<!--------------------------------------------------------------------->


## Implement a parameterized ring-oscillator
[**[Contents]**](#contents)

<p align="justify">
The second circuit that you are going to map and debug to the <i>Arty</i> board
in this practicum is a parameterized <b>ring-oscillator</b> as shown in figure.
</p>

<br />
<img src="doc/pictures/RingOscillatorFPGA.png" alt="drawing" width="2000"/>
<br />

<p align="justify">
The proposed circuit uses an AND-gate into the feedback loop to enable/disable the
output toggle, thus requiring an <b>odd number of inverters</b> in the chain
to oscillate. A simpler version of this design as been already discussed
and simulated  in <code>lab2</code> using a reduced and fixed number of inverters.
</p>

<p align="justify">
Despite its apparent simplicity a ring-oscillator offers a first example of a <b>non-trivial implementation</b>
requiring both <b>special synthesis directives</b> and <b>special timing constraints</b> in order to properly
implement this circuit on real FPGA hardware.
</p>


<p align="justify">
Copy from the <code>.solutions/</code> directory both Verilog and XDC files already prepared for you:
</p>

<pre>
% cp .solutions/RingOscillator.v .
% cp .solutions/RingOscillator.xdc .
</pre>

<br />

<p align="justify">
Inspect yourself the proposed code with your preferred <b>text-editor</b> application and review
most important syntax features, new constructs and special statements summarized below.
</p>

<br />

<p>
<b>RTL IMPLEMENTATION AND SYNTHESIS PRAGMAS</b>
</p>

<p align="justify">
In order to easily change the <b>number of inverters</b> in the ring-oscillator chain
(and therefore the <b>frequency</b> of the <code>clk</code> output toggle) the module
uses <code>NUM_INVERTERS</code> declared as a <code>parameter</code>.
A Verilog <code>generate</code> <b>for-loop</b> is then used to automatically replicate
and interconnect the chosen number of inverters.
</p>

<br />

<p align="justify">
Most important, you should have noticed the usage of the following <b>non-Verilog syntax</b>
in the code:
</p>

<pre>
(* dont_touch = "yes" *) wire [NUM_INVERTERS:0] w ;

...
...

(* dont_touch = "yes" *) not inv (w[k+1], w[k]) ;
</pre>

<br />
 
<p align="justify">
This is a first example of so called <b>synthesis pragmas</b>, also referred to as <b>synthesis attributes</b>
or <b>synthesis directives</b>.
Synthesis pragmas are tool-specific <b>extra comment-like HDL statements</b> (ignored by the compiler when you run the
simulation flow) to "guide" the synthesis tool in generating the desired hardware.
</p>

<p align="justify">
When you run the FPGA implementation flow the <b>synthesis engine</b> translates the RTL code
into FPGA primitives. During this process the tool also performs several <b>optimizations</b>
to obtain best <b>timing</b>, <b>power</b> and <b>area</b> <b>quality-of-results (QoR)</b>.
</p>

<p align="justify">
A ring oscillator needs $N = 2k +1$ (even number) inverters to oscillate. However if you cascade $2 k$ (odd number)
inverters the resulting <b>logic</b> combinational function is a simple identity and the synthesis tool properly
recognizes this. As a result from a design-optimization point of view there is no reason for the synthesis engine
to keep $2 k$ un-necessary inverters out of $2k + 1$ and after its logic optimization the initial circuit
would reduce to a simple AND gate plus an inverter connected in feedback, or equivalently one single NAND gate
connected in feedback.
</p>


<br />

<p>
<b>DESIGN CONSTRAINTS</b>
</p>



- timing loops



Before running the FPGA implementation flow modify with your preferred **text-editor**
the project-setup script `setup.tcl` and update the values set for
`projectName` and `toplModuleName` variables as follows:

```
#set projectName {Gates}
set projectName {RingOscillator}

...

#set topModuleName {Gates}
set topModuleName {RingOscillator}
```

<br />

Save the file after modifications. Once ready launch the flow at the command line with:

```
% make clean
% make build
```

<br />

After the implementation has successfully completed install the firmware to the FPGA board
with:

```
% make install
```

<br />

Verify the functionality of the ring-oscillator you have mapped on real hardware.
Use the **SW0** slide-switch assigned to the `start` Verilog input port
to enable/disable the oscillator and probe the `clk` signal at the oscilloscope.
Verify that the **LD4** general-purpose standard LED properly turns on/off to indicate
that the oscillator is running or not.

<br />

<blockquote>

<p><b>HINT</b></p>

<p align="justify">
In order to "capture" the transition of the <code>start</code> signal from logic 0 to
logic 1 and observe the <code>clk</code> output starting oscillating you have to properly set
<b>trigger options</b> of the oscilloscope you are working with in order to
use a <i>single-trigger</i> or <i>single shot</i> trigger mode.
</p>

<p align="justify">
Disable the ring-oscillator by setting <code>start</code> to 0 with the slide-switch
and ensure that the status-led turns off.
Then open the <b>Trigger Menu</b> and switch the trigger-mode from <b>Auto</b> (default)
to <b>Normal</b>. Ensure that a positive-edge transition is used as
trigger condition. Finally select the channel used to display the
<code>probe</code> Verilog output port for the trigger and enable the ring-oscillator.
</p>

<p align="justify">
In <i>Normal</i> trigger mode in fact the trigger only occurs if the specified trigger
conditions are met, freezing the display after the trigger event.
In <i>Auto</i> mode (default) a trigger is always forced instead, continuously updating
displayed waveforms.
</p>

<p align="justify">
Do not forget to set the trigger mode back to <i>Auto</i> once done.
</p>

</blockquote>

<br />

<br /><img src="doc/pictures/RingOscillatorOscilloscope.png" alt="drawing" width="650"/><br /><br />


<blockquote>
<p><b>QUESTION</b><p>
<p>Which is the frequency of the resulting clock waveform ?</p>
<p>____________________________________________________________________________________________________</p>
</blockquote>


<br />


$$
f_{osc} \sim \dfrac{1}{N}
$$

In the proposed implementatio we have one additional propagation delay in the feedback loop
due to the presence of the AND control gate.

However we can assume that the AND and the inverters have comparable propagation delays.
This is also a reasonable assumption since at end all cells are mapped to LUT primitives.

$$
f_{osc} \approx \dfrac{1}{2 t_p (N+1) } \sim \frac{1}{N+1}
$$

Given the large number of inverters in the chain we can also approximate $N + 1 approx N$.


<br />
<!--------------------------------------------------------------------->

## Exercises
[**[Contents]**](#contents)

<br />

**EXERCISE 1**

Usare

```
`define NUM_INVERTERS 237 
```

and `NUM_INVERTERS

al posto di un valore hard-coded.



<br />

**EXERCISE 2**

Implementare un full-adder


```
assign Sum  =  ...
assign Cout = ...
```

<br />
<!--------------------------------------------------------------------->

