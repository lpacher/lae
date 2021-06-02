//
// Example clock-generator with parameterized period.
//
// Luca Pacher - pacher@to.infn,it
// May 8, 2020
//
// **NOTE: Default clock frequency is 100 MHz (Digilent Arty A7 on-board master clock)
//


`timescale 1ns / 100ps

module ClockGen #(parameter real PERIOD = 10.0) (

   output reg clk

   ) ;

   // clock-generator using a forever statement inside initial block
   initial begin

      clk = 1'b0 ;

      forever #(PERIOD/2.0) clk = ~ clk ;
   end

endmodule

