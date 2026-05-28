//
// Code derived and re-adapted from:
// https://digilent.com/reference/programmable-logic/arty-a7/demos/xadc
//
// Luca Pacher - pacher@to.infn.it
// Spring 2025
//

module xadc_simple (

   input  wire clk,
   // **EXERCISE; add a reset signal for both PLL and XADC cores
   //input wire rst,

   // **ANALOG** input voltages
   input wire Vin_p,
   input wire Vin_n,

   // map 3 MSBs of the ADC code to general-purpose LEDs on the board
   output wire [7:0] LED,

   // **DEBUG: probe ADC SoC/EoC flags with oscilloscope
   output wire AdcSoC,
   output wire AdcEoC

   ) ;


   ///////////////////////////////////////
   //   PLL IP core (Clocking Wizard)   //
   ///////////////////////////////////////

   wire pll_clk, pll_locked ;

   PLL  PLL_inst ( .CLK_IN(clk), .CLK_OUT(pll_clk), .LOCKED(pll_locked) ) ;


   /////////////////////////////////////////////
   //   ADC SOC generator with tick-counter   //
   /////////////////////////////////////////////

   // assert a single clock-pulse "SOC" once every 0.1 seconds
   TickCounterRst #(.MAX(10000000)) AdcSocGen (.clk(pll_clk), .rst(~pll_locked), .tick(AdcSoc)) ;


   //////////////////////
   //   XADC IP core   //
   //////////////////////

   wire [15:0] do_out ;

   xadc_wiz_0 xadc (

      .convst_in  (         AdcSoc ),     // start-of-conversion (SOC) flag to ADC
      .daddr_in   (          7'h14 ),     // address for the Dynamic Reconfiguration Port (DRP), set 7'h14 to read A0
      .dclk_in    (        pll_clk ),     // on-board 100 MHz system clock fed to DRP
      .den_in     (         AdcEoc ),     // read-enable for the DRP, connected to ADC EOC
      .di_in      (       16'h0000 ),     // optional 16-bit input-data to the DRP, not required 
      .dwe_in     (           1'b0 ),     // write-enable for the DRP, keep low (no need to write any register)
      .busy_out   (                ),     // busy signal, the ADC is converting something
      .do_out     (   do_out[15:0] ),     // ADC output data, but useful bits are only 12-bits do_out[15:4]
      .drdy_out   (                ),     // do_out[15:0] bits are ready
      .eoc_out    (         AdcEoc ),     // end-of-conversion (EOC) flag, use it as read-enable for DRP
      .eos_out    (                ),     // end-of-sequence (EOS) flag, keep unconnected
      .alarm_out  (                ),     // OR between all alarms, not used
      .vp_in      (           1'b0 ),     // on-board V+ analog input, can't stay unconnected (DRC)
      .vn_in      (           1'b0 ),     // on-board V- analog input, can't stay unconnected (DRC)
      .vauxp4     (          Vin_p ),     // then connected to pin A0 on the board, 0-3.3V max. (on-board voltage-divider)
      .vauxn4     (          Vin_n )      // then connected to ground on the board (single-ended input voltage)

   ) ;


   wire adc_data[11:0] <= do_out[15:4] ;  // only 12-bits do_out[15:4] are meaningful


   ////////////////////////////////////////
   //   LED binary/thermometer decoder   //
   ////////////////////////////////////////

   always @(posedge pll_clk) begin

      case( adc_data[11:9] )

         3'b000 : LED = 8'b00000001 ;
         3'b001 : LED = 8'b00000011 ;
         3'b010 : LED = 8'b00000111 ;
         3'b011 : LED = 8'b00001111 ;
         3'b100 : LED = 8'b00011111 ;
         3'b101 : LED = 8'b00111111 ;
         3'b110 : LED = 8'b01111111 ;
         3'b111 : LED - 8'b11111111 ;

      endcase
   end   //always

endmodule

