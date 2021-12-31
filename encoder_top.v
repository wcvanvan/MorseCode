`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//Company:
//Engineer:

// Create Date: 2021/12/12 21:35:49
// Design Name:
// Module Name: topotp
// Project Name:
// Target Devices:
// Tool Versions:
// Description:

// Dependencies:

// Revision:
// Revision 0.01 - File Created
// Additional Comments:

////////////////////////////////////////////////////////////////////////////////


module encoder_top(input clk,
                   input rst,
                   input [3:0] row,       // ???????? ??
                   output [3:0] col,
                   output [7:0] seg_en,
                   output beep,
                   output [7:0] seg_out,
                   output [2:0] count_led,
                   input [8:0] switches,
                   input speed_adjust,
                   input sound_begin);
    
    wire clk_bps;  // 控制按钮
    wire clk_bps2; // 控制scan_cnt
    counter counter(
    .clk(clk),
    .rst(rst),
    .clk_bps(clk_bps),
    .clk_bps2(clk_bps2)
    );
    
    key_top key_top(
    .clk(clk),
    .clk_bps(clk_bps),
    .clk_bps2(clk_bps2),
    .rst(rst),
    .beep(beep),
    .switches(switches),
    .speed_adjust(speed_adjust),
    .sound_begin(sound_begin),
    .row(row),                 // ???????? ??
    .col(col),
    .seg_en(seg_en),
    .seg_out(seg_out)
    );
    
endmodule
