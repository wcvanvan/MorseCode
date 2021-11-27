`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/27 19:04:11
// Design Name:
// Module Name: encoder
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


module encoder(input turn_on);
    // turn_on为1时代表此时为encoder模式，操作都应该在turn_on为1时才进行
    wire [9:0] buttons;
    wire [8:0] switches; //最后一位用于一次全部输出，绑定到第1到第9个开关??
    wire [2:0] speed; // 控制速度，绑定到第10到第12个开关
    wire encode, backspace, reset; // 绑定：A encode, B backspace, C reset
    
    always @(posedge buttons[0]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[1]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[2]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[3]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[4]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[5]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[6]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[7]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[8]) begin
        if (turn_on) begin
            
        end
    end
    
    always @(posedge buttons[9]) begin
        if (turn_on) begin
            
        end
    end
endmodule
