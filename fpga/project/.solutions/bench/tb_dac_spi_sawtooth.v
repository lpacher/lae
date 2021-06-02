//
// Verilog testbench for dac_spi_sawtooth module. 
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_dac_spi_sawtooth ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   // SPI signals
   wire dac_csn, dac_sclk, dac_sdi ;

   // status LED (busy)
   wire led ;

   dac_spi_sawtooth  DUT (

      .clk       ( clk100   ),
      .rst       ( 1'b0     ),
      .gain      ( 1'b1     ),
      .shutdown  ( 1'b0     ),
      .dac_csn   ( dac_csn  ),
      .dac_sclk  ( dac_sclk ),
      .dac_sdi   ( dac_sdi  ),
      .led       ( led      )

      ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   // actually nothing to do, simply run for some time and observe SPI transactions
   initial begin

      #(20*500*10) $finish ;

   end

endmodule

