//
// Testbench for parameterizable ROM.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

`define ROM_WIDTH  8
`define ROM_DEPTH  1024


`timescale 1ns / 1ps

module tb_ROM ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen   ClockGen_inst (.clk(clk100)) ;


   //////////////////////////////////////////////////////
   //    10 MHz ROM read-enable generator as "tick"   //
   /////////////////////////////////////////////////////

   wire rom_ren ;

   TickCounter  #(.MAX(10)) TickCounter_inst ( .clk(clk100), .tick(rom_ren)) ;


   ///////////////////////////
   //   pointer generator   //
   ///////////////////////////


   reg [$clog2(`ROM_DEPTH)-1:0] rom_addr = 'b0  ;     // address counter

   always @(posedge clk100) begin
      if(rom_ren)
         //rom_addr <= #10 rom_addr + 'b1 ;      // add 10 ns delay only for better visualization and easier debug, everything works also without it
         rom_addr <= rom_addr + 'b1 ;

   end   // always


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   wire [`ROM_WIDTH-1:0] rom_data ;

   ROM #(.WIDTH(`ROM_WIDTH), .DEPTH(`ROM_DEPTH)) DUT (.clk(clk100), .ren(rom_ren), .addr(rom_addr), .dout(rom_data)) ;
   //ROM_WIDTH8_DEPTH64 DUT (.clk(clk100), .qspo_ce(rom_ren), .a(rom_addr), .qspo(rom_data) ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #(`ROM_DEPTH*1000) $finish ;   // simply run for some time
   end


   // monitor the ROM content in the simulator console
   always @(posedge rom_ren)
      $display("%d", rom_data) ;

endmodule

