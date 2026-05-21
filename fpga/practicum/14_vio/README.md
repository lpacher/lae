<div align="justify">

# Practicum 14
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

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

<br />
<!--------------------------------------------------------------------->


## Practicum aims
[**[Contents]**](#contents)

This practicum should exercise the following concepts:

* introduce the usage of the Virtual Input/Output (VIO) core in Vivado
* insert a VIO debug core on a simple RTL design
* force/release FPGA internal nodes remotely from the Vivado Hardware Manager

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

<br />
<!--------------------------------------------------------------------->


## Insert a Virtual Input Output (VIO) debug core
[**[Contents]**](#contents)

For this purpose simply start the Vivado IP flow from `Makefile` as follows:

```
% make ip mode=gui
```

<br />

Once the IP repository has been successfully initialized in the Vivado **IP Catalog**
go through **Vivado Repository > Debug & Verification > Debug > VIO (Virtual Input/Output)** or simply
search for "vio" in the Search bar. Right-click on the IP and select **Customize IP**.

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

At this point **modify the template RTL code** and try yourself to **instantiate** the VIO core to drive both reset and enable
input control signals for the counter **from inside the FPGA** in combination with the external reset and enable signals coming
from physical push-button/switch on the _Arty_ board.

<br />
<!--------------------------------------------------------------------->


## Implement the design on target FPGA
[**[Contents]**](#contents)

Inspect the content of the main **Xilinx Design Constraints (XDC)** file used to implement the design
on real FPGA hardware already prepared for you:

```
% cat xdc/counter_ila.xdc
```

<br />

If not already in place, copy the file from the `.solutions/` directory as follows:

```
% cp .solutions/xdc/counter_ila.xdc  xdc/
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

<br />
<!--------------------------------------------------------------------->


## Force and release FPGA internal signals remotely
[**[Contents]**](#contents)

<br />
<!--------------------------------------------------------------------->


## Exercise
[**[Contents]**](#contents)

In addition to the VIO core add to the design also the ILA debug core as in previous practicum to "spy"
internal reset and enable values. For this purpose properly add `mark_debug` and `keep` synthesis pragmas.

<br />
<!--------------------------------------------------------------------->


## Further readings
[**[Contents]**](#contents)

</div>
