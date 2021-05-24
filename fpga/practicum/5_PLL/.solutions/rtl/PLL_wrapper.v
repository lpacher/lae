//
// Verilog code to demonstrate the functionality of a PLL IP core on real FPGA hardware.
// The code "wraps" a compiled Xilinx PLL core that generates 4x different lower-frequency
// clocks starting from the available 100 MHz on-board oscillator. A non-trivial hard-coded
// 4:1 multiplexer is then use to select the PLL output clock sent to the oscilloscope.
// The PLL "locked" signal can be also probed at the oscilloscope for debug purposes.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module PLL_wrapper (

   input wire clk,                   // assume 100 MHz clock frequency from on-board oscillator
   input wire rst,                   // PLL reset, mapped to push-button BTN0
   input wire [1:0] sel,             // 2-bit clock MUX selector, mappep to slide-switches SW0 and SW1

   // PLL signals
   output wire pll_clk, pll_locked   // observe PLL output signals at the oscilloscope

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   // PLL output clocks
   wire pll_clk_0 ;       // 34.0 MHz
   wire pll_clk_1 ;       // 17.5 MHz
   wire pll_clk_2 ;       // 12.0 MHz
   wire pll_clk_3 ;       //  5.0 MHz

   PLL  PLL_inst (

      .clk_in     (        clk ),
      .reset      (        rst ),
      .clk_out_0  (  pll_clk_0 ),
      .clk_out_1  (  pll_clk_1 ),
      .clk_out_2  (  pll_clk_2 ),
      .clk_out_3  (  pll_clk_3 ),
      .locked     ( pll_locked )

      ) ;


   ///////////////////////////////////////////
   //   NON-TRIVIAL 4:1 MUX on clock path   //
   ///////////////////////////////////////////

   //
   // **IMPORTANT
   //
   // If you try to implememt the 4:1 MUX using RTL code the FPGA implementation flows stops with a placement error.
   // This is due to the fact that clock signals are considered by the tool as "global" signals and you cannot
   // buffer too many different clock signals inside a single CLB.
   // The workaround is to use the dedicated Xilinx BUFGMUX FPGA primitive to build "by hand" a 4:1 multiplexer
   // with PLL output clock as inputs.
   // Additionally, set the CLOCK_DEDICATED_ROUTE property on MUX internal outputs to force the placement flow to continue.
   //

   wire [2:0] bufgmux_out ;

   (* DONT_TOUCH = "yes" *)
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) BUFGMUX_0 ( .S(sel[0]), .I0(pll_clk_0), .I1(pll_clk_1), .O(bufgmux_out[0]) ) ;

   (* DONT_TOUCH = "yes" *)
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) BUFGMUX_1 ( .S(sel[0]), .I0(pll_clk_2), .I1(pll_clk_3), .O(bufgmux_out[1]) ) ;

   // combine BUFGMUX_0 and BUFGMUX_1 outputs into a single output using a third BUFGMUX primitive

   (* DONT_TOUCH = "yes" *)
   BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) BUFGMUX_2 ( .S(sel[1]), .I0(bufgmux_out[0]), .I1(bufgmux_out[1]), .O(bufgmux_out[2]) ) ;

   assign pll_clk = bufgmux_out[2] ;


/*
   reg clk_mux ;

   always @(*) begin

      case (sel[1:0])

         2'b00 : clk_mux = pll_clk_0 ;
         2'b01 : clk_mux = pll_clk_1 ;
         2'b10 : clk_mux = pll_clk_2 ;
         2'b11 : clk_mux = pll_clk_3 ;

      endcase
   end

   assign pll_clk = clk_mux ;

*/

   // **DEBUG
   //assign pll_clk = pll_clk_0 ;
   //assign pll_clk = pll_clk_1 ;
   //assign pll_clk = pll_clk_2 ;
   //assign pll_clk = pll_clk_3 ;

endmodule

