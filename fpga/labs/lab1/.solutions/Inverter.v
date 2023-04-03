//
// Verilog description for a NOT-gate (inverter) using either a continuous
// assignment, a conditional assignment or a gate-primitive instantiation.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

// this is a C-style single-line comment


/*

this is another C-style comment
but distributed across multiple lines

*/


`timescale 1ns / 100ps     // specify time-unit and time-precision, this is only for simulation purposes

//
// Verilog-95 port declaration, but we will use Verilog-2001 in the course
//module Inverter (X, ZN) ;
//   wire X, ZN ;
//

module Inverter (

   input  wire X,
   output wire ZN ) ;      // using 'wire' in the port declaration is redundant, by default I/O ports are already considered WIRES unless otherwise specified

   // continuous assignment
   //assign ZN = ~X ;
   assign #3 ZN = ~X ;    // include 3ns propagation delay between input and output

   // conditional assignment (MUX-style)
   //assign ZN = (X == 1'b1) ? 1'b0 : 1'b1 ;   // **NOTE: same as ZN = (X) ? 1'b1 : 1'b0 ;

   // gate-primitive instantiation
   //not u1 (ZN, X) ;

endmodule

