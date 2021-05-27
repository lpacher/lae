//
// Example testbench for UART TX
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_uart_tx ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  #(.PERIOD(10.0)) ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst = 1'b1 ;

   reg tx_start = 1'b0 ;

   wire TxD ;

   reg [7:0] tx_data ;

   uart_tx   DUT (

      .clk           (       clk100 ),
      .reset         (          rst ),
      .tx_start      (     tx_start ),
      .tx_data       ( tx_data[7:0] ),
      .TxD           (          TxD )

      ) ;


   initial begin

      #500 rst = 1'b0 ;    // de-assert the reset

      #200 tx_data = 8'hAB ;

      @(posedge clk100) tx_start = 1'b1 ;    // start transmission
      @(posedge clk100) tx_start = 1'b0 ;

      #(12*10414*10.0) tx_data = 8'hCD ;     // wait 12 "baud ticks" x 10.0 ns clock period x 10414 clock cycles per "tick"

      @(posedge clk100) tx_start = 1'b1 ;    // start transmission
      @(posedge clk100) tx_start = 1'b0 ;

      #(12*10414*10.0) tx_data = 8'hEF ;

      @(posedge clk100) tx_start = 1'b1 ;    // start transmission
      @(posedge clk100) tx_start = 1'b0 ;

      #(12*10414*10.0) $finish ;

   end

endmodule

