// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company:
// // Engineer:
// //
// // Create Date: 2021/11/27 18:50:48
// // Design Name:
// // Module Name: converter
// // Project Name:
// // Target Devices:
// // Tool Versions:
// // Description:
// //
// // Dependencies:
// //
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// //
// //////////////////////////////////////////////////////////////////////////////////


module converter(input clk,
                 input rst,
                 output beep,
                 input [8:0] switches,
                 input speed_adjust,
                 output reg [7:0] seg_en,
                 output reg [7:0] seg_out,
                 output [2:0] count_led,
                 input sound_begin,
                 input [3:0] row,
                 output [3:0] col,
                 input mode,
                 output mode_light,
                 input dot,
                 dash,
                 confirm,
                 back,
                 output [9:0] led);
    wire [7:0] seg_en_e;
    wire [7:0] seg_en_d;
    wire [7:0] seg_out_e;
    wire [7:0] seg_out_d;
    assign mode_light = mode;
    encoder_top et(.clk(clk), .rst(rst), .row(row), .col(col),  .seg_en(seg_en_e), .seg_out(seg_out_e), .beep(beep), .switches(switches), .speed_adjust(speed_adjust), .sound_begin(sound_begin), .count_led(count_led));
    decoder_top dt(.clk(clk), .rst(rst), .dot(dot), .dash(dash), .confirm(confirm), .back(back), .led(led), .seg_out(seg_out_d), .seg_en(seg_en_d));
    always @(*) begin
        if (mode) begin
            seg_en    = seg_en_e;
            seg_out   = seg_out_e;
        end
        else begin
            seg_en    = seg_en_d;
            seg_out   = seg_out_d;
        end
    end
endmodule
