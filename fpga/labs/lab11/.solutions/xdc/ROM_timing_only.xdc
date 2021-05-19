##
## Timing-only constraints to run the synthesis flow and demonstrate the effectiveness
## of the rom_style synthesis pragma for a ROM.
##

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]

## constrain all in2reg timing paths
set_input_delay -clock clk100 2.000 [concat [get_ports ren] [get_ports addr*]]

