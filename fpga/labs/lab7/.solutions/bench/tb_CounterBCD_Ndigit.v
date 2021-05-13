//
// Testbench module for parameterizable N-digit BCD counter.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


//
// Dependencies:
//
// bench/ClockGen.v
// rtl/BCD_counter_Ndigit.v
// rtl/TickCounter.v
//


`define NUMBER_OF_DIGITS 4

`timescale 1ns / 100ps


module tb_CounterBCD_Ndigit ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk100, clk100_buf ;

   ClockGen ClockGen_inst (.clk(clk100)) ;

   IBUF  IBUF_inst ( .I(clk100), .O(clk100_buf) ) ;


   ////////////////
   //   ticker   //
   ////////////////

   // assert a single clock-pulse every 1 us i.e. 100 x 10 ns clock period at 100 MHz

   //wire enable ;
   reg enable ;

   //TickCounter  #(.MAX(100)) TickCounter_inst ( .clk(clk100_buf), .tick(enable)) ;



   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst ;

   wire [`NUMBER_OF_DIGITS*4-1:0] BCD ;  // each 4-bit slice of the BCD counter is a "digit" in decimal

   //CounterBCD  DUT ( .clk(clk100_buf), .rst(rst), .en(enable), .BCD(BCD)) ; 

   CounterBCD_Ndigit #(.Ndigit(`NUMBER_OF_DIGITS)) DUT ( .clk(clk100_buf), .rst(rst), .en(enable), .BCD(BCD)) ;



   //////////////////
   //   stimulus   //
   //////////////////

   wire [3:0] BCD_0 = BCD[ 3: 0] ;
   wire [3:0] BCD_1 = BCD[ 7: 4] ;
   wire [3:0] BCD_2 = BCD[11: 8] ;
   wire [3:0] BCD_3 = BCD[15:12] ;

`ifdef TICKER

   initial begin

      #72 rst = 1'b1 ;

      // release the reset
      #515 rst = 1'b0 ;

      #(1000*2157) force enable = 1'b0 ; $display("Effective number of counts from BCD counter : %d%d%d%d", BCD_3 , BCD_2 , BCD_1 , BCD_0 ) ;

      #500 $finish  ;
   end

`else

   // assume 100 MHz clock frequency and count clock pulses every 10 ns instead

   //realtime t1, t2 ;              // **WARN: 'realtime' is 64-bit DOUBLE-precision floating point to be used with $realtime system task
   time t1, t2 ;                    // **WARN: 'time' is 64-bit UNSIGNED integer to be used with $time system task (in ps since timescale is ps)

   initial begin

      #72 rst = 1'b1 ; enable = 1'b0 ;

      // release the reset
      #515 rst = 1'b0 ;

      #500   enable = 1'b1 ; t1 = $time ;
      #10843 enable = 1'b0 ; t2 = $time ;

      $display("\n**INFO: Expected number of clock cycles counted by BCD counter : %d", (t2-t1)/10.0 ) ;
      $display("        Effective number of counts from BCD counter : %d%d%d%d", BCD_3 , BCD_2 , BCD_1 , BCD_0 ) ;

      #3000 $finish  ;

   end

`endif   // TICKER

endmodule

