README：
	显示模式为帧模式，一帧256点。
	在Firefly上测试存在信号延迟问题以及刷新率问题，PC上无问题。
	打开Z-Turn工程后，进入SDK后，需要用xemacpsif_physpeed.c替换掉Z-Turn\mys-xc7z020-trd\mys-xc7z020-trd.sdk\lwip_firefly_bsp\ps7_cortexa9_0\libsrc\lwip141_v1_7\src\contrib\ports\xilinx\netif\xemacpsif_physpeed.c