//
// Synthesizable Verilog implementation of a parameterized ring-oscillator
// using STRUCTURAL CODE and gate-primitives.
//
//
// Luca Pacher - pacher@to.infn.it
// Spring 2024
//
//
// **IMPORTANT NOTES
//
// The circuit uses an AND-gate into the feedback loop to enable/disable the
// output toggle, thus requiring an **ODD** number of inverters in the chain.
//
// Additional 'dont_touch' synthesis directives are mandatory in order to infer
// the desired hardware, otherwise the synthesis engine would delete all inverters
// into the chain. 
//

`timescale 1ns / 100ps


module RingOscillator (

   input  wire start,
   output wire clk,

   // **DEBUG
   output wire led,
   output wire probe

   ) ;


   // **IMPORTANT: the chosen number of inverters MUST be an **ODD** number (AND-gate used in the feedback loop to enable/disable the toggle)
   parameter integer NUM_INVERTERS = 283 ;   // approx. 4.5 MHz clock signal at the oscilloscope

   // wires for internal connections
   (* dont_touch = "yes" *) wire [NUM_INVERTERS:0] w ;

   // start/stop AND gate
   and en_and (w[0], w[NUM_INVERTERS], start) ;

   // inverters chain
   generate 

      genvar k ;

      for(k=0; k < NUM_INVERTERS; k=k+1) begin

         (* dont_touch = "yes" *) not inv (w[k+1], w[k]) ;
   
      end  //for
   endgenerate

   assign clk = w[NUM_INVERTERS] ;

   // **DEBUG: drive a status LED with 'start'
   assign led = start ;

   // **DEBUG: probe 'start' at the oscilloscope
   assign probe = start ;

endmodule

