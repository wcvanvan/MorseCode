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


module buzzer(input clk,
              input rst,
              input [8:0] switches,
              input[143:0] code,
              input speed_adjust,
              output beep,
              input sound_begin);
    // reg[143:0] code       = 144'b0000_11011010101101_0000_10110101011011_0000_11011010101101_0000_10110101011011_0000_11011010101101_0000_10110101011011_0000_11011010101101_0000_10110101011011;
    reg clk_div              = 0;
    assign beep              = clk_div & beep_en;
    parameter period_clk_div = 30000;
    reg [7:0] bit_counter    = 0;
    reg [25:0] cnt_clk_div   = 0;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            cnt_clk_div <= 0;
        end
        else begin
            if (cnt_clk_div == (period_clk_div >> 1) -1) begin
                clk_div     <= ~clk_div;
                cnt_clk_div <= 0;
            end
            else begin
                cnt_clk_div <= cnt_clk_div + 1;
            end
        end
    end
    
    reg[26:0] cnt_clk_code    = 0;
    reg[26:0] period_clk_code = 1_0000_0000;
    always @(*) begin
        if (speed_adjust == 1'b1) begin
            period_clk_code <= 1_0000_0000;
        end
        else begin
            period_clk_code <= 3_0000_0000;
        end
    end
    reg clk_code = 0;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            cnt_clk_code <= 0;
        end
        else begin
            if (cnt_clk_code == (period_clk_code >> 1) -1) begin
                clk_code     <= ~clk_code;
                cnt_clk_code <= 0;
            end
            else begin
                cnt_clk_code <= cnt_clk_code + 1;
            end
        end
    end
    
    reg all_read   = 0;
    assign beep_en = code[143 - bit_counter];
    
    always @(posedge clk_code or posedge rst) begin
        if (rst || ~sound_begin) begin
            bit_counter <= 0;
            all_read <= 0;
        end
        else if (all_read == 0) begin
            if (switches[(bit_counter+1)/18] == 0 && switches[8] == 0) begin
                bit_counter <= bit_counter + 19;
                end
            else begin
                bit_counter <= bit_counter + 1;
            end
            if (bit_counter > 143) begin
                all_read    <= 1;
                bit_counter <= 0;
            end
        end
    end
            
            endmodule
