
## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]

## **EXERCISE: what happens with 1 GHz clock ?
#create_clock -period 1.000 -name clk100 -waveform {0.000 0.500} -add [get_ports clk]

## assume 100ps clock uncertainty for both setup/hold checks
set_clock_uncertainty 0.100 [all_clocks]

#set_clock_uncertainty -setup 0.100 [all_clocks]
#set_clock_uncertainty -hold  0.075 [all_clocks]

## **IMPORTANT: use a false_path in case of **ASYNCHRONOUS RESET**
#set_false_path -to [get_ports rst]

## constrain the in2reg timing paths (assume approx. 70% clock period)
#set_output_delay -clock clk100 7.000 [all_inputs]

## constrain the reg2out timing paths (assume approx. 30% clock period)
#set_output_delay -clock clk100 3.000 [all_outputs]

set_false_path -to [all_outputs]
