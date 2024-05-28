//
// Testbench module for 4-bit synchronous up-counter.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2022
//

`timescale 1ns / 100ps

module tb_SyncCounter4b ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk, clk_buf ;

   ClockGen  #(.PERIOD(100.0)) ClockGen_inst (.clk(clk) ) ;   // override default period as module parameter (default is 50.0 ns)


   ////////////////////////////////////////////////
   //   example Xilinx primitive instantiation   //
   ////////////////////////////////////////////////

   IBUF IBUF_inst ( .I(clk), .O(clk_buf) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst = 1'b0 ;
   reg en  = 1'b0 ;

   wire [3:0] count ;

   SyncCounter4b  DUT (.clk(clk_buf), .rst(rst), .en(en), .Q(count) ) ;


   //////////////////
   //   stimulus   //
   //////////////////

   initial begin

      #100 rst = 1'b1 ;              // assert the reset
      #150 rst = 1'b0 ;              // release the reset

      #500 en  = 1'b1 ;              // enable counting

      #500 en  = 1'b0 ;              // pause
      #500 en  = 1'b1 ;              // restart

      #(20*100 + 17) rst = 1'b1 ;    // explore all possible output codes, then assert an asynchronous reset and check what happens

      #500 $finish ;
   end

endmodule
