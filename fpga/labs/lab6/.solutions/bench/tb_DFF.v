//
// Testbench module for DFF.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_DFF ;

   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk, clk_buf ;

   ClockGen  #(.PERIOD(100.0)) ClockGen_inst (.clk(clk) ) ;   // override default period as module parameter (default is 10.0 ns)


   ////////////////////////////////////////////////
   //   example Xilinx primitive instantiation   //
   ////////////////////////////////////////////////

   IBUF IBUF_inst ( .I(clk), .O(clk_buf) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg D = 1'b1 ;
   reg rst = 1'b1 ;

   wire Qlatch, Qff ;

   DLATCH  DUT_0 (.D(D), .EN(clk), .Q(Qlatch) ) ;                 // D-latch
   DFF     DUT_1 (.clk(clk_buf), .rst(rst), .D(D), .Q(Qff) ) ;     // D-FlipFlop


   //////////////////
   //   stimulus   //
   //////////////////

   // use the $random Verilog task to generate a random input pattern
   always #(20.0) D = $random ;             // **WARN: $random returns a 32-bit integer ! Here there is an implicit TYPE CASTING

   initial begin

      #100  rst = 1'b0 ;   // release the reset signal
      #1500 rst = 1'b1 ;

      #300 $finish ;   // stop the simulation
   end

endmodule

