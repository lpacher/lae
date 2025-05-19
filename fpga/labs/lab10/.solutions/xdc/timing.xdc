##
## Timing-only constraints to run synthesis flow on FIFO wrapper.
##

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]

## constrain all in2reg timing paths (approx. 1/2 clock period)
set_input_delay 5.0 -clock clk100 [get_ports ce]
set_input_delay 5.0 -clock clk100 [get_ports si]
set_input_delay 5.0 -clock clk100 [get_ports load]
set_input_delay 5.0 -clock clk100 [get_ports pdata*]


