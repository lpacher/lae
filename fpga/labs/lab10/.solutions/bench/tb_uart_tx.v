//
// Example simulation for simplified UART transmission unit using a Parallel-In
// Serial-Out (PISO) shift register.
// 
// Ref. also to the following serial protocol timing specification.
//
//   __________________       _____ _____ _____ _____ _____ _____ _____ _____ _____ ___________
//                     \_____/_____X_____X_____X_____X_____X_____X_____X_____X     :
//
//         IDLE        START  BIT0  BIT1  BIT2  BIT3  BIT4  BIT5  BIT6  BIT7  STOP  IDLE
//
//
// Luca Pacher - pacher@to.infn.it
// Fall 2020
//


`timescale 1ns / 100ps

module tb_uart_tx ;



   /////////////////////////////////
   //   100 MHz clock generator   //
   /////////////////////////////////

   wire clk100 ;

   ClockGen  ClockGen_inst ( .clk(clk100) ) ;


   //////////////////////////////////////////////////
   //   free-running 9.6 kHz baud-rate generator   //
   //////////////////////////////////////////////////

   wire baud_tick ;

   BaudGen  BaudGen_inst (.clk(clk100), .tx_en(baud_tick)) ;   // use the tick-counter !


   ///////////////////////////////////////////////
   //   UART transmitter using shift-register   //
   ///////////////////////////////////////////////

   reg [7:0] tx_data ;

   reg tx_start = 1'b0 ;

   wire TxD ;

   PISO  #(.WIDTH(10), .INIT( {10{1'b1}}))  UART_TX (

      .clk   (                  clk100 ),
      .ce    (               baud_tick ),
      .si    (                    1'b1 ),
      .pdata ( {1'b1 , tx_data , 1'b0} ),   // **IMPORTANT: stop-bit + 8-bit data + start-bit !
      .load  (                tx_start ),
      .so    (                    TxD  )

      ) ;


   ///////////////////////
   //   main stimulus   //
   ///////////////////////

   integer k ;

   initial begin

      #500 ;

      for(k = 0; k < 10; k = k+1) begin

         tx_data = $random ;

         #(50000) tx_start = 1'b1 ;                // "strange" delay only to have tx_start in between two ticks, totally uncorrelated with the baud "tick"

         #(10) tx_start = 1'b0 ;                   // "dirty" way to generate a single clock-pulse

         @(posedge baud_tick) #(11*10414*10.0) ;   // wait for 11 baud "ticks"

      end   // for

      #100 tx_start = 1'b0 ;   // disable data transmission, check what happens

      #(12*10414*10.0) $finish ;

   end

endmodule

