//
// Alternative coding style for 110 sequence detector using Moore FSM.
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
   output wire detected          // single clock-pulse output asserted when 110 is detected

   ) ;


   ///////////////////////////
   //   states definition   //
   ///////////////////////////

`ifdef STATES_ENCODING_BINARY

   parameter [1:0] S0 = 2'b00 ;
   parameter [1:0] S1 = 2'b01 ;
   parameter [1:0] S2 = 2'b10 ;
   parameter [1:0] S3 = 2'b11 ;

   reg [1:0] STATE ;

`endif


`ifdef STATES_ENCODING_GRAY

   parameter [1:0] S0 = 2'b00 ;
   parameter [1:0] S1 = 2'b01 ;
   parameter [1:0] S2 = 2'b11 ;
   parameter [1:0] S3 = 2'b10 ;

   reg [1:0] STATE ;

`endif


`ifdef STATES_ENCODING_ONEHOT

   parameter [3:0] S0 = 2'b0001 ;
   parameter [3:0] S1 = 2'b0010 ;
   parameter [3:0] S2 = 2'b0100 ;
   parameter [3:0] S3 = 2'b1000 ;

   reg [3:0] STATE ;

`endif



   /////////////////////////////////////////////////
   //   FSM coding into single sequential block   //
   /////////////////////////////////////////////////

   always @(posedge clk) begin

      if(reset)
         STATE <= S0 ;

      else

         case ( STATE )

            default : S0 ;

            S0 : if(si) STATE <= S1 ; else STATE <= S0 ; 
            S1 : if(si) STATE <= S2 ; else STATE <= S0 ;
            S2 : if(si) STATE <= S2 ; else STATE <= S3 ;
            S3 : if(si) STATE <= S1 ; else STATE <= S0 ;

         endcase

   end   // always


   assign detected = (STATE == S3) ? 1'b1 : 1'b0 ;

endmodule

