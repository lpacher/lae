//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Verilog description for a buffer using structural code to provide
// a first example of design hierarchy and code reusability in HDL
// programming.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2026
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//`include Inverter.v   **OPTIONAL: use the C-like `include directive to locate Inverter.v containing the implementation of the Inverter module

`timescale 1ns / 100ps

module Buffer (

   input  wire X,
   output wire ZB ) ;   // **IMPORTANT: you can't use 'Z' because the identifier is already reserved for the 'high-impedance' logic constant!

   // continuous assignment
   //assign ZB = X ;

   // gate-primitive instantiation
   //buf u1 (ZB,X) 

   // structural code
   wire inv1_to_inv2 ;

   Inverter inv_1 ( .X(X), .ZN(inv1_to_inv2) ;
   Inverter inv_2 ( .X(inv1_to_inv2), .ZN(ZN) ;

endmodule

