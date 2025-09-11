//=================================================================================
//
// **EXTRA: Example VHDL implementation of a 2:1 MUX using when/else statements.
//          Required for the STRUCTURAL code (schematic) implementation.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2025
//
//=================================================================================


`timescale 1ns / 1ps

module MUX2 (

   input  wire A,
   input  wire B,
   input  wire S,
   output wire Z

   ) ;


   // conditioal assign
   assign Z = (S == 1'b1) ? A : B ;

endmodule


//=================================================================================
//
// Simple MUX-design to selectively turn-on LD7-LD5 and LD6-LD4 available
// on the Digilent Arty board.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2025
//
//=================================================================================


module LED_pattern_mux (

   input  wire sel,           // control switch (e.g. slide-switch SW0)
   output wire [3:0] LED      // output LEDs

   ) ;


   /////////////////////////////////////////////////////////////////////////
   //   MUX-like behavioral implementation using conditional assignment   //
   /////////////////////////////////////////////////////////////////////////

   //assign LED = (sel == 1'b0 ) ? 4'b1010 : 4'b0101 ;


   /////////////////////////////////////////////////////
   //   logic equations as derived from truth-table   //
   /////////////////////////////////////////////////////

   //assign LED[3] = ~sel ;
   //assign LED[2] =  sel ;
   //assign LED[1] = ~sel ;
   //assign LED[0] =  sel ;


   //////////////////////////////////////////////////////////////
   //   STRUCTURAL code (schematic) using 2:1 MUX components   //
   //////////////////////////////////////////////////////////////

   MUX2  MUX_3 ( .A(1'b1), .B(1'b0), .S(sel), .Z(LED[3]) ); 
   MUX2  MUX_2 ( .A(1'b0), .B(1'b1), .S(sel), .Z(LED[2]) ); 
   MUX2  MUX_1 ( .A(1'b1), .B(1'b0), .S(sel), .Z(LED[1]) ); 
   MUX2  MUX_0 ( .A(1'b0), .B(1'b1), .S(sel), .Z(LED[0]) ); 

endmodule

