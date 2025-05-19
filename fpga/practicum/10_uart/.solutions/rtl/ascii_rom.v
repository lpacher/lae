//
// ROM used to store ASCII "printable" characters to be sent to PC over serial protocol.
// Ref. also to doc/ascii_table.pdf as part of this practicum.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

`define ROM_WIDTH   8
`define ROM_DEPTH  95   // ASCII printable characters go from 32 to 127 but 127 is DELETE

module ascii_rom (

   input  wire clk,
   input  wire ren,                           // read-enable
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

   // simply specify ASCII values for each memory-slot... and a FOR-LOOP is the best choice for this job!
   //initial begin
   //
   //   mem[0] = 8'd32 ;
   //   mem[1] = 8'd33 ;
   //   mem[2] = 8'd34 ;
   //
   //   ...
   //   ...
   //
   //   mem[94] = 8'd126 ; 
   //
   //end   // initial


   integer k ;   // explore all possible "printable" characters of the ASCII code (from 32 to 126)

   initial begin

      for (k=0; k < `ROM_DEPTH; k=k+1) begin

         mem[k] = k + 32 ;   // specify in the initial block ROM values for each address

      end   // for
   end   // initial

endmodule

