#
# Example constraints file for a 3-digit BCD to 7-segment display deaign.
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#


## push button
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports BTN]

## on-board 100 MHz clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]


## reset on BTN0
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports rst]


## count-enable on slide switch SW0
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33}  [get_ports en]



## PMOD JA header mapping

set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports segA  ]
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports segB  ]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports segC  ]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports segD  ]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports segE  ]
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports segF  ]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports segG  ]
#set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports segDP ]



## anodes on PMOD JD

set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { seg_anode[2] } ]
set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports { seg_anode[1] } ]
set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { seg_anode[0] } ]
