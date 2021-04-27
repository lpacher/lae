//
// Testbench module for 5-bit/32-bit one-hot decoder.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_OneHotDecoder ;


   /////////////////////////
   //   clock generator   //
   /////////////////////////

   parameter real clk_period = 20.0 ;

   wire clk ;

   ClockGen  #( .PERIOD(clk_period))  ClockGen ( .clk(clk) ) ;


   ///////////////////////
   //   5-bit counter   //
   ///////////////////////

   reg [4:0] count = 5'd0 ;

   always @(posedge clk)
      count <= count + 1'b1 ;


   /////////////////////////////////
   //   device under test (DUT)   //
   /////////////////////////////////

   wire [31:0] code ;

   OneHotDecoder DUT (.Bin(count[4:0]), .Bout(code[31:0]) ) ;
   //ThermometerDecoder DUT (.Bin(count[4:0]), .Bout(code[31:0]) ) ;


   //////////////////
   //   stimulus   //
   //////////////////

   initial begin

      #(64*clk_period) $finish ;   // explore all possible input codes, then stop

   end

endmodule

