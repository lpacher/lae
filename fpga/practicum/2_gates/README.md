
# Practicum 2
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/practicum)]

## Contents

* [**Introduction**](#introduction)
* [**Practicum aims**](#practicum-aims)
* [**Navigate to the practicum directory**](#navigate-to-the-practicum-directory)
* [**Map and debug fundamental logic gates**](#map-and-debug-fundamental-logic-gates)
* [**Run implementation and programming flows from Makefile**](#run-implementation-and-programming-flows-from-makefile)
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

<p align="justify">
As a first step, open a <b>terminal</b> window and change to the practicum directory:
</p>

<pre>
% cd Desktop/lae/fpga/practicum/2_gates
</pre>

<br />

<p align="justify">
List the content of the directory:
</p>

<pre>
% ls -l
% ls -l .solutions
</pre>


<br />
<!--------------------------------------------------------------------->


## Map and debug fundamental logic gates
[**[Contents]**](#contents)

<p align="justify">
The circuit that you are going to implement and debug is shown in figure.
</p>

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

<img src="doc/pictures/LEDs_schematic.png" alt="drawing"/>

<br />

</blockquote>

<br />



<p align="justify">
To save time, copy from the <code>.solutions/</code> directory the <code>Gates.v</code> source file already
discussed in <code>lab2</code> and <code>lab5</code> as follows:
</p>

<pre>
% cp .solutions/Gates.v .
</pre>

<br />

<blockquote>

<p><b>WARNING</b></p>

<p align="justify">
Do not forget the dot <code>.</code> to indicate that the <b>target destination directory</b>
for the <code>cp</code> command is the current working directory!
</p>

</blockquote>

<br />

<p align="justify">
In order to map the Verilog code on real FPGA hardware you also need to write a <b>constraints file</b>
using a <b>Xilinx Design Constraints (XDC) script</b>. Create therefore with your <b>text-editor</b> application
a new source file named <code>Gates.xdc</code> as follows:
</p>

<pre>
% gedit Gates.xdc &   (for Linux users)

% n++ Gates.xdc       (for Windows users)
</pre>

<br />


<p align="justify">
Copy from the <code>.solutions/</code> directory the reference XDC file for the <i>Arty</i> board:
</p>

<pre>
% cp .solutions/arty_all.xdc .
</pre>

<br />


<p align="justify">
Try to <b>write yourself design constraints</b> required to implement the design on the actual board.
In the following you can find useful information to help you in writing the code.
</p>

<br />

<hr><!-- horizontal divider -->

<br />

<b>PHYSICAL CONSTRAINTS (PORT MAPPING)</b>

<p align="justify">
As a first step you have to write <b>pin constraints</b> required to map <code>A</code> and <code>B</code>
Verilog inputs to slide-witches <b>SWO</b> and <b>SW1</b> and to map <code>Z[0]</code> ... <code>Z[5]</code>
Verilog outputs to general-purpose LEDs as in figure. Use the main <code>arty_all.xdc</code> as a reference
for the syntax.
</p>

<pre>
set_property -dict { PACKAGE_PIN <FPGA pin> IOSTANDARD LVCMOS33 } [get_ports <HDL port name> ]
</pre>

<br />

<p align="justify">
As already discussed in the introductory practicum each HDL top-level port
needs both an FPGA physical pin name and the I/O voltage to be specified
in the constraints file by setting <code>PACKAGE_PIN</code> and <code>IOSTANDARD</code>
properties.
</p>

<p align="justify">
The above syntax uses one single <code>set_property</code> statement to assign both 
<code>PACKAGE_PIN</code> and <code>IOSTANDARD</code> in form of a "dictionary", that
is a list of <i>(key,value)</i> pairs.
</p>

<p align="justify">
Alternatively you can set <code>PACKAGE_PIN</code> and <code>IOSTANDARD</code> properties
using two independent statements targeting the same HDL top-level port:
</p>

<pre>
set_property PACKAGE_PIN <FPGA pin> [get_ports <HDL port name> ]
set_property IOSTANDARD LVCMOS33 [get_ports <HDL port name> ]
</pre>

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

<pre>
get_ports Z[0]
</pre>

<br />

<p align="justify">
would rise an error, because <code>[0]</code> for Tcl means "evaluate" what is between <code>[</code>
and <code>]</code> (nothing in this case).
The following command works fine instead, because curly brackets <code>{ }</code> means "this is just a string":
</p>

<pre>
get_ports {Z[0]}
<pre>

</blockquote>


<br /><br />


<b>TIMING CONSTRAINTS</b>

<p align="justify">
Since this is a pure <b>combinational circuit</b> timing constraints are relaxed. A first possibility
is to require some <b>maximum delay</b> between inputs and outputs using the <code>set_max_delay</code>
constraint.
</p>

<p align="justify">
As an example, you can constrain a max. 10 ns delay between any input to any output with the following syntax:
</p>

<pre>
set_max_delay 10 -from [all_inputs] -to [all_outputs]
</pre>

<br />

<p align="justify">
You can also play with the delay value and verify the effect in Vivado <b>timing reports</b>.
</p>

<p align="justify">
Alternatively you can simply <b>disable all timing checks</b> with <code>set_false_path</code>
as follows:
</p>


<pre>
set_false_path -from [all_inputs] -to [all_outputs]
</pre>

<br /><br />


<b>ELECTRICAL CONSTRAINTS</b>


<p align="justify">
You can re-use same electrical constraints from the introductory practicum:
</p>

<pre>
set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
</pre>

<br />

<p align="justify">
Optionally you can include the following additional XDC statements to <b>optimize the memory configuration file (.bin)</b>
to program the external <b>128 Mb (16 MB) Quad Serial Peripheral Interface (SPI) Flash memory</b> in order to automatically
load the FPGA configuration at power-up:
</p>

<pre>
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4                [current_design]
</pre>

<br />


<hr><!-- horizontal divider -->

<br />

<p align="justify">
Once ready, open Vivado in graphical mode with
</p>

<pre>
% vivado -mode gui &                               (for Linux users)

% echo "exec vivado -mode gui &" | tclsh -norc     (for Windows users)
</pre>

<br />

<p align="justify">
and try to run the FPGA implementation flow in <i>Project Mode</i> up to bitstream generation:
</p>

* create into the current directory a new project named `Gates` targeting the `xc7a35ticsg324-1L` FPGA device
* add the `Gates.v` Verilog file to the project
* add `Gates.xdc` design constraints to the project
* run elaboration and inspect the RTL schematic
* run synthesis and inspect the post-synthesis schematic
* run implementation and inspect place-and-route results into the _Device_ view
* generate the bitstream

<br />

<blockquote>
<p><b>QUESTION</b><p>
<p>Which FPGA device primitives have been used to map the design on real hardware ?</p>
<p>___________________________________________________________________________________</p>
</blockquote>

<br />

<p align="justify">
After the implementation flow has successfully completed <b>locate the bitstream file</b>
to be used for firmware installation.
For this purpose remind that when running Vivado in <i>Project Mode</i> by default both bitstream (.bit) and
raw-binary (.bin) programming files are written by Vivado into the <code>*.runs/impl_1/</code> directory
automatically created by the tool as part of the project tree setup.
</p>

<p align="justify">
Verify at the end of the flow that the bitstream file has been properly generated:
</p>

<pre>
% ls -lh ./Gates.runs/impl_1/ | grep .bit
</pre>

<br />

<blockquote>
<p><b>QUESTION</b><p>
<p>Which is the on-disk size of the bitstream file ?</p>
<p>___________________________________________________________________________________</p>
</blockquote>

<br />

<p align="justify">
Program the FPGA using the Vivado <i>Hardware Manager</i> as discussed in the introductory practicum
and debug the expected functionality of the firmware by playing with slide-switches and LEDs
on the board.
</p>

<br />
<!--------------------------------------------------------------------->


## Run implementation and programming flows from Makefile
[**[Contents]**](#contents)

<p align="justify">
In the introductory practicum we already explored the possibility to run both FPGA implementation and programming flows
in <b>batch mode</b> using Tcl scripts and a <code>Makefile</code>.
</p>

<p align="justify">
For this practicum improved <i>Project Mode</i> Tcl scripts and <code>Makefile</code> have been already prepared for you.
Copy into the current directory the following sources:
</p>

<pre>
% cp .solutions/Makefile    .
% cp .solutions/setup.tcl   .
% cp .solutions/build.tcl   .
% cp .solutions/install.tcl .
</pre>

<br />

<p align="justify">
Once all scripts are in place try to re-run all flows from scratch using the <code>make</code> utility as follows:
</p>

<pre>
% make clean
% make build
% make install
</pre>

<br />

<p align="justify">
Explore the content of the updated scripts with your preferred text editor or using basic
command-line utilities <code>cat</code>, <code>more</code> or <code>less</code>.
</p>

<pre>
% cat Makefile
% cat setup.tcl
% less build.tcl
% less install.tcl
</pre>

<br />

<p align="justify">
As you can notice the proposed updated flow uses a new <code>setup.tcl</code> to specify Tcl variables
that are common to both implementation and programming flows such as the project name
and directory, the top-level RTL module and the target FPGA device.
</p>

<p align="justify">
According to our initial coding conventions for the moment our basic projects only
contain one single Verilog file <code>ModuleName.v</code> and one XDC file <code>ModuleName.xdc</code>.
Therefore a single <code>topModuleName</code> Tcl variable is enough to specify <code>$topModuleName.v</code>
and <code>$topModuleName.xdc</code> input files and to have a more portable flow.
</p>

<p align="justify">
Later in the course we will export all project information as environment variables from <code>Makefile</code>
in a more convenient way.
</p>

<br />
<!--------------------------------------------------------------------->


## Restore a design checkpoint in Vivado
[**[Contents]**](#contents)

<p align="justify">
When running Vivado in <i>Project Mode</i> a so-called <b>design checkpoint (DCP)</b> file
is automatically saved for you by Vivado at each major step of the flow (synthesis, placement and routing).
</p>

<p align="justify">
A design checkpoint is a Vivado-specific <b>binary database</b> with file extension <code>.dcp</code> that
represents a "snapshot" of the entire design at a particular stage of the flow.
As an example, a post-synthesis database contains the synthesized netlist and design constraints, while
a placed or a routed database contains also additional information related to the physical
implementation of the design.
</p>

<p align="justify">
Explore all design checkpoint files that are part of the Vivado project tree:
</p>

<pre>
% ls -lh ./Gates.runs/*/* | grep .dcp
</pre>

<br />

<p align="justify">
By using design checkpoints you can later <b>restore</b> a design project back into Vivado.
</p>

<p align="justify">
Try to restore the "routed" design checkpoint automatically generated for you
by the <code>make build</code> flow. Start a new Vivado session in GUI mode with
the new <code>make gui</code> target:
</p>

<pre>
% make gui
</pre>

<br />

<p align="justify">
Then go through <b>File > Checkpoint > Open...</b> and restore the <code>Gates.runs/impl_1/Gates_routed.dcp</code> database.
</p>

<p align="justify">
Observe the equivalent command in the Tcl console:
</p>

<pre>
open_checkpoint ./Gates.runs/impl_1/Gates_routed.dcp
</pre>

<br />

<p align="justify">
Explore the design in the graphical user interface. Exit Vivado once happy.
</p>

<p align="justify">
A second possibility is to automatically load a design checkpoint by passing
the name of the database as main argument when executing <code>vivado</code>
at the commad line.
</p>

<p align="justify">
As an example, try to restore the post-synthesis design checkpoint with the following command:
</p>

<pre>
% vivado -mode gui ./Gates.runs/synth_1/Gates.dcp
</pre>

<br />

<p align="justify">
Explore the design in the graphical user interface. Exit Vivado before moving to the ring-oscillator implementation.
</p>

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
The proposed circuit uses an AND-gate into the feedback loop to enable/disable the <code>clk</code>
output toggle, thus requiring an <b>odd number</b> $N = 2k + 1$ of inverters
in the chain to oscillate. A simpler version of this design as been already discussed
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

(* dont_touch = "yes" *) not NOT_INST (w[k+1], w[k]) ;
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
to obtain best <b>quality-of-results (QoR)</b> in terms of <b>timing</b>,
<b>power</b> and <b>area</b>.
</p>

<p align="justify">
A ring oscillator needs $N = 2k +1$ (odd number) inverters to oscillate. However if you cascade $2 k$ (even number)
inverters the resulting <b>logic function</b> as expected is a simple identity and the synthesis tool properly
recognizes this. As a result from a design-optimization point of view there is no reason for the synthesis engine
to keep $2 k$ un-necessary inverters out of $2k + 1$ and after its logic optimization the initial circuit
would reduce to a simple AND gate plus an inverter connected in feedback, or equivalently one single NAND gate
connected in feedback.
</p>

<p align="justify">
In order to "force" the synthesis tool to <b>keep all inverters</b> in the chain special
<code>dont_touch</code> statements enclosed within <code>(*</code> and <code>*)</code> are added into RTL
for this purpose. In particular we ask the synthesis tool to "don't touch" and keep all wires
<code>w[0]</code> ... <code>w[N]</code> used for internal connections along with all <code>not</code>
instances in the for-loop. In fact <code>dont_touch</code> can be placed on any signal, module or
instance in your design.
</p>

<br />

<blockquote>

<p><b>IMPORTANT</b></p>

<p align="justify">
As recommended by Xilinx the <code>dont_touch</code> attribute <b>should be set in RTL only</b>.
In fact it might happen that signals or instances that need to be kept can often be optimized
<b>before the XDC file is parsed</b> by the synthesis engine! Therefore, setting this attribute
in the RTL ensures that it is really used and that all signals/instances/modules that you want to keep are effectively
preserved.
</p>

<p align="justify">
Moreover adding <code>dont_touch</code> in RTL is also a <b>good coding practice</b>
because the code is automatically self-documented and when working into a larger design team
it is much easier for the <b>back-end designer</b> (the person in charge of running synthesis and
implementation flows) to know what the <b>front-end designer</b> (who actually writes the RTL code)
wants to keep in the design.
</p>

</blockquote>

<br />

<p align="justify">
There are many other synthesis attributes supported by Xilinx Vivado. A few examples are:
</b>

* `TRANSLATE_OFF/TRANSLATE_ON`
* `KEEP`
* `KEEP_HIERARCHY`
* `RAM_STYLE`
* `ROM_STYLE`
* `MARK_DEBUG`
* `FULL_CASE/PARALLEL_CASE` etc.


<br />

<p align="justify">
Most of these special synthesis directives can be either placed into the RTL code or into the XDC file, however
there are also RTL-only and XDC-only attributes. In Xilinx Vivado these statements are <b>case-insensitive</b> and you can
write them either all-capital or lowercase.
For a complete list of synthesis attributes supported by Xilinx Vivado
refer to the <i>Synthesis Attributes</i> chapter of the <i>Vivado Design Suite User Guide: Synthesis (UG901)</i>:
</p>

_<https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug901-vivado-synthesis.pdf>_

<br />

Please be aware that synthesis pragmas are always tool-specific, therefore always refer to the
official documentation of the synthesis tool that you are working with.

<br />

<p>
<b>DESIGN CONSTRAINTS</b>
</p>

<p align="justify">
Beside the usage of <code>dont_touch</code> synthesis pragmas we also need <b>special timing constraints</b> to successfully
generate a bitstream file to program the FPGA.
</p>

<p align="justify">
The ring-oscillator is a combinational circuit that by purpose uses a "feedback" in the inverter chain in order to oscillate.
However this feedback also introduces a <b>timing loop issue</b> detected by the <b>Static Timing Analysis (STA) engine</b>
that Vivado runs during synthesis and physical implementation (place-and-route) flows to compute propagation delays and
to check the timing.
</p>

<p align="justify">
Combinational timing loops are created whenever the output of a combinational circuit is fed back to its input, resulting
in a timing loop. This loops unnecessarily increase the number of cycles by infinitely going around the same path and
the propagation delay cannot be computed by the STA tool.
</p>

<p align="justify">
As a result despite we already disable all timing checks in the constraints file with
</p>

<pre>
set_false_path -from [all_inputs] -to [all_outputs]
</pre>

<br />

<p align="justify">
the following statement is required to resolve the timing loop and let Vivado to complete
the implementation flow and to generate the bitstream:
</p>

<pre>
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets w* ]
</pre>

<br />

<p align="justify">
Without this statement the flow runs up to synthesis but later Vivado rises an error at the end of the implementation.
You can easily confirm this by running the <code>build</code> flow at the command-line using the <code>make</code>
utility with/without this <code>ALLOW_COMBINATORIAL_LOOPS</code> property as described below.
</p>

<p align="justify">
Please refer to the <i>Vivado Design Suite User Guide: Design Analysis and Closure Techniques (UG906)</i>
for more details about timing analysis and results in Xilinx Vivado:
</p>


_<https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug906-vivado-design-analysis.pdf>_

<br />


<p>
<b>FPGA IMPLEMENTATION AND FIRMWARE DEBUG</b>
</p>

<p align="justify">
Before running the FPGA implementation flow modify with your preferred <b>text-editor</b> the main
project setup script <code>setup.tcl</code>

<pre>
% gedit setup.tcl &   (for Linux users)

% n++ setup.tcl       (for Windows users)
</pre>

<br />

<p align="justify">
and update the values set for <code>projectName</code> and <code>topModuleName</code> variables as follows:
</p>

<pre>
#set projectName {Gates}
set projectName {RingOscillator}

...

#set topModuleName {Gates}
set topModuleName {RingOscillator}
</pre>


<br />

<p align="justify">
Save the file after modifications. Once ready launch the flow at the command line with:
</p>

<pre>
% make clean
% make build
</pre>

<br />


<p align="justify">
After the implementation has successfully completed install the firmware to the FPGA board with:
</p>

<pre>
% make install
</pre>

<br />

<p align="justify">
Verify the functionality of the ring-oscillator you have mapped on real hardware.
Use the <b>SW0</b> slide-switch assigned to the <code>start</code> Verilog input port
to enable/disable the oscillator and probe the <code>clk</code> signal at the oscilloscope.
Verify that the <b>LD4</b> general-purpose standard LED properly turns on/off to indicate
that the oscillator is running or not. An additional <code>start_probe</code> Verilog output
is available to also display <code>start</code> at the oscilloscope. 
</p>

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
Disable the ring-oscillator by setting <code>start</code> to logic 0 with the slide-switch
and ensure that the status-led turns off.
Then open the <b>Trigger Menu</b> and switch the trigger-mode from <b>Auto</b> (default)
to <b>Normal</b>. Ensure that a positive-edge transition is used as
trigger condition. Finally select the channel used to display the
<code>start_probe</code> Verilog output port for the trigger and enable the ring-oscillator.
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
<p>___________________________________________________________________________________</p>
</blockquote>

<br />

<p align="justify">
Modify the <code>RingOscillator.xdc</code> file by commenting out the <code>set_property</code> statement
setting the<code>ALLOW_COMBINATORIAL_LOOPS</code> property as follows:
</p>

<pre>
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets w* ]
</pre>

<br />

<p align="justify">
Save and try to re-run the flow from scratch with:
</p>

<pre>
% make clean build
</pre>

<br />


<p align="justify">
Observe the following <b>Design Rule Check (DRC) error</b> generated by Vivado when the <code>write_bitstream</code> command
is invoked at the end of the flow:
</p>

<pre>
ERROR: [DRC LUTLP-1] Combinatorial Loop Alert: 284 LUT cells form a combinatorial loop. This can create a race condition.
Timing analysis may not be accurate. The preferred resolution is to modify the design to remove combinatorial logic loops.
If the loop is known and understood, this DRC can be bypassed by acknowledging the condition and setting the following
XDC constraint on any one of the nets in the loop: 'set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets <myHier/myNet>]'.
One net in the loop is xxx. Please evaluate your design. The cells in the loop are: xxx ...
</pre>

<br />

<p align="justify">
Restore the XDC file back to its initial version by removing the extra comment character <code>#</code> added before. Do not
forget to save your file after modifications. 
</p>

<pre>
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets w* ]
</pre>

<br />
<!--------------------------------------------------------------------->


## Exercises
[**[Contents]**](#contents)

<br />

**EXERCISE 1**

<p align="justify">
The number of inverters in the ring-oscillator chain determines the <b>frequency</b> of the <code>clk</code>
output toggle. Since <code>NUM_INVERTERS</code> is a Verilog <code>parameter</code> you can easily change this number
and perform a study of the <b>frequency vs. number of inverters</b> relationship.
</p>


<p align="justify">
Let suppose $t_p$ the propagation delay of a single inverter cell. The total input-to-output propagation delay (half-period)
for a cascade of $N$ inverters is therefore:
</p>

$$
\frac{T}{2} = N t_p
$$

<p align="justify">
As a result the expected oscillation frequency is:
</p>

$$
f_{osc} = \frac{1}{T} = \dfrac{1}{2 N t_p}
$$

<p align="justify">
Hence the frequency shoul be proportional to $1/N$:

$$
f_{osc} \propto \frac{1}{N}
$$

<p align="justify">
In the proposed implementation we have one additional propagation delay in the feedback loop
due to the presence of the AND control gate.
Indeed we can assume that the AND and the inverters have comparable propagation delays.
This is also a reasonable assumption since at end all cells are mapped to LUT primitives inside the FPGA.
As a result we can expect that:
</p>

$$
f_{osc} \approx \frac{1}{2 (N + 1) t_p } \propto \frac{1}{N+1}
$$

<p align="justify">
You can therefore map to FPGA the ring-oscillator for different values of <code>NUM_INVERTERS</code>, measure at the oscilloscope
the frequency of the <code>clk</code> output toggle and verify with a <b>linear fit</b> the
expected linear trend versus $1/(N+1)$. Given the large number of inverters in the chain we can also simply approximate
$N + 1 \approx N$ and perform the study versus $1/N$.
</p>

<p align="justify">
Open the <code>RingOscillator.v</code> Verilog code with your preferred text editor application and run the FPGA implementation
and programming flows at the command line by exploring 5-10 different <code>NUM_INVERTERS</code> values.
At the end of each implementation install the new firmware to the FPGA and measure at the oscilloscope
the frequency of the output toggle.
</p>

<p align="justify">
In order to significantly change the frequency you have to generate the firmware for $\approx 2N_0$ , $\approx 3N_0$ ... $\approx 5N_0$ etc.
assuming $N_0$ the initial value chosen for you for <code>NUM_INVERTERS</code> in the Verilog code.
</p>

<p align="justify">
Most important, be always sure that <code>NUM_INVERTERS</code> is an <b>odd number</b>, otherwise the circuit will never oscillate!
As an example:
</p>

<br />

|   $N$    |   $f_{osc}$   |
|:--------:|:-------------:|
|   283    |      ...      |
|   567    |      ...      |
|   849    |      ...      |
|   1133   |      ...      |
|   1417   |      ...      |
|   ...    |      ...      |
|   ...    |      ...      |

<br />

The overall procedure can be summarized as follows:

* stop the ring-oscillator on the _Arty_ board
* change `NUM_INVERTERS` in the `RingOscillator.v` Verilog code
* save the modified Verilog file after your changes
* generate the bitstream (`make build`)
* install the firmware (`make install`)
* enable the ring-oscillator
* measure at the oscilloscope the frequency of the output toggle
* repeat for 5-10 different **odd** values of `NUM_INVERTERS`

<br />

<blockquote>

<p><b>IMPORTANT</b></p>

<p align="justify">
After each measurement <b>disable the ring-oscillator</b> by setting <code>start</code> to logic 0 with the corresponding slide
switch and ensure that the status led turns-off. At the end of the <code>make install</code> flow restart the oscillator.
If you don't restart the oscillator whenever a new firmware is installed the output toggle seen at the oscilloscope
remains corrupted!
</p>
</blockquote>


<br />

<p align="justify">
Create a new directory for your data analysis developments:
</p>

<pre>
% mkdir data
</pre>

<br />

<p align="justify">
Use <b>ROOT</b> for your data analysis and make <code>TGraph</code> plots for the frequency vs. $(N+1)$
and for the frequency vs. $1/(N+1)$. Verify the expected linearity of the characteristic with a fit.
</p>

<br />

<blockquote>
<p><b>HINT</b></p>

<p align="justify">
Simple plots of experimental data in form of y-values vs. x-values in ROOT are implemented using the <code>TGraph</code> class,
which also allows to <b>read and plot measurements data from a text file</b>.
</p>

<p align="justify">
With your text-editor application create a new text file e.g. <code>data/RingOscillator.dat</code> and register your
measurements as follows:
</p>

<pre>
# N  Fosc
283  ...
567  ...
849  ...
1133 ...
1417 ...
...  ...
...  ...
</pre>

<br />


<p align="justify">
Start an <b>interactive ROOT session</b> at the command line:

<pre>
% root -l
</pre>

<br />

<p>
Plot the characteristic interactively with:
</p>

<pre>
root[] TGraph gr("data/RingOscillator.dat")
root[] gr.Draw("ALP")
</pre>

<br />

<p align="justify">
Alternatively you can place your measurements into <b>standard C/C++ arrays</b> and use them
into the <code>TGraph</code> constructor:
</p>

<pre>
root[] int Npt = ...
root[] double xData[Npt] = {283 , 567 , 849 , 1133 , 1415 ... }
root[] double yData[Npt] = { ... }
root[] TGraph gr(Npt,xData,yData)
root[] gr.Draw("ALP")
</pre>

</blockquote>

<br />


<p align="justify">
Sample <b>ROOT un-named scripts</b> have been already prepared for you as a reference starting point for your analysis. You
can copy a first example code from the <code>sample/</code> directory at the top of the Git repository as follows:
</p>

<pre>
% cp ../../../sample/ROOT/plotDataArray.cxx .
</pre>

<br />

Ask to the teacher if you are not confident in using the ROOT software.

<br />

**EXERCISE 2**

<p align="justify">
The proposed ring-oscillator implementation uses <code>NUM_INVERTERS</code> specified as a Verilog <b>module parameter</b>.
Another possibility to easily change the number of inverters in the chain is to define and later use <code>NUM_INVERTERS</code>
as a Verilog <b>macro</b> with the following syntax:
</p>

<pre>
`define NUM_INVERTERS 237 
</pre>

<br />

<p align="justify">
Try yourself to modify the <code>RingOscillator.v</code> code in order to use this Verilog feature. For this purpose it might be useful
to remind that the <b>value</b> of a Verilog macro is accessed in the code with the <b>back-tick</b> character <code>`</code> followed
by the <b>name</b> of the macro. As an example:
</p>

<pre>
(* dont_touch = "yes" *) wire [`NUM_INVERTERS:0] w ;
</pre>

<br />

**EXERCISE 3**

Try yourself to implement and debug a simple <b>full-adder</b> combinational block.

<pre>
assign {Cout, Sum}  = A + B + Cin ;
</pre>

<br />
<!--------------------------------------------------------------------->

