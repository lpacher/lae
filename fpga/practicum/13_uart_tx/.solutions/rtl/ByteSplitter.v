
`timescale 1ns / 100ps

module ByteSplitter (

    input wire clk, rst,
    input wire [11:0] adc_data,
    input wire tx_busy, tx_done.
    output wire tx_start,
    output wire [7:0] tx_data

   );


   wire [7:0] tx_byte1 = 8'hAB ;
   wire [7:0] tx_byte2 = 8'hCD ;


   /////////////////////////////////
   //   byte-splitter using FSM   //
   /////////////////////////////////

   wire tx_busy, tx_done ;   //FROM UART FSM

   parameter [1:0] IDLE  = 2'b00 ;
   parameter [1:0] SYNC  = 2'b11 ;
   parameter [1:0] BYTE1 = 2'b01 ;
   parameter [1:0] BYTE2 = 2'b10 ;

   reg [1:0] STATE = 2'b00 ;


   always @(posedge clk) begin

      if (rst) begin
         tx_start = 1'b0 ;
         STATE <= IDLE ;
      end
      else begin
         case (STATE)
            //_________________________________
            //
            IDLE :
            begin
               tx_start = 1'b0 ;
               if (adc_eoc) begin
                  tx_start = 1'b1 ;
                  STATE <= SYNC ;
               end
            end
            //_________________________________
            //
            SYNC :
            begin
               STATE <= BYTE1 ;  //wait on clock-cycle to match timing
            end
            //_________________________________
            //
            BYTE1 :
            begin
               tx_start = 1'b0 ;
               if (~tx_busy) begin
                  STATE <= BYTE2 ;
               end
               else
                  STATE <= BYTE1 ;
            end
            //_________________________________
            //
            BYTE2 :
            begin
               tx_start = 1'b1 ;
               if (~tx_busy) begin
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


   //wire tx_start = (STATE == BYTE1) || (STATE == BYTE2) ;
   wire [7:0] tx_data = (STATE == BYTE1) ? tx_byte1 : tx_byte2 ;

endmodule
