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

   reg adc_soc = 1'b0 ;

   initial begin

      #1000 adc_soc = 1'b1 ;
      #10   adc_soc = 1'b0 ;
   end

/*

   // assert a single clock-pulse "SOC" once every 0.1 seconds
   wire adc_soc ;

   //TickCounterRst #(.MAX(10000000)) AdcSocGen (.clk(pll_clk), .rst(~pll_locked), .tick(adc_soc)) ;
   TickCounterRst #(.MAX(100000)) AdcSocGen (.clk(pll_clk), .rst(~pll_locked), .tick(adc_soc)) ;

*/

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


   // compose BYTES to be transmitted over serial lane
   wire [7:0] tx_byte1 = (select == 1'b0) ? 8'hFF : adc_data[7:0] ;                  //lower tx_byte
   wire [7:0] tx_byte2 = (select == 1'b0) ? 8'hFF : {4'b0000 , adc_data[11:8] } ;    //upper tx_byte


   /////////////////////////////////
   //   tx_byte-splitter using FSM   //
   /////////////////////////////////

   wire busy ;   //FROM UART FSM

   parameter [1:0] IDLE       = 2'b00 ;
   parameter [1:0] BYTE1 = 2'b01 ;
   parameter [1:0] BYTE2 = 2'b10 ;
   parameter [1:0] DONE       = 2'b11 ;   //dummy-state, just one clock delay

   reg [1:0] STATE = 2'b00 ;

   always @(posedge pll_clk) begin

      if (~pll_locked)
         STATE <= IDLE ;
      else
         case (STATE)

            default : STATE <= IDLE ;
            //_________________________________
            //
            IDLE :
            begin
               if (adc_eoc)
                  STATE <= BYTE1 ;
            end
            //_________________________________
            //
            BYTE1 :
            begin
               if (~busy)
                  STATE <= BYTE2 ;
            end
            //_________________________________
            //
            BYTE2 :
            begin
               if (~busy)
                  STATE <= DONE ;
            end
            //_________________________________
            //
            DONE : STATE <= IDLE ;
         endcase
   end   //always


   /////////////////////////////
   //   baud-rate geberator   //
   /////////////////////////////

   wire baud_tick ;

   BaudGen  BaudGen (.clk(pll_clk), .rst(~pll_locked), .tx_en(baud_tick)) ;


   //////////////////////////////
   //   UART transmitter FSM   //
   //////////////////////////////

   wire tx_start = (STATE == BYTE1) || (STATE == BYTE2) ;
   wire [7:0] tx_data = (STATE == BYTE1) ? tx_byte1 : tx_byte2 ;

   uart_tx_FSM  uart_tx (

      .clk           (       pll_clk ),
      .rst           (   ~pll_locked ),
      .tx_start      (      tx_start ),
      .tx_en         (     baud_tick ),
      .tx_data       (  tx_data[7:0] ),
      .tx_busy       (          busy ),
      .TxD           (           TxD )

      ) ;


   // display the serial output at the oscilloscope (use "busy" as trigger to show START/STOP bits)
   assign txd_probe  = TxD ;
   assign busy_probe = busy ;

endmodule

