//
// Example sawtooth waveform generator using a 12-bit free-running counter
// and the MCP4821 12-bit D/A converter with SPI configuration.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module dac_spi_sawtooth (

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


   /////////////////////////////////////
   //   12-bit free-running counter   //
   /////////////////////////////////////

   //
   // **IMPORTANT !
   //
   // Each SPI "transaction" requires (2*16 +1) SCLK half-periods, each half-period is 5x 10ns, moreover
   // cs_n has to stay high for minimum 15ns (datasheet), in practice 2x 10ns running with 100 MHz clock.
   // At the end MAX=170 for the tick-counter is the minimum value that can be used to control
   // the free-running counter without missing codes loaded into the DAC.
   //
   // MAX = 170  =>  1/(4096*170*10ns) = 143.6 Hz
   // MAX = 200  =>  1/(4096*200*10ns) = 122.1 Hz
   // MAX = 500  =>  1/(4096*500*10ns) =  48.8 Hz
   //

   wire tick ;

   TickCounterRst  #( .MAX(500) ) Ticker ( .clk(pll_clk), .rst(~pll_locked | rst), .tick(tick) ) ;

   reg [11:0] counter_free = 'b0 ;

   always @(posedge pll_clk) begin

      if ( ~pll_locked | rst) begin
         counter_free <=  'b0 ;
      end
      else if (tick) begin 
         counter_free <= counter_free + 'b1 ;
      end
   end   // always


   //////////////////////////////////
   //   SPI transmitter (master)   //
   //////////////////////////////////

   // **DEBUG
   wire [15:0] tx_data = { 1'b0 , 1'bx , gain , shutdown , counter_free[11:8] , 8'b0 } ;   // only 16 steps with right-most bits of the counter

   //wire [15:0] tx_data = { 1'b0 , 1'bx , gain , shutdown , counter_free[11:0] } ;    // all possible 0 to 4095 counter values

   spi_tx_FSM #( .HALF_PERIOD_CLK_CYCLES(10) ) spi (     // you can also lower the frequency of the SPI sclk by increasing the max. for the half-period counter

      .clk      ( pll_clk           ),
      .rst      ( ~pll_locked | rst ),
      .tx_data  ( tx_data[15:0]     ),
      .tx_start ( tick              ),
      .cs_n     ( dac_csn           ),
      .sclk     ( dac_sclk          ),
      .mosi     ( dac_sdi           ),
      .busy     ( led               )

      ) ;

endmodule

