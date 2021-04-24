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

// choose here the implementation that you want to simulate

`define IF_ELSE
//`define TRUTH_TABLE
//`define CONDITIONAL_ASSIGN
//`define LOGIC_EQUATION
//`define STRUCTURAL

module MUX2 (

   input wire A, B, S,

`ifdef IF_ELSE
   output reg Z         // the net type must be 'reg' if Z is used within a procedural block such as 'always' 
`elsif TRUTH_TABLE
   output reg Z
`else
   output wire Z        // Z must be declared as 'wire' if assigned through 'assign' or gate primitives, otherwise
`endif

   ) ;


   ////////////////////////////////
   //   behavioral description   //
   ////////////////////////////////

   // using an if/else statement

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

`endif


`ifdef TRUTH_TABLE

   // using a case statement

   always @(*) begin              // as recommended by the Verilog standard, use always @(*) to describe COMBINATIONAL blocks

      case({S,A,B})

         3'b000 : Z = 1'b0 ;  // A
         3'b001 : Z = 1'b0 ;  // A
         3'b010 : Z = 1'b1 ;  // A
         3'b011 : Z = 1'b1 ;  // A
         3'b100 : Z = 1'b0 ;  // B
         3'b101 : Z = 1'b1 ;  // B
         3'b110 : Z = 1'b0 ;  // B
         3'b111 : Z = 1'b1 ;  // B

      endcase
   end  // always

`endif

   ////////////////////////////////
   //   conditional assignment   //
   ////////////////////////////////

`ifdef CONDITIONAL_ASSIGN

   assign Z = (S == 1'b0) ? A : B ;  

`endif


   //////////////////////////
   //   boolean function   //
   //////////////////////////

`ifdef LOGIC_EQUATION

   assign Z = (A & ~S) | (B & S) ;

`endif


   ////////////////////////////////////
   //   schematic using primitives   //
   ////////////////////////////////////

`ifdef STRUCTURAL

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

`endif

endmodule

