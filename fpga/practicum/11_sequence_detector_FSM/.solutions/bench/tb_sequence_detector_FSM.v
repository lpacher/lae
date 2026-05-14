
`timescale 1ns / 100ps

module tb_sequence_detector_FSM ;

   /////////////////////////
   //   clock generator   //
   /////////////////////////

   wire clk ;

   ClockGen  #(.PERIOD(10.0)) ClockGen_inst (.clk(clk) ) ;   // override default period as module parameter (default is 50.0 ns)


   ///////////////////////////
   //   device under test   //
   ///////////////////////////

   reg rst = 1'b0 ;

   reg [3:0] sequence ;   //from ROM

   wire detected ;
   wire [2:0] STATE ;

   sequence_detector_FSM  DUT (

      .clk        ( clk           ),
      .reset      ( rst           ),
      .SW         ( sequence[3:0] ),
      .state_led  ( STATE[2:0]    ),
      .detected   ( detected      )
   ) ;



   //////////////////////
   //   ROM sequence   //
   //////////////////////

   reg [4:0] mem [0:15] ;

   // ROM initialization
   initial begin

      mem[ 0] = 4'b0000 ;
      mem[ 1] = 4'b0010 ;
      mem[ 2] = 4'b1010 ;
      mem[ 3] = 4'b0000 ;
      mem[ 4] = 4'b0001 ;
      mem[ 5] = 4'b0011 ;
      mem[ 6] = 4'b1011 ;
      mem[ 7] = 4'b0000 ;  //OK
      mem[ 8] = 4'b0001 ;  //OK
      mem[ 9] = 4'b0011 ;  //OK
      mem[10] = 4'b0011 ;  //OK
      mem[11] = 4'b0111 ;  //OK
      mem[12] = 4'b1111 ;  //OK  => detected!
      mem[13] = 4'b1110 ;
      mem[14] = 4'b0000 ;  //OK
      mem[15] = 4'b0001 ;  //OK

   end


   //////////////////
   //   stimulus   //
   //////////////////

   integer k ;

   initial begin

      #30 rst = 1'b1 ;

      for (k=0; k<16;k=k+1) begin
         #100 sequence = mem[k] ;
      end

      #100 $finish ;
   end   //initial

endmodule
