//
// Example clock-generator in Verilog with parameterized clock period.
//
// The default clock frequency is 100 MHz (Digilent Arty A7 on-board
// master clock from XTAL oscillator).
//
// Luca Pacher - pacher@to.infn,it
// Fall 2020
//

`ifndef CLOCK_GEN__V   // include guard
`define CLOCK_GEN__V


`timescale 1ns / 100ps

module ClockGen #(parameter real PERIOD = 10.0) (

   output reg clk

   ) ;


   // alternatively, parameters can be declared after the module port declaration (original Verilog-95 standard)
   //parameter real PERIOD = 10.0 ;


   // clock-generator using a forever statement inside initial block
   initial begin

      clk = 1'b0 ;

      forever #(PERIOD/2.0) clk = ~ clk ;
   end

endmodule

`endif   //CLOCK_GEN__V
