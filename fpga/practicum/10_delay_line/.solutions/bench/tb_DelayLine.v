//
// Minimal testbench code for DelayLine.v Verilog module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module tb_DelayLine ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire pwm, pwm_delayed ;   // simply connect the auxiliary PWM output as input signals as in the lab

   reg [3:0] sel = 4'b0000 ;

   DelayLine  DUT ( .clk(clk100), .DelaySelect(sel), .SignalIn(pwm), .SignalOut(pwm_delayed), .PWM(pwm) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer k ;

   initial begin

      #1000 ;   // wait for PLL to lock

      for (k=0; k<16; k=k+1) begin

         #(256*10) sel = k ;   // **NOTE: the auxiliary free-running PWM generator is 8-bit wide

      end

      #(256*10) $finish ;

   end

endmodule

