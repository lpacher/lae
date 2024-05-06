
//
// Example Verilog code for a N-bit parameterized binary oto Gray decoder
//

`ifndef GRAY_DECODER__V   //include guard
`define GRAY_DECODER__V

`timescale 1ns / 100ps

module GrayDecoder #(parameter integer NBIT = 5)(

   input  wire [NBIT-1:0] Bin,         // N-bit BASE-2 binary input code
   output wire  [NBIT-1:0] GrayOut      // N-bit Gray output code

   ) ;

   integer i ;    // 32-bit integer

   always @(*) begin

      // MSB
      GrayOut[NBIT-1] = Bin[NBIT-1] ;

      // LSB to MSB-1
      for(i=0; i < NBIT-1 ; i=i+1) begin

         GrayOut[i] = Bin[i] ^ Bin[i+1] ;
   
      end //for
   end  //always

   //assign GrayOut = (Bin >> 1) ^ Bin ;                   // right-shift operator
   //assign GrayOut = { 1'b0 , Bin[NBIT-1:1]} ^ Bin ;



endmodule

`endif