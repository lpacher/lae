//
// Example Verilog code for a BCD to 7-segments display decoder. Either define
// COMMON_ANODE or COMMON_CATHODE macros to switch between CA or CC modules.
// Available 7-segments display modules in the lab for this practicum (FYS-5613AX)
// are COMMON CATHODE devices.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

`define COMMON_CATHODE           // POSITIVE-LOGIC  => segX = 1'b1 LED is ON, segX = 1'b0 LED is OFF
//`define COMMON_ANODE           // NEGATIVE-LOGIC  => segX = 1'b0 LED is ON, segX = 1'b1 LED is OFF 

module SevenSegmentDecoder (

   input wire [3:0] BCD,

   output wire DP,

   output wire segA,
   output wire segB,
   output wire segC,
   output wire segD,
   output wire segE,
   output wire segF,
   output wire segG

   ) ;


   // you can decide to tie-high or tie-down the unused decimal point (DP)
   assign DP = 1'b0 ;
   //assign DP = 1'b1 ;

   //
   // **DEBUG: 7-segments display using logic constants
   //                                                     //a b c d e f g
   //assign {segA, segB, segC, segD, segE, segF, segG} = 7'b0_0_1_0_0_1_0 ;   // direct assignment of LED controls

   reg [6:0] LED ;

   always @(*) begin

      case( BCD[3:0] )

/*
         // COMMON CATHODE
         4'b0000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111110 ;  //  0
         4'b0001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0110000 ;  //  1
         4'b0010  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1101101 ;  //  2
         4'b0011  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111001 ;  //  3
         4'b0100  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001100 ;  //  4
         4'b0101  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1011011 ;  //  5
         4'b0110  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1011111 ;  //  6
         4'b0111  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1110000 ;  //  7
         4'b1000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111111 ;  //  8
         4'b1001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111011 ;  //  9

         default  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000001 ;
*/

         // COMMON CATHODE
         4'b0000  :  LED = 7'b1111110 ;  //  0
         4'b0001  :  LED = 7'b0110000 ;  //  1
         4'b0010  :  LED = 7'b1101101 ;  //  2
         4'b0011  :  LED = 7'b1111001 ;  //  3
         4'b0100  :  LED = 7'b1001100 ;  //  4
         4'b0101  :  LED = 7'b1011011 ;  //  5
         4'b0110  :  LED = 7'b1011111 ;  //  6
         4'b0111  :  LED = 7'b1110000 ;  //  7
         4'b1000  :  LED = 7'b1111111 ;  //  8
         4'b1001  :  LED = 7'b1111011 ;  //  9

         // **IMPORTANT: latches inferred otherwise !
         default  :  LED = 7'b0000001 ;  // minus sign otherwise

         // COMMON ANODE (just for reference)
         //4'b0000  :  LED = 7'b0000001 ;  //  0
         //4'b0001  :  LED = 7'b1001111 ;  //  1
         //4'b0010  :  LED = 7'b0010010 ;  //  2
         //4'b0011  :  LED = 7'b0000110 ;  //  3
         //4'b0100  :  LED = 7'b1001100 ;  //  4
         //4'b0101  :  LED = 7'b0100100 ;  //  5
         //4'b0110  :  LED = 7'b0100000 ;  //  6
         //4'b0111  :  LED = 7'b0001111 ;  //  7
         //4'b1000  :  LED = 7'b0000000 ;  //  8
         //4'b1001  :  LED = 7'b0000100 ;  //  9

      endcase
   end

`ifdef COMMON_CATHODE

   assign {segA, segB, segC, segD, segE, segF, segG} = LED[6:0] ;

   //assign segA = LED[6] ;
   //assign segB = LED[5] ;
   //assign segC = LED[4] ;
   //assign segD = LED[3] ;
   //assign segE = LED[2] ;
   //assign segF = LED[1] ;
   //assign segG = LED[0] ;

`elsif COMMON_ANODE

   assign {segA, segB, segC, segD, segE, segF, segG} = ~LED[6:0] ;   // **IMPORTANT: here the BITWISE logic negation is mandatory, the ! operator would be wrong

   //assign segA = ~LED[6] ;
   //assign segB = ~LED[5] ;
   //assign segC = ~LED[4] ;
   //assign segD = ~LED[3] ;
   //assign segE = ~LED[2] ;
   //assign segF = ~LED[1] ;
   //assign segG = ~LED[0] ;

`endif

endmodule

