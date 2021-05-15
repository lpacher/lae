//
// Example parameterizable N-bit Pulse-Width Modulation (PWM) generator in Verilog.
// The default value for the threshold width is 4-bit in order to map the threshold
// into 4x slide-switches as available on Digilent Arty A7 development board.
// Code derived and readapted from https://www.fpga4fun.com
//
// The code also shows how to instantiate and **CONFIGURE** already in the RTL
// code Xilinx FPGA I/O primitives such as simple OBUF output buffers.
// This is another example of a **GOOD** FPGA design practice. For complex FPGA
// digital designs in fact it is always recommended to know how to program/fine-tune
// the I/O interface with the external PCB (e.g.  set I/O termination for LVDS RX/TX,
// add pull-up/pull-down for selected signals, program slew rate/drive-strength etc).
// This can be done by writing a dedicated I/O code that "wraps" the FPGA core logic
// (similarly to a "padframe" that instantiates I/O cells in digital-on-top ASIC
// design flows).
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module PWM #(parameter integer THRESHOLD_NBITS = 4) (

   input  wire clk,
   input  wire [THRESHOLD_NBITS-1:0] threshold,     // programmable threshold, determines the duty-cycle of the PWM output waveform
   output wire pwm_out

   ) ;


   ///////////////////////////////////////////////////////////
   //   Phase-Locked Loop (PLL) IP core (Clocking Wizard)   //
   ///////////////////////////////////////////////////////////

   // PLL output signals
   wire pll_clk, pll_locked ;

   PLL PLL_inst (

      .CLK_IN  ( clk        ),   // input clock: 100 MHz with maximum input jitter filtering 
      .CLK_OUT ( pll_clk    ),   // output clock: 100 MHz
      .LOCKED  ( pll_locked )

      ) ;


   /////////////////////////////////
   //   tick counter (optional)   //
   /////////////////////////////////

   wire enable ;

   TickCounter #(.MAX(1)) TickCounter_inst ( .clk(pll_clk), .tick(enable) ) ;   // with MAX = 1 the "tick" is always high, same as running at 100 MHz


   //////////////////////////////
   //   free-running counter   //
   //////////////////////////////

   reg [THRESHOLD_NBITS-1:0] pwm_count = {THRESHOLD_NBITS{1'b0}} ;   // use the replication operator to initialize all FF outputs to 1'b0, but you can also simply use 'b0

   always @(posedge pll_clk) begin

      if (enable & pll_locked) begin

         // simple implementation, count from 0 to 111 ... 11, then pwm_out = 0 when threshold = 0, but pwm_out != 1 when threshold = 111 ... 11
         //pwm_count <= pwm_count + 1'b1 ;

         // alternatively, count from 0 to 111 ... 10 sunch that PWM = 0 when threshold = 0 and PWM = 1 when threshold = 111 ... 11 (like for "Arduino" PWM pins)
         if( pwm_count == {THRESHOLD_NBITS{1'b1}} -1 )
            pwm_count <= 'b0 ;

         else 
            pwm_count <= pwm_count + 1'b1 ;

      end  // if
   end   // always


   ///////////////////////////
   //   binary comparator   //
   ///////////////////////////

   wire pwm_comb ;

   // PWM output: logic 1 if pwm_count < threshold, 0 otherwise
   assign pwm_comb = ( pwm_count < threshold ) ? 1'b1 : 1'b0 ;        // binary comparator (pure combinationational block using conditional assignment)

/*

   // alternative coding style using procedural block
   reg pwm_comb ;

   always @(*) begin
      if( pwm_count < threshold )
         pwm_comb = 1'b1 ;
      else
         pwm_comb = 1'b0 ;
   end   // always

*/


   /////////////////////////////////////////////////////////////////////////////
   //   **EXAMPLE: pre-placed RTL output buffer with detailed configuration   //
   /////////////////////////////////////////////////////////////////////////////

   //
   // Pre-place and configure a Xilinx FPGA output buffer OBUF primitive already in RTL.
   //
   // SLEW => "SLOW" (default) or "FAST"
   // DRIVE => 2, 4, 6, 8, 12(default), 16 or 24. Allowed values for LVCMOS33 IOSTANDARD are: 4, 6, 8, 12(default) or 16
   //
   // Ref. also to Xilinx official documentation:
   //
   //   Vivado Design Suite Properties Reference Guide (UG912)
   //   Vivado Design Suite 7 Series FPGA and Zynq-7000 SoC Libraries Guide (UG953) 
   //

   OBUF  #(.IOSTANDARD("LVCMOS33"), .DRIVE(12), .SLEW("FAST")) OBUF_inst (.I(pwm_comb), .O(pwm_out)) ;   // **REMINDER: requires glbl.v compiled and elaborate along with other sources

endmodule

