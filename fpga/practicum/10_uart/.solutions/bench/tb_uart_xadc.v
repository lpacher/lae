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


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   wire pll_clk, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk100), .CLK_OUT(pll_clk), .LOCKED(pll_locked) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg tx_start = 1'b0 ;

   wire [11:0] adc_data = 12'hABC ;

   wire baud_tick, sdo, busy ;

   BaudGen  BaudGen (.clk(pll_clk), .rst(~pll_locked), .tx_en(baud_tick)) ;

   wire [15:0] tx_data = { adc_data[7:0] , 4'b0000 , adc_data[11:8] } ;   // compose BYTES to be transmitted over serial lane

   wire busy, sdo ;

   uart_tx_bit_counter  #(.NBYTES(2)) uart_tx_bit_counter (

      .clk           (       pll_clk ),
      .tx_start      (      tx_start ),
      .tx_en         (     baud_tick ),
      .tx_data       ( tx_data[15:0] ),
      .tx_busy       (          busy ),
      .TxD           (           sdo )

      ) ;



   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #500   tx_start = 1'b1 ;
      #(10414*14*3) $finish ;

   end

endmodule
