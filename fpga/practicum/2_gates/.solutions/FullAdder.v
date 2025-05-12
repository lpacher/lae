//
// Example different implementations using Verilog HDL
// for a Full-Adder (FA) circuit.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2025
//

`timescale 1ns / 100ps

module FullAdder (

   input  wire A,
   input  wire B,
   input  wire Cin,    // input carry
   output wire Sum,
   output wire Cout    // output carry
   //output reg  Cout

   ) ;

   /////////////////////////////////////////////////////////////////
   //   continuous assignment using the standard sum + operator   //
   /////////////////////////////////////////////////////////////////

   //
   // **IMPORTANT
   //
   // The binary addition can be implemented using the standard sum operaror `+` as in any other
   // programming language. The synthesis tool will be then responsible to infer necessary logic
   // gates to implement the circuit in real hardware. Alternatively since the circuit is a pure
   // combinational block you can use a truth-table or derive logic equations from K-maps.
   //
   assign {Cout,Sum} = A + B + Cin ;


   //
   // **NOTE
   //
   // You can also assign the {Cout,Sum} concatenation using an always block!
   //
   //always @(*)
   //   {Cout,Sum} = A + B + Cin ;
   //


/*


   /////////////////////////////////////////////////
   //   truth-table implementation (behavioral)   //
   /////////////////////////////////////////////////

   always @(*) begin

      case ( {Cin,A,B} )

          3'b000 : {Cout,Sum} = 2'b00 ;
          3'b001 : {Cout,Sum} = 2'b01 ;
          3'b010 : {Cout,Sum} = 2'b01 ;
          3'b011 : {Cout,Sum} = 2'b10 ;    // **NOTE: 1+1 = 2 that is... 0 with the CARRY of 1 !
          3'b100 : {Cout,Sum} = 2'b01 ;
          3'b101 : {Cout,Sum} = 2'b10 ;
          3'b110 : {Cout,Sum} = 2'b10 ;
          3'b111 : {Cout,Sum} = 2'b11 ;    // 1+1+1 = 3

      endcase
   end   //always



   /////////////////////////
   //   logic equations   //
   /////////////////////////

   // sum
   assign Sum  = A ^ B ^ Cin ;   // XOR between A, B and Cin inputs

   // output carry
   assign Cout = (A & B) | (Cin & (A ^ B)) ;

*/

endmodule

