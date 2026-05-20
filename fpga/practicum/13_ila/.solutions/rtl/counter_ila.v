//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Example 28-bit binary counter Verilog design with external reset
// and count-enable control signals to demonstrate the usage of the
// Integrated Logic Analyzer (ILA) debug core in Vivado.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2026
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
      if (~reset) begin          //synchronous-reset, active-low
         count <= 'b0 ;
      end
      else if (enable) begin
         count <= count + 'b1 ;
      end
   end   //always

   assign LED = count[27:24] ;


   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //   **EXERCISE: compile and add here an Integrated Logic Analyzer (ILA) IP core to monitor all I/O signals   //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   // ...

endmodule

