//
// Example Verilog implementation for a simple 4-bit synchronous up-counter using
// either behavioral or structural coding styles.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2022
//


`timescale 1ns / 100ps

module DFF (

   input  wire clk,   // clock
   input  wire rst,   // reset, active-high (then can be synchronous or asynchronous according to sensitivity list)
   input  wire D,
   output reg  Q,
   output wire Qbar

   ) ;

   // **NOTE: can be replaced by 'always_ff' in SystemVerilog

   //always @(posedge clk) begin                       // synchronous reset
   always @(posedge clk or posedge rst) begin      // asynchronous reset

      if (rst) begin      // same as if (rst == 1'b1)
         Q <= 1'b0 ;      // **NOTE: inside clocked always blocks use a NON-BLOCKING assignment <= instead of a BLOCKING assignment =
      end
      else begin
         Q <= D ;
      end
   end  // always


   // inverted output
   //not (Qbar,Q) ;
   assign Qbar = ~ Q ;

endmodule

//_______________________________________________________________


`timescale 1ns / 100ps

module XOR (

   input  wire A, B,
   output wire Z

   ) ;

   //xor (Z,A,B) ;
   assign Z = A ^ B ;

endmodule

//_______________________________________________________________


`timescale 1ns / 100ps

module AND (

   input  wire A, B,
   output wire Z

   ) ;

   //and (Z,A,B) ;
   assign Z = A & B ;

endmodule

//_______________________________________________________________


`timescale 1ns / 100ps

module TFF (

   input  wire T, rst, clk,
   output wire Q

   ) ;


   ////////////////////
   //   structural   //
   ////////////////////

   wire Dint ;

   DFF  u1 (.clk(clk), .rst(rst), .D(Dint), .Q(Q) ) ;
   XOR  u2 (.A(T), .B(Q), .Z(Dint) ) ;


   ////////////////////
   //   behavioral   //
   ////////////////////

/*
   always @(posedge clk) begin
      if(rst) begin
         Q <= 1'b0 ;
      end
      else begin
         Q <= T ^ Q ;
      end
   end   //always

*/

endmodule

//_______________________________________________________________


`timescale 1ns / 100ps

module SyncCounter4b (

   input  wire clk, rst, en,
   output wire [3:0] Q

   ) ;


   ////////////////////
   //   structural   //
   ////////////////////

   // 4-bit bus for internal wiring
   wire [3:0] T ;

   assign T[0] = en ;
   //assign T[1] = Q[0] & T[0] ;
   //assign T[2] = Q[1] & T[1] ;
   //assign T[3] = Q[2] & T[2] ;

   AND  u0 ( .A(Q[0]), .B(T[0]), .Z(T[1]) ) ;
   AND  u1 ( .A(Q[1]), .B(T[1]), .Z(T[2]) ) ;
   AND  u2 ( .A(Q[2]), .B(T[2]), .Z(T[3]) ) ;

   TFF  ff_0 ( .clk(clk), .rst(rst), .T(T[0]), .Q(Q[0]) ) ;
   TFF  ff_1 ( .clk(clk), .rst(rst), .T(T[1]), .Q(Q[1]) ) ;
   TFF  ff_2 ( .clk(clk), .rst(rst), .T(T[2]), .Q(Q[2]) ) ;
   TFF  ff_3 ( .clk(clk), .rst(rst), .T(T[3]), .Q(Q[3]) ) ;


   ////////////////////
   //   behavioral   //
   ////////////////////

/*
   reg [3:0] Qreg ;   // since we declared the Q output bus as 'wire' we cannot assign values to Q within an 'always' sequential block

   assign Q = Qreg ;

   //always @(posedge clk or posedge rst) begin      // asynchronous reset
   always @(posedge clk) begin                       // synchronous reset

      if(rst == 1'b1) begin

         Qreg <= 4'b0000 ;

      end
      else if(en == 1'b1) begin

         Qreg <= Qreg + 1'b1 ;

      end
   end   // always

*/

endmodule
