`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/02 11:01:06
// Design Name: 
// Module Name: key_top
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


module key_top(
  input           clk,
  input           rst,
  input      [3:0] row,                 // ������� ��
  output reg [3:0] col,                 // ������� ��
  output     [7:0] seg_an,
//  output reg [7:0] seg_out   
output  reg [7:0] seg_out   
);
 
//++++++++++++++++++++++++++++++++++++++
// ��Ƶ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt;                         // ������
wire key_clk;
 
always @ (posedge clk or posedge rst)
  if (rst)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;
    
assign key_clk = cnt[19];                // (2^20/50M = 21)ms 
//--------------------------------------
// ��Ƶ���� ����
//--------------------------------------
 
//++++++++++++++++++++++++++++++++++++++
// ״̬������ ��ʼ
//++++++++++++++++++++++++++++++++++++++
// ״̬�����٣����������
parameter NO_KEY_PRESSED = 6'b000_001;  // û�а�������  
parameter SCAN_COL0      = 6'b000_010;  // ɨ���0�� 
parameter SCAN_COL1      = 6'b000_100;  // ɨ���1�� 
parameter SCAN_COL2      = 6'b001_000;  // ɨ���2�� 
parameter SCAN_COL3      = 6'b010_000;  // ɨ���3�� 
parameter KEY_PRESSED    = 6'b100_000;  // �а�������

reg [5:0] current_state, next_state;    // ��̬����̬
 
always @ (posedge key_clk or posedge rst)
  if (rst)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;
 
// ��������ת��״̬
always @ (*)
  case (current_state)
    NO_KEY_PRESSED :                    // û�а�������
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // ɨ���0�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // ɨ���1�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // ɨ���2��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // ɨ���3��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // �а�������
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase
 
reg       key_pressed_flag;             // ���̰��±�־
reg [3:0] col_val, row_val;             // ��ֵ����ֵ
 
// ���ݴ�̬������Ӧ�Ĵ�����ֵ
always @ (posedge key_clk or posedge rst)
  if (rst)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // û�а�������
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // ����̰��±�־
      end
      SCAN_COL0 :                       // ɨ���0��
        col <= 4'b1110;
      SCAN_COL1 :                       // ɨ���1��
        col <= 4'b1101;
      SCAN_COL2 :                       // ɨ���2��
        col <= 4'b1011;
      SCAN_COL3 :                       // ɨ���3��
        col <= 4'b0111;
      KEY_PRESSED :                     // �а�������
      begin
        col_val          <= col;        // ������ֵ
        row_val          <= row;        // ������ֵ
        key_pressed_flag <= 1;          // �ü��̰��±�־  
      end
    endcase
//--------------------------------------
// ״̬������ ����
//--------------------------------------
 
 
//++++++++++++++++++++++++++++++++++++++
// ɨ������ֵ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [3:0] keyboard_val;
always @ (posedge key_clk or posedge rst)
  if (rst)
    keyboard_val <= 4'h0;
  else
    if (key_pressed_flag)
      case ({col_val, row_val})
        8'b1110_1110 : keyboard_val <= 4'h1;
        8'b1110_1101 : keyboard_val <= 4'h4;
        8'b1110_1011 : keyboard_val <= 4'h7;
        8'b1110_0111 : keyboard_val <= 4'hE;
         
        8'b1101_1110 : keyboard_val <= 4'h2;
        8'b1101_1101 : keyboard_val <= 4'h5;
        8'b1101_1011 : keyboard_val <= 4'h8;
        8'b1101_0111 : keyboard_val <= 4'h0;
         
        8'b1011_1110 : keyboard_val <= 4'h3;
        8'b1011_1101 : keyboard_val <= 4'h6;
        8'b1011_1011 : keyboard_val <= 4'h9;
        8'b1011_0111 : keyboard_val <= 4'hF;
         
        8'b0111_1110 : keyboard_val <= 4'hA; 
        8'b0111_1101 : keyboard_val <= 4'hB;
        8'b0111_1011 : keyboard_val <= 4'hC;
        8'b0111_0111 : keyboard_val <= 4'hD;        
      endcase
//--------------------------------------
//  ɨ������ֵ���� ����
//--------------------------------------

//--------------------------------------
//  �����������ʾ
//--------------------------------------
assign seg_an = ~8'b11111111;
always @ (keyboard_val)
     begin 
     case (keyboard_val)
         4'h0: seg_out = 8'b01000000; // 0
         4'h1: seg_out = 8'b01111001; // 1
         4'h2: seg_out = 8'b00100100; // 2
         4'h3: seg_out = 8'b00110000; // 3
         4'h4: seg_out = 8'b00011001; // 4
         4'h5: seg_out = 8'b00010010; // 5
         4'h6: seg_out = 8'b00000010; // 6
         4'h7: seg_out = 8'b01111000; // 7
         4'h8: seg_out = 8'b00000000; // 8
         4'h9: seg_out = 8'b00010000; // 9
         4'ha: seg_out = 8'b00001000; // A
         4'hb: seg_out = 8'b00000011; // b
         4'hc: seg_out = 8'b01000110; // c
         4'hd: seg_out = 8'b00100001; // d
         4'he: seg_out = 8'b00000110; // E
         4'hf: seg_out = 8'b00001110; // F
         default: seg_out = 8'b0000000;
     endcase
     end    
//     vio_0 your_instance_name (
//  .clk(clk),                // input wire clk
//  .probe_out0(seg_out)  // output wire [7 : 0] probe_out0
//);
endmodule