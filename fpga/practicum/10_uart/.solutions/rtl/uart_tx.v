//
// Complete UART TX unit (baud-rate generator + serializer).
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module uart_tx (

   input  wire clk,
   input  wire reset,
   input  wire tx_start,
   input  wire [15:0] tx_data,
   output wire TxD,
   output wire tx_busy

   ) ;



   //////////////////////////////////////
   //   ~9.6 kHz baud-rate generator   //
   //////////////////////////////////////

   // generate a ~9.6 kHz single-clock pulse Baud-rate for data transmission by dividing
   // the on-bard 100 MHz clock by 10415

   wire tx_en ;

   //TickCounter  #(.MAX(10415)) baud_gen ( .clk(clk), .tick(tx_en)) ;

   // 14-bit free-running counter
   reg [13:0] count_baudrate = 14'b0 ;

   always @(posedge clk)
      if( count_baudrate == 10414 )
         count_baudrate <= 'b0 ;                              // force the roll-over
      else
         count_baudrate <= count_baudrate + 1 ;

   assign tx_en = ( count_baudrate == 0 ) ? 1'b1 : 1'b0 ;     // assert a single-clock pulse each time the counter resets


   ////////////////////
   //   serializer   //
   ////////////////////

/*
   uart_tx_FSM   uart_tx_FSM (

      .clk           (          clk ),
      .reset         (        reset ),
      .tx_start      (     tx_start ),
      .tx_en         (        tx_en ),
      .tx_data       ( tx_data[7:0] ),
      .TxD           (          TxD ),
      .tx_busy       (      tx_busy )

      ) ;

*/

   uart_tx_dummy  #(.NBYTES(2)) uart_tx_shift_register (

      .clk           (           clk ),
      .tx_start      (      tx_start ),
      .tx_en         (         tx_en ),
      .tx_data       ( tx_data[15:0] ),
      .TxD           (           TxD )

      ) ;


endmodule

