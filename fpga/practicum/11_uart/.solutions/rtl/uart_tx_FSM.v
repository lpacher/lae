//
// Implementation of UART transmission unit using a Finite State Machine (FSM).
// The block only transmits one BYTE and it is foreseen to be interfaced with a FIFO.
//
// Luca Pacher - pacher@to.infn.it
// Fall 2020
//
//
//   __________________       _____ _____ _____ _____ _____ _____ _____ _____ _____ ___________
//                     \_____/_____X_____X_____X_____X_____X_____X_____X_____X     :
//
//         IDLE        START  BIT0  BIT1  BIT2  BIT3  BIT4  BIT5  BIT6  BIT7  STOP  IDLE
//
//


`timescale 1ns / 100ps

module uart_tx_FSM (

   input  wire clk,                     // assume 100 MHz on-board system clock
   input  wire rst,                     // synchronous reset, active high
   input  wire tx_start,                // start of transmission (e.g. a push-button or a single-clock pulse flag, more in general from a FIFO-empty flag)
   input  wire tx_en,                   // baud-rate "tick", single clock-pulse asserted once every 1/(9.6 kHz)
   input  wire [7:0] tx_data,           // byte to be transmitted over the serial lane
   output reg  tx_busy,                 // keep high while trasmitting data
   //output reg  tx_done,
   output reg  TxD                      // serial output stream

   ) ;


   ///////////////////////////
   //   states definition   //
   ///////////////////////////

   // simply assume a straight-binary states encoding and count from 0 to 12
   parameter [3:0] IDLE  = 4'h0 ;
   parameter [3:0] LOAD  = 4'h1 ;
   parameter [3:0] START = 4'h2 ;
   parameter [3:0] BIT0  = 4'h3 ;
   parameter [3:0] BIT1  = 4'h4 ;
   parameter [3:0] BIT2  = 4'h5 ;
   parameter [3:0] BIT3  = 4'h6 ;
   parameter [3:0] BIT4  = 4'h7 ;
   parameter [3:0] BIT5  = 4'h8 ;
   parameter [3:0] BIT6  = 4'h9 ;
   parameter [3:0] BIT7  = 4'hA ;
   parameter [3:0] STOP  = 4'hB ;
   parameter [3:0] PAUSE = 4'hC ;   // optionally wait for another baud period before moving to IDLE

   reg [3:0] STATE, STATE_NEXT ;


   ///////////////////////
   //   input buffers   //
   ///////////////////////

   reg [7:0] tx_data_buf ;   // **WARN: in hardware this becomes a bank of LATCHES !


   /////////////////////////////////////////////////
   //   next-state logic (pure sequential part)   //
   /////////////////////////////////////////////////

   always @(posedge clk) begin      // infer a bank of FlipFlops

      if(rst)
         STATE <= IDLE ;
      else

         STATE <= STATE_NEXT ;

   end   // always


   ////////////////////////////
   //   combinational part   //
   ////////////////////////////

   always @(*) begin

      TxD = 1'b1 ;   // latches inferred otherwise

      case( STATE )

         IDLE : begin

            TxD     = 1'b1 ;
            tx_busy = 1'b0 ;
            //tx_done = 1'b0 ;

            if (tx_start)
               STATE_NEXT = LOAD ;       //  move to LOAD and wait for the first Baud "tick" before starting the transaction
            else
               STATE_NEXT = IDLE ;

         end   // IDLE

         //_____________________________


         LOAD : begin

            TxD     = 1'b1 ;   // the serial output is still in "idle"
            //tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            tx_data_buf[7:0] = tx_data[7:0] ;   // LATCHES here !

            if (tx_en)                    // **IMPORTANT: move to next state only if a baud "tick" is present !
               STATE_NEXT = START ;
            else
               STATE_NEXT = LOAD ;

         end   // LOAD
         //_____________________________


         START : begin

            TxD     = 1'b0 ;              // assert START bit to '0' as requested by RS-232 protocol
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT0 ;
            else
               STATE_NEXT = START ;

         end   // START
         //_____________________________


         BIT0 : begin

            TxD     = tx_data_buf[0] ;    // send the LSB first as requested by RS-232 protocol
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT1 ;
            else
               STATE_NEXT = BIT0 ;

         end   // BIT0
         //_____________________________


         BIT1 : begin

            TxD     = tx_data_buf[1] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT2 ;
            else
               STATE_NEXT = BIT1 ;

         end   // BIT1
         //_____________________________


         BIT2 : begin

            TxD     = tx_data_buf[2] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT3 ;
            else
               STATE_NEXT = BIT2 ;

         end   // BIT2
         //_____________________________


         BIT3 : begin

            TxD     = tx_data_buf[3] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT4 ;
            else
               STATE_NEXT = BIT3 ;

         end   // BIT3
         //_____________________________


         BIT4 : begin

            TxD     = tx_data_buf[4] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT5 ;
            else
               STATE_NEXT = BIT4 ;
         end   // BIT4
         //_____________________________


         BIT5 : begin

            TxD     = tx_data_buf[5] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT6 ;
            else
               STATE_NEXT = BIT5 ;

         end   // BIT5
         //_____________________________


         BIT6 : begin

            TxD     = tx_data_buf[6] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = BIT7 ;
            else
               STATE_NEXT = BIT6 ;

         end   // BIT6
         //_____________________________


         BIT7 : begin

            TxD     = tx_data_buf[7] ;
            tx_busy = 1'b1 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = STOP ;
            else
               STATE_NEXT = BIT7 ;
         end   // BIT7
         //_____________________________


         STOP : begin

            TxD     = 1'b1 ;            // assert STOP bit to '1' as requested by RS-232 protocol
            tx_busy = 1'b1 ;
            //tx_done = 1'b1 ;            // assert a single clock-pulse tx_done when moving back to IDLE

            if (tx_en)
               //STATE_NEXT = IDLE ;
               STATE_NEXT = PAUSE ;
            else
               STATE_NEXT = STOP ;

         end   // STOP
         //_____________________________


         PAUSE : begin

            TxD     = 1'b1 ;
            tx_busy = 1'b0 ;
            //tx_done = 1'b0 ;

            if (tx_en)
               STATE_NEXT = IDLE ;
            else
               STATE_NEXT = PAUSE ;

         end   // PAUSE

         default : STATE_NEXT = IDLE ;   // **IMPORTANT: latches inferred otherwise !

      endcase

   end   // always

endmodule

