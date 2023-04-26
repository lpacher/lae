
# Lab 4 Instructions
[[**Home**](https://github.com/lpacher/lae)] [[**Back**](https://github.com/lpacher/lae/tree/master/fpga/labs)]

## Contents

* [**Introduction**](#introduction)
* [**Lab aims**](#lab-aims)
* [**Navigate to the lab directory**](#navigate-to-the-lab-directory)
* [**Setting up the work area**](#setting-up-the-work-area)
* [**Copy simulation scripts**](#copy-simulation-scripts)
* [**RTL coding**](#rtl-coding)
* [**Simulate the design**](#simulate-the-design)
* [**Exercises**](#exercises)

<br />
<!--------------------------------------------------------------------->


## Introduction
[**[Contents]**](#contents)

In this lab we complete our discussion about combinational circuits and we implement a simple **5b/32b binary to one-hot decoder**
to show the usage of the Verilog `for` loop statement.

<br />
<!--------------------------------------------------------------------->


## Lab aims
[**[Contents]**](#contents)

This lab should exercise the following concepts:

* introduce the Verilog `for` loop statement
* implement and simulate a more complex example of combinational block in Verilog

<br />
<!--------------------------------------------------------------------->


## Navigate to the lab directory
[**[Contents]**](#contents)

Open a **terminal** window and change to the `lab4/` directory:

```
% cd Desktop/lae/fpga/labs/lab4
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

To create a new fresh working area, type:

```
% make area
```


<br />
<!--------------------------------------------------------------------->


## Copy simulation scripts
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

Verify that all required scripts are in place:

```
% ls -l scripts/sim/
```

<br/>

## RTL coding
[**[Contents]**](#contents)

Create a new Verilog file `rtl/OneHotDecoder.v` with your preferred text editor:

```
% gedit rtl/OneHotDecoder.v &   (for Linux users)

% n++ rtl\OneHotDecoder.v       (for Windows users)
```

<br />

Implement the functionality of a **binary to one-hot decoder** using a Verilog `for` loop statement as follows:

```verilog
//
// Behavioural implementation using for-loop of a 5-bit/32-bit one-hot decoder.
//


`timescale 1ns / 100ps

module OneHotDecoder (

   input  wire [4:0]  Bin,      //  5-bit base-2 binary input code
   output reg  [31:0] Bout      // 32-bit one-hot output code

   ) ;


   integer i ;

   always @(*) begin

      for(i=0; i < 32; i=i+1) begin

         Bout[i] = (Bin[4:0] == i) ;      // this is equivalent to (Bin[4:0] == i) ? 1'b1 : 1'b0 ;

      end  // for
   end  // always

endmodule
```

<br />
<!--------------------------------------------------------------------->


## Simulate the design
[**[Contents]**](#contents)

We can easily verify the proper functionality of the decoder by using a 5-bit counter to generate a base-2 binary word fed to the decoder.<br />
All simulation sources have been already prepared for you and can be copied from the `.solutions/` directory as follows:

```
% cp .solutions/bench/ClockGen.v           bench/
% cp .solutions/bench/tb_OneHotDecoder.v   bench/
```

<br />


Open the main testbench file with your text editor and inspect the following code:


```verilog
//
// Testbench module for 5-bit/32-bit one-hot decoder.
//


`timescale 1ns / 100ps

module tb_OneHotDecoder ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   parameter real clk_period = 20.0 ;

   wire clk ;

   ClockGen  #( .PERIOD(clk_period))  ClockGen ( .clk(clk) ) ;


   ///////////////////////
   //   5-bit counter   //
   ///////////////////////

   reg [4:0] count = 5'd0 ;

   always @(posedge clk)
      count <= count + 1'b1 ;


   /////////////////////////////////
   //   device under test (DUT)   //
   /////////////////////////////////

   wire [31:0] code ;

   OneHotDecoder  DUT (.Bin(count[4:0]), .Bout(code[31:0]) ) ;


   //////////////////
   //   stimulus   //
   //////////////////

   initial begin

      #(64*clk_period) $finish ;   // explore all possible input codes, then stop

   end


   //////////////////////////////////////
   //   text-based simulation output   //
   //////////////////////////////////////

   initial begin
      $monitor("%d ns   %b   %b", $time, count, code) ;
   end


endmodule
```

<br />

Try to simulate the design from the command line:

```
% make sim
```
<br />

Debug simulation results in the XSim graphical interface. Close the simulator once happy.

<br />
<!--------------------------------------------------------------------->


## Exercises
[**[Contents]**](#contents)

<br />

**EXERCISE 1**

Create a new Verilog source file `rtl/ThemometerDecoder.v`. Modify the behavioral description
of the one-hot decoder in order to implement a **5b/32b binary to thermometer decoder** instead.

Reuse the previous testbench to check the proper functionality of the block by updating the instantiation
of the module under test:

```
//OneHotDecoder  DUT ( .Bin(count[4:0]), .Bout(code[31:0]) ) ;
ThermometerDecoder  DUT ( .Bin(count[4:0]), .Bout(code[31:0]) ) ;
```

<br />

Update also the values of `RTL_TOP_MODULE` and `RTL_VLOG_SOURCES` variables in the `Makefile` to simulate the new combinational block:

```
#RTL_TOP_MODULE := OneHotDecoder
RTL_TOP_MODULE := ThermometerDecoder

...
...

#RTL_VLOG_SOURCES := $(RTL_DIR)/OneHotDecoder.v
RTL_VLOG_SOURCES := $(RTL_DIR)/ThermometerDecoder.v
```

<br />

Re-compile and re-simulate the design:

```
% make clean
% make sim
```

<br />

**EXERCISE 2**

Create a new Verilog source file `rtl/GrayDecoder.v`. Try yourself to implement and
simulate a **4b/4b binary-to-Gray decoder**. This functionality can be implemented using
simple `assign` statements:

```verilog
// MSB
assign GrayOut[N-1] = Bin[N-1] ;   // same as GrayOut[N-1] = Bin[N-1] ^ 1'b0

// LSB to MSB-1
assign GrayOut[0] = Bin[0] ^ Bin[1] ;
assign GrayOut[1] = Bin[1] ^ Bin[2] ;
...
...
assign GrayOut[N-2] = Bin[N-2] ^ Bin[N-1] ;
```

<br />

which is equivalent to a XOR between the binary input word `Bin` and the same word right-shifted by one position
using the right-shift `>>` operator:

<br />

``` verilog
assign GrayOut = (Bin >> 1) ^ Bin ;
``` 

<br />

Indeed since there is a recursive formula a for-loop statement can be also used to implement this functionality.
The following code-snippet can be used as an example starting point:

<br />

```verilog
always @(*) begin

   // MSB
   GrayOut[N-1] = Bin[N-1] ;

   // LSB to MSB-1
   for(i=0; i < N-1; i=i+1) begin
      GrayOut[i] = Bin[i] ^ Bin[i+1] ;
   end
end   //always
```

<br />

