//
// Testbench module for UART transmitter using FSM.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_uart_tx_FSM ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   //////////////////////////////////////////
   //   free-running baud-rate generator   //
   //////////////////////////////////////////

   wire baud_tick ;

   BaudGen   BaudGen_inst (.clk(clk100), .tx_en(baud_tick)) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst = 1'b1 ;

   reg tx_start = 1'b0 ;

   reg [7:0] tx_data = 8'hFF ;

   wire sdo ;

   uart_tx_FSM   DUT  ( .clk(clk100), .rst(rst), .tx_start(tx_start), .tx_en(baud_tick), .tx_data(tx_data), .TxD(sdo)) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer k ;

   initial begin

      #500 rst = 1'b0 ;   // release the reset

      for(k = 0; k < 10; k = k+1) begin

         tx_data = $random ;

         #(50000) tx_start = 1'b1 ;                // "strange" delay only to have tx_start in between two ticks, totally uncorrelated with the baud "tick"

         #(10) tx_start = 1'b0 ;                   // "dirty" way to generate a single clock-pulse

         @(posedge baud_tick) #(11*10414*10.0) ;   // wait for 11 UART "bits"

      end   // for

      #100 tx_start = 1'b0 ;   // disable data transmission, check what happens

      #(12*10414*10.0) $finish ;

   end  // initial

   // **DEBUG: probe FSM current state for easier waveform debugging
   wire [3:0] STATE = DUT.STATE ;

endmodule


