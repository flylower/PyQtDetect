connect -url tcp:127.0.0.1:3121
source D:/z-turn_lwip_test_sucessful/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_1/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
loadhw D:/z-turn_lwip_test_sucessful/mys-xc7z020-trd/mys-xc7z020-trd.sdk/design_1_wrapper_hw_platform_1/system.hdf
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS2 210249A06649"} -index 0
dow D:/z-turn_lwip_test_sucessful/mys-xc7z020-trd/mys-xc7z020-trd.sdk/test_print1_prj/Debug/test_print1_prj.elf
bpadd -addr &main
