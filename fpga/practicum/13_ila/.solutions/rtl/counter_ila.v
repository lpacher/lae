
`timescale 1ns / 100ps

module counter_ila (

   input  wire clk,
   (* mark_debug = "true", keep = "true" *)
   input  wire reset,
   (* mark_debug = "true", keep = "true" *)
   input  wire enable,
   (* mark_debug = "true", keep = "true" *)
   output wire [3:0] LED

   ) ;


   reg [27:0] count = 'b0 ;

   always @(posedge clk) begin
      if (~reset) begin
         count <= 'b0 ;
      end
      else if (enable) begin
         count <= count + 'b1 ;
      end
   end   //always

   assign LED = count[27:24] ;


   //////////////////////////////////////////////////////////////////////////////////////////////
   //   **EXERCISE: add here an Integrated Logic Analyzer (ILA) IP core to monitor the reset   //
   //////////////////////////////////////////////////////////////////////////////////////////////

   // ...

endmodule

