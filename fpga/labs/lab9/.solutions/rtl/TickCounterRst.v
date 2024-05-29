//
// Parameterized modulus-MAX 32-bit tick generator with reset. Use the resulting "tick"
// single clock-pulse as "enable" for your synchronous logic if you need to decrease
// the speed of the data processing without the need of a dedicated extra clock signal.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module TickCounterRst #(parameter integer MAX = 10414) (      // default is ~9.6 kHz as for UART baud-rate

   input  wire clk,      // assume 100 MHz input clock
   input  wire rst,      // optional external reset, synchronous active-high
   output reg  tick      // single clock-pulse output

   ) ;


   /////////////////////////////////////////////////
   //   32-bit modulus-MAX free-running counter   //
   /////////////////////////////////////////////////

   //
   // **NOTE
   //
   // Assuming 100 MHz input clock we can generate up to 2^32 -1 different tick periods, e.g.
   //
   // MAX =    10 => one "tick" asserted every    10 x 10 ns = 100 ns  => logic "running" at  10 MHz
   // MAX =   100 => one "tick" asserted every   100 x 10 ns =   1 us  => logic "running" at   1 MHz
   // MAX =   200 => one "tick" asserted every   200 x 10 ns =   2 us  => logic "running" at 500 MHz
   // MAX =   500 => one "tick" asserted every   500 x 10 ns =   5 us  => logic "running" at 200 kHz
   // MAX =  1000 => one "tick" asserted every  1000 x 10 ns =  10 us  => logic "running" at 100 kHz
   // MAX = 10000 => one "tick" asserted every 10000 x 10 ns = 100 us  => logic "running" at  10 kHz etc.
   //

   reg [$clog2(MAX)-1:0] count = 'b0 ;   // **IMPORTANT: use the ceil-function on log2(MAX) to determine how many FlipFlops are required to count from 0 to MAX

   always @(posedge clk) begin

      if(rst) begin

         count <= 'b0 ;
         tick  <= 1'b0 ;

      end
      else begin

         if( count == MAX-1 ) begin

            count <= 'b0 ;             // force the roll-over
            tick  <= 1'b1 ;            // assert a single-clock pulse each time the counter resets

         end
         else begin

            count <= count + 'b1 ;
            tick  <= 1'b0 ;

         end
      end    // if rst
   end   // always

endmodule
