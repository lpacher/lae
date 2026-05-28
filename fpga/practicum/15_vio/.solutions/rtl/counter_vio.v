//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Example 28-bit binary counter Verilog design with external reset
// and count-enable control signals to demonstrate the usage of the
// Virtual Input/Output (VIO) debug core in Vivado.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2026
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`timescale 1ns / 100ps

module counter_vio (

   input  wire clk,
   input  wire reset,
   input  wire enable,
   output wire [3:0] LED

   ) ;


   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //   **EXERCISE: compile and add here a Vitual Input/Output (VIO) IP core to drive reset/enable signals from Vivado Hardware Manager   //
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //wire reset_from_vio ;
   //wire enable_from_vio ;

   // ...


   wire reset_int ;
   wire enable_int ;

   //assign reset_int = ...
   //assign enable_int = ...


   ///////////////////////////////
   //   28-bit binary counter   //
   ///////////////////////////////

   reg [27:0] count = 'b0 ;

   always @(posedge clk) begin
      if ( ... ) begin          //synchronous-reset, active-low
         count <= 'b0 ;
      end
      else if ( ... ) begin
         count <= count + 'b1 ;
      end
   end   //always

   assign LED = count[27:24] ;


   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //   **EXERCISE: compile and add here an Integrated Logic Analyzer (ILA) IP core to monitor all I/O signals   //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   // ...

endmodule

