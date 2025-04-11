//
// Verilog description of a simple 2:1 multiplexer using different coding styles.
//
// Comment/uncomment the code according to the actual implementation you want to
// simulate in your testbench or use Verilog MACROS.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

`default_nettype none   // force the user to declare the data type for all nets


// either choose here the implementation that you want to simulate or compile sources with 'xvlog -define MACRO_NAME'

//`define IF_ELSE
`define TRUTH_TABLE
//`define CONDITIONAL_ASSIGN
//`define LOGIC_EQUATION
//`define STRUCTURAL

// alternatively you can also collect all defines into a separate source file and include it into RTL code
//`include "rtl/defines.v"


module MUX2 (

   input wire A,
   input wire B,
   input wire S,

`ifdef IF_ELSE
   output reg Z         // the net type must be 'reg' if Z is used within a procedural block such as 'always' 
`elsif TRUTH_TABLE
   output reg Z
`else
   output wire Z        // Z must be declared as 'wire' if assigned through 'assign' or gate primitives, otherwise
`endif

   ) ;


   ///////////////////////////////////////////
   //   behavioral descriptions (if/else)   //
   ///////////////////////////////////////////

`ifdef IF_ELSE 

   //always @(*) begin
   always @(A,B,S) begin          // **IMPORTANT: this is a COMBINATIONAL block, all signals contribute to the SENSITIVITY LIST

      if( S == 1'b0 ) begin       // **NOTE: the C-style equality operator checks if the condition is true or false
         Z = A ;
      end
      else begin
         Z = B ;
      end
   end  // always


   //////////////////////////////////////
   //   truth-table (case statement)   //
   //////////////////////////////////////

`elsif TRUTH_TABLE

   always @(*) begin              // as recommended by the Verilog standard, use always @(*) to describe COMBINATIONAL blocks

      case({S,A,B})

         3'b000 : Z = 1'b0 ;  // A
         3'b001 : Z = 1'b0 ;  // A
         3'b010 : Z = 1'b1 ;  // A
         3'b011 : Z = 1'b1 ;  // A
         3'b100 : Z = 1'b0 ;  // B
         3'b101 : Z = 1'b1 ;  // B
         3'b110 : Z = 1'b0 ;  // B
         //3'b111 : Z = 1'b1 ;  // B
         3'b111 : Z = 1'b0 ;        // **WRONG VALUE** => decomment to check if the self-checking testbench fails!

         /*
         3'd0 : Z = 1'b0 ;  // A      // alternatively you can specify case-values in decimal radix
         3'd1 : Z = 1'b0 ;  // A
         3'd2 : Z = 1'b1 ;  // A
         3'd3 : Z = 1'b1 ;  // A
         3'd4 : Z = 1'b0 ;  // B
         3'd5 : Z = 1'b1 ;  // B
         3'd6 : Z = 1'b0 ;  // B
         3'd7 : Z = 1'b1 ;  // B
         */

      endcase
   end  // always


   ////////////////////////////////
   //   conditional assignment   //
   ////////////////////////////////

`elsif CONDITIONAL_ASSIGN

   assign Z = (S == 1'b0) ? A : B ;  


   ///////////////////////////////////////////////
   //   boolean function (as from SOP design)   //
   ///////////////////////////////////////////////

`elsif LOGIC_EQUATION

   assign Z = (A & ~S) | (B & S) ;


   /////////////////////////////////////////////////////////////////////////
   //   gate-level schematic (structural code) using Verilog primitives   //
   /////////////////////////////////////////////////////////////////////////

`elsif STRUCTURAL

   wire w1, w2, Sbar ;

   /*
   not u1 (Sbar, S) ;

   and u2 (w1, A, Sbar) ;
   and u3 (w2, B, S) ;

   or  u4 (Z, w1, w2) ;
   */

   // add delays to show timing hazards
   not #(1) u1 (Sbar, S) ;

   and #(1) u2 (w1, A, Sbar) ;
   and #(1) u3 (w2, B, S) ;

   or  #(1) u4 (Z, w1, w2) ;

   // **FIX timing hazards
   //wire w3 ;
   //
   //and #(1) u5 (w3, A, B) ;
   //or  #(1) u4 (Z, w1, w2, w3) ;


   /////////////////////////////////////////////////
   //   empty stub otherwise (Verilog abstract)   //
   /////////////////////////////////////////////////

`else

   //no actual implementation

`endif

endmodule

