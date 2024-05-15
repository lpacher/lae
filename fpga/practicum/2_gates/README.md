
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

In this practicum you are going to implement and debug fundamental **logic gates** such
as AND, NAND, OR, NOR, XOR and XNOR as already discussed in `lab2` and `lab5`.
For this purpose you will use simple **slide switches** and **general-purpose LEDs** available
on the _Digilent Arty Board_.

Additionally you will implement and verify a **parameterized ring-oscillator** circuit.
Despite the circuit is pretty simple to be coded in Verilog you will need
additional `dont_touch` **synthesis directives** and **special timing constraints** in order
to properly map the RTL code on real FPGA hardware.

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

```
% cd Desktop/lae/fpga/practicum/2_gates
```

<br />

List the content of the directory:

```
% ls -l
% ls -l .solutions
```

<br />
<!--------------------------------------------------------------------->


## Map and debug fundamental logic gates
[**[Contents]**](#contents)

The circuit that you are going to implement and debug is shown in figure.

<br />

<img src="doc/pictures/GatesFPGA.png" alt="drawing" width="850"/>


<br />

>
> **NOTE**
>
> As you can inspect from board schematics general-purpose **RGB LEDs** are connected to the main 5V supply
> voltage through inverters implemented with BJT transistors, while general-purpose **standard LEDs** simply
> connect to ground with 330 $\Omega$ series limiting resistors. 
>
> The circuit schematic depicted in figure is therefore a simplified reference circuit diagram. 
>
> ![](./doc/pictures/LEDs_schematic.png)
>

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

>
> **IMPORTANT**
>
> Since everything in Tcl at the end is considered a string you need a way to **evaluate** Tcl commands.
> Square brackets `[ ]` are used for this purpose to indicate "command evaluation".
> As you might expect this introduces issues when working with **signal buses** in Verilog
> that also use `[ ]` to access bus items. This happens also if you use `std_logic_vector`
> ports in VHDL, because
> square brackets are used in XDC to access bus items despite the chosen HDL language used
> for the top-level module.
>
> Usually in the XDC file we use `get_ports` to map top-level RTL ports into physical FPGA pins,
> however in case of HDL signals declared as buses we have to prevent `[ ]` to be used for command evaluation.
> This is done by **adding curly brackets** `{ }` around the signal name.
>
> As an example,
>
> ```
> get_ports Z[0]
> ```
>
> <br />
>
> would rise an error, because `[0]` for Tcl means "evaluate" what is between `[` and `]` (nothing in this case).
> The following command works fine instead, because curly brackets `{ }` means "this is just a string":
>
> ```
> get_ports {Z[0]}
> ```
>

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

The second circuit that you are going to map and debug on real FPGA hardware
in this practicum is a parameterized ring-oscillator as shown in figure.

<br />
<img src="doc/pictures/RingOscillatorFPGA.png" alt="drawing" width="2000"/>
<br />

The circuit uses an AND-gate into the feedback loop to enable/disable the
output toggle, thus requiring an **odd number of inverters** in the chain
to oscillate. A simpler version of this design as been already discussed
and simulated  in `lab2` using a reduced and fixed number of inverters.

Despite its apparent simplicity a ring-oscillator circuit offers a first
example of a **non-trivial implementation** requiring **special synthesis directives**
and **special timing constraints** in order to properly map the RTL code
on real FPGA hardware.

As a first step copy from the `.solutions/` directory both Verilog and XDC sources already
prepared for you:

```
% cp .solutions/RingOscillator.v .
% cp .solutions/RingOscillator.xdc .
```

<br />


Vd



Cosa mettere:

- che il disegno e' facile ma da implementare non e' scontato => `dont_touch` synthesis pragmas

- timing loops

- automatizzare il flow per diversi valori di `NUM_INVERTERS`


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

>
> **HINT**
>
> In order to "capture" the transition of the `start` signal from logic 0 to
> logic 1 and observe the `clk` output starting oscillating you have to properly set
> **trigger options** of the oscilloscope you are working with in order to
> use a _single-trigger_ or _single shot_ trigger mode.
>
> Disable the ring-oscillator by setting `start` to 0 with the slide-switch
> and ensure that the status-led turns off.
> Then open the **Trigger Menu** and switch the trigger-mode from **Auto** (default)
> to **Normal**. Ensure that a positive-edge transition is used as
> trigger condition. Finally select the channel used to display the
> `probe` Verilog output port for the trigger and enable the ring-oscillator.
>
> In _Normal_ trigger mode in fact the trigger only occurs if the specified trigger
> conditions are met, freezing the display after the trigger event.
> In _Auto_ mode (default) a trigger is always forced instead, continuously updating
> displayed waweforms.
>
> Do not forget to set the trigger mode back to _Auto_ once done.
>

<br />

<br />
<img src="doc/pictures/RingOscillatorOscilloscope.png" alt="drawing" width="650"/>
<br />

<br />

>
> **QUESTION**
>
> Which is the frequency of the resulting clock waveformn ?
>
>   \____________________________________________________________________________________________________
>

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

