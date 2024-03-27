//
// Example Verilog testbench for the Inverter module.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps   // specify time-unit and time-precision, this is only for simulation purposes


// **TEST: if you set a smaller time-precision e.g. 10ps the simulation time increases
//`timescale 1ns / 10ps

module tb_Inverter ;   // empty port declaration for a testbench

   reg in ;      // **IMPORTANT: note that this is declared as 'reg' net type
   wire out ;

   // instantiate the device under test (DUT)
   //Inverter DUT (in, out) ;                       // by-position port mapping (aka "ordered" port connections)
   Inverter DUT ( .X(in), .ZN(out) ) ;              // by-name port mapping (aka "named" port connection)

   // main stimulus
   initial begin
   
      #500 in = 1'b0 ;   // **QUESTION: what happens to 'in' before 500ns ?
      #200 in = 1'b1 ;
      #750 in = 1'b0 ;

      #500 $finish ;     // stop the simulation (this is a Verilog "task")
   end


   /*   **EXTRA: instantiate and simulate a 3-state buffer

   reg enable = 1'b0 ;    // output-enable
   wire triOut ;

   BufferTri  DUT_2 ( .X(out), .OE(enable), .ZT(triOut) ) ;

   // **IMPORTANT: this initial block runs IN PARALLEL with the previous block  => HDL coding is intrinsically PARALLEL PROGRAMMING
   initial begin
      #750  enable = 1'b1 ;
      #1200 enable = 1'b0 ;
   end

   */

endmodule
