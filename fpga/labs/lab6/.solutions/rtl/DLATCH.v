//
// Verilog code for a simple D-Latch. 
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module DLATCH (

   input  wire D, EN,
   output reg Q

   ) ;


   // behavioural description
   always @(D,EN) begin          // **NOTE: can be replaced by 'always_latch' in SystemVerilog

      if (EN) begin       // same as if (EN == 1'b1 )
         Q <= D ;
      end
      //else begin        // **IMPORTANT: in this case the 'else' clause is optional, if you don't specify the 'else' condition the tool automatically infers MEMORY for you !
      //   Q <= Q ;
      //end

   end  // always

endmodule

