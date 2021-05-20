//
// Example parameterizable N-bit Parallel-In Serial-Out (PISO) shift register with
// positive-edge clock, asynchronous parallel load, serial-in, and serial-out.
// Use the SRL_STYLE synthesis pragma to instruct the tool how to implement the
// shift-register in FPGA hardware:
//
//   (* srl_style = "register" *)         => infer FlipFlops
//   (* srl_style = "srl" *)              => infer dedicated SRL components
//
// This can be set either in RTL code or in XDC as set_property. 
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module PISO #(parameter integer WIDTH = 8, parameter [WIDTH-1:0] INIT = {WIDTH{1'b0}} ) ( 

   input  wire clk, ce,                // clock and clock-enable
   input  wire si,                     // serial-in
   input  wire [WIDTH-1:0] pdata,      // N-bit parallel-data
   input  wire load,                   // load 1, shift 0
   output wire so                      // serial-out

   ) ;


   ///////////////////////////////
   //   N-bits shift register   //
   ///////////////////////////////

   (* srl_style = "register" *)
   reg [WIDTH-1:0] q = INIT ;          // this works on FPGA thanks to the Global Set/Reset (GSR) when firmware is downloaded !


   always @(posedge clk) begin

      // load mode
      if(load) begin
         q <= pdata ;
      end

      // shift-mode otherwise
      else if (ce) begin

         q[WIDTH-1:0] <= { q[WIDTH-2:0] , si } ;     // shift-left using concatenation

         // **NOTE: this is equivalent to :
         // q[0] <= SI ;
         // q[1] <= q[0] ;
         // q[2] <= q[1] ;
         // ...
         // ...
         // q[WIDTH-1] <= q[WIDTH-2] ;

      end   // if
   end   // always


/*

   // alternatively, you can also use a for-loop statement

   integer i ;

   always @(posedge clk) begin

      // load mode
      if(load) begin
         q <= pdata ;
      end

      // shift-mode otherwise
      else if (ce) begin

         q[0] <= si ;

         for(i = 0; i < WIDTH-1; i = i+1  ) begin

            q[i+1] <= q[i] ;

         end   // for
      end   // if
   end   // always

*/

   // assign the MSB to serial-out
   assign so = q[WIDTH-1] ;

endmodule

