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
              output reg clk_buzzer);
// initial begin
//     clk2 = 1'b0;
// end
wire clk_out;
reg [7:0] switches;
clk_div_even #(50000000, 26) clk_divider(.clk(clk), .clk_out(clk_2hz));
// 5 * 10^7 in binary:10111110101111000010000000 (26bits)
reg [7:0] bit_counter = 0;
always @(clk_2hz) begin
    if (bit_counter%14 == 0) begin
        if (switches[bit_counter/14] == 0) begin
            bit_counter <= bit_counter + 14;
        end
    end
    clk_buzzer  <= code[bit_counter] & clk_2hz;
    bit_counter <= bit_counter + 1;
    // $display("clk2hz: %d, bit_counter: %d, code: %d, clk2: %d",clk_2hz, bit_counter, code[bit_counter], clk2);
end
endmodule
