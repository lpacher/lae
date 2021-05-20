//
// A simple Verilog "wrapper" for the automatically-generated FIFO IP core.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module FIFO (

   // clock and reset
   input  wire Clock,              // assume on-board 100 MHz clock
   input  wire Reset,              // synchronous reset, active-high

   // write section
   input  wire WrEnable,           // write-enable
   input  wire [7:0] WrData,       // input data

   // read section
   input  wire RdEnable,           // read-enable
   output wire [7:0] RdData,       // output data

   // diagnostics
   output wire Full, Empty         // status flags

   ) ;


   //////////////////////////////////
   //   FIFO IP (FIFO Generator)   //
   //////////////////////////////////

   // **NOTE: the actual FIFO implementation is placed in ../cores/FIFO_WIDTH8_DEPTH32/FIFO_WIDTH8_DEPTH32_sim_netlist.v

   FIFO_WIDTH8_DEPTH32   FIFO_WIDTH8_DEPTH32_inst (

      .clk    (        Clock ),
      .srst   (        Reset ),
      .din    (  WrData[7:0] ),
      .wr_en  (     WrEnable ),
      .rd_en  (     RdEnable ),
      .dout   (  RdData[7:0] ),
      .full   (         Full ),
      .empty  (        Empty )

      ) ;

endmodule
