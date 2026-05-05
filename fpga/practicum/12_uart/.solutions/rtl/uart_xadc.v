//
// Example FPGA project: read the on-die temperature through XADC and send ADC data
// to a PC using UART serial protocol.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module uart_xadc (

   input  wire clk,                       // assume 100 MHz clock from external on-board oscillator
   output wire TxD,                       // serial output, hard-wired FPGA pin already connected by Digilent to USB/UART bridge on the board
   output wire txd_probe, busy_probe      // optionally, probe signals at the oscilloscope

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   wire pll_clk, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk), .CLK_OUT(pll_clk), .LOCKED(pll_locked) ) ;



   ///////////////////////////
   //   ADC SOC generator   //
   ///////////////////////////

   // assert a single clock-pulse "SOC" once every 0.1 seconds
   wire adc_soc ;

   TickCounterRst #(.MAX(10000000)) AdcSocGen (.clk(pll_clk), .rst(~pll_locked), .tick(adc_soc)) ;


   ////////////////////////////////////////////////////////////
   //    XADC configured to read on-die temperature sensor   //
   ////////////////////////////////////////////////////////////

   wire adc_eoc ;

   wire [11:0] adc_data ;

   //assign adc_data = 12'hABC ;    // **DEBUG


   XADC  XADC (

      .AdcClk    (        pll_clk ),
      .AdcSoc    (        adc_soc ),
      .AdcEoc    (        adc_eoc ),
      .AdcData   ( adc_data[11:0] )

   ) ;


   ///////////////////////////////////////////////////////
   //   UART transmitter (baud-rate generator + FSM)   //
   //////////////////////////////////////////////////////

   wire baud_tick, sdo, busy ;

   BaudGen  BaudGen (.clk(pll_clk), .rst(~pll_locked), .tx_en(baud_tick)) ;

   wire [15:0] tx_data = { adc_data[7:0] , 4'b0000 , adc_data[11:8] } ;   // compose BYTES to be transmitted over serial lane


   //
   // alternative implementation of UART transmitter using a one-hot bit-counter
   //
   wire busy, sdo ;

   uart_tx_bit_counter  #(.NBYTES(2)) uart_tx_bit_counter (

      .clk           (       pll_clk ),
      .tx_start      (       adc_eoc ),
      .tx_en         (     baud_tick ),
      .tx_data       ( tx_data[15:0] ),
      .tx_busy       (          busy ),
      .TxD           (           sdo )

      ) ;

   assign TxD = sdo ;

   // display the serial output at the oscilloscope (use "busy" as trigger to show START/STOP bits)
   assign txd_probe  = sdo ;
   assign busy_probe = busy ;

endmodule

