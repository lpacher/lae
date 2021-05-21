//
// Example Moore Finite State Machine (FSM) for 110 sequence detector.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


// choose here the desired encoding style for FSM states
`define STATES_ENCODING_BINARY
//`define STATES_ENCODING_GRAY
//`define STATES_ENCODING_ONEHOT


`timescale 1ns / 100ps

module SequenceDetector (

   input  wire clk,
   input  wire reset,            // synchronous reset, active-high
   input  wire si,               // serial-in
   output wire detected          // single clock-pulse output asserted when 110 is detected_comb

   ) ;


   ///////////////////////////
   //   states definition   //
   ///////////////////////////

`ifdef STATES_ENCODING_BINARY

   parameter [1:0] S0 = 2'b00 ;
   parameter [1:0] S1 = 2'b01 ;
   parameter [1:0] S2 = 2'b10 ;
   parameter [1:0] S3 = 2'b11 ;

   reg [1:0] STATE, STATE_NEXT ;

`endif


`ifdef STATES_ENCODING_GRAY

   parameter [1:0] S0 = 2'b00 ;
   parameter [1:0] S1 = 2'b01 ;
   parameter [1:0] S2 = 2'b11 ;
   parameter [1:0] S3 = 2'b10 ;

   reg [1:0] STATE, STATE_NEXT ;

`endif


`ifdef STATES_ENCODING_ONEHOT

   parameter [3:0] S0 = 2'b0001 ;
   parameter [3:0] S1 = 2'b0010 ;
   parameter [3:0] S2 = 2'b0100 ;
   parameter [3:0] S3 = 2'b1000 ;

   reg [3:0] STATE, STATE_NEXT ;

`endif



   /////////////////////////////////////////////////
   //   next-state logic (pure sequential part)   //
   /////////////////////////////////////////////////

   always @(posedge clk) begin      // infer a bank of FlipFlops

      if(reset)
         STATE <= S0 ;

      else
         STATE <= STATE_NEXT ;

   end   // always



   ////////////////////////////
   //   combinational part   //
   ////////////////////////////

   reg detected_comb ;

   always @(*) begin

      detected_comb = 1'b0 ;

      case ( STATE )

         default : STATE_NEXT = S0 ;   // **IMPORTANT ! Use a "catch-all" condition to cover all remaining codes, LATCHES inferred otherwise !

         S0 : begin

            detected_comb = 1'b0 ;

            if(si == 1'b1)
               STATE_NEXT = S1 ;
            else 
               STATE_NEXT = S0 ;

         end

         //_____________________________
         //

         S1 : begin

            detected_comb = 1'b0 ;

            if(si == 1'b1)
               STATE_NEXT = S2 ;
             else
               STATE_NEXT = S0 ;
         end

         //_____________________________
         //

         S2 : begin

            detected_comb = 1'b0 ;

            if(si == 1'b0)
               STATE_NEXT = S3 ;
            else
               STATE_NEXT = S2 ;
         end

         //_____________________________
         //

         S3 : begin

            detected_comb = 1'b1 ;   // 110 sequence detected !

            if(si == 1'b1)
               STATE_NEXT = S1 ;
            else
               STATE_NEXT = S0 ;
         end

      endcase

   end   // always


   // just for reference, pre-place an OBUF primitive on output signal in RTL
   OBUF  OBUF_inst (.I(detected_comb), .O(detected)) ;

endmodule

