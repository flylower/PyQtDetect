setws .
# 创建hardware 
createhw -name hw0 -hwspec ../pyqtdetect_wrapper.hdf
# 新建FSBL
createapp -name fsbl -app {Zynq FSBL} -proc ps7_cortexa9_0 -hwproject hw0 -os standalone
# 添加Debug macros
configapp -app fsbl define-compiler-symbols FSBL_DEBUG_DETAILED
# 启用FatFs库
setlib -bsp fsbl_bsp -lib lwip202
# update
updatemss -mss fsbl_bsp/system.mss
# 重编译bsp
regenbsp -bsp fsbl_bsp

# 新建Project
createapp -name pyqtdetect -app {lwIP Echo Server} -bsp fsbl_bsp -proc ps7_cortexa9_0 -hwproject hw0 -os standalone
# 设置uart
#configbsp -bsp wavdatatran_bsp stdin ps_uart_1
#configbsp -bsp wavdatatran_bsp stdout ps_uart_1
#  
# configapp -app pyqtdetect -add compiler-misc {-std=c99}

file delete pyqtdetect/src/main.c
file delete pyqtdetect/src/echo.c
# file delete fsbl_bsp/ps7_cortexa9_0/libsrc/lwip202_v1_2/src/contrib/ports/xilinx/netif/xemacpsif_physpeed.c
file copy -force ../source/sdk/main.c pyqtdetect/src/
file copy -force ../source/sdk/echo.c pyqtdetect/src/

# file copy -force ../source/sdk/xemacpsif_physpeed.c fsbl_bsp/ps7_cortexa9_0/libsrc/lwip202_v1_2/src/contrib/ports/xilinx/netif/
#sdk setws -switch $ :: env(TEMP)
#exec $eclipse -vm $vm -nosplash                                    \
#    -application org.eclipse.cdt.managedbuilder.core.headlessbuild \
#    -import "file://$apppath" -data $wspath
#	
#sdk setws -switch $ :: env(TEMP)

# projects -clean
projects -build


# exec bootgen -arch zynq -image output.bif -w -o BOOT.bin
# exec program_flash -f /tmp/wrk/BOOT.bin -flash_type qspi_single -blank_check -verify -cable type xilinx_tcf url tcp:localhost:3121