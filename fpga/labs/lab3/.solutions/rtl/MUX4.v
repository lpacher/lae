//
// Verilog description of a simple 4:1 multiplexer using a case statement.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module MUX4 (

   input wire [3:0] D,
   input wire [1:0] S,
   output reg Z

   ) ;


   ////////////////////////////////
   //   behavioral description   //
   ////////////////////////////////

   // use a case statement
   always @(*) begin

      case( S[1:0] )

         2'b00 : Z = D[0] ;
         2'b01 : Z = D[1] ;
         2'b10 : Z = D[2] ;
         2'b11 : Z = D[3] ;

      endcase
   end  // always

endmodule

