//
// Example Verilog implementation of a ring-oscillator using STRUCTURAL CODE
// and gate-primitives with propagation delays.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2024
//

`timescale 1ns / 100ps

module RingOscillator (

   input  wire start,
   output wire clk

   ) ;

   // wires for internal connections
   wire [4:0] w ;

   /*

   // implementation using continuous assignments and propagation delays
   assign #3 w[0] = ~(w[4] & start) ;

   assign #3 w[1] = ~w[0] ;
   assign #3 w[2] = ~w[1] ;
   assign #3 w[3] = ~w[2] ;
   assign #3 w[4] = ~w[3] ;

   */


   // implementation using gate-primitives and structural code
   nand #(3) g0 (w[0], w[4], start) ;

   not  #(3) g1 (w[1], w[0]) ;
   not  #(3) g2 (w[2], w[1]) ;
   not  #(3) g3 (w[3], w[2]) ;
   not  #(3) g4 (w[4], w[3]) ;

   assign clk = w[4] ;

endmodule