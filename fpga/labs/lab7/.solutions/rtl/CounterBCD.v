//
// Binary-Coded Decimal (BCD) counter with count-enable and carry flag.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module CounterBCD (

   input  wire clk,
   input  wire rst,
   input  wire  en,
   output reg [3:0] BCD,
   output wire carryout

   ) ;


   always @(posedge clk) begin

      if( rst == 1'b1 )              // synchronous reset, active-high (same as 'if(rst)' for less typing)
         BCD <= 4'b0000 ;            // here you can also use 4'd0 or 'd0

      else begin

         if( en == 1'b1 ) begin      // let the counter to increment only if enabled (same as 'if(en)' for less typing)

            if( BCD == 4'b1001 )     // force the count roll-over at 9 (you can also use 4'd9)
               BCD <= 4'b0000 ;
            else
               BCD <= BCD + 4'b1 ;
         end
         //else ? keep memory otherwise
      end
   end // always


   assign carryout = ( (BCD == 4'b1001) && (en == 1'b1) ) ? 1'b1 : 1'b0 ;

endmodule

