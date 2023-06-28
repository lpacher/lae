//
// Verilog description for a three-state buffer using either a conditional
// assignment or a gate-primitive instantiation.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2023
//


`timescale 1ns / 100ps

module BufferTri (

   input  wire X, OE,
   output wire ZT ) ;

   // conditional assignment (MUX-style)
   assign ZT = (OE == 1'b1) ? X : 1'bz ;   // **NOTE: same as ZT = (OE) ? X : 1'bz ;

   // gate-primitive instantiation
   //bufif1 u1 (ZT,X,OE) ;                 // bufif1 = active-high output-enable, bufif0 = active-low. Additional notif0/notif1 exist for three-state inverters

endmodule

