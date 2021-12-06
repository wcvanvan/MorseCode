`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/12/04 18:09:43
// Design Name:
// Module Name: keyboard_read_in
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


module keyboard_read_in(input[6:0] keyboard_input); //4 bits for row, 3 bits for column
    reg[3:0] number;
    always @(keyboard_input) begin
        case (keyboard_input)
            7'b1000100 : number = 4'b0001;
            7'b1000010 : number = 4'b0010;
            7'b1000001 : number = 4'b0011;
            7'b0100100 : number = 4'b0100;
            7'b0100010 : number = 4'b0101;
            7'b0100001 : number = 4'b0110;
            7'b0010100 : number = 4'b0111;
            7'b0010010 : number = 4'b1000;
            7'b0010001 : number = 4'b1001;
            7'b0001010 : number = 4'b0000;
            default: number     = 4'b0000;
        endcase
    end
endmodule
