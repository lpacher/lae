//
// Example FPGA project: read the on-die temperature through XADC and send ADC data to a PC using UART serial protocol.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module xadc_uart_tx (

   input  wire clk,        // on-board 100 MHz clk
   input  wire rst,        // push-button
   output wire TxD         // mapped to UART TX serial lane

   ) ;


   /////////////////////////
   //   clocking wizard   //
   /////////////////////////

   wire clk_int ;

   clk_wiz_0  clk_wiz_0 ( .clk_in1(clk), .clk_out1(clk_int) ) ;


   ///////////////////////////
   //   ADC SOC generator   //
   ///////////////////////////

   // assert a single clock-pulse "SOC" once every 0.1 seconds

   wire adc_soc ;

   TickCounter #(.MAX(10000000)) AdcSocGen (.clk(clk_int), .tick(adc_soc)) ;



   ////////////////////////////////////////////////////////////
   //    XADC configured to read on-die temperature sensor   //
   ////////////////////////////////////////////////////////////

   wire adc_eoc ;

   wire [11:0] adc_data ;

   //assign adc_data = 12'hABC ;    // **DEBUG


   XADC  XADC (

      .AdcClk    (        clk_int ),
      .AdcSoc    (        adc_soc ),
      .AdcEoc    (        adc_eoc ),
      .AdcData   ( adc_data[11:0] )

   ) ;


   /////////////////
   //   UART TX   //
   /////////////////


   wire [15:0] tx_data = { adc_data[7:0] , 4'b0000 , adc_data[11:8] } ;   // compose BYTES to be transmitted over serial lane

   uart_tx   uart_tx (

      .clk           (       clk_int ),
      .reset         (           rst ),
      .tx_start      (       adc_eoc ),
      .tx_data       ( tx_data[15:0] ),
      .TxD           (           TxD )

      ) ;

endmodule

