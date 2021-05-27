//
// Send all possible "printable" ASCII characters from ROM to a computer
// using the UART serial interface and observe the serial protocol at the
// oscilloscope.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//

`define SIM

`timescale 1ns / 100ps

module uart_ascii (

   input  wire clk,                       // assume 100 MHz clock from external on-board oscillator
   output wire TxD,                       // serial output, hard-wired FPGA pin already connected by Digilent to USB/UART bridge on the board
   output wire txd_probe, busy_probe      // optionally, probe signals at the oscilloscope

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   wire pll_clk, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk), .CLK_OUT(pll_clk), .LOCKED(pll_locked) ) ;


   ///////////////////////////////////
   //   ROM read-enable generator   //
   ///////////////////////////////////

   wire rom_ren ;   // single clock-pulse from tick counter

`ifdef SIM

   // use a higher frequency ticker for simulations, otherwise simulation time explodes (cover LOAD to IDLE states)
   TickCounterRst #(.MAX(10414*14)) ticker (.clk(pll_clk), .rst(~pll_locked), .tick(rom_ren)) ;

`else
 
   // assert a single clock-pulse read-enable once every 0.5 seconds
   TickCounterRst #(.MAX(50000000)) ticker (.clk(pll_clk), .rst(~pll_locked), .tick(rom_ren)) ;

`endif


   ///////////////////////////////
   //   ROM address generator   //
   ///////////////////////////////

   reg [7:0] rom_addr = 8'h00  ;     // address counter

   always @(posedge pll_clk) begin

      if(rom_ren) begin

         if(rom_addr == 94) begin           // **REMIND: ROM depth is 95, address from 0 to 94 memory slots !

            rom_addr <= 'b0 ;

         end
         else begin

            rom_addr <= rom_addr + 'b1 ;

         end
      end   // if
   end   // always



   ///////////////////////////
   //   ASCII table (ROM)   //
   ///////////////////////////

   wire [7:0] tx_data ;

   ascii_rom   ascii_rom (

      .clk   (  pll_clk ),
      .ren   (  rom_ren ),
      .addr  ( rom_addr ),
      .dout  (  tx_data )

      ) ;



   ///////////////////////////////////////////////////////
   //   UART transmitter (baud-rate generator + FSM)   //
   //////////////////////////////////////////////////////

   wire baud_tick, sdo, busy ;

   BaudGen  BaudGen (.clk(pll_clk), .rst(~pll_locked), .tx_en(baud_tick)) ;

   uart_tx_FSM  uart_tx (

      .clk       (     pll_clk ),
      .rst       ( ~pll_locked ),
      .tx_start  (     rom_ren ),
      .tx_en     (   baud_tick ),
      .tx_data   (     tx_data ),
      //.tx_data   (     8'h41 ),   // **DEBUG: send ASCII character "A"
      .TxD       (         sdo ),
      .tx_busy   (        busy )

      ) ;

   assign TxD = sdo ;

   // display the serial output at the oscilloscope (use "busy" as trigger to show START/STOP bits)
   assign txd_probe  = sdo ;
   assign busy_probe = busy ;

endmodule


