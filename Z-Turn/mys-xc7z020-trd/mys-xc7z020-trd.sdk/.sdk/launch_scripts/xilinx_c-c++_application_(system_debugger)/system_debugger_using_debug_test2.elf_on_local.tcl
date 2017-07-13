connect -url tcp:127.0.0.1:3121
source C:/Users/dell/Desktop/mys-xc7z020-trd.xpr/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649" && level==0} -index 1
fpga -file C:/Users/dell/Desktop/mys-xc7z020-trd.xpr/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_0/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
loadhw C:/Users/dell/Desktop/mys-xc7z020-trd.xpr/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_0/system.hdf
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
ps7_init
ps7_post_config
bpadd -addr &main
