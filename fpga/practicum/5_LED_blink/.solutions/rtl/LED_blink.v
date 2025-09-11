//
// Turn on/off an on-board LED using a free-running counter as clock divider.
// Optionally, drive a 7-segment display module as discussed in practicum #3.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//

//`include "rtl/SevenSegmentDecoder.v"

`timescale 1ns / 100ps

module LED_blink (

   input  wire clk,         // assume 100 MHz external clock from on-board oscillator

   // **EXERCISE: add an external count-enable control (e.g. slide-switch)
   //input wire enable,

   output wire LED,
   output wire LED_probe    // probe at the oscilloscope the LED control signal

   // **EXERCISE: drive a 7-segment display module with a suitable 4-bit slice of the counter
   //output wire segA,
   //output wire segB,
   //output wire segC,
   //output wire segD,
   //output wire segE,
   //output wire segF,
   //output wire segG,
   //output wire DP

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


   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //   optionally, drive a 7-segment display (simply re-use the module already implemented into practicum #3)   //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*

   wire [3:0] BCD = count[27:24] ;

   SevenSegmentDecoder SevenSegmentDecoderInst (

       .BCD  ( BCD[3:0] ),
       .DP   ( DP       ),
       .segA ( segA     ),
       .segB ( segB     ),
       .segC ( segC     ),
       .segD ( segD     ),
       .segE ( segE     ),
       .segF ( segF     ),
       .segG ( segG     ),
       .LED  (          )    // leave **UNCONNECTED**
   ) ;

*/

endmodule

