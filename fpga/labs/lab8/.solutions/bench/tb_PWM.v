//
// Simple testbench module for parameterizable N-bit Pulse-Width Modulation (PWM) generator.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_PWM ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen ClockGen_inst ( .clk(clk100) ) ;



   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg [7:0] threshold ;   // assume to use an 8-bit PWM counter (default width is 4-bit instead)

   wire pwm_out ;

   PWM #(.THRESHOLD_NBITS(8)) DUT (.clk(clk100), .threshold(threshold[7:0]), .pwm_out(pwm_out)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      // explore 8x PWM periods for each configuration 

      #0          threshold = 8'h0A ;      //  10
      #(8*256*10) threshold = 8'hA0 ;      // 160
      #(8*256*10) threshold = 8'h6D ;      // 109
      #(8*256*10) threshold = 8'hFF ;      // 255  what happens when threshold = MAX depends on actual PWM implementation
      #(8*256*10) threshold = 8'h00 ;      //   0

      #(8*256*10) $finish ;

   end

endmodule

