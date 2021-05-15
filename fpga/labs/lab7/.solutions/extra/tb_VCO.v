//
// Verilog testbench for VCO mixed-signal real model.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_VCO ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   real Vctrl ;   // analog control voltage
   wire clk ;     // VCO output clock

   VCO   DUT (.Vctrl(Vctrl), .clk(clk)) ;


   /////////////////////////
   //   analog stimulus   //
   /////////////////////////

   initial begin
      #0    Vctrl = 1.25 ;
      #3000 Vctrl = 2.00 ;
      #3000 Vctrl = 0.50 ;
      #3000 Vctrl = 0.78 ;
      #3000 Vctrl = 1.25 ;
      #3000 Vctrl = 0.00 ;   // check also that clock frequency is 2.5 MHz as expected for Vctrl = 0 V

      #3000 $finish ;
   end

endmodule

