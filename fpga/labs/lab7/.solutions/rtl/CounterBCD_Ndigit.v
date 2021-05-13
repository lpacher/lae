//
// Parameterized N-digit BCD counter. The logic includes an end-of-scale flag
// asserted when 9999 ... 9 is reached and an overflow flag when the count goes
// out of range.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


//
// Dependencies:
//
// rtl/CounterBCD.v
//


`timescale 1ns / 100ps

module CounterBCD_Ndigit #(parameter integer Ndigit = 3) (

   input  wire clk,
   input  wire rst,
   input  wire en,
   output wire [Ndigit*4-1:0] BCD,
   output wire overflow,               // asserted when the most-significant digit generates a carry
   output wire eos                     // asserted when 9999 ... 9 is reached

   ) ;



   //
   // **EXAMPLE: a simple clock-divider
   //

   //reg clk_div = 1'b0 ;
   //
   //always @(posedge clk)
   //   clk_div = ~ clk_div ;


   //
   // **EXAMPLE: clock divider using auxiliary free-running counter
   //

   // auxiliary 6-bit free-running counter for clock division
   reg [5:0] count_free = 5'b00000 ;

   always @(posedge clk)
      count_free = count_free + 5'b1 ;

   // choose below the desired divided clock fed to the BCD counter


   wire clk_int ;

   //assign clk_int = clk ;                   // clk
   //assign clk_int = count_free[0] ;         // clk/2    e.g. 100 MHz/2 = 50   MHz
   //assign clk_int = count_free[1] ;         // clk/4    e.g. 100 MHz/4 = 25   MHz
   //assign clk_int = count_free[2] ;         // clk/8    e.g. 100 MHz/8 = 12.5 MHz
   //assign clk_int = count_free[3] ;         // clk/16   etc.
   //assign clk_int = count_free[4] ;         // clk/32
   assign clk_int = count_free[5] ;           // clk/64


   /////////////////////////////
   //   N-digit BCD counter   //
   /////////////////////////////


   wire [Ndigit:0] w ;   // Ndigit + 1 wires to inteconnect BCD counters each other

   assign w[0] = en ;

   generate

      genvar k ;

      for(k = 0; k < Ndigit; k = k+1) begin : digit  

         CounterBCD  digit (

            .clk      (         clk_int ),
            .rst      (             rst ),
            .en       (            w[k] ),
            .BCD      (  BCD[4*k+3:4*k] ),
            .carryout (          w[k+1] )

         ) ;

      end // for

   endgenerate


   // generate end-of-scale flag when 9999 ... 9 is reached
   assign eos = ( BCD == {Ndigit{4'b1001}} ) ? 1'b1 : 1'b0 ;      // use Verilog replication operator to replicate 4'1001 N times

   // generate overflow flag
   assign overflow = w[Ndigit] ;    // simply the carry-out of the most-significant BCD counter

endmodule

