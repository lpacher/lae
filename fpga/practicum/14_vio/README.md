<div align="justify">

# Practicum 14
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

## Estimated time: **30 minutes**

## Contents

* [**Introduction**](#introduction)
* [**Practicum aims**](#practicum-aims)
* [**Navigate to the practicum directory**](#navigate-to-the-practicum-directory)
* [**Setting up the work area**](#setting-up-the-work-area)
* [**Review RTL sources**](#review-rtl-sources)
* [**Insert a Virtual Input Output (VIO) debug core**](#insert-a-virtual-input-output-vio-debug-core)
* [**Export the debug probes file**](#export-the-debug-probes-file)
* [**Implement the design on target FPGA**](#implement-the-design-on-target-fpga)
* [**Install and debug the firmware**](#install-and-debug-the-firmware)
* [**Force and release FPGA internal signals remotely**](#force-and-release-fpga-internal-signals-remotely)
* [**Exercise**](#exercise)
* [**Further readings**](#further-readings)

<br />
<!--------------------------------------------------------------------->

## Introduction
[**[Contents]**](#contents)

The goal of this practicum is to to introduce and demonstrate the usage
of the **Virtual Input/Output (VIO)** debug feature available in Vivado.
This IP core will allow you to **force/release selected internal FPGA signals remotely**
from a Vivado _Hadware Manager_ session in order to "emulate"
the effect of real physical push-buttons and switches.

<br />
<!--------------------------------------------------------------------->


## Practicum aims
[**[Contents]**](#contents)

This practicum should exercise the following concepts:

* introduce the usage of the Virtual Input/Output (VIO) core in Vivado
* insert a VIO debug core on a simple RTL design
* force/release FPGA internal nodes remotely from the Vivado _Hardware Manager_

<br />
<!--------------------------------------------------------------------->


## Navigate to the practicum directory
[**[Contents]**](#contents)

As a first step, open a **terminal** window and change to the practicum directory:

```
% cd Desktop/lae/fpga/practicum/13_ila
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

Additionally, recursively copy from the `.solutions/` directory the following design sources and scripts:

```
% cp -r .solutions/rtl/      .
% cp -r .solutions/scripts/  .
% cp -r .solutions/xdc/      .
```

<br />

Create a new fresh working area:

```
% make area
```

<br />
<!--------------------------------------------------------------------->


## Review RTL sources
[**[Contents]**](#contents)

The target design used to demonstrate VIO capabilities will be the same counter already
used in the previous practicum to demonstrate the usage of the ILA core.

Review yourself in your preferred **text-editor** application the main RTL module `rtl/counter_vio.v`
before continuing:

```
% gedit rtl/counter_vio.v &   (for Linux users)

% n++ rtl\counter_vio.v       (for Windows users)
```

<br />

As you can notice **the RTL code is not complete** and you are requested to properly
**compile and  insert a VIO core** in the design in order to be able to **force/release remotely**
both the reset and the enable of the counter in addition to external signals coming
from the physical board.

<br />
<!--------------------------------------------------------------------->


## Insert a Virtual Input Output (VIO) debug core
[**[Contents]**](#contents)

As a first step launch the **Vivado IP flow** from `Makefile` as follows:

```
% make ip mode=gui
```

<br />

Once the IP repository has been successfully initialized in the Vivado **IP Catalog**
go through **Vivado Repository > Debug & Verification > Debug > VIO (Virtual Input/Output)** or simply
search for "vio" in the _Search_ bar. Right-click on the IP and select **Customize IP**.

<br />

In the **General Options** TAB configure the IP with the following specifications:

* Component Name: `vio_core`
* Input Probe Count: 0
* Output Probe Count: 2


Additionally in the **PROBE_OUT** TAB specify proper **initial values** for the probes. Assuming that
`PROBE_OUT0` will drive the active-low reset while `PROBE_OUT1` will drive the enable use these settings:

* PROBE_OUT0: 0x1
* PROBE_OUT1: 0x1

Left-click OK once done. In the **Generate Output Products** window be sure that the **Out of Context** option is checked.
Finally left-click on **Generate** to compile the IP core.

<br />

Once the IP compilation process successfully completed exit from Vivado and verify that all IP deliverables are in place:

```
% ls -l ./cores/vio_core/*
```

<br />

Review the **Verilog instantiation template** (`.veo`) part of these deliverables:

```
% cat ./cores/ila_core/vio_core.veo
```

<br />

At this point try yourself to **complete the template RTL code** in order to **instantiate** the VIO core
to drive both reset and enable control signals for the counter **from the VIO core** in combination with
real external reset and enable input signals coming from physical push-button/switch on the _Arty_ board.

<br />
<!--------------------------------------------------------------------->


## Implement the design on target FPGA
[**[Contents]**](#contents)

Since the core functionality of the counter as well as its I/O interface with the outside
world has not changed all design constraints are the same as those used in the previous
practicum:

```
% diff xdc/counter_vio.xdc ../13_ila/xdc/counter_ila.xdc
```

<br />

If not already in place, copy the file from the `.solutions/` directory as follows:

```
% cp .solutions/xdc/counter_vio.xdc  xdc/
```

<br />


Identify all pins that have been used to map top-level RTL ports.
Run the FPGA implementation flow in _**Non Project mode**_ from the command line:

```
% make build
```

<br />

Once done, verify that the **bitstream file** has been properly generated:

```
% ls -l work/build/outputs/  | grep .bit
```

<br />
<!--------------------------------------------------------------------->


## Export the debug probes file
[**[Contents]**](#contents)

In order to be able to "emulate" physical switches for the reset and for the enable into the
Vivado _Harware Manager_ a JSON debug **probes file** (`.ltx`) has to be provided along with
the main bitstream file (`.bit`) similarly to what was requested in the ILA flow.

As a reminder this file is automatically generated for you when running **Project mode** scripts,
while it's up to the user to export this file when working with **Non Project mode** scripts
with the `write_debug_probes` Tcl command.

For this reason **restore the final routed design checkpoint (DCP)** in the Vivado graphical interface
and export the requested file.

For Linux users:

```
% vivado -mode gui ./work/build/outputs/routed.dcp
```

<br />

For Windows users:

```
% echo "exec vivado -mode gui ./work/build/outputs/routed.dcp &" | tclsh -norc
```

<br />

Inspect in the GUI the final **gate-level schematic** and verify that the VIO core is found in your
design.

<br />

Then **export the probes file** by running the following command in the Vivado Tcl console:

```
write_debug_probes ./work/build/outputs/counter_vio.ltx
```

<br />

Close Vivado once done and verify that the new file is in place:

```
% ls -l ./work/build/outputs/ | grep ltx
```


<br />
<!--------------------------------------------------------------------->


## Install and debug the firmware
[**[Contents]**](#contents)

Connect the board to the USB port of your personal computer using a **USB A to micro USB cable**.
Verify that the **POWER** status LED turns on. Once the board has been recognized by the operating
system **upload the firmware** from the command line using:

```
% make install
```

<br />

Play with reset and count-enable controls to check that the firmware works as expected.
Verify that from the "user" point of view the insertion of the VIO core in the design
has been seamless, with no effects on the counter behaviour.

<br />
<!--------------------------------------------------------------------->


## Force and release FPGA internal signals remotely
[**[Contents]**](#contents)

In order to be able to effectively "stimulate" **remotely** your design running into FPGA with signals
generated by the VIO core a **JTAG connection** between the FPGA and a Vivado _Hardware Manager_ session
has to run under the hood.

For this purpose start a new session of the Vivado _Hardware Manager_ from the command line.
For less typing you can use the following `Makefile` target in place of running `vivado -mode gui`
standalone as usual:

```
% make hw_manager mode=gui
```

<br />

Establish a new connection between the _Hardware Manager_ and the _Arty_ board and re-program the FPGA.
To do this, simply left-click on **Open target > Auto Connect**, then right-click
on the `xc7a35t` device, select **Program Device...** and specify **both** the **bitstream file** (`.bit`)
and the **debug probes file** (`.ltx`).

Once the FPGA has been successfully programmed the _Hardware Manager_ displays the **VIO Default Dashboard**.
This window allows you to create **virtual push-buttons and slide-switches** to force/release
remotely FPGA internal signals in place of real physical switches.

Try yourself to create for the counter

* a virtual active-low push-button for the reset and
* a virtual slide-switch for the enable

then play with these virtual stimuli and debug the functionality of the firmware.

<br />
<!--------------------------------------------------------------------->


## Exercise
[**[Contents]**](#contents)

VIO and ILA debug cores are two completely independent debug features. Indeed if you need to insert
a VIO debug probe into your RTL design for troubleshooting very likely you will also include an ILA
debug core to trace its effects.

In addition to the VIO core try yourself to add to the design also an ILA debug core as in the previous
practicum in order to "spy" internal reset and enable values as well as LED output values.
For this purpose compile a suitable ILA debug core from scratch  and properly add `mark_debug` and `keep`
synthesis pragmas:


```verilog
(* mark_debug = "true", keep = "true" *)
wire reset_int ;

(* mark_debug = "true", keep = "true" *)
wire enable_int ;
```


<br />
<!--------------------------------------------------------------------->

</div>
