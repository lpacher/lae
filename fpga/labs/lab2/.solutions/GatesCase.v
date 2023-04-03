//
// Implement basic logic operators as truth-tables using a Verilog case statement.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module GatesCase (

   input  wire A
   input  wire B,
   output reg [5:0] Z     // **QUESTION: why Z is now declared as reg ?

   ) ;

   // as recommended by the Verilog standard, use always @(*) to describe COMBINATIONAL blocks
   always @(*) begin

      case( {A,B} )   // concatenation operator { , }, that's why Verilog uses begin/end instead of standard C/C++ brackets {}

         2'b00 :  Z = 6'b101010 ;
         2'b01 :  Z = 6'b010110 ;
         2'b10 :  Z = 6'b010110 ;
         2'b11 :  Z = 6'b110101 ;

      endcase
   end  // always

endmodule

