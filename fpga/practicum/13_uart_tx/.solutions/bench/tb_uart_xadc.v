//
// Not a real testbench for the XADC, just verify the functionality of the alternative
// UART transmitter implementation.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_uart_xadc ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen   ClockGen_inst (.clk(clk100)) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire TxD ;

   uart_xadc  DUT ( .clk(clk100), .select(1'b1), .TxD(TxD) );


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin
      #(10414*14*3) $finish ;
   end

endmodule
