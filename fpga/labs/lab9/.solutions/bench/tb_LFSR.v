//
// Testbench module for Pseudo-Random Bit Sequence (PRBS) generator using a Linear
// Feedback Shift Register (LFSR).
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`include "ClockGen.v"

`timescale 1ns / 100ps

module tb_LFSR ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire PRBS ;

   LFSR  DUT (.clk(clk100), .PRBS(PRBS) ) ;
   //LFSR #(.SEED(8'h00))  DUT (.clk(clk100), .PRBS(PRBS) ) ;   // **QUESTION: what happens if the seed is 8'h00 ?


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer f ;    // the $fopen Verilog task returns a 32-bit integer

   initial begin

      f = $fopen("LFSR.txt") ;      // open the file handler

      #150000 $fclose(f) ; $finish ;   // simply run for some time and observe the pseudo-random output bit pattern
   end


   wire [7:0] random ;
   assign random = DUT.q[7:0] ;   // you can access lower-level signals from testbench with hierarchical probing

   always @(random) begin      // register pseudo-random bit values to ASCII for later histogramming

      $fdisplay(f,"%d", random) ;
   end

endmodule

