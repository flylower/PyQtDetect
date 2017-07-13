`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/04 18:00:55
// Design Name: 
// Module Name: edgedetect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module edgedetect(
    input  inpsig,
    input  clk_in,
	output sig_falling,
	output sig_rising
    );
	
	reg inpsig_buf;
	reg inpsig_pre_buf;
	
	always@(posedge clk_in)
	begin
		inpsig_buf <= inpsig;
		inpsig_pre_buf <= inpsig_buf;
	end 

	assign sig_falling = inpsig_pre_buf && ~inpsig_buf;
	assign sig_rising  = ~inpsig_pre_buf && inpsig_buf;
	
endmodule
