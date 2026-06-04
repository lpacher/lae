//
// Free-running 9.6 kHz baud rate generator for UART transmitter. Simply instantiate
// the programmable tick-counter in order to generate a 9.6 kHz single clock-pulse
// "tick" used as clock-enable in the UART transmitter code as requested by RS-232
// serial protocol.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module BaudGen (

   input  wire clk,        // assume 100 MHz input clock
   input  wire rst,
   output wire tx_en       // 9.6 kHz baud "tick"

   ) ;

   TickCounterRst #(.MAX(10414))  BaudTicker ( .clk(clk), .rst(rst), .tick(tx_en) ) ;

endmodule

