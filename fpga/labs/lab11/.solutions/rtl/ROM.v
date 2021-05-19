// 
// Example parameterized Read-Only Memory (ROM) in Verilog. Use the ROM_STYLE synthesis
// pragma to instruct the tool how to infer the ROM memory in FPGA hardware:
//
//   (* rom_style = "block" *)         => infer BRAM components
//   (* rom_style = "distributed" *)   => infer LUTs components
//
// This can be set either in RTL code or in XDC as set_property. By default the
// tool selects which ROM style to infer based on heuristics that give the best
// results for the most designs. ROM initial values can be specified in the code
// or in an external file imported using $readmemb() or $readmemh() tasks.
//
// Ref. also to Vivado Synthesis user guide (UG901):
//
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug901-vivado-synthesis.pdf
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module ROM #(parameter integer WIDTH = 8, parameter integer DEPTH = 1024) (

   input  wire clk,
   input  wire ren,                        // read-enable
   input  wire [$clog2(DEPTH)-1:0] addr,   // address 0 to DEPTH-1 memory locations (10-bits for 1024 samples)
   output reg  [WIDTH-1:0] dout

   ) ;


   /////////////////////////
   //   ROM declaration   //
   /////////////////////////

   (* rom_style = "distributed" *)              // this is a first example of a SYNTHESIS PRAGMA, instruct the tool how to infer the ROM memory with LUTs or BRAMs
   reg [WIDTH-1:0] mem [0:DEPTH-1] ;


   ////////////////////
   //   read logic   //
   ////////////////////

   // initialize all FlipFlop outputs to zero at FPGA startup
   initial
      dout <= 'b0 ;
      //dout <= {WIDTH{1'b0}} ;   // alternatively you can also use the replication operator


   always @(posedge clk) begin
      if(ren)
         dout <= mem[addr] ;   // simply read the ROM word from address i-th

   end   // always


   ////////////////////////////
   //   ROM initialization   //
   ////////////////////////////

   initial begin

      // initialize the ROM using an external file...
      $readmemh("/path/to/Desktop/lae/fpga/labs/lab11/rtl/ROM_8x1024.hex", mem) ;         // **IMPORTANT: customize the path according to your machine !

/*
      // or simply specify in the initial block ROM values for each address
      mem[0] = 8'h01 ;
      mem[1] = 8'h23 ;
      mem[2] = 8'h45 ;
      mem[3] = 8'h67 ;
      mem[4] = 8'h89 ;
      mem[5] = 8'hAB ;
      mem[6] = 8'hCD ;
      mem[7] = 8'hEF ;

      ...
      ...  etc.

*/

   end

endmodule

