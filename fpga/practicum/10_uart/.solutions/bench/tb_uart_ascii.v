//
// Minimal testbench code for uart_ascii.v Verilog module
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_uart_ascii ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen   ClockGen_inst (.clk(clk100)) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire TxD ;

   uart_ascii   DUT ( .clk(clk100), .TxD(TxD) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #(10414*14*3) $finish ;   // observe 3x serial sequences, then stop

   end

endmodule

