//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Verilog description for a NOT-gate (inverter) using a continuous assign.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`timescale 1ns / 100ps

module Inverter (
   input  wire X,
   output wire ZN ) ;

   assign ZN = ~X ;
   //assign ZN = X ;   // BUFFER

endmodule

