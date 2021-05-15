//
// Example Real-Number Model (RNM) using SystemVerilog real ports for a simple
// Voltage-Controlled Oscillator (VCO). This can be used as a reference code
// to describe and simulate other mixed-signal blocks such as A/D and D/A converters
// using real numbers.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module VCO (

   input  real  Vctrl,     // analog control voltage using a 'real' input port, only supported by SystemVerilog
   output logic clk        // SystemVerilog 'logic' net type, same as 'reg'

   ) ;

   // VCO parameters
   parameter real INTRINSIC_FREQ = 2.5 ;    // MHz
   parameter real VCO_GAIN = 10.0 ;         // MHz/V

   real clk_delay ;
   real freq ;

   initial begin
      clk = 1'b0 ;
      freq = INTRINSIC_FREQ ;             // initial frequency
      clk_delay = 1.0/(2*freq)*1e3 ;      // initial semi-period
   end


   // change the clock frequency whenever the control voltage changes
   always @(Vctrl) begin
      freq = INTRINSIC_FREQ + VCO_GAIN*Vctrl ;
      clk_delay = 1.0/(2*freq)*1e3 ;

      $display("VCO clock frequency for Vctrl = %.2f V is %2.2f MHz", Vctrl, freq) ;
   end

   // clock generator
   always #clk_delay clk = ~clk ;

endmodule : VCO

