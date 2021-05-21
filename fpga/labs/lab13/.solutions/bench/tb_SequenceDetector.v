//
// Example testbench module for 110 sequence detector.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_SequenceDetector ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  #(.PERIOD(10.0)) ClockGen_inst (.clk(clk100)) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst, si = 1'b0 ;

   wire tick ;

   SequenceDetector  DUT ( .clk(clk100), .reset(rst), .si(si), .detected(tick) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   //
   // reset process
   //
   initial begin

      #20  rst = 1'b1 ;
      #175 rst = 1'b0 ;

   end


   //
   // pseudo-random bit sequence (PRBS)
   //
   initial begin

      #2.5      // only for better visualization, sample input data at period/2

      repeat (500) #10 si = $random ;   // generate 500 consecutive random bit values fed to sequence detector

      #10 $finish ;

   end

endmodule

