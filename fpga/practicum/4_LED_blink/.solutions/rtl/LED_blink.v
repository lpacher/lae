//
// Turn on/off an on-board LED using a free-running counter as clock divider.
// Optionally, drive a 7-segment display module as discussed in practicum #3.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module LED_blink (

   input  wire clk,         // assume 100 MHz external clock from on-board oscillator

   // **EXERCISE: add an external count-enable control (e.g. slide-switch)
   //input wire enable,

   output wire LED,
   output wire LED_probe    // probe at the oscilloscope the LED control signal

   // **EXERCISE: drive a 7-segment display module with a suitable 4-bit slice of the counter
   //output reg segA,
   //output reg segB,
   //output reg segC,
   //output reg segD,
   //output reg segE,
   //output reg segF,
   //output reg segG,
   //output reg DP

   ) ;


   //////////////////////////////
   //   free-running counter   //
   //////////////////////////////

   reg [27:0] count ;

   //initial
   //   count = 'b0 ;.  // **QUESTION: what happens if 'count' is not initialized into RTL code ?


   always @(posedge clk) begin
      //if(enable) begin
         count <= count + 'b1 ;            // **QUESTION: where is the reset for this counter ? 
      //end
   end


   //////////////////////////////
   //   drive the LED output   //
   //////////////////////////////

   // simply turn on/off the LED with one bit of the output count

   assign LED = count[24] ;        // **QUESTION: which is the blink frequency of the LED ?
   //assign LED = count[25] ;
   //assign LED = count[26] ;
   //assign LED = count[27] ;

   // **DEBUG: probe at the oscilloscope the LED control signal on some general-purpose I/O
   assign LED_probe = LED ;


   ///////////////////////////////////////////////
   //   optionally, drive a 7-segment display   //
   ///////////////////////////////////////////////

/*

   wire [3:0] BCD = count[27:24] ;

   always @(*) begin

      DP = 1'b0 ;   // simply tie-down the Decimal Point (DP) dot

      case( BCD[3:0] )

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

         default  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000000 ;  //  turned-off otherwise

         // COMMON ANODE
         //4'b0000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000001 ;  //  0
         //4'b0001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001111 ;  //  1
         //4'b0010  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0010010 ;  //  2
         //4'b0011  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000110 ;  //  3
         //4'b0100  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001100 ;  //  4
         //4'b0101  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100100 ;  //  5
         //4'b0110  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100000 ;  //  6
         //4'b0111  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0001111 ;  //  7
         //4'b1000  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000000 ;  //  8
         //4'b1001  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000100 ;  //  9
         //default  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111111 ;  //  turned-off otherwise

      endcase
   end   // always

*/

endmodule

