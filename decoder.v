`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/27 18:58:10
// Design Name:
// Module Name: decoder
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


module decoder(input turn_on);
    // turn_on为1时代表此时为decoder模式，操作都应该在turn_on为1时才进行
    wire dot, dash, confirm, backspace, reset;
    // 绑定五个按钮，左dot, 右dash, 中confirm, 上backspace, 下reset
    always @(posedge dot) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge dash) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge confirm) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge backspace) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge reset) begin
        if (turn_on) begin
            
        end
    end
    
    
endmodule
