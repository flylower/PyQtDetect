/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xil_io.h"

int main()
{
	int a,  b;
    init_platform();
    while(1)
    	{
    	Xil_Out32(0x43C00000, 0x1);// 1 sel channel2; 2 sel channel4
    	a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    	}
    Xil_Out32(0x43C00000, 0x1);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x2);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x3);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x4);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x5);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x6);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x7);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x8);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0x9);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0xa);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0xb);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
    Xil_Out32(0x43C00000, 0xc);// 1 sel channel2; 2 sel channel4
    a = Xil_In32(0x40000000);
    xil_printf("%d\n\r", a);
	//if(a == 1024)
	xil_printf("%d\n\r", a);
    b = Xil_In32(0x43C00000);
    print("Hello World\n\r");
    while(1)
    	{
    		a = Xil_In32(0x40000000);
    		//if(a == 1024)
    		xil_printf("%d\n\r", a);
    		sleep(1);
    	}
    cleanup_platform();
    return 0;
}
