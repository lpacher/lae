//
// Behavioural implementation of a parameterizable N-bit binary/Gray decoder.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2022
//


`timescale 1ns / 100ps

module GrayDecoder #(parameter integer N = 4) (

   input  wire [N-1:0] Bin,         // N-bit base-2 binary input code
   output reg  [N-1:0] GrayOut      // N-bit Gray output code
 
   ) ;

   integer i ;

   always @(*) begin

      GrayOut[N-1] = Bin[N-1] ;    // **NOTE: same as Bin[N-1] ^ 1'b0

      for(i=0; i < N-1; i=i+1) begin
         GrayOut[i] = Bin[i] ^ Bin[i+1] ;
      end  // for
   end  // always

   /*

   //   **IMPORTANT NOTE**
   // The same functionality can be implemented in a more compact way using the right-shift operator >> as follows:

   always @(*) begin
      GrayOut[N-1:0] = (Bin[N-1:0] >> 1) ^ Bin[N-1:0] ;    // where Bin[N-1:0] >> 1 is { 1'b0 , Bin[N-1] , Bin[N-2] , .... , Bin[1] }
   end

   */

endmodule

