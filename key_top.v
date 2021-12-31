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
  input   clk,
  input clk_bps,               // 矩阵键盘 列
  input clk_bps2,               // 矩阵键盘 列
  input   rst,
  output beep,
  input [8:0] switches,
  input speed_adjust,
  output reg[3:0] col,             // 矩阵键盘 行
  input [3:0] row,    
  output reg [7:0] seg_en,
  output  reg [7:0] seg_out,
  input sound_begin
);

//++++++++++++++++++++++++++++++++++++++
// 分频部分 开始
//++++++++++++++++++++++++++++++++++++++
reg [23:0] cnt;                         // 计数子
wire key_clk;
reg[3:0] scan_cnt;
reg [10:0]count;
always @ (posedge clk or posedge rst) begin
    if (rst)
       cnt <= 0;
    else begin
       cnt <= cnt + 1'b1;
       if(clk_bps2) begin
         if (scan_cnt == count) begin
           scan_cnt <= 0;
         end
         else begin
            scan_cnt<= scan_cnt +1;           
         end
       end
    end
end
assign key_clk = cnt[23];                // (2^24/50M = 21*16)ms 

//--------------------------------------
// 分频部分 结束
//--------------------------------------
 

//++++++++++++++++++++++++++++++++++++++
// 状态机部分 开始
//++++++++++++++++++++++++++++++++++++++
// 状态数较少，独热码编码
parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
parameter SCAN_COL0      = 6'b000_010;  // 扫描第0列 
parameter SCAN_COL1      = 6'b000_100;  // 扫描第1列 
parameter SCAN_COL2      = 6'b001_000;  // 扫描第2列 
parameter SCAN_COL3      = 6'b010_000;  // 扫描第3列 
parameter KEY_PRESSED    = 6'b100_000;  // 有按键按下

reg [5:0] current_state, next_state;    // 现态、次态
 	 	
always @ (posedge key_clk or posedge rst)
  if (rst)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;
 
// 根据条件转移状态
always @ (*)
  case (current_state)
    NO_KEY_PRESSED :                    // 没有按键按下
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // 扫描第0列 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // 扫描第1列 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // 扫描第2列
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // 扫描第3列
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // 有按键按下
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase
 
reg       key_pressed_flag;             // 键盘按下标志
reg [3:0] col_val, row_val;             // 列值、行值

reg [7:0] s [7:0] ;
// 根据次态，给相应寄存器赋值
always @ (posedge key_clk or posedge rst)
  if (rst)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // 没有按键按下
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // 清键盘按下标志
      end
      SCAN_COL0 :                       // 扫描第0列
        col <= 4'b1110;
      SCAN_COL1 :                       // 扫描第1列
        col <= 4'b1101;
      SCAN_COL2 :                       // 扫描第2列
        col <= 4'b1011;
      SCAN_COL3 :                       // 扫描第3列
        col <= 4'b0111;
      KEY_PRESSED :                     // 有按键按下
      begin
        col_val          <= col;        // 锁存列值
        row_val          <= row;        // 锁存行值
        key_pressed_flag <= 1;          // 置键盘按下标志     
      end
    endcase

    always @(posedge key_pressed_flag or posedge rst) begin
      if (rst) begin
        count <= 0;
      end
      else begin
        if ({col_val, row_val} == 8'b1110_0111) begin
          if (count >= 1) begin
              count <= count - 1;
          end
        end
        else begin
          if (count <= 7) begin
              count <= count + 1;
          end
        end
    end
    end

//--------------------------------------
// 状态机部分 结束
//--------------------------------------
 
 
//++++++++++++++++++++++++++++++++++++++
// 扫描行列值部分 开始
//++++++++++++++++++++++++++++++++++++++
reg [3:0] keyboard_val;
always @ (posedge clk_bps2 or posedge rst) begin
  if (rst) begin
    s[0] <= 5'h10;
    s[1] <= 5'h10;
    s[2] <= 5'h10;
    s[3] <= 5'h10;
    s[4] <= 5'h10;
    s[5] <= 5'h10;
    s[6] <= 5'h10;
    s[7] <= 5'h10;
  end
  else begin  
      if (key_pressed_flag) begin
            case ({col_val, row_val})
                8'b1110_1110 : s[count-1] <= 4'h1;
                8'b1110_1101 : s[count-1] <= 4'h4;
                8'b1110_1011 : s[count-1] <= 4'h7;
                8'b1110_0111 : begin end
                 
                8'b1101_1110 : s[count-1] <= 4'h2;
                8'b1101_1101 : s[count-1] <= 4'h5;
                8'b1101_1011 : s[count-1] <= 4'h8;
                8'b1101_0111 : s[count-1] <= 4'h0;
                 
                8'b1011_1110 : s[count-1] <= 4'h3;
                8'b1011_1101 : s[count-1] <= 4'h6;
                8'b1011_1011 : s[count-1] <= 4'h9;
                default: s[count-1] <= 5'h10;
              endcase
    end//else
   end//if press
 end//begin

//--------------------------      ------------
//  扫描行列值部分 结束
//--------------------------      ------------

//--------------------------      ------------
//  数码管译码显示
//--------------------------      ------------


  //使能信号seg_en ,时间闪烁 scan_cn      t
always @(*) begin
       case(scan_cnt)
             3'b001:    begin  seg_en = 8'b0111_1111;   keyboard_val = s[0];   
             case (keyboard_val)
                4'h0:seg_out = 8'b01000000; // 0
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
                
                default: seg_out = 8'b1111_1111;
            endcase   
            end
             3'b010:    begin  seg_en = 8'b1011_1111;   keyboard_val = s[1]; case (keyboard_val)
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
                     
                     default: seg_out = 8'b1111_1111;
                 endcase  end
             3:         begin  seg_en = 8'b1101_1111;   keyboard_val = s[2];  case (keyboard_val)
                          4'h0: seg_out = 8'b11000000; // 0
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
                          
                          default: seg_out = 8'b1111_1111;
                      endcase  end
             4:         begin  seg_en = 8'b1110_1111;   keyboard_val = s[3];case (keyboard_val)
                               4'h0: seg_out = 8'b11000000; // 0
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
                               
                               default: seg_out = 8'b1111_1111;
                           endcase  end
             5:         begin  seg_en = 8'b1111_0111;   keyboard_val = s[4];   case (keyboard_val)
                    4'h0: seg_out = 8'b11000000; // 0
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
                    
                    default: seg_out = 8'b1111_1111;
                endcase end
             6:         begin  seg_en = 8'b1111_1011;   keyboard_val = s[5];   
             case (keyboard_val)
                  4'h0: seg_out = 8'b11000000; // 0
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
                  default: seg_out = 8'b1111_1111;
                                             endcase
              end
             7:    begin  seg_en = 8'b1111_1101;   keyboard_val = s[6]; case (keyboard_val)
                4'h0: seg_out = 8'b11000000; // 0
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
                default: seg_out = 8'b1111_1111;
              endcase   end
             8:   begin  
                seg_en = 8'b1111_1110;   
                keyboard_val = s[7]; 
                case (keyboard_val)
                   4'h0: seg_out = 8'b11000000; // 0
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
                   
                   default: seg_out = 8'b1111_1111;
                 endcase  
                end
             default:   begin  seg_en = 8'b1111_1111; seg_out = 8'b1111_1111; end
        endcase
end

    encode e(clk, rst, s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7], beep, switches, speed_adjust, sound_begin);
endmodule
