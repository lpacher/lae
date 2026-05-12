//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Try yourself to implement a 2-bit to 4-bit binary/one-hot decoder
// to drive 7-segment display module anodes.
//
// The functionality that you are requested to implement is the following:
//
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`timescale 1ns / 100ps

module OneHotAnodeDecoder (

   input  wire [1:0] slice,
   output reg  [3:0] anode        // 4-bit bus driven inside 'always' block
   //output wire  [3:0] anode     // 4-bit bus driven by continuous 'assign' statements 

   ) ;


   /*


   ...
   ...
   ...


   */

endmodule
