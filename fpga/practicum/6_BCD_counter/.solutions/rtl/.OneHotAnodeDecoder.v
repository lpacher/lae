//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Binary/one-hot decoder for 7-segment display module anodes multiplexing.
//
//  slice[1:0]   |   anode[3:0]
//      00       |      0001
//      01       |      0010
//      10       |      0100
//      11       |      1000
//
//                 _                 _
// _______________/ \_______________/ \______  anode[3]
//               _                  _
// _____________/ \________________/ \_______  anode[2]
//             _                  _
// ___________/ \________________/ \_________  anode[1]
//           _                  _
// _________/ \________________/ \___________  anode[0]
//
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`timescale 1ns / 100ps

module OneHotAnodeDecoder (

   input  wire [1:0] slice,
   output reg  [3:0] anode              //4-bit bus driven inside 'always' block
   //output wire  [3:0] anode           //4-bit bus driven by continuous 'assign' statements 

   ) ;


   integer i ;

   always @(*) begin

      for (i=0 ; i<4; i=i+1) begin      // compact procedural code using a Verilog for-loop

         anode[i] = ( slice == i ) ;   // same as ( slice == i ) ? 1'b1 : 1'b0 ;

      end  // for
   end  // always


   /*

   assign anode[0] = ( slice == 0 ) ? 1'b1 : 1'b0 ;      // alternatively, use concurrent conditional assignments on wires
   assign anode[1] = ( slice == 1 ) ? 1'b1 : 1'b0 ;
   assign anode[2] = ( slice == 2 ) ? 1'b1 : 1'b0 ;
   assign anode[3] = ( slice == 3 ) ? 1'b1 : 1'b0 ;

   */

endmodule
