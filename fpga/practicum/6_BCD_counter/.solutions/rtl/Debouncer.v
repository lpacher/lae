//
// Simple push-button debouncer with 0.5 kHz or 1 kHz low sampling frequency.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module Debouncer (

   input  wire clk,            // assume 100 MHz clock frequency from on-board oscillator
   input  wire button,         // glitching push-button input
   output wire pulse           // clean single-pulse output

   ) ;


   ////////////////////////////////////////
   //   low-frequency 'tick' generator   //
   ////////////////////////////////////////

   wire enable ;

   TickCounter #(.MAX(50000)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 0.5 kHz clock-enable
   //TickCounter #(.MAX(100000)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 1 kHz clock-enable


   ////////////////////////////////
   //   single-pulse generator   //
   ////////////////////////////////

   reg [2:0] q = 'b0 ;   // 3 FlipFlops

   always @(posedge clk) begin

      if(enable) begin
         q[0] <= button ;
         q[1] <= q[0] ;
         q[2] <= q[0] & (~q[1]) ;
      end
   end

   assign pulse = q[2] ;

endmodule

