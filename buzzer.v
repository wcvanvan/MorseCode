`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/04 18:52:01
// Design Name:
// Module Name: buzzer
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


module buzzer(input [139:0] code,     // 14 * 8 + 7 * 4
              input clk,
              input rst_n,
              output reg clk_buzzer);
reg [7:0] switches;
reg [7:0] bit_counter = 0;

reg [24:0] cnt;
wire clk_0.6s;

always @ (posedge clk or rst_n)
    if (rst_n)
        cnt <= 0;
    else
        cnt <= cnt + 1'b1;

assign clk_0.6s = cnt[24];

always @(clk_0.6s or rst_n) begin
    if (rst_n) begin
        bit_counter <= 0;
    end
    else
        if (bit_counter == 0 or bit_counter == 18 or bit_counter == 36 || bit_counter == 54 || bit_counter == 72 || bit_counter == 90 || bit_counter == 108 || bit_counter == 126) begin
            if (switches[bit_counter/14] == 0) begin
                bit_counter <= bit_counter + 14;
            end
        end
        clk_buzzer  <= code[bit_counter] & clk_0.6s;
        bit_counter <= bit_counter + 1;
end
endmodule
