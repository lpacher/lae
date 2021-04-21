//
// Implement basic logic operators using Verilog gates primitives.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

//
// Available Verilog logic gates primitives are:
// 
// not
// and
// nand
// or 
// nor
// xor
// xnor
//


`timescale 1ns / 100ps

module GatesPrimitives (

   input  wire A,
   input  wire B,
   output wire [5:0] Z    // note that Z is a 6-bit width output BUS

   ) ;

   // AND gate
   and u0 (Z[0], A, B) ;

   // NAND gate
   nand u1 (Z[1], A, B);

   // OR gate
   or u2 (Z[2], A, B) ;

   // NOR gate
   nor u3 (Z[3], A, B) ;

   // XOR gate
   xor u4 (Z[4], A, B) ;

   // XNOR gate
   xnor u5 (Z[5], A, B) ;


endmodule

