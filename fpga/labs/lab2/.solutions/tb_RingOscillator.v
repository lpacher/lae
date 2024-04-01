//
// Example testbench module for ring-oscillator circuit.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2024
//


`timescale 1ns / 100ps

module tb_RingOscillator ;

   reg start = 1'b0 ;

   wire clk ;

   /////////////////////////////////
   //   device under test (DUT)   //
   /////////////////////////////////

   RingOscillator  DUT (.start(start), .clk(clk)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #500  start = 1'b1 ;      // enable the circuit to oscillate
      #2500 start = 1'b0 ;      // disable the circuit

      #200 $finish ;

   end

endmodule
