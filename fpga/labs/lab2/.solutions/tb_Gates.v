//
// Simple testbench to simulate basic logic gates with different implementations.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_Gates ;

   // 40 MHz clock generator
   reg clk = 1'b0 ;              // note that we can also initialize a 'reg' to some initial value when declared

   always #12.5 clk = ~ clk ;

   // 2-bits counter
   reg [1:0] count = 2'b00 ;

   always @(posedge clk)
      count <= count + 1'b1 ;    // **WARN: be aware of the casting ! This is count[2:0] <= count[2:0] + 1'b1 !

   // device under test (DUT)
   wire [5:0] Z;

   //Gates           DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;      // **UNCOMMENT** here the DUT that you want to simulate
   //GatesCase       DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;
   //GatesPrimitives DUT (.A(count[0]), .B(count[1]), .Z(Z)) ;

   // main stimulus
   initial
      #(4*25) $finish ;   // here we only need to choose the simulation time, e.g. 4x clock cycles

endmodule

