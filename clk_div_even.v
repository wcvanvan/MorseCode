`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/01/2021 10:51:08 AM
// Design Name:
// Module Name: clk_div_even
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

module clk_div_even #(parameter period = 1,
                      cnt_width = 1)
                     (input clk,
                      output reg clk_out);
    reg [cnt_width-1:0] cnt;
    // initial begin
    //     clk_out = 0;
    //     cnt     = 0;
    // end
    always@(clk) begin
        if (cnt == period) begin
            clk_out <= ~clk_out;
            cnt     <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
endmodule
