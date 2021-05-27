//
// ROM used to store ASCII "printable" characters to be sent to PC over serial protocol.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

`define ROM_WIDTH   8
`define ROM_DEPTH  95

module ascii_rom (

   input  wire clk,
   input  wire ren,          // read-enable
   input  wire [$clog2(`ROM_DEPTH):0] addr,   // address 95 memory locations (ASCII "printable" characters range from 32 to 126, 127 is DELETE)
   output reg [7:0] dout

   ) ;



   /////////////////////////
   //   ROM declaration   //
   /////////////////////////

   (* rom_style = "distributed" *) 
   reg [7:0] mem [0:`ROM_DEPTH-1] ;


   ////////////////////
   //   read logic   //
   ////////////////////

   // initialize all FlipFlop outputs to zero at FPGA startup
   initial
      dout <= 'b0 ;


   always @(posedge clk) begin
      if(ren)
         dout <= mem[addr] ;   // simply read the ROM word from address i-th

   end   // always


   ////////////////////////////
   //   ROM initialization   //
   ////////////////////////////

   integer k ;   // explore all possible "printable" characters of the ASCII code (from 32 to 126)

   initial begin

      for (k = 0; k<`ROM_DEPTH; k=k+1) begin

         mem[k] = k + 32 ;   // specify in the initial block ROM values for each address

      end   // for
   end   // initial

endmodule

