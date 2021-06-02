//
// Example sine waveform generator using sampled sine values stored into a ROM
// and the MCP4821 12-bit D/A converter with SPI configuration.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//

`timescale 1ns / 100ps

module dac_spi_sine (

   input wire clk,              // assume 100 MHz clock frequencu from on-board oscillator
   input wire rst,              // additional reset (push-button)

   // DAC configuration
   input wire gain, shutdown,   // both active low, mapped to slide-switches

   // SPI signals
   output wire dac_csn,
   output wire dac_sclk,
   output wire dac_sdi,

   // status LED (SPI "busy")
   output led

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   // PLL signals
   wire pll_clk, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk), .CLK_OUT(pll_clk), .LOCKED(pll_locked) ) ;


   //////////////////////////////////////////////
   //    ROM read-enable generator as "tick"   //
   //////////////////////////////////////////////

   //
   // **IMPORTANT !
   //
   // Each SPI "transaction" requires (2*16 +1) SCLK half-periods, each half-period is 5x 10ns, moreover
   // cs_n has to stay high for minimum 15ns (datasheet), in practice 2x 10ns running with 100 MHz clock.
   // At the end MAX=170 for the tick-counter is the minimum value that can be used to read the ROM
   //
   // The resulting sine waveform has a frequency of 1/(1024*MAX*10ns). Examples:
   //
   // MAX = 170  =>  1/(1024*170*10ns) = 574.4 Hz
   // MAX = 180  =>  1/(1024*180*10ns) = 542.5 Hz
   // MAX = 200  =>  1/(1024*200*10ns) = 488.3 Hz
   //

   wire rom_ren ;

   TickCounterRst  #(.MAX(200)) TickCounter_inst ( .clk(pll_clk), .rst(~pll_locked | rst), .tick(rom_ren)) ;


   ///////////////////////////
   //   pointer generator   //
   ///////////////////////////

   reg [$clog2(1024)-1:0] rom_addr = 'b0  ;     // address counter

   always @(posedge pll_clk) begin

      if (~pll_locked | rst)
         rom_addr <= 'b0 ;

      else if (rom_ren)
         rom_addr <= rom_addr + 'b1 ;

   end   // always


   /////////////////////////////////
   //   12x1024 sine-values ROM   //
   /////////////////////////////////

   wire [11:0] rom_data ;

   ROM #(.WIDTH(12), .DEPTH(1024)) DUT (.clk(pll_clk), .ren(rom_ren), .addr(rom_addr), .dout(rom_data)) ;


   //////////////////////////////////
   //   SPI transmitter (master)   //
   //////////////////////////////////

   wire [15:0] tx_data = { 1'b0 , 1'bx , gain , shutdown , rom_data[11:0] } ; 

   spi_tx_FSM  spi (

      .clk      ( pll_clk           ),
      .rst      ( ~pll_locked | rst ),
      .tx_data  ( tx_data[15:0]     ),
      .tx_start ( rom_ren           ),
      .cs_n     ( dac_csn           ),
      .sclk     ( dac_sclk          ),
      .mosi     ( dac_sdi           ),
      .busy     ( led               )

      ) ;

endmodule

