//
// Example 8-bit Pseudo-Random Bit Sequence (PRBS) generator using a Linear Feedback
// Shift Register (LFSR).
//
// Code derived and readapted from https://www.fpga4fun.com
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module LFSR #(parameter [7:0] SEED = 8'hFF) (   // seed of the pseudo-random bit sequence

   input  wire clk,      // assume 100 MHz input clock fed to PLL
   output wire PRBS      // output pseudo-random bit sequence

   ) ;


   ////////////////////////////////////////
   //   linear feedback shift register   //
   ////////////////////////////////////////

   // 8-bit shift register
   reg [7:0] q = SEED ;         // **QUESTION: what happens if we put 8'h00 ?


   wire feedback = q[7] ;

   //wire feedback = q[7] ^ (q[6:0] == 7'b0000000) ;  // this modified feedback allows reaching 256 states instead of 255


   always @(posedge clk) begin

     q[0] <= feedback ;
     q[1] <= q[0] ;
     q[2] <= q[1] ^ feedback ; 
     q[3] <= q[2] ^ feedback ;
     q[4] <= q[3] ^ feedback ;
     q[5] <= q[4] ;
     q[6] <= q[5] ;
     q[7] <= q[6] ;

   end // always

   assign PRBS = q[7] ;

endmodule

