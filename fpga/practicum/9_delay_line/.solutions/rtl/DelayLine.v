//
// Example Digital Delay Line (DLL) using a simple shift register and MUX.  
// Use the 4-bit MUX to select the amount of delay to add to an input signal
// in terms of number of clock periods.
// You can also add a PLL clock management IP to multiply the input clock
// in order to achieve a higher delay resolution.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module DelayLine (

   input  wire [3:0] DelaySelect,   // delay value (0, 1, 2, ... 15)
   input  wire clk,
   input  wire SignalIn,            // input signal
   output reg  SignalOut,           // delayed output signal
   output wire PWM                  // for debug purposes, also generate a PWM signal to be used as input for the delay-line

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   // PLL signals
   wire pll_clk, pll_locked, UNCONNECTED ;

   PLL  PLL_inst ( .CLK_IN(clk), . CLK_OUT_100(pll_clk), .CLK_OUT_200(UNCONNECTED), .LOCKED(pll_locked) ) ;
   //PLL  PLL_inst ( .CLK_IN(clk), . CLK_OUT_100(UNCONNECTED), .CLK_OUT_200(pll_clk), .LOCKED(pll_locked) ) ;


   ////////////////////////
   //   shift register   //
   ////////////////////////

   reg [14:0] q = 15'b0 ;   // **NOTE: we have 16 possible delay values, but for 0 delay we want SignalOut = SignalIn, thus only 15 FlipFlops

   always @(posedge pll_clk) begin

      if( ~pll_locked )
         q <= 15'b0 ;

      else
         q[14:0] <= { q[13:0] , SignalIn } ;   // shift-right using concatenation
   end


   ////////////////////
   //   output MUX   //
   ////////////////////

   always @(*) begin

      case( DelaySelect[3:0] )

         4'h0 : SignalOut = SignalIn ;   // no delay
         4'h1 : SignalOut = q[ 0] ;      //  1x clock period delay
         4'h2 : SignalOut = q[ 1] ;      //  2x clock period delay
         4'h3 : SignalOut = q[ 2] ;      //  3x clock period delay
         4'h4 : SignalOut = q[ 3] ;      //  4x clock period delay
         4'h5 : SignalOut = q[ 4] ;      //  5x clock period delay
         4'h6 : SignalOut = q[ 5] ;      //  6x clock period delay
         4'h7 : SignalOut = q[ 6] ;      //  7x clock period delay
         4'h8 : SignalOut = q[ 7] ;      //  8x clock period delay
         4'h9 : SignalOut = q[ 8] ;      //  9x clock period delay
         4'hA : SignalOut = q[ 9] ;      // 10x clock period delay
         4'hB : SignalOut = q[10] ;      // 11x clock period delay
         4'hC : SignalOut = q[11] ;      // 12x clock period delay
         4'hD : SignalOut = q[12] ;      // 13x clock period delay
         4'hE : SignalOut = q[13] ;      // 14x clock period delay
         4'hF : SignalOut = q[14] ;      // 15x clock period delay

      endcase
   end   // always


   //////////////////////////////////////////////////////
   //   auxiliary 8-bit PWM generator (test feature)   //
   //////////////////////////////////////////////////////

   // free-running counter
   reg [7:0] pwm_count = 8'h00 ;

   always @(posedge pll_clk) begin

      if( ~pll_locked )
         pwm_count <= 8'h00 ;

      else
         pwm_count <= pwm_count + 'b1 ;

   end   // always


   // binary comparator
   assign PWM = (pwm_count < 150) ? 1'b1 : 1'b0 ;

endmodule

