`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/27 18:50:48
// Design Name:
// Module Name: converter
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


module converter(input mode,
                 input clk);
    top decoder(.clk(clk), .mode(mode))
    keyboard kb(.clk(clk), .mode(mode));
endmodule
