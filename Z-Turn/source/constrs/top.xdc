set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN P15} [get_ports IIC_0_sda_io]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN P16} [get_ports IIC_0_scl_io]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN B19} [get_ports UART_0_rxd]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN E17} [get_ports UART_0_txd]

#SPI
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN T11} [get_ports CS_n]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN U13} [get_ports EOC]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN J14} [get_ports DOUT]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN G15} [get_ports ADDR]
set_property -dict {IOSTANDARD  LVCMOS33 PACKAGE_PIN G20} [get_ports IOCLK]

set_property CFGBVS      VCCO     [current_design]
set_property CONFIG_VOLTAGE 3.3   [current_design]
