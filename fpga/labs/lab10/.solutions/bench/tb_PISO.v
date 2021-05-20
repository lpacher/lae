//
// Verilog testbench for 8-bit shift register.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module tb_PISO ;


   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg shift0_load1 ;
   reg [7:0] data ;

   wire serial_out ;

   PISO  #(.WIDTH(8), .INIT(8'hFF))  DUT ( .clk(clk100), .ce(1'b1), .load(shift0_load1), .pdata(data), .si(1'b1), .so(serial_out)) ;  // **NOTE: keep serial-in to 1'b1 for easier debug !


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   initial begin

      #0   shift0_load1 = 1'b1 ; data = 8'b1010_1101 ;         // 8'hAD

      #418 shift0_load1 = 1'b0 ;                               // strange number, just to be asynchronous with clock

      #(8*20.0) shift0_load1 = 1'b1 ; data = 8'b0010_1010 ;    // 8'h2A

      #418 shift0_load1 = 1'b0 ;                               // strange number, just to be asynchronous with clock

      #1000 $finish ;
   end

endmodule

