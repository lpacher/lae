//
// Testbench module for DLATCH.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_DLATCH ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg D = 1'b1 ;
   reg load ;

   wire Q ;

   DLATCH DUT ( .D(D), .EN(load), .D(D), .Q(Q) ) ;


   //////////////////
   //   stimulus   //
   //////////////////

   // use the $random Verilog task to generate a random input pattern
   always #(20.0) D = $random ;             // **WARN: $random returns a 32-bit integer ! Here there is an implicit TYPE CASTING

   initial begin

      #100 load = 1'b0 ;
      #500 load = 1'b1 ;
      #300 load = 1'b0 ;
      #750 load = 1'b1 ;
      #300 load = 1'b0 ;

      #300 $finish ;   // stop the simulation
   end

endmodule

