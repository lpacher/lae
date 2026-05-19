//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Example sequence-detector Finite State Machine (FSM) implementation.
// The machine is designed to detect the switching-sequence of the four
// slide-switches available on the Digilent Arty board from right to left.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2026
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`timescale 1ns / 100ps

module sequence_detector_FSM (

   input  wire clk,         // external 100 MHz clock from XTAL oscillator
   input  wire reset,       // external reset (map this to the RESET red push-button)
   input  wire [3:0] SW,    // slide-switches
   output wire detected,    // turn on a LED with this output when the sequence has been detected

   // **DEBUG: show to standard LEDs current-state binary values
   output wire [2:0] state_led

   ) ;


   //////////////////////////////////
   //   **EXERCISE: add PLL core   //
   //////////////////////////////////

   //wire pll_clk, pll_locked ;
   //PLL PLL_INST (.CLK_IN(clk), .CLK_OUT(pll_clk), .LOCKED(pll_locked)) ;


   /////////////////////////////////
   //   states-definition table   //
   /////////////////////////////////

   parameter [2:0] IDLE   = 3'b111 ;
   parameter [2:0] START  = 3'b001 ;   // 4'b0000 detected
   parameter [2:0] ONE    = 3'b010 ;   // 4'b0001 detected
   parameter [2:0] TWO    = 3'b011 ;   // 4'b0011 detected
   parameter [2:0] THREE  = 3'b100 ;   // 4'b0111 detected
   parameter [2:0] DONE   = 3'b101 ;   // 4'b1111 detected


   reg [2:0] STATE, STATE_NEXT ;

   // **DEBUG: map STATE-bits to standard LEDs
   assign state_led = STATE ;


   /////////////////////////////////////////////////
   //   next-state logic (FSM sequential part)   //
   /////////////////////////////////////////////////

   //always @(posedge pll_clk) begin
   //   if (~reset || ~pll_locked) begin

   always @(posedge clk) begin
      if (~reset) begin        //RESET button => active-low
         STATE <= IDLE ;
      end
      else begin
         STATE <= STATE_NEXT ;
      end
   end   //always


   ////////////////////////////
   //   combinational part   //
   ////////////////////////////

   always @(*) begin

      case (STATE)

         IDLE : begin 
            if ( SW == 4'b0000 )
               STATE_NEXT <= START ;
            else
               STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         START : begin
            if ( SW == 4'b0000 )
               STATE_NEXT <= START ;
            else if ( SW == 4'b0001 )
               STATE_NEXT <= ONE ;
            else
               STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         ONE : begin
            if ( SW == 4'b0001 )
               STATE_NEXT <= ONE ;
            else if ( SW == 4'b0011 )
               STATE_NEXT <= TWO ;
            else
               STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         TWO : begin
            if ( SW == 4'b0011 )
               STATE_NEXT <= TWO ;
            else if ( SW == 4'b0111 )
               STATE_NEXT <= THREE ;
            else
               STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         THREE : begin
            if ( SW == 4'b0111 )
               STATE_NEXT <= THREE ;
            else if ( SW == 4'b1111 )
               STATE_NEXT <= DONE ;
            else STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         DONE : begin
            if ( SW == 4'b1111 )
               STATE_NEXT <= DONE ;
            else if ( SW == 4'b0000 )
               STATE_NEXT <= START ;
            else
               STATE_NEXT <= IDLE ;
         end
         //__________________________________________________________________
         //
         default : STATE_NEXT = IDLE ;   //catch-all
         //
      endcase
   end   //always

   assign detected = (STATE == DONE) ? 1'b1 : 1'b0 ;

endmodule
