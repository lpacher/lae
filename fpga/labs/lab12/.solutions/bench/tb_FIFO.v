//
// Example testbench to simulate an 8-bit wide, 32-bit deep First-In Fisrt-Out (FIFO)
// memory compiled as IP using Xilinx FIFO Generator.
//
// The $stop Verilog task is executed whenever a FIFO-full condition is detected and
// pauses the simulation. To continue the simulation until the end issuing "run all"
// in the XSim Tcl console.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`define FIFO_WIDTH   8   // useless in this testbench, just to remind us that if needed we can also use macros in Verilog ...
`define FIFO_DEPTH  32


`timescale 1ns / 100ps

module tb_FIFO ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;



   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst ;

   reg wr_enable = 1'b0 ;
   reg rd_enable = 1'b0 ;

   reg  [7:0] wr_data = 8'h00 ;
   wire [7:0] rd_data ;

   wire empty, full ;

   FIFO  DUT (

      // clock and reset
      .Clock     (       clk100 ),
      .Reset     (          rst ),

      // write section
      .WrEnable  (    wr_enable ),
      .WrData    ( wr_data[7:0] ),

      // read section
      .RdEnable  (    rd_enable ),
      .RdData    ( rd_data[7:0] ),

      // diagnostics
      .Full      (         full ),
      .Empty     (        empty )

      ) ;



   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   // **IMPORTANT: in the following there are 4 procedural blocks that runs in parallel (concurrent programming)


   //
   // reset process
   //
   initial begin
      #72  rst = 1'b1 ;    // assert reset
      #200 rst = 1'b0 ;    // release reset (Xilinx recommends at least 100ns long reset)
   end


   //
   // write process
   //
   integer wr ;  // for-loop iterator

   initial begin

      #400   // wait for reset to be released

      for (wr = 0; wr < 100; wr = wr+1) begin

         #100 wr_data[7:0] = $random ;   // **REMIND: $random returns a 32-bit random integer, here we cast the 8 left-most bits to wr_data

         @(posedge clk100) wr_enable = 1'b1 ;    // "dirty" way to generate a single clock-pulse control signal
         @(posedge clk100) wr_enable = 1'b0 ;

      end   // for
   end   // initial


   //
   // read process => start reading the FIFO at 800ns, then stop for 4us to go FULL, finally resume
   //
   integer rd ;   // for-loop iterator

   initial begin

      #400   // wait for reset to be released

      #400   // start reading only after 800ns

      for( rd = 0; rd < 32; rd = rd+1) begin

         #100

         @(posedge clk100) rd_enable = 1'b1 ;    // "dirty" way to generate a single clock-pulse control signal
         @(posedge clk100) rd_enable = 1'b0 ;

      end   // for


      #4000   // stop reading for 4us, meanwhile the FIFO goes FULL !

      for (rd = 0; rd < 70; rd = rd+1) begin

         #100

         @(posedge clk100) rd_enable = 1'b1 ;
         @(posedge clk100) rd_enable = 1'b0 ;
      end

      #1000 $finish ;

   end   // initial


   //
   // monitor FIFO status
   //
   always @(posedge full) begin

      $display("\n\n**BAD** ! FIFO-full condition detected at %f us !\n\n", ($realtime)*1e-3 ) ;

      #100 $stop ;  // suspend the simulation and enter into interactive debug mode (but the simulation can continue by issuing "run all" in the XSim Tcl console)

   end

endmodule

