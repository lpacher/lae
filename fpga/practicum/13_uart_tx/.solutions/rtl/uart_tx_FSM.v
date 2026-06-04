//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Implementation of UART transmission unit using a Finite State Machine (FSM).
// The block only transmits one BYTE and it is foreseen to be interfaced with a FIFO.
//
// Ref. also to: https://github.com/FPGA-course-2025/day3/blob/main/UART/uart_transmitter.vhd
//
// Luca Pacher - pacher@to.infn.it
// Fall 2020
//
//
//   ______________||_________________________________________________________________________   tx_start
//
//   __________________       _____ _____ _____ _____ _____ _____ _____ _____ _____ __________
//                     \_____/_____X_____X_____X_____X_____X_____X_____X_____X     :             TxD
//
//         IDLE        START  BIT0  BIT1  BIT2  BIT3  BIT4  BIT5  BIT6  BIT7  STOP  IDLE
//
//                     ____________________________________________________________
//   _________________/                                                            \__________   tx_busy
//
//   ______________________________________________________________________________||_________   tx_done
//
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`timescale 1ns / 100ps

module uart_tx_FSM (

   input  wire clk,                     // assume 100 MHz on-board system clock
   input  wire rst,                     // synchronous reset, active high
   input  wire tx_start,                // start of transmission (e.g. a push-button or a single-clock pulse flag, more in general from a FIFO-empty flag)
   input  wire tx_baud,                 // baud-rate "tick", single clock-pulse asserted once every 1/(9.6 kHz)
   input  wire [7:0] tx_data,           // byte to be transmitted over the serial lane
   output wire tx_busy,                 // keep high while transmitting data
   output reg  tx_done,                 // single-pulse asserted when finished
   output reg  TxD                      // serial output stream

   ) ;


   ///////////////////////////
   //   states definition   //
   ///////////////////////////

   // simply assume a straight-binary states encoding and count from 0 to 12
   parameter [3:0] IDLE  = 4'h0 ;
   parameter [3:0] SYNC  = 4'h1 ;
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

   reg [3:0] STATE ;


   ///////////////////////
   //   input buffers   //
   ///////////////////////

   reg [7:0] tx_data_buf ;


   /////////////////////////////////////////////////
   //   FSM coding into single sequential block   //
   /////////////////////////////////////////////////

   always @(posedge clk) begin

      if(rst) begin
         STATE <= IDLE ;
      end
      else begin
         case( STATE )

            IDLE :
            begin
               TxD     <= 1'b1 ;
               //tx_busy <= 1'b0 ;
               //tx_done <= 1'b0 ;
               if (tx_start) begin
                  STATE <= SYNC ;       //  move to SYNC and wait for the first Baud "tick" before starting the transaction
               end
               else
                  STATE <= IDLE ;
            end
            //_____________________________
            //
            SYNC :
            begin
               TxD     <= 1'b1 ;   // the serial output is still in "idle"
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               tx_data_buf[7:0] <= tx_data[7:0] ;
               // **IMPORTANT: move to next state only if a baud "tick" is present!
               if (tx_baud)
                  STATE <= START ;
               else
                  STATE <= SYNC ;
            end
            //_____________________________
            //
            START :
            begin
               TxD     <= 1'b0 ;              // assert START bit to '0' as requested by RS-232 protocol
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT0 ;
               else
                  STATE <= START ;
            end
            //_____________________________
            //
            BIT0 :
            begin
               TxD     <= tx_data_buf[0] ;    // send the LSB first as requested by RS-232 protocol
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT1 ;
               else
                  STATE <= BIT0 ;
            end
            //_____________________________
            //
            BIT1 :
            begin
               TxD     <= tx_data_buf[1] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT2 ;
               else
                  STATE <= BIT1 ;
            end
            //_____________________________
            //
            BIT2 :
            begin
               TxD     <= tx_data_buf[2] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT3 ;
               else
                  STATE <= BIT2 ;
            end
            //_____________________________
            //
            BIT3 : begin
               TxD     <= tx_data_buf[3] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT4 ;
               else
                  STATE <= BIT3 ;
            end
            //_____________________________
            //
            BIT4 :
            begin
               TxD     <= tx_data_buf[4] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT5 ;
               else
                  STATE <= BIT4 ;
            end
            //_____________________________
            //
            BIT5 :
            begin
               TxD     <= tx_data_buf[5] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT6 ;
               else
                  STATE <= BIT5 ;
            end
            //_____________________________
            //
            BIT6 :
            begin
               TxD     <= tx_data_buf[6] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= BIT7 ;
               else
                  STATE <= BIT6 ;
            end
            //_____________________________
            //
            BIT7 :
            begin
               TxD     <= tx_data_buf[7] ;
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;
               if (tx_baud)
                  STATE <= STOP ;
               else
                  STATE <= BIT7 ;
            end
            //_____________________________
            //
            STOP :
            begin
               TxD     <= 1'b1 ;            // assert STOP bit to '1' as requested by RS-232 protocol
               //tx_busy <= 1'b1 ;
               //tx_done <= 1'b0 ;            // assert a single clock-pulse tx_done when moving back to IDLE
               if (tx_baud)
                  STATE <= IDLE ;
               else
                  STATE <= STOP ;
            end
            //_____________________________
            //
            default : STATE <= IDLE ;
         endcase
      end   //else
   end   //always


   ///////////////////////////
   //   busy-flag (level)   //
   ///////////////////////////

   assign tx_busy = (STATE == IDLE) ? 1'b0 : 1'b1 ;   //LEVEL flag, always-on while not IDLE


   /////////////////////////////////////////
   //    done-flag (single clock-pulse)   //
   /////////////////////////////////////////

   always @(posedge clk) begin

      tx_done = 1'b0 ;

      if( (STATE == STOP) && tx_baud)
         tx_done = 1'b1 ;

   end   //always


endmodule

