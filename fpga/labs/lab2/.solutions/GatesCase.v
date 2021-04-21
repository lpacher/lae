//-----------------------------------------------------------------------------------------------------
//                               University of Torino - Department of Physics
//                                   via Giuria 1 10125, Torino, Italy
//-----------------------------------------------------------------------------------------------------
// [Filename]       GatesCase.v
// [Project]        Advanced Electronics Laboratory course
// [Author]         Luca Pacher - pacher@to.infn.it
// [Language]       Verilog 2001 [IEEE Std. 1364-2001]
// [Created]        Apr 28, 2020
// [Modified]       -
// [Description]    Describe basic logic gates in Verilog using case statements.
// [Notes]          -
// [Version]        1.0
// [Revisions]      28.04.2020 - Created
//-----------------------------------------------------------------------------------------------------


`timescale 1ns / 100ps

module GatesCase (

   input  wire A
   input  wire B,
   output reg [5:0] Z     // **QUESTION: why Z is now declared as reg ?

   ) ;

   // AND
   always @(*) begin

      case( {A,B} )        //  concatenation operator { , }, that's why Verilog uses begin/end instead of standard C/C++ brackets {}

         2'b00 :  Z[0] = 1'b0 ;
         2'b01 :  Z[0] = 1'b0 ;
         2'b10 :  Z[0] = 1'b0 ;
         2'b11 :  Z[0] = 1'b1 ;

      endcase
   end  // always


   // NAND
   always @(*) begin

      case( {A,B} )

         2'b00 :  Z[1] = 1'b1 ;
         2'b01 :  Z[1] = 1'b1 ;
         2'b10 :  Z[1] = 1'b1 ;
         2'b11 :  Z[1] = 1'b0 ;

      endcase
   end  // always


   // OR
   always @(*) begin

      case( {A,B} )

         2'b00 :  Z[2] = 1'b0 ;
         2'b01 :  Z[2] = 1'b1 ;
         2'b10 :  Z[2] = 1'b1 ;
         2'b11 :  Z[2] = 1'b1 ;

      endcase
   end  // always


   // NOR
   always @(*) begin

      case( {A,B} )

         2'b00 :  Z[3] = 1'b1 ;
         2'b01 :  Z[3] = 1'b0 ;
         2'b10 :  Z[3] = 1'b0 ;
         2'b11 :  Z[3] = 1'b0 ;

      endcase
   end  // always


   // XOR
   always @(*) begin

      case( {A,B} )

         2'b00 :  Z[4] = 1'b0 ;
         2'b01 :  Z[4] = 1'b1 ;
         2'b10 :  Z[4] = 1'b1 ;
         2'b11 :  Z[4] = 1'b0 ;

      endcase
   end  // always


   // XNOR
   always @(*) begin

      case( {A,B} )

         2'b00 :  Z[0] = 1'b1 ;
         2'b01 :  Z[0] = 1'b0 ;
         2'b10 :  Z[0] = 1'b0 ;
         2'b11 :  Z[0] = 1'b1 ;

      endcase
   end  // always


endmodule

