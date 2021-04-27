//
// Behavioural implementation using for-loop of a 5-bit/32-bit one-hot decoder.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module OneHotDecoder (

   input  wire [4:0]  Bin,      //  5-bit base-2 binary input code
   output reg  [31:0] Bout      // 32-bit one-hot output code
 
   ) ;


   integer i ;

   always @(*) begin

      for(i=0; i < 32; i=i+1) begin

         Bout[i] = (Bin[4:0] == i) ;      // this is equivalent to (Bin[4:0] == i) ? 1'b1 : 1'b0 ;

      end  // for
   end  // always

endmodule

