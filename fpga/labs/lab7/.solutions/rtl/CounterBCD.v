//
// Binary-Coded Decimal (BCD) counter with count-enable and carry flag.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module CounterBCD (

   input  wire clk,
   input  wire rst,           // active-high reset
   input  wire  en,           // asynchronous enable
   output reg [3:0] BCD,      // 4-bit BCD output code
   output wire carryout

   ) ;
   

   always @(posedge clk) begin                              // synchronous reset
   //always @(posedge clk or posedge rst) begin 	    // asynchronous reset

      if( rst == 1'b1 )
         BCD <= 4'b0000 ;

      else begin

         if( en == 1'b1 ) begin      // let the counter to increment only if enabled !

            if( BCD == 4'b1001 )     // force the count roll-over at 9
               BCD <= 4'b0000 ;
            else
               BCD <= BCD + 1'b1 ;
         end

         //else begin
         //   BCD <= BCD ;    // keep MEMORY otherwise, but this can be omitted !
         //end

      end  // if
   end // always

   assign carryout = ( BCD == 4'b1001 ) ? 1'b1 : 1'b0 ;

endmodule

