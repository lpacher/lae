
`timescale 1ns / 100ps

module counter_ila (

   input  wire clk,
   input  wire reset,
   input  wire enable,
   output wire [3:0] LED

   ) ;


   reg [26:0] count = 'b0 ;

   always @(posedge clk) begin
      if (~reset) begin
         count <= 'b0 ;
      end
      else if (enable) begin
         count <= count + 'b1 ;
      end
   end   //always

   assign LED = count[26:23] ;


   //////////////////////////////////////////////////////////////////////////////////////////
   //   **TODO: add here an Integrated Logic Analyzer (ILA) IP core to monitor the reset   //
   //////////////////////////////////////////////////////////////////////////////////////////

   // ...
   // ...
   // ...

endmodule

