
`timescale 1ns / 100ps

module sequence_detector_FSM (

   input  wire clk,
   input  wire reset,
   input  wire [3:0] SW,
   output wire LED

   ) ;

   parameter [2:0] IDLE   = 3'b000 ;
   parameter [2:0] START  = 3'b001 ;   // 4'b0000 detected
   parameter [2:0] ONE    = 3'b010 ;   // 4'b0001 detected
   parameter [2:0] THREE  = 3'b011 ;   // 4'b0011 detected
   parameter [2:0] SEVEN  = 3'b100 ;   // 4'b0111 detected
   parameter [2:0] DONE   = 3'b101 ;   // 4'b1111 detected


   reg [2:0] STATE ;


   always @(posedge clk) begin

      if (reset) begin
         STATE <= IDLE ;
      end
      else begin
         case (STATE)

            IDLE    : if ( SW == 4'b0000 ) STATE <= START ; else STATE <= IDLE ;
            START   : if ( SW == 4'b0001 ) STATE <= ONE   ; else STATE <= IDLE ;
            ONE     : if ( SW == 4'b0011 ) STATE <= THREE ; else STATE <= IDLE ;
            THREE   : if ( SW == 4'b0111 ) STATE <= SEVEN ; else STATE <= IDLE ;
            SEVEN   : if ( SW == 4'b1111 ) STATE <= DONE  ; else STATE <= IDLE ;

            //catch-all
            default : IDLE ;

         endcase
      end   //else
   end   //always

   assign LED = (STATE == DONE) ? 1'b1 : 1'b0 ;

endmodule
