connect -url tcp:127.0.0.1:3121
source E:/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_1/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649" && level==0} -index 1
fpga -file E:/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_1/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
loadhw E:/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_1/system.hdf
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
dow E:/mys-xc7z020-trd/mys-xc7z020-trd.sdk/lwIP_test/Debug/lwIP_test.elf
bpadd -addr &main
