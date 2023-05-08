//
// Example Verilog implementation for a simple 4-bit asynchronous ripple counter using structural code.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2022
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

//_______________________________________________________________


`timescale 1ns / 100ps

module RippleCounter4b (

   input  wire clk, rst,
   output wire [3:0] Q

   ) ;

   // 4-bit bus for internal wiring
   wire [3:0] Qbar ;


   ////////////////////
   //   up-counter   //
   ////////////////////

   DFF  ff_0 ( .rst( rst ), .clk( clk     ), .D( Qbar[0] ), .Q( Q[0] ), .Qbar( Qbar[0]) ) ;
   DFF  ff_1 ( .rst( rst ), .clk( Qbar[0] ), .D( Qbar[1] ), .Q( Q[1] ), .Qbar( Qbar[1]) ) ;
   DFF  ff_2 ( .rst( rst ), .clk( Qbar[1] ), .D( Qbar[2] ), .Q( Q[2] ), .Qbar( Qbar[2]) ) ;
   DFF  ff_3 ( .rst( rst ), .clk( Qbar[2] ), .D( Qbar[3] ), .Q( Q[3] ), .Qbar( Qbar[3]) ) ;


   //////////////////////
   //   down-counter   //
   //////////////////////

   //DFF  ff_0 ( .rst( rst ), .clk( clk  ), .D( Qbar[0] ), .Q( Q[0] ), .Qbar( Qbar[0]) ) ;
   //DFF  ff_1 ( .rst( rst ), .clk( Q[0] ), .D( Qbar[1] ), .Q( Q[1] ), .Qbar( Qbar[1]) ) ;
   //DFF  ff_2 ( .rst( rst ), .clk( Q[1] ), .D( Qbar[2] ), .Q( Q[2] ), .Qbar( Qbar[2]) ) ;
   //DFF  ff_3 ( .rst( rst ), .clk( Q[2] ), .D( Qbar[3] ), .Q( Q[3] ), .Qbar( Qbar[3]) ) ;

endmodule
