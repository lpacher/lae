
<div align="justify">

# Practicum 15
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

<br />

Experiment yourself with the JTAG state-machine using Vivado _Hardware Manager_ low-level JTAG Tcl commands:

* `run_state_hw_jtag`
* `runtest_hw_jtag`
* `scan_ir_hw_jtag`
* `scan_dr_hw_jtag`

<br />

<img src="doc/pictures/JTAG_FSM.png" alt="drawing" width="700"/>

<br /><br />

In order to be able to directly interact with the JTAG **Test Access Port (TAP)**
from the Vivado _Hardware Manager_ you have to establish a connection between the computer
and the board in **JTAG mode** as follows:

```
connect_hw_server -url localhost:3121 -verbose
open_hw_target -jtag_mode on
```

<br />

Once the target is running in JTAG mode both the **Instruction Register (IR)** and **Data Registers (DR)**
are accessible through the `scan_ir_hw_jtag` and `scan_dr_hw_jtag` Tcl commands respectively.
Additionally the devices on the target can also be put into various states using the `run_state_hw_jtag` command.

As an example:

```
run_state_jw_jtag RESET
run_state_jw_jtag IDLE
```

<br />

Explore yourself all command-line options for these commands:

```
run_state_hw_jtag -help
runtest_hw_jtag -help
scan_ir_hw_jtag -help
scan_dr_hw_jtag -help
```

<br />

For this practicum you have to carefully read and understand the <b><i>Advanced JTAG Usage</i></b> chapter
of the official [**7 Series FPGAs Configuration User Guide**](https://docs.amd.com/v/u/en-US/ug470_7Series_Config).

<br />

As an example, try yourself to write a Tcl script to read-back the reserved  **64-bits Device DNA** using
the `FUSE_DNA` JTAG command corresponding to the op-code `6'b110010` as depicted below.

<br />

<img src="doc/pictures/JTAG_OPCODES.png" alt="drawing" width="800"/>

<br /><br />

Connect also **oscilloscope probes** on the dedicated **JTAG header** to debug JTAG waveforms.

<br />

Some useful references:

* _<https://www.xjtag.com/about-jtag/jtag-a-technical-overview/>_
* _<https://docs.amd.com/v/u/en-US/ug470_7Series_Config>_


