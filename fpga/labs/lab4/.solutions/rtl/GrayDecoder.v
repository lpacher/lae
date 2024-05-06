//
//
// Example Verilog implementation for a parameterized N-bit binary to Gray decoder.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2024
//

`ifndef GRAY_DECODER__V   // include guard
`define GRAY_DECODER__V


`timescale 1ns / 100ps

module GrayDecoder #(parameter integer Nbit = 5) (

   input  wire [Nbit-1:0] Bin,         // N-bit base-2 binary input code
   output reg  [Nbit-1:0] GrayOut      // N-bit Gray output code

   ) ;

   integer i ;   // **WARN: this is a 32-bit integer!

   always @(*) begin

      // MSB
      GrayOut[Nbit-1] = Bin[Nbit-1] ;   // **NOTE: same as GrayOut[Nbit-1] = Bin[Nbit-1] ^ 1'b0

      // LSB to MSB-1
      for(i=0; i < Nbit-1 ; i=i+1) begin

         GrayOut[i] = Bin[i] ^ Bin[i+1] ;

      end   //for
   end   //always

   // alternatively, more compact right-shift or concatenation operators can be used in place of a for-loop
   //assign GrayOut = (Bin >> 1) ^ Bin ;
   //assign GrayOut = { 1'b0 , Bin[Nbit-1:1]} ^ Bin ;   // same as (Bin >> 1)


endmodule

`endif
