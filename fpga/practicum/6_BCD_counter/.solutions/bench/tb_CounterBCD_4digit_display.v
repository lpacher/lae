//
// Not a complete testbench, only verify that all connections are OK and that
// the BCD counter counts properly, but don't care about the multiplexing logic.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_CounterBCD_4digit_display ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst (.clk(clk100)) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire segA, segB, segC, segD, segE, segF, segG ;
   wire [3:0] anode ;

   reg rst = 1'b1 ;
   reg button = 1'b0 ;

   CounterBCD_4digit_display  DUT (

      .clk    (     clk100 ),
      .rst    (        rst ),
      .en     (       1'b1 ),
      .button (     button ),
      .segA   (       segA ),
      .segB   (       segB ),
      .segC   (       segC ),
      .segD   (       segD ),
      .segE   (       segE ),
      .segF   (       segF ),
      .segG   (      segG  ),
      .anode  ( anode[3:0] )

      ) ;

   wire [3:0] DIGIT_0 = DUT.BCD[ 3: 0] ;
   wire [3:0] DIGIT_1 = DUT.BCD[ 7: 4] ;
   wire [3:0] DIGIT_2 = DUT.BCD[11: 8] ;
   wire [3:0 ]DIGIT_3 = DUT.BCD[15:12] ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer k ;

   initial begin

      #500 button = 1'b1 ;  #50 button = 1'b0 ;

      #500 rst = 1'b0 ;   // release the reset, by default synchronous with the push-button!

      for (k=0; k < 100 ; k=k+1) begin

         #500 button = 1'b1 ;  #50 button = 1'b0 ;

      end

      #500 $finish ;

   end

endmodule

