//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
// 4-digit BCD counter driving a 4-digit 7-segment display module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`


`timescale 1ns / 100ps

module CounterBCD_4digit_display (

   input  wire clk,          // assume 100 MHz clock from on-board oscillator
   input  wire rst,          // reset, active high
   input  wire en,
   input  wire button,       // play incrementing the BCD counter using a push button
   output wire segA,
   output wire segB,
   output wire segC,
   output wire segD,
   output wire segE,
   output wire segF,
   output wire segG,
   output wire [3:0] anode 

   ) ;


   ///////////////////////////////////////////
   //   **OPTIONAL: push-button debouncer   //
   ///////////////////////////////////////////

   //wire button_debounced ;
   //Debouncer  Debouncer_button ( .clk(clk), .button(button), .pulse(button_debounced) ) ;


   //////////////////////////////
   //   free-running counter   //
   //////////////////////////////

   reg [24:0] count = 'b0 ;

   always @(posedge clk) begin
      count <= count + 'b1 ;
   end


   ////////////////////////////////////////////////////////////////
   //   control slice for multiplexing anodes and BCD-boundles   //
   ////////////////////////////////////////////////////////////////

   wire [1:0] refresh_slice ;

   assign refresh_slice = count[19:18] ;    // this choice determines the refresh frequency for 7-segment display digits


   /////////////////////////////
   //   4-digit BCD counter   //
   /////////////////////////////

   wire [15:0] BCD ;

   CounterBCD_Ndigit  #(.NDIGITS(4)) counter (

      .clk      (   button ),   // **REMIND: this is a BAD design!
      .en       (       en ),
      .rst      (      rst ),
      .BCD      (      BCD ),
      .eos      (          ),
      .overflow (          )

   ) ;


   ///////////////////////////////////
   //   multiplexer on BCD slices   //
   ///////////////////////////////////

   reg [3:0] BCD_mux ;

   always @(*) begin

      case( refresh_slice[1:0] )

         2'b00 : BCD_mux = BCD[ 3: 0] ;
         2'b01 : BCD_mux = BCD[ 7: 4] ;
         2'b10 : BCD_mux = BCD[11: 8] ;
         2'b11 : BCD_mux = BCD[15:12] ;

      endcase
   end   // always


   //////////////////////////////////////////////////////// 
   //   binary/one-hot decoder for anodes multiplexing   //
   ////////////////////////////////////////////////////////

   OneHotAnodeDecoder  anode_decoder (

      .slice  ( refresh_slice ),
      .anode  (         anode )

   ) ;


   ///////////////////////////
   //   7-segment decoder   //
   ///////////////////////////

   SevenSegmentDecoder  display_decoder (

      .BCD   (   BCD_mux ),
      .segA  (      segA ),
      .segB  (      segB ),
      .segC  (      segC ),
      .segD  (      segD ),
      .segE  (      segE ),
      .segF  (      segF ),
      .segG  (      segG ),
      .DP    (           )

   ) ;

endmodule

