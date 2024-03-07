//
// Verilog code for a simple D-FlipFlop. Modify the sensitivity list of the
// always block in order to switch between synchronous and asynchronous reset.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module DFF (

   input  wire clk,   // clock
   input  wire rst,   // reset, active-high (then can be synchronous or asynchronous according to sensitivity list)
   input  wire D,
   output reg  Q,
   output wire Qbar

   ) ;

   // **NOTE: can be replaced by 'always_ff' in SystemVerilog

/*

   // simple FlipFlop without reset
   always @(posedge clk) begin
      Q <= D ;
   end ;

*/


   //always @(posedge clk) begin                       // synchronous reset
   always @(posedge clk or posedge rst) begin      // asynchronous reset

      if (rst) begin      // same as if (rst == 1'b1)
         Q <= 1'b0 ;      // **NOTE: inside clocked always blocks use a NON-BLOCKING assignment <= instead of a BLOCKING assignment =
      end
      else begin
         Q <= D ;
      end
   end  // always

   // inverted output
   assign Qbar = ~ Q ;

endmodule
