//
// Simple testbench to simulate basic logic gates with different implementations.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_Gates ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   reg clk = 1'b0 ;              // note that we can also initialize a 'reg' to some initial value when declared

   // 100 MHz clock toggle
   always #5.0 clk = ~ clk ;     // simply "toggle" the clk value every 1/2 period 

   //
   // a better solution is to avoid hard-coded "magic numbers", use Verilog PARAMETERS instead
   //
   //parameter real PERIOD = 10.0 ;
   //always #(PERIOD/2.0) clk = ~ clk ;   // force the toggle each PERIOD/2
   //


   ////////////////////////
   //   2-bits counter   //
   ////////////////////////

   reg [1:0] count = 2'b00 ;

   always @(posedge clk)
      count <= count + 1 ;    // **WARN: be aware of the implicit casting! This is count[1:0] <= count[1:0] + 32'b1 since 1 is a 32-bit integer! Use + 1'b1 to avoid bad surprises!


   /////////////////////////////////
   //   device under test (DUT)   //
   /////////////////////////////////

   wire [5:0] Z;

   Gates           DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;      // **UNCOMMENT** here the DUT that you want to simulate
   //GatesCase       DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;
   //GatesPrimitives DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial
      #(4*10) $finish ;   // here we only need to choose the simulation time, e.g. 4x clock cycles

endmodule

