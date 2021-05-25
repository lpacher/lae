//
// Simple testbench module for 4-bit Pulse-Width Modulation (PWM) generator.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_PWM4 ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen ClockGen_inst ( .clk(clk100) ) ;



   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg [3:0] threshold ;   // assume to use an 4-bit PWM counter in the lab

   wire pwm_out ;

   PWM #(.THRESHOLD_NBITS(4)) DUT (.clk(clk100), .threshold(threshold), .pwm_out(pwm_out)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer k ;

   initial begin

      // explore all possible threshold values from 0 to F using a for-loop
      for (k=0; k < 16; k=k+1) begin

         #20000 threshold = k ;
      end

      #(20000) $finish ;

   end

endmodule

