
`timescale 1ns / 100ps

module SawtoothGen (

   input  wire clk,
   output wire pwm_out

   ) ;

   
   ////////////////////////////////////////////////
   //   8-bit free-running counter with ticker   //
   ////////////////////////////////////////////////

   //
   // Assume to use R = 1k and C = 1u for the filter
   //

   reg [7:0] threshold_count = 8'h00 ;

   wire enable ;

   //TickCounter #(.MAX(50000)) TickCounter_inst ( .clk(clk), .tick(enable) ) ;
   TickCounter #(.MAX(100000)) TickCounter_inst ( .clk(clk), .tick(enable) ) ;  //discrete 4 Hz waveform with R=1k and C=1u filter

   always @(posedge clk) begin
      if (enable) begin
         threshold_count <= threshold_count + 'b1 ;
      end
   end


   ///////////////////////
   //   PWM generator   //
   ///////////////////////

   reg [7:0] pwm_count = 8'h00 ;

   always @(posedge clk) begin

      if (pwm_count == 8'hFE)   //count from 00000000  to 11111110 to get rail-to-rail DC values
         pwm_count <= 8'h00 ;
      else
         pwm_count <= pwm_count + 'b1 ;
   end   //always

   // binary comparator
   assign pwm_out = ( pwm_count < threshold_count ) ? 1'b1 : 1'b0 ;

endmodule

