//
// Verilog testbench for spi_tx_FSM module. 
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_spi_tx_FSM ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg pll_locked = 1'b0 ;
   reg tx_start = 1'b0 ;

   // SPI signals
   wire dac_csn, dac_sclk, dac_sdi, busy ;


   spi_tx_FSM  DUT (

      .clk      ( clk100      ),
      .rst      ( ~pll_locked ),
      .tx_start ( tx_start    ),
      .cs_n     ( dac_csn     ),
      .sclk     ( dac_sclk    ),
      .mosi     ( dac_sdi     ),
      .busy     ( busy        ),
      .tx_data  ( 16'hABCD    )      // 1010_1011_1100_1101

      ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #100 pll_locked = 1'b1 ;

      #500 @(posedge clk100) tx_start = 1'b1 ;
           @(posedge clk100) tx_start = 1'b0 ;   // single clock-pulse tx_start

      #2000 ;
 
      #500 @(posedge clk100) tx_start = 1'b1 ;
           @(posedge clk100) tx_start = 1'b0 ;   // single clock-pulse tx_start

      #2000 ;

      #500 @(posedge clk100) tx_start = 1'b1 ;
           @(posedge clk100) tx_start = 1'b0 ;   // single clock-pulse tx_start

      #2000 $finish ;

   end

endmodule

