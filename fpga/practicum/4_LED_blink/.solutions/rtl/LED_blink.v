//
// Turn on/off an on-board LED using a free-running counter as clock divider.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module LED_blink (

   input  wire clk,      // assume 100 MHz external clock from on-board oscillator
   output wire LED

   ) ;


   //////////////////////////////
   //   free-running counter   //
   //////////////////////////////

   reg [27:0] count = 'b0 ;

   always @(posedge clk) begin
      count <= count + 'b1 ;            // **QUESTION: where is the reset for this counter ? 
   end


   //////////////////////////////
   //   drive the LED output   //
   //////////////////////////////

   // simply turn on/off the LED with a count-slice

   assign LED = count[24] ;        // **QUESTION: which is the blink frequency of the LED ?
   //assign LED = count[25] ;
   //assign LED = count[26] ;
   //assign LED = count[27] ;

endmodule

