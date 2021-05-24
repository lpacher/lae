//
// Simple testbench for LED_blink module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_LED_blink ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire led ;   // not so interesting to probe since you have to wait for seconds to observe a "toggle"

   LED_blink  DUT (.clk(clk100), .LED(led)) ;


   wire [27:0] count = DUT.count ;   // inspect the internal counter instead...

   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #(10000) $finish ;   // simply run for sometime and observe the internal free-running counter incrementing
   end

endmodule
