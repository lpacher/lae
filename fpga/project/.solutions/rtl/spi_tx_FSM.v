//
// Example Serial Peripheral Interface (SPI) transmitter using a state machine.
// Use the block to drive the MCP4821 12-bit DAC.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module spi_tx_FSM #(

   parameter integer HALF_PERIOD_CLK_CYCLES = 5,    // 1/2 system clock to sclk ratio
   parameter integer DATA_WIDTH = 16,               // total number of bits transmitted to the chip over MOSI line
   parameter         CPOL = 1'b0,                   // clock polarity: defines the value of sclk when no transactions occur (IDLE state)
   parameter         CPHA = 1'b0                    // clock phase: defines the sampling edge for transmitted data

   ) (

   // inputs
   input  wire clk,                                 // assume 100 MHz clock frequency from on-board oscillator
   input  wire rst,                                 // synchronous reset, active high (can be also as simple as PLL "locked" flag)
   input  wire tx_start,                            // single clock-pulse to start the transaction
   input  wire [DATA_WIDTH-1:0] tx_data,            // 16-bit configuration data for the DAC (4-bit config + 12-bit DAC code)

   // outputs
   output reg cs_n,                                 // SPI chip-select, active-low
   output reg sclk,                                 // SPI serial clock (actually not a true free-running clock but a train of "clock pulses" when chip-select is low)
   output reg busy,                                 // auxiliary busy signal, useful to trigger at the oscillocope (basically ~cs_n)
   output reg mosi                                  // SPI master-out, slave-in

   ) ;


   ///////////////////////////
   //   internal counters   //
   ///////////////////////////

   //
   // **NOTE: we need two counters, a first counter is used to determine the half-period of sclk starting from the system clock clk,
   // a second counter increments each time the first one resets and determines how much time the chip-select stays low
   //

   // number of clk cycles that determines the half-period of sclk
   reg [$clog2(HALF_PERIOD_CLK_CYCLES)-1:0] half_period_counter = HALF_PERIOD_CLK_CYCLES-1 ;

   // number of sclk toggles 
   reg [$clog2(2*DATA_WIDTH+1)-1:0] sclk_toggle_counter = 'b0 ;   // **IMPORTANT: we have to count up to 2*DATA_WIDTH+1, not 2*DATA_WIDTH !


   ////////////////////////////////
   //   other internal signals   //
   ////////////////////////////////

   // transmit clock edge (basically sclk or ~sclk depending on CPHA)
   reg tx_edge ;

   // transmit register (parallel-in serial-out)
   reg [DATA_WIDTH-1:0] tx_register = 'b0 ;


   ///////////////////////////
   //   states definition   //
   ///////////////////////////

   // simplest implementation, only use two states!
   parameter IDLE     = 1'b0 ;
   parameter TRANSMIT = 1'b1 ;

   reg STATE ;   // just one FlipFlop !


   //////////////////////////////////////
   //   state machine implementation   //
   //////////////////////////////////////

   always @(posedge clk) begin

      if (rst) begin 

         STATE <= IDLE ;

         // outputs
         cs_n    <= 1'b1 ;
         busy    <= 1'b0 ;
         mosi    <= 1'b0 ;
         sclk    <= CPOL ;

         // reset counters and tx_edge
         half_period_counter <= HALF_PERIOD_CLK_CYCLES-1 ; 
         sclk_toggle_counter <= 'b0 ;
         tx_edge <= ~CPHA ;

      end
      else begin

         case (STATE)

            IDLE : begin

               // outputs
               cs_n    <= 1'b1 ;
               busy    <= 1'b0 ;
               mosi    <= 1'b0 ;
               sclk    <= CPOL ;

               // reset counters and tx_edge
               half_period_counter <= HALF_PERIOD_CLK_CYCLES-1 ; 
               sclk_toggle_counter <= 'b0 ;
               tx_edge <= ~CPHA ;

               if (tx_start) begin   // single clock-pulse detected

                  busy <= 1'b1 ;    // **WARN: the chip-select here remains high indeed! cs_n goes to 1'b0 when in TRANSMIT state

                  tx_register <= tx_data ;   // load data to be transmitted into the transmit register

                  STATE <= TRANSMIT ;

               end
               else begin

                  STATE <= IDLE ;      // stay in IDLE if no tx_start pulse is received
               end
            end   // IDLE

            //___________________________________________________________________________
            //

            TRANSMIT : begin

               cs_n <= 1'b0 ;       // tie-low the chip-select, SPI activates
               busy <= 1'b1 ;

               if (half_period_counter == HALF_PERIOD_CLK_CYCLES-1) begin

                  // the following code executes only when half_period_counter == HALF_PERIOD_CLK_CYCLES-1

                  //////////////////////////////////////
                  half_period_counter <= 'b0 ;
                  tx_edge <= ~ tx_edge ;

                  if (sclk_toggle_counter == (2*DATA_WIDTH)+1) begin

                     cs_n <= 1'b1 ;   // transaction completed, force chip-select back to high and move to IDLE 

                     STATE <= IDLE ;

                  end
                  else begin

                     sclk_toggle_counter <= sclk_toggle_counter + 'b1 ;
                     STATE <= TRANSMIT ;

                  end

                  // generate the sclk toggle
                  if (sclk_toggle_counter <= (2*DATA_WIDTH) && cs_n == 1'b0)
                     sclk <= ~sclk ;

                  // generate the MOSI output stream (PISO)
                  if (tx_edge == 1'b1 && sclk_toggle_counter < (2*DATA_WIDTH + CPHA)-1) begin

                     mosi        <= tx_register[DATA_WIDTH-1] ;                  // push out the MSB over the MOSI line and
                     tx_register <= { tx_register[DATA_WIDTH-2:0] , 1'b0 } ;     // replace the LSB of tx_register with a zero

                  end
                  //////////////////////////////////////

               end 
               else begin   // half-period not reached, increment the counter

                  half_period_counter <= half_period_counter + 'b1 ;

                  STATE <= TRANSMIT ;

               end

            end   // TRANSMIT

            //___________________________________________________________________________
            //

            default : STATE <= IDLE ;

         endcase

      end   // if/else rst
   end   // always

endmodule

