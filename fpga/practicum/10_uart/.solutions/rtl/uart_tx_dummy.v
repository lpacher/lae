//
// Simplified UART TX unit using a one-hot bit counter to keep track of data-alignment.
// A realistic implementation uses a FSM to serialize parallel input data and a FIFO to
// properly interface the trasmitter with the user logic.
// Use the NBYTES Verilog parameter to customize the number of BYTES (ASCII characters)
// transmitted over RS-232 serial protocol.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


//
//   __________________       _____ _____ _____ _____ _____ _____ _____ _____ _____ ___________
//                     \_____/_____X_____X_____X_____X_____X_____X_____X_____X     :
//
//         IDLE        START  BIT0  BIT1  BIT2  BIT3  BIT4  BIT5  BIT6  BIT7  STOP  IDLE
//
//


`timescale 1ns / 100ps

module uart_tx_dummy #(parameter integer NBYTES = 1) (

   input  wire clk,                             // on-board 100 MHz system clock 
   input  wire tx_start,                        // start of transmission (e.g. a push-button or a single-clock pulse flag, more in general from a FIFO-empty flag)
   input  wire tx_en,                           // baud-rate "tick", single clock-pulse asserted once every 1/(9.6 kHz)
   input  wire [(NBYTES*8)-1:0] tx_data,        // data-width of payload data to be transmitted
   output reg  TxD                              // serial output stream 

   ) ;


   // create a one-hot bit counter to keep track of data alignment

   reg [NBYTES*(1+8+1):0] bit_count ;

   always @(posedge clk ) begin

      if( tx_start == 1'b1 ) begin
         bit_count[0]                <= 1'b1 ;              // reset shift register outputs with 1000 ... 00000
         bit_count[NBYTES*(1+8+1):1] <=  'b0 ;
      end

      else if( tx_en == 1'b1 )
         bit_count[NBYTES*(1+8+1):0] <= { bit_count[NBYTES*(1+8+1)-1:0] , 1'b0 } ;   // shift-right using concatenation, just once per Baud-rate "tick"

   end   // always


   // compose the TX serial stream according to RS-232 standard

   integer k ;

   always @(posedge clk) begin

      TxD <= 1'b1 ;                                                                    // IDLE

      // loop over the number of bytes to be transmitted
      for( k = 0; k < NBYTES; k = k+1 ) begin    

            if( bit_count[1 + 10*k] == 1'b1 ) TxD <= 1'b0 ;                            // START bit

            else if( bit_count[ 2 + 10*k] == 1'b1 ) TxD <= tx_data[0 + 8*k] ;          // LSB first
            else if( bit_count[ 3 + 10*k] == 1'b1 ) TxD <= tx_data[1 + 8*k] ;
            else if( bit_count[ 4 + 10*k] == 1'b1 ) TxD <= tx_data[2 + 8*k] ;
            else if( bit_count[ 5 + 10*k] == 1'b1 ) TxD <= tx_data[3 + 8*k] ;
            else if( bit_count[ 6 + 10*k] == 1'b1 ) TxD <= tx_data[4 + 8*k] ;
            else if( bit_count[ 7 + 10*k] == 1'b1 ) TxD <= tx_data[5 + 8*k] ;
            else if( bit_count[ 8 + 10*k] == 1'b1 ) TxD <= tx_data[6 + 8*k] ;
            else if( bit_count[ 9 + 10*k] == 1'b1 ) TxD <= tx_data[7 + 8*k] ;

            else if( bit_count[10 + 10*k] == 1'b1 ) TxD <= 1'b1 ;                      // STOP bit

      end   // for k
   end   // always

endmodule

