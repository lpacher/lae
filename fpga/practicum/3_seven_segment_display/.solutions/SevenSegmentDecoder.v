//
// Example Verilog code for a BCD to 7-segments display decoder. Available 7-segments display
// modules in the lab are COMMON ANODE devices.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module SevenSegmentDecoder (

   input wire [3:0] BCD,

   output wire DP,

   output reg segA,
   output reg segB,
   output reg segC,
   output reg segD,
   output reg segE,
   output reg segF,
   output reg segG

   ) ;


   // you can decide to tie-high or tie-down the unused decimal point (DP)
   assign DP = 1'b0 ;
   //assign DP = 1'b1 ;

   //
   // **DEBUG: 7-segments display using logic constants
   //                                                     //a b c d e f g
   //assign {segA, segB, segC, segD, segE, segF, segG} = 7'b0_0_1_0_0_1_0 ;   // direct assignment of LED controls


   always @(*) begin

      case( BCD[3:0] )
                                                                 //  abcdefg
         4'b0000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000001 ;  //  0
         4'b0001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001111 ;  //  1
         4'b0010  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0010010 ;  //  2
         4'b0011  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000110 ;  //  3
         4'b0100  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001100 ;  //  4
         4'b0101  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100100 ;  //  5
         4'b0110  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100000 ;  //  6
         4'b0111  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0001111 ;  //  7
         4'b1000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000000 ;  //  8
         4'b1001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000100 ;  //  9

         // **IMPORTANT: latches inferred otherwise !
         default  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111110 ;  // minus sign otherwise

      endcase
   end

endmodule

