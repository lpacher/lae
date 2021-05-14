//
// Parameterized N-digit BCD counter. The logic includes an end-of-scale flag
// asserted when 9999 ... 9 is reached and an overflow flag when the count goes
// out of range.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


//
// Dependencies:
//
//`include "rtl/CounterBCD.v"
//


`timescale 1ns / 100ps

module CounterBCD_Ndigit #(parameter integer Ndigit = 1) (

   input  wire clk,
   input  wire rst,
   input  wire en,
   output wire [Ndigit*4-1:0] BCD
   //output wire overflow,               // asserted when the most-significant digit generates a carry
   //output wire eos                     // asserted when 9999 ... 9 is reached

   ) ;


   ////////////////////////////////////
   //   PLL IP core (Clock Wizard)   //
   ////////////////////////////////////

   // PLL signals
   wire pll_clk100, pll_clk200, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk), .CLK_OUT_100(pll_clk100), .CLK_OUT_200(pll_clk200), .LOCKED(pll_locked) ) ;


   wire pll_clk ;

   // choose here the clock fed to core logic
   assign pll_clk =  pll_clk100 ;              // 100 MHz output clock
   //assign pll_clk =  pll_clk200 ;            // 200 MHz output clock


/*

   ///////////////////////////////////////////
   //   **EXAMPLE: a simple clock-divider   //
   ///////////////////////////////////////////

   //reg clk_div = 1'b0 ;
   //
   //always @(posedge clk)
   //   clk_div = ~ clk_div ;


   ///////////////////////////////////////////////////////////////////////
   //   **EXAMPLE: clock divider using auxiliary free-running counter   //
   ///////////////////////////////////////////////////////////////////////

   // auxiliary 6-bit free-running counter for clock division
   reg [5:0] count_free = 6'b000_000 ;                            // **IMPORTANT: this initialization is feasible in FPGA thanks to Global Set/Reset (GSR) !

   always @(posedge clk)
      count_free = count_free + 5'b1 ;

   wire clk_div ;   // divided clock, e.g. 100 MHz => 50 MHz

   // choose below the desired divided clock fed to the BCD counter
   //assign clk_div = clk ;                             // clk      e.g. 100 MHz
   //assign clk_div = count_free[0] ;                   // clk/2    e.g. 100 MHz/2 = 50   MHz
   //assign clk_div = count_free[1] ;                   // clk/4    e.g. 100 MHz/4 = 25   MHz
   //assign clk_div = count_free[2] ;                   // clk/8    e.g. 100 MHz/8 = 12.5 MHz
   //assign clk_div = count_free[3] ;                   // clk/16   etc.
   //assign clk_div = count_free[4] ;                   // clk/32
   assign clk_div = count_free[5] ;                     // clk/64

*/


   /////////////////////////////////////////////////////////
   //   **EXAMPE: use a "ticker" to slow-down the logic   //
   /////////////////////////////////////////////////////////

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


   // assert a single clock-pulse "tick" every 1 us i.e. 100 x 10 ns clock period at 100 MHz
   wire tick ;

   //TickCounter  #(.MAX(10)) TickCounter_inst ( .clk(clk), .tick(tick)) ;          // 10 MHz
   //TickCounter  #(.MAX(100)) TickCounter_inst ( .clk(clk), .tick(tick)) ;       //  1 MHz

   TickCounter  #(.MAX(100)) TickCounter_inst ( .clk(pll_clk), .tick(tick)) ;


   /////////////////////////////
   //   N-digit BCD counter   //
   /////////////////////////////


   wire [Ndigit:0] w ;   // Ndigit + 1 wires to interconnect BCD counters each other

   //assign w[0] = en ;
   assign w[0] = en & tick ;   // **IMPORTANT: now the logic proceeds only if a "tick" pulse is also present!


   generate

      genvar k ;

      for(k = 0; k < Ndigit; k = k+1) begin : digit  

         CounterBCD  digit (

            //.clk      (             clk_div ),     // **BAD design practice, do not use "custom" clocks
            .clk      (                 clk ),       // **GOOD design practice, all FFs receive the same clock
            //.rst      (                 rst ),
            .rst      ( rst | (~pll_locked) ),       // **IMPORTANT: we also use the "locked" signal from the PLL as reset! 
            .en       (                w[k] ),
            .BCD      (      BCD[4*k+3:4*k] ),
            .carryout (              w[k+1] )

         ) ;

      end // for

   endgenerate


   // generate end-of-scale flag when 9999 ... 9 is reached
   //assign eos = ( BCD == {Ndigit{4'b1001}} ) ? 1'b1 : 1'b0 ;      // use Verilog replication operator to replicate 4'1001 N times

   // generate overflow flag
   //assign overflow = w[Ndigit] ;    // simply the carry-out of the most-significant BCD counter

endmodule

