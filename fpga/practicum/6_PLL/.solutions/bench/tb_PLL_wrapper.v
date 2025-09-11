//
// Minimal testbench code for PLL_wrapper.v Verilog module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//

`timescale 1ns / 100ps

module tb_PLL_wrapper ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   /////////////////////////// 
   //   device under test   //
   /////////////////////////// 

   // PLL output signals
   wire pll_clk, pll_locked ;

   reg rst = 1'b1 ;
   reg [1:0] clk_sel = 2'b00 ;

   PLL_wrapper  DUT ( .clk(clk100), .rst(rst), .sel(clk_sel), .pll_clk(pll_clk), .pll_locked(pll_locked) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #500 rst = 1'b0 ;         // release the reset

      #3000 ;                   // wait for PLL to lock

      #5000 clk_sel = 2'b01 ;
      #5000 clk_sel = 2'b10 ;
      #5000 clk_sel = 2'b11 ;

      #5000 $finish ;

   end

endmodule

