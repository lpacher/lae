##
## Timing-only constraints to run synthesis flow on UART FSM.
##

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports Clock]

## constrain all in2reg timing paths
set_input_delay -clock clk100 2.000 [concat [get_ports tx_data*] [get_ports tx_start] [get_ports tx_en] [get_ports rst] ]


