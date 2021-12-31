`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/29 17:25:19
// Design Name: 
// Module Name: flash_led_top
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


module decoder_top(
        input clk,
 	 	input rst,
 	 	input dot,dash,confirm,back,
 	 	output [9:0]led,
 	 	output [7:0]seg_out,
 	 	output [7:0]seg_en
 	 	);
 	 	
 	 	wire clk_bps;
 	 	wire clk_bps2;
 	 	reg[9:0]temp;
 	 	
 	 	counter counter(
 	 		.clk( clk ),
 	 		.rst( rst ),
 	 		.clk_bps( clk_bps ),
 	 		.clk_bps2(clk_bps2)
 	 	);
 	 	ctl ctl(
 	 		.clk( clk ),
 	 		.rst( rst ),
 	 		.clk_bps( clk_bps ),
 	 		.clk_bps2( clk_bps2 ),
 	 		.dot(dot),
 	 		.dash(dash),
 	 		.confirm(confirm),
 	 		.back(back),
 	 		.led( led ),
 	 		.seg_en( seg_en ),
 	 		.seg_out( seg_out )
 	 	);
endmodule
