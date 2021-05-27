//
// Verilog Wrapper for the XADC IP core configured in trigger-mode to read the on-die temperature sensor.
// Simply instantiate the XADC IP compiled from
//
// IP Catalog => FPGA Features and Design => XADC => XADC Wizard
//
// and configured as follows:
//
// Basic TAB:           DRP, Event Mode, Single Channel, disable reset_in pin
// ADC Setup TAB:       Seqencer Mode: Off; Channel Averaging: None; disable all remaining options
// Alarms TAB:          turn off all alarms
// Single Channel TAB:  Selected Channel: TEMPERATURE
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module XADC (

   input  wire AdcClk,              // on-board 100 MHz system clock
   input  wire AdcSoc,              // start-of-conversion (SOC), single clock-pulse
   output wire AdcEoc,              // end-of-conversion (EOC)
   output wire [11:0] AdcData       // 12-bit ADC output code

   ) ;



   //////////////////////
   //   XADC IP core   //
   //////////////////////

   wire [15:0] do_out ;

   xadc_wiz_0 xadc (

      .convst_in             (         AdcSoc ),     // start-of-conversion (SOC) flag to ADC
      .daddr_in              (          7'h00 ),     // address for the Dynamic Reconfiguration Port (DRP), set 7'h00 to read the on-chip temperature sensor
      .dclk_in               (         AdcClk ),     // on-board 100 MHz system clock fed to DRP
      .den_in                (         AdcEoc ),     // read-enable for the DRP, connected to ADC EOC
      .di_in                 (       16'h0000 ),     // optional 16-bit input-data to the DRP, not required 
      .dwe_in                (           1'b0 ),     // write-enable for the DRP, keep low (no need to write any register)
      .busy_out              (                ),     // busy signal, the ADC is converting something (e.g. connect to status LED on the board)
      .do_out                (   do_out[15:0] ),     // ADC output data, but useful bits are only 12-bits do_out[15:4]
      .drdy_out              (                ),     // do_out[15:0] bits are ready
      .eoc_out               (         AdcEoc ),     // end-of-conversion (EOC) flag, use it as read-enable for DRP
      .eos_out               (                ),     // end-of-sequence (EOS) flag, keep unconnected
      .alarm_out             (                ),     // OR between all alarms, not used
      .vp_in                 (           1'b0 ),     // on-board V+ analog input, can't stay unconnected (DRC)
      .vn_in                 (           1'b0 )      // on-board V- analog input, can't stay unconnected (DRC)

   ) ;


   //////////////////////////////////////////////////////
   //   register ADC output into a bank of FlipFlops   //
   //////////////////////////////////////////////////////

   reg [11:0] adc_data_reg = 12'hFFF ;

   always @(posedge AdcClk) begin

      if( AdcEoc )

         adc_data_reg[11:0] <= do_out[15:4] ;  // only 12-bits do_out[15:4] are meaningful
   end

   assign AdcData[11:0] = adc_data_reg[11:0] ;

endmodule
