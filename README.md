显示模式为帧模式，一帧256点。 在Firefly上测试存在信号延迟问题以及刷新率问题，PC上无问题。 
##### 1.Add Z-turn Board Eth Phy KSZ9031 Support Method: 
1. 	cd ./sdk/fsbl_bsp/ps7_cortexa9_0/libsrc/lwip202_v1_0/src/contrib/ports/xilinx/netif/xemacpsif_physpeed.c
1. 	make to patch xemacpsif_physpeed.c.patch.lwip202_v1.0, Suggestted patch SDK Root Path\SDK_Ver\data\embeddedsw\ThirdParty\sw_services\lwip{ver}_v{major}_{minjor}\src\contrib\ports\xilinx\netif

##### 2.Some Eth-Phy Methods:
###### 	1). AR8035 Atheros:
	

```
static u32_t get_Marvell_phy_speed(XEmacPs *xemacpsp, u32_t phy_addr)
{
	u16_t temp;
	u16_t control;
	u16_t status;
	u16_t status_speed;
	u32_t timeout_counter = 0;
	u32_t temp_speed;

	xil_printf("Start PHY autonegotiation \r\n");

	//ÔÚAD8035 PHYÖÐÆôÓÃRGMII TXÊ±ÖÓÑÓ³Ù
	XEmacPs_PhyWrite£¨xemacpsp£¬phy_addr£¬0x1D£¬0x05£©;
	XEmacPs_PhyWrite£¨xemacpsp£¬phy_addr£¬0x1E£¬0x0100£©;
	//ÔÚAD8035 PHYÖÐÆôÓÃRGMII RXÊ±ÖÓÑÓ³Ù
	XEmacPs_PhyWrite£¨xemacpsp£¬phy_addr£¬0x1D£¬0x0£©;
	XEmacPs_PhyWrite£¨xemacpsp£¬phy_addr£¬0x1E£¬0x8000£©;

	XEmacPs_PhyWrite(xemacpsp,phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 2);
	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_CONTROL_REG_MAC, &control);
	control |= IEEE_RGMII_TXRX_CLOCK_DELAYED_MASK;
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_CONTROL_REG_MAC, control);

	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);

	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, &control);
	control |= IEEE_ASYMMETRIC_PAUSE_MASK;
	control |= IEEE_PAUSE_MASK;
	control |= ADVERTISE_100;
	control |= ADVERTISE_10;
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, control);

	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
					&control);
	control |= ADVERTISE_1000;
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
					control);

	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);
	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																&control);
	control |= (7 << 12);	/* max number of gigabit attempts */
	control |= (1 << 11);	/* enable downshift */
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																control);
	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_AUTONEGOTIATE_ENABLE;
	control |= IEEE_STAT_AUTONEGOTIATE_RESTART;
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_RESET_MASK;
	XEmacPs_PhyWrite(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	while (1) {
		XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
		if (control & IEEE_CTRL_RESET_MASK)
			continue;
		else
			break;
	}

	XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_STATUS_REG_OFFSET, &status);

	xil_printf("Waiting for PHY to complete autonegotiation.\r\n");

	while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
		sleep(1);
		XEmacPs_PhyRead(xemacpsp, phy_addr,
						IEEE_COPPER_SPECIFIC_STATUS_REG_2,  &temp);
		timeout_counter++;

		if (timeout_counter == 30) {
			xil_printf("Auto negotiation error \r\n");
			return XST_FAILURE;
		}
		XEmacPs_PhyRead(xemacpsp, phy_addr, IEEE_STATUS_REG_OFFSET, &status);
	}
	xil_printf("autonegotiation complete \r\n");

	XEmacPs_PhyRead(xemacpsp, phy_addr,IEEE_SPECIFIC_STATUS_REG,
					&status_speed);
	if (status_speed & 0x400) {
		temp_speed = status_speed & IEEE_SPEED_MASK;

		if (temp_speed == IEEE_SPEED_1000)
			return 1000;
		else if(temp_speed == IEEE_SPEED_100)
			return 100;
		else
			return 10;
	}

	return XST_SUCCESS;
}
```

	