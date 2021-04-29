//
// Implement basic logic gates in Verilog using continuous assignments.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

//
// **NOTE
//
// Available Verilog basic bitwise logic operators are :
//
// NOT  ~
// AND  &
// OR   |
// XOR  ^
//


`timescale 1ns / 100ps

module Gates (

   input  wire A,
   input  wire B,
   output wire [5:0] Z    // note that Z is a 6-bit width output BUS

   ) ;

   // AND
   assign Z[0] = A & B ;

   // NAND
   assign Z[1] = ~(A & B) ;

   // OR
   assign Z[2] = A | B ;

   // NOR
   assign Z[3] = ~(A | B) ;

   // XOR
   assign Z[4] = A ^ B ;

   // XNOR
   assign Z[5] = ~(A ^ B) ;


endmodule

