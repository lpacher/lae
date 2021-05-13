
# Lab 7 Instructions
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/labs)]

## Contents

* [**Introduction**](#introduction)
* [**Lab aims**](#lab-aims)
* [**Navigate to the lab directory**](#navigate-to-the-lab-directory)
* [**Setting up the work area**](#setting-up-the-work-area)
* [**Copy scripts**](#copy-scripts)
* [**RTL coding**](#rtl-coding)
* [**Simulate the design**](#simulate-the-design)
* [**Clock management issues**](#clock-management-issues)
* [**Compile a Phase-Locked Loop (PLL) IP core**](#compile-a-phase-locked-loop-pll-ip-core)
* [**Exercises**](#exercises)

<br />
<!--------------------------------------------------------------------->


## Introduction
[**[Contents]**](#contents)

In this lab we implement and simulate a **parameterizable Binary-Coded Decimal (BCD) counter** using Verilog.
For this purpose we introduce the new `generate` for-loop construct to **replicate a certain module or primitive**
an arbitrary number of times. We also use this very simple example synchronous design to discuss some **good and bad FPGA design practices**
related to **clock management** and **physical implementation**. Finally we will add to the design a **Phase-Locked Loop (PLL) IP core**.

<br />
<!--------------------------------------------------------------------->


## Lab aims
[**[Contents]**](#contents)

This lab should exercise the following concepts:

* learn how to implement counters in Verilog
* introduce the `generate` for-loop statement to replicate instances
* understand good and bad RTL coding practices for timing closure in synchronous digital designs
* launch the Vivado IP flow
* compile a Phase-Locked Loop (PLL) IP for clock management

<br />
<!--------------------------------------------------------------------->


## Navigate to the lab directory
[**[Contents]**](#contents)

Open a **terminal** window and change to the `lab7/` directory:

```
% cd Desktop/lae/fpga/labs/lab7
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

Explore available targets:

```
% make help
```

<br />

>
> **QUESTION**
>
> Do you recognize new targets implemented in the `Makefile` ? <br /><br />
>
>   \____________________________________________________________________________________________________
>

<br />

Create a new fresh working area:

```
% make area
```

<br />
<!--------------------------------------------------------------------->


## Copy scripts
[**[Contents]**](#contents)

Copy from the `.solutions/` directory all **Tcl simulation scripts** already prepared for you:

```
% cp .solutions/scripts/sim/compile.tcl    scripts/sim/
% cp .solutions/scripts/sim/elaborate.tcl  scripts/sim/
% cp .solutions/scripts/sim/simulate.tcl   scripts/sim/
% cp .solutions/scripts/sim/probe.tcl      scripts/sim/
% cp .solutions/scripts/sim/run.tcl        scripts/sim/
% cp .solutions/scripts/sim/relaunch.tcl   scripts/sim/
```

<br />

For less typing, you can also use the **wildcard character** `*` as follows:

```
% cp .solutions/scripts/sim/*.tcl   scripts/sim/
```

<br />

> **REMINDER**
>
> If you want to use the asterisk `*` as **wildcard** for `cp` on Windows, please be aware that the `cp.exe` executable
> that comes with the _GNU Win_ package works properly **only using forward slashes** `/` **in the path!**
>
> ```
> % cp .solutions/scripts/sim/*.tcl   scripts/sim/
> ```
>
> If you use the **TAB completion** on Windows the path is completed using **back slashes** `\` but the resulting command **DOESN'T WORK and generates an error**
> because back-slashes `\` are interpreted as **escape characters** by `cp.exe`:
>
> ```
> % cp .solutions\scripts\sim\*.tcl   scripts\sim\
>
> cp: cannot stat '.solutionsscriptssim*.tcl' : No such file or directory
> ```
>
> You can use the native `copy` **DOS command** instead:
>
> ```
> % copy .solutions\scripts\sim\*.tcl   scripts\sim\
> ```
>

<br />


Additionally, copy from the `.solutions/` directory the following **Tcl common scripts**:


```
% cp .solutions/scripts/common/variables.tcl   scripts/common
% cp .solutions/scripts/common/part.tcl        scripts/common
% cp .solutions/scripts/common/init.tcl        scripts/common
% cp .solutions/scripts/common/ip.tcl          scripts/common
```

<br />


For less typing use:

```
% cp .solutions/scripts/common/*.tcl   scripts/common/
```

<br />

Verify that all required scripts are in place:

```
% ls -l scripts/common/
% ls -l scripts/sim/
```

<br/>
<!--------------------------------------------------------------------->


## RTL coding
[**[Contents]**](#contents)

With your **text editor** application create a first new Verilog file `rtl/CounterBCD.v` with the following content:


```verilog
`timescale 1ns / 100ps

module BCD_counter_en (

   input  wire clk,
   input  wire rst,
   input  wire  en,
   output reg [3:0] BCD,
   output wire carryout 

   ) ;
   

   always @(posedge clk) begin                              // synchronous reset
   //always @(posedge clk or posedge rst) begin 	    // asynchronous reset

      if( rst == 1'b1 )
         BCD <= 4'b0000 ;

      else begin

         if( en == 1'b1 ) begin      // let the counter to increment only if enabled !

            if( BCD == 4'b1001 )     // force the count roll-over at 9
               BCD <= 4'b0000 ;
            else
               BCD <= BCD + 1'b1 ;
         end

      end
   end // always


   assign carryout = ( BCD == 4'b1001 ) ? 1'b1 : 1'b0 ;

endmodule
```

<br />


Create also a second Verilog source `rtl/CounterBCD_Ndigit.v` with the following content:

```verilog
`timescale 1ns / 100ps

module CounterBCD_Ndigit #(parameter integer Ndigit = 4) (

   input   wire clk,
   input   wire rst,
   input   wire en,
   output  wire [Ndigit*4-1:0] BCD

   ) ;


   wire [Ndigit:0] w ;   // wires to inteconnect BCD counters each other

   assign w[0] = en ;

   generate

      genvar k ;

      for(k = 0; k < Ndigit; k = k+1) begin : digit  

         CounterBCD   digit (

            .clk      (             clk ),
            .rst      (             rst ),
            .en       (            w[k] ),
            .BCD      (  BCD[4*k+3:4*k] ),
            .carryout (          w[k+1] )

         ) ;

      end // for

   endgenerate

endmodule
```

<br />
<!--------------------------------------------------------------------->


## Simulate the design
[**[Contents]**](#contents)

Simulation sources have been already prepared for you, copy from the `.solutions/` directory the following **testbench sources** :


```
% cp .solutions/bench/ClockGen.v               ./bench
% cp .solutions/bench/tb_BCD_counter_Ndigit.v  ./bench
```


Compile, elaborate and simulate the design with :

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
<!--------------------------------------------------------------------->


## Clock management issues
[**[Contents]**](#contents)

<br />
<!--------------------------------------------------------------------->


## Compile a Phase-Locked Loop (PLL) IP core
[**[Contents]**](#contents)

<br />
<!--------------------------------------------------------------------->



## Exercises
[**[Contents]**](#contents)


Modify the code of the parameterized N-digit BCD counter in order to introduce an additional **"end of scale" flag** `eos` asserted
when 9999 ...9 is reached. As an example you can use the Verilog **replication operator** with the following syntax :

```verilog
// generate end-of-scale flag when 9999 ... 9 is reached
assign eos = ( BCD == {Ndigit{4'b1001}} ) ? 1'b1 : 1'b0 ;      // use Verilog replication operator to replicate 4'1001 N times
```

Alternatively you can generate a true **"overflow" flag** `overflow` by registering in a FlipFlop the true carry-out flag of the most-significant
BCD counter :

```verilog
// generate overflow flag
always @(posedge clk) begin

   if(rst == 1'b1) begin
      overflow <= 1'b0 ;
   end
   else begin
      overflow <= ( w[Ndigit] == 1'b1 ) ;
   end
end   // always
```

In required, this flag can be than used to **stop and freeze the counter** when an overflow is detected.


## Exercise

Modify the testbench in order to count **only once every 1 us** but **without changing the main 100 MHz clock frequency**.
Create a new **"ticker" module** using an additional **modulus-N free-running counter** to generate a **single clock-pulse "tick"**
every 1 us to be used as **count-enable** instead.

As an example :

```verilog
`timescale 1ns / 100ps

module TickCounter #(parameter integer MAX = 10414) (      // default is ~9.6 kHz as for UART baud-rate

   input  wire clk,      // assume 100 MHz input clock
   output reg  tick      // single clock-pulse output

   ) ;


   reg [31:0] count = 32'd0  ;      // **IMPORTANT: unused bits are simply DELETED by the synthesizer !

   always @(posedge clk) begin

      if( count == MAX-1 ) begin

         count <= 32'd0 ;           // force the roll-over
         tick  <= 1'b1 ;            // assert a single-clock pulse each time the counter resets

      end
      else begin

         count <= count + 1'b1 ;
         tick  <= 1'b0 ;

      end    // if
   end   // always

endmodule
```

<hr>

**IMPORTANT**

This is an example of a **good RTL coding practice** in pure synchronous digital systems design. In fact, whenever you
need to **"slow down"** the speed of the data processing in your design you should **avoid to generate additional clocks** by means of
counters, clock-dividers or even a dedicated clock manager.<br/>
Generate a **single clock-pulse "tick"** to be used as **"enable"** for the data processing in your synchronous logic instead.

<hr>


## Extra code

The complete code for a 3-bit BCD counter driving a **7-segment display device** is also part of RTL solutions.

Inspect the content of `.solutions/rtl/SevenSegmentDisplayDecoder.v` and `.solutions/rtl/Ndigit_7seg_display.v` Verilog sources and try to understand
the structure of the overall design.
