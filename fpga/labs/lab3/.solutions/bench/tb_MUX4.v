//
// Testbench for a MUX4 module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_MUX4 ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk ;

   ClockGen #(.PERIOD(50.0)) ClockGen (.clk(clk)) ;


   ////////////////////////////////////
   //   6-bits synchronous counter   //
   ////////////////////////////////////

   reg [5:0] count = 6'b000_000 ;

   always @(posedge clk)
      count <= count + 1'b1 ;           // **WARN: be aware of the casting ! This is count[2:0] <= count[2:0] + 1'b1 !


   /////////////////////////////////
   //   device under test (DUT)   //
   /////////////////////////////////

   wire Z;

   MUX4  DUT (.D(count[3:0]), .S(count[5:4]), .Z(Z)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #(64*50.0) $finish ;   // explore all 64 counter values, then stop the simulation
   end

endmodule

