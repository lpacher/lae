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
   //assign Z[1] = ~Z[0] ;     // OK in Verilog, not allowed using VHDL instead (in VHDL an output port can be only written, not read)

   // OR
   assign Z[2] = A | B ;

   // NOR
   assign Z[3] = ~(A | B) ;
   //assign Z[3] = ~Z[2] ;

   // XOR
   assign Z[4] = A ^ B ;
   //assign Z[4] = (~A &B ) | (A & (~B)) ;     // XOR logic equation

   // XNOR
   assign Z[5] = ~(A ^ B) ;
   //assign Z[5] = ~Z[4] ;
   //assign Z[5] = ((~A) & (~B)) | (A & B) ;   // XNOR logic equation

endmodule

