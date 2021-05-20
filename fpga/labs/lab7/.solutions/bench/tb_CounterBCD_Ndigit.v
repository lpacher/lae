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

//`define FREQUENCY   100e6
//`define FREQUENCY   100e6/2
//`define FREQUENCY   100e6/4
//`define FREQUENCY   100e6/8
//`define FREQUENCY   100e6/16
//`define FREQUENCY   100e6/32
//`define FREQUENCY   100e6/64

`define FREQUENCY    10e6   // 10 MHz with MAX=10  in the "ticker"
//`define FREQUENCY     1e6   //  1 MHz with MAX=100 in the "ticker"

`timescale 1ns / 100ps


module tb_CounterBCD_Ndigit ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk100, clk100_buf ;

   ClockGen ClockGen_inst (.clk(clk100)) ;

   IBUF  IBUF_inst ( .I(clk100), .O(clk100_buf) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst, enable ;

   wire [`NUMBER_OF_DIGITS*4-1:0] BCD ;  // each 4-bit slice of the BCD counter is a "digit" in decimal

   //CounterBCD  DUT ( .clk(clk100_buf), .rst(rst), .en(enable), .BCD(BCD)) ; 

   CounterBCD_Ndigit #(.Ndigit(`NUMBER_OF_DIGITS)) DUT ( .clk(clk100_buf), .rst(rst), .en(enable), .BCD(BCD)) ;



   //////////////////
   //   stimulus   //
   //////////////////

   wire [3:0] DIGIT_0 = BCD[ 3: 0] ;
   wire [3:0] DIGIT_1 = BCD[ 7: 4] ;
   wire [3:0] DIGIT_2 = BCD[11: 8] ;
   wire [3:0] DIGIT_3 = BCD[15:12] ;

   // assume 100 MHz clock frequency and count clock pulses every 10 ns instead

   //realtime t1, t2 ;              // **WARN: 'realtime' is 64-bit DOUBLE-precision floating point to be used with $realtime system task
   time t1, t2 ;                    // **WARN: 'time' is 64-bit UNSIGNED integer to be used with $time system task (in ns since timescale is ns)

   initial begin

      #72 rst = 1'b1 ; enable = 1'b0 ;

      // release the reset
      #515 rst = 1'b0 ;

      #500   enable = 1'b1 ; t1 = $time ;   // returns 64-bit uint ns
      #10843 enable = 1'b0 ; t2 = $time ;   // returns 64-bit uint ns

      $display("\n**INFO: Expected number of clock cycles counted by BCD counter : %d", ((t2-t1)*1e-9)*(`FREQUENCY) ) ;
      $display("        Effective number of counts from BCD counter : %d%d%d%d", DIGIT_3 , DIGIT_2 , DIGIT_1 , DIGIT_0 ) ;

      #500  force clk100  = 1'b0 ;          // **QUESTION: what happens to the PLL if the input clock disappears ?
      #1000 release clk100 ;

      #3000 $finish  ;

   end

endmodule

