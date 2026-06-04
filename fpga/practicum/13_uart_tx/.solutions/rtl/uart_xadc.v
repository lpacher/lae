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
   input  wire select,                    // select what to send through UART
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

   XADC  XADC (

      .AdcClk    (        pll_clk ),
      .AdcSoc    (        adc_soc ),
      .AdcEoc    (        adc_eoc ),
      .AdcData   ( adc_data[11:0] )
   );


   wire tx_byte_up  = (~select) ? 8'hAB : { 4'b0000 , adc_data[11:8] } ;
   wire tx_byte_low = (~select) ? 8'hCD : adc_data[7:0]  ;


   /////////////////////////////
   //   baud-rate generator   //
   /////////////////////////////

   wire baud_tick ;

   BaudGen  BaudGen (.clk(pll_clk), .rst(~pll_locked), .tx_en(baud_tick)) ;


   /////////////////////////////////
   //   byte-splitter using FSM   //
   /////////////////////////////////

   wire tx_busy, tx_done ;   //from UART FSM

   parameter [1:0] IDLE  = 2'd0 ;
   parameter [1:0] BYTE1 = 2'd1 ;
   parameter [1:0] BYTE2 = 2'd2 ;

   reg [1:0] STATE = 2'd0 ;

   reg [7:0] tx_data = 8'hFF ;
   reg tx_start = 1'b0 ;

   always @(posedge pll_clk) begin

      if (~pll_locked) begin
         STATE    <= IDLE  ;
         tx_data  <= 8'hFF ;
         tx_start <= 1'b0  ;
      end
      else begin

         case (STATE)
            //_________________________________
            //
            IDLE :
            begin
               tx_start <= 1'b0 ;
               if (adc_eoc) begin
                  STATE <= BYTE1 ;
                  tx_data  <= tx_byte_up ;
                  tx_start <= 1'b1 ;
               end
            end
            BYTE1 :
            begin
               tx_start <= 1'b0 ;
               if (tx_done) begin
                  STATE <= BYTE2 ;
                  tx_data  <= tx_byte_low ;
                  tx_start <= 1'b1 ;
               end
               else begin
                  STATE <= BYTE1 ;
                  tx_start <= 1'b0 ;
               end
            end
            //_________________________________
            //
            BYTE2 :
            begin
               tx_start <= 1'b0 ;
               if (tx_done) begin
                  STATE <= IDLE ;
               end
               else
                  STATE <= BYTE2 ;
            end
            //_________________________________
            //
            default : STATE <= IDLE ;
         endcase
      end
   end   //always

//   wire [7:0] tx_data = (STATE == BYTE1) ? tx_byte_up : tx_byte_low ;


   //////////////////////////////
   //   UART transmitter FSM   //
   //////////////////////////////


   uart_tx_FSM  uart_tx (

      .clk      (       pll_clk ),
      .rst      (   ~pll_locked ),
      .tx_start (      tx_start ),
      .tx_baud  (     baud_tick ),
      .tx_data  (       tx_data ),
      .tx_busy  (       tx_busy ),
      .tx_done  (       tx_done ),
      .TxD      (           TxD )
   );

   // display the serial output at the oscilloscope (use "busy" as trigger to show START/STOP bits)
   assign txd_probe  = TxD;

   //assign busy_probe = tx_busy ;
   assign busy_probe = (STATE == BYTE1) || (STATE == BYTE2);

endmodule

