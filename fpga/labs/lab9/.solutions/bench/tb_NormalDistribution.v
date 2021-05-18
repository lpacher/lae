//
// Example code to genrate normally-distributed pseudo-random numbers
// using the Central Limit Theorem and LFSRs.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`include "ClockGen.v"

`timescale 1ns / 100ps


//
// 11-bit LFSR
//

module LFSR #(parameter [10:0] SEED = 11'hFFF) (

   input wire clk,
   output wire [10:0] random   // since we are interested in summing numbers, output the 11-bit code

   ) ;


   // 11-bit shift register
   reg [10:0] q = SEED ;

   wire feedback = q[10] ^ q[9] ^ q[6] ;

   always @(posedge clk) begin

      q[ 0] <= feedback ;
      q[ 1] <= q[ 0] ;
      q[ 2] <= q[ 1] ;
      q[ 3] <= q[ 2] ;
      q[ 4] <= q[ 3] ;
      q[ 5] <= q[ 4] ;
      q[ 6] <= q[ 5] ;
      q[ 7] <= q[ 6] ;
      q[ 8] <= q[ 7] ;
      q[ 9] <= q[ 8] ;
      q[10] <= q[ 9] ;

   end

   assign random = q ;

endmodule


//
// Testbench code
//

`timescale 1ns / 100ps

module tb_NormalDistribution ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////////////////////////////////////////
   //   instantiate 4x independent LFSRs with different seeds   //
   ///////////////////////////////////////////////////////////////

   wire [10:0] uniform_0, uniform_1, uniform_2, uniform_3 ;

   LFSR  #(.SEED(00_000_000_001)) LFSR_0 (.clk(clk100), .random(uniform_0) ) ;
   LFSR  #(.SEED(00_000_001_000)) LFSR_1 (.clk(clk100), .random(uniform_1) ) ;
   LFSR  #(.SEED(00_001_000_000)) LFSR_2 (.clk(clk100), .random(uniform_2) ) ;
   LFSR  #(.SEED(01_000_000_000)) LFSR_3 (.clk(clk100), .random(uniform_3) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer random ;   // don't care about the carry in the addition between LFSR numbers, simply use a 32-bit integer to store the sum

   integer f ;    // the $fopen Verilog task returns a 32-bit integer

   initial begin

      f = $fopen("gaus.txt") ;      // open the file handler

      #(1000000) $fclose(f) ; $finish ;   // simply run for some time and observe the pseudo-random output bit pattern
   end


   always @(posedge clk100) begin      // register pseudo-random bit values to ASCII file for later histogramming

      random = uniform_0 + uniform_1 + uniform_2 + uniform_3 ;
      $fdisplay(f,"%d", random) ;
   end

endmodule

