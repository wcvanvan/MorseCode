`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/08/29 17:23:43
// Design Name:
// Module Name: flash_led_ctl
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


module ctl(input clk,
           input rst,
           input clk_bps, // 控制按钮
           input clk_bps2, // 控制scan_cnt
           input dot,
           dash,
           confirm,
           back,
           output reg[12:0]led,       //led�???????
           output reg[7:0]seg_out,
           output reg[7:0]seg_en);
          //  output reg[3:0]count);
    //  output reg [7:0]count_led);
    
    wire [9:0] temp;
    parameter a0 = 8'b0100_0000;  // 0
    parameter a1 = 8'b0111_1001;  // 1
    parameter a2 = 8'b0010_0100;  // 2
    parameter a3 = 8'b0011_0000;  // 3
    parameter a4 = 8'b0001_1001;  // 4
    parameter a5 = 8'b0001_0010;  // 5
    parameter a6 = 8'b0000_0010;  // 6
    parameter a7 = 8'b0111_1000;  // 7
    parameter a8 = 8'b0000_0000;  // 8
    parameter a9 = 8'b0001_0000;  // 9
    parameter a  = 8'b0000_1000;  // A
    parameter b  = 8'b0000_0011;  // b
    parameter c  = 8'b0100_0110;  // c
    parameter d  = 8'b0010_0001;  // d
    parameter e  = 8'b0000_0110;  // E
    parameter f  = 8'b0100_1110;  // F
    parameter g  = 8'b0100_0010;//G
    parameter h  = 8'b0000_1001;//H
    parameter ci = 8'b0111_0000;//I
    parameter j  = 8'b0111_0001;//J
    parameter k  = 8'b0000_1010;//K
    parameter l  = 8'b0100_0111;//L
    parameter m  = 8'b0100_1000;//M
    parameter n  = 8'b0010_1011;//N
    parameter o  = 8'b0010_0011;//O
    parameter p  = 8'b0000_1100;//P
    parameter q  = 8'b0001_1000;//Q
    parameter r  = 8'b0100_1110;//R
    parameter s  = 8'b1011_0110;//S
    parameter t  = 8'b0000_0111;//T
    parameter u  = 8'b0100_0001;//U
    parameter v  = 8'b0110_0011;//V
    parameter w  = 8'b0000_0001;//W
    parameter x  = 8'b0001_1011;//X
    parameter y  = 8'b0001_0001;//Y
    parameter z  = 8'b0010_0101;//Z

    reg[3:0] scan_cnt;//高频刷新七段数码管计数器
    
    
    reg [2:0]s7_len;//右下角缓存区长度，实时输�??
    reg [2:0]s7_out_len;
    reg [6:0]s7_out_val;//等于s7_val(位数不同无所谓，有点难改就不改了)，确定输�??
    reg [4:0]s7_val;//s7_val 是输入具体长短键(�???????多五�???????),是存储具�???????1/0信息的变量，�??????? ·-A ，s7_val = 5'b000_10 ;  S ···  s7_val = 5'b00_000;
    reg [3:0] count = 1;//七段数码管显示多少位解码
    reg submit;//是否confirm成功
    reg wrong_input = 0;

    //     //debug
    // always @(count) begin
    //   led[10] = count[0];
    //   led[11] = count[1];
    //   led[12] = count[2];
    // end
    
    /*
     s1-s8分别代表数码管每�???????位的seg_out
     */
    reg [7:0]s1 = ~8'b0000_0000;
    reg [7:0]s2 = ~8'b0000_0000;
    reg [7:0]s3 = ~8'b0000_0000;
    reg [7:0]s4 = ~8'b0000_0000;
    reg [7:0]s5 = ~8'b0000_0000;
    reg [7:0]s6 = ~8'b0000_0000;
    reg [7:0]s7 = ~8'b0000_0000;
    reg [7:0]s8 = ~8'b0000_0000;
    
    //++++++++++++++++++++++++++++++++++++++
    // 计数部分�???????�???????  用于数码管显�??????? drive scan_cnt
    //++++++++++++++++++++++++++++++++++++++
    // wc修改 scan_cnt判断条件
    //debug
    always@(posedge clk or posedge rst)begin
            if (rst)
                scan_cnt <= 0;
            else
                if (clk_bps2) begin
                  if (scan_cnt == 8) begin
                      scan_cnt <= 0;
                  end
                  else begin
                      scan_cnt <= scan_cnt + 1;
                  end
                end
            end//always
    //         //--------------------------------------
    //         // 计数部分 结束
    //         //--------------------------------------

    always @(*) begin
      case(scan_cnt)
        1: begin 
          seg_en <= ~8'b1000_0000;
          seg_out <= s1;
        end
        2: begin 
          seg_en <= ~8'b0100_0000;
          seg_out <= s2;
        end
        3: begin 
          seg_en <= ~8'b0010_0000;
          seg_out <= s3;
        end
        4: begin 
          seg_en <= ~8'b0001_0000;
          seg_out <= s4;
        end
        5: begin 
          seg_en <= ~8'b0000_1000;
          seg_out <= s5;
        end
        6: begin 
          seg_en <= ~8'b0000_0100;
          seg_out <= s6;
        end
        7: begin 
          seg_en <= ~8'b0000_0010;
          seg_out <= s7;
        end
        8: begin
          seg_en <= ~8'b0000_0001;
          seg_out <= s8;
        end
        default: begin
          seg_en <= ~80000_0000;
          seg_out <= ~8'b0000_0000;
        end
      endcase
    end        
        
        
        //++++++++++++++++++++++++++++++++++++++
        // 按键部分 �???????�???????
        //++++++++++++++++++++++++++++++++++++++

  parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
  parameter DOT_PRESSED     = 6'b000_010;  // 扫描第0列 
  parameter DASH_PRESSED      = 6'b000_100;  // 扫描第1列 
  parameter BACK_PRESSED      = 6'b001_000;  // 扫描第2列   
  parameter CONFIRM_PRESSED    = 6'b100_000;  // 有按键按下
  reg confirm_pressed_flag = 0;

  reg [5:0] current_state, next_state;    // 现态、次态
 	 	
  always @ (posedge clk_bps or posedge rst) begin
    if (rst)
      current_state <= NO_KEY_PRESSED;
    else
      current_state <= next_state;
  end  

  always @(*) begin
    case(current_state) 
      NO_KEY_PRESSED: begin
        if (confirm) begin
          next_state <= CONFIRM_PRESSED;
        end
        else if (dot) begin
          next_state <= DOT_PRESSED;
        end
        else if (dash) begin
          next_state <= DASH_PRESSED;
        end
        else if (back) begin
          next_state <= BACK_PRESSED;
        end
        else begin
          next_state <= NO_KEY_PRESSED;
        end
      end

      DOT_PRESSED: begin
        if (confirm) begin
          next_state <= CONFIRM_PRESSED;
        end
        else if (dot) begin
          next_state <= DOT_PRESSED;
        end
        else if (dash) begin
          next_state <= DASH_PRESSED;
        end
        else if (back) begin
          next_state <= BACK_PRESSED;
        end
        else begin
          next_state <= NO_KEY_PRESSED;
        end
      end

      DASH_PRESSED: begin
        if (confirm) begin
          next_state <= CONFIRM_PRESSED;
        end
        else if (dot) begin
          next_state <= DOT_PRESSED;
        end
        else if (dash) begin
          next_state <= DASH_PRESSED;
        end
        else if (back) begin
          next_state <= BACK_PRESSED;
        end
        else begin
          next_state <= NO_KEY_PRESSED;
        end
      end

      BACK_PRESSED: begin
        if (confirm) begin
          next_state <= CONFIRM_PRESSED;
        end
        else if (dot) begin
          next_state <= DOT_PRESSED;
        end
        else if (dash) begin
          next_state <= DASH_PRESSED;
        end
        else if (back) begin
          next_state <= BACK_PRESSED;
        end
        else begin
          next_state <= NO_KEY_PRESSED;
        end
      end

      CONFIRM_PRESSED: begin 
        if (confirm) begin
          next_state <= CONFIRM_PRESSED;
        end
        else if (dot) begin
          next_state <= DOT_PRESSED;
        end
        else if (dash) begin
          next_state <= DASH_PRESSED;
        end
        else if (back) begin
          next_state <= BACK_PRESSED;
        end
        else begin
          next_state <= NO_KEY_PRESSED;
        end
      end
    endcase
  end


   always @(posedge clk_bps or posedge rst) begin
                if (rst)  begin
                    s7_val     <= 0;
                    s7_len <= 0;
                    s7_out_val <= 0;
                    s7_out_len <= 0;
                end
                else  begin
                  case (next_state)
                    NO_KEY_PRESSED : begin
                      s7_out_val <= 0;
                      s7_out_len <= 0;
                      confirm_pressed_flag <= 0;
                    end 
                    DOT_PRESSED: begin
                        s7_val[s7_len] <= 1'b0;
                        s7_len         <= s7_len+1;//缓存区数�???????+1
                        if (s7_len > 4) begin
                            s7_len <= 0;
                            s7_val <= 0;
                        end
                        confirm_pressed_flag <= 0;
                    end
                    DASH_PRESSED: begin
                        s7_val[s7_len] <= 1'b1;
                        s7_len         <= s7_len+1;
                        if (s7_len > 4) begin
                            s7_len <= 0;
                            s7_val <= 0;
                        end
                        confirm_pressed_flag <= 0;
                    end
                    BACK_PRESSED: begin
                        if (s7_len > 0) begin
                            s7_len         <= s7_len-1;//缓存�???????-1
                            s7_val[s7_len] <= 1'b0;//缓存区当前位置赋值为0
                        end
                        confirm_pressed_flag <= 0;
                    end
                    CONFIRM_PRESSED: begin
                        s7_out_val <= s7_val;//s7_out_val是判断解码是否成�???????
                        s7_out_len <= s7_len;
                        confirm_pressed_flag <= 1;          // 置键盘按下标志  
                        s7_val <= 0;//缓存区清�???????
                        s7_len     <= 0;//缓存区清�???????
                    end
                    default: begin end
                  endcase
                end
   end

    
    
    //++++++++++++++++++++++++++++++++++++++
    // 右下角缓存灯 �???????�???????  s7_len 代表缓存区数�???????
    //++++++++++++++++++++++++++++++++++++++
    
    always @(*) begin
        case(s7_len)
            1:led[2:0]        <= 3'b001;
            2:led[2:0]        <= 3'b010;
            3:led[2:0]        <= 8'b011;
            4:led[2:0]        <= 8'b100;
            5:led[2:0]        <= 8'b101;
            6:led[2:0]        <= 8'b110;
            7:led[2:0]        <= 8'b111;
            default: led[2:0] <= 8'b000;
        endcase
    end
    
    // wc修改led
    always @(*) begin
        led[7:3] <= s7_val;
    end
    
    //--------------------------------------
    // 右下角缓存灯 结束
    //--------------------------------------
    
    
    // //++++++++++++++++++++++++++++++++++++++
    // // 左下�??????? �???????�???????
    // //++++++++++++++++++++++++++++++++++++++
    // wc修改 去掉count_led
    // always @(*)
    // begin
    //     if (~mode)//�???????右边的按键，没啥用，不影�???????
    //         case(count)
    //             1:count_led        <= 8'b1;
    //             2:count_led        <= 8'b11;
    //             3:count_led        <= 8'b111;
    //             4:count_led        <= 8'b1111;
    //             5:count_led        <= 8'b1111_1;
    //             6:count_led        <= 8'b1111_11;
    //             7:count_led        <= 8'b1111_111;
    //             8:count_led        <= 8'b1111_1111;
    //             default: count_led <= 8'b0100_0010;//此处�???????后需要改�???????1111_1111
    //         endcase
    //         end//always
    //         //--------------------------------------
    //         // 左下�??????? 结束
    //         //--------------------------------------
    
    
  //++++++++++++++++++++++++++++++++++++++
// 解码判断区 开始 
//++++++++++++++++++++++++++++++++++++++
// wc修改rst
assign temp = {s7_out_len[2:0],s7_out_val[6:0]};
always @(posedge clk_bps or posedge rst) begin
          if (rst) begin
              
              led[9] <= 0;
              count     <= 1;
              led[8] <= 0;
              s1 <= ~8'b0000_0000;
              s2 <= ~8'b0000_0000;
              s3 <= ~8'b0000_0000;
              s4 <= ~8'b0000_0000;
              s5 <= ~8'b0000_0000;
              s6 <= ~8'b0000_0000;
              s7 <= ~8'b0000_0000;
              s8 <= ~8'b0000_0000;
          end
          else if (confirm_pressed_flag) begin
            case(temp)
                  10'b101_0011_111:     //0
                                begin  
                                  led[9] <= 0;
                                
                                    case(count)  
                                    /*
                                            count  <= count+1;
                                        if (count >= 9) begin led[8] <= 1 end;
                                    */
                                           1: begin s1<=8'b0100_0000;  
                                           end// 0 
                                           2: begin s2<=8'b0100_0000;  end// 0 
                                           3: begin s3<=8'b0100_0000;  end// 0 
                                           4: begin s4<=8'b0100_0000;  end// 0 
                                           5: begin s5<=8'b0100_0000;  end// 0 
                                           6: begin s6<=8'b0100_0000;  end// 0 
                                           7: begin s7<=8'b0100_0000;  end// 0 
                                           8: begin s8<=8'b0100_0000;  end// 0 
                                           default: begin
                                                
                                               end // A         
                                    endcase
                                    count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                                end
                  
                  10'b101_0011_110:    //1
                         begin  
                              led[9] <= 0;
                               case(count)  
                                     1:  begin s1<=8'b0111_1001;   end// 1 
                                     2: begin s2<=8'b0111_1001;   end// 1
                                     3: begin s3<=8'b0111_1001;   end// 1 
                                     4: begin s4<=8'b0111_1001;   end// 1 
                                     5: begin s5<=8'b0111_1001;   end// 1 
                                     6: begin s6<=8'b0111_1001;  end// 1 
                                     7: begin s7<=8'b0111_1001;   end// 1 
                                     8: begin s8<=8'b0111_1001;   end// 1 
                                  default: begin   end 
                               endcase
                               count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                        end
                       
                        
                     //2
                  10'b101_0011_100:     
                  begin 
                    led[9] <= 0;
                       case(count)  
                            1:  begin s1<=8'b0010_0100;  end// s1 <= 2 
                           2: begin s2<=8'b0010_0100;    end// s1 <= 2 
                          3: begin s3<=8'b0010_0100;     end// s1 <= 2  
                          4: begin s4<=8'b0010_0100;     end// s1 <= 2  
                          5: begin s5<=8'b0010_0100;     end// s1 <= 2 
                           6: begin s6<=8'b0010_0100;       end// s1 <= 2 
                           7: begin s7<=8'b0010_0100;        end// s1 <= 2 
                           8: begin s8<=8'b0010_0100;   end// s1 <= 2 
                       default: begin    end 
                      endcase
                      count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  //3
                  10'b101_0011_000:     
                  begin 
                    led[9] <= 0;
                          case(count)  
                               1:  begin s1<=8'b0011_0000; end// s1 <= 3 
                               2: begin s2<=8'b0011_0000;  end// s1 <= 3
                               3: begin s3<=8'b0011_0000;  end// s1 <= 3
                               4: begin s4<=8'b0011_0000;  end// s1 <= 3
                               5: begin s5<=8'b0011_0000; end// s1 <= 3
                               6: begin s6<=8'b0011_0000; end// s1 <= 3 
                               7: begin s7<=8'b0011_0000;  end// s1 <= 3
                               8: begin s8<=8'b0011_0000;  end// s1 <= 3 
                                 default: begin    end
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
               end
                  //4
                  10'b101_0010_000:   
                  begin 
                    led[9] <= 0;
                        case(count)  
                              1:  begin s1<=8'b0001_1001;   end// s1 <= 4
                              2: begin s2<=8'b0001_1001; end// s1 <= 4
                              3: begin s3<=8'b0001_1001;   end// s1 <= 4 
                              4: begin s4<=8'b0001_1001;   end// s1 <= 4
                               5: begin s5<=8'b0001_1001;  end// s1 <= 4 
                                 6: begin s6<=8'b0001_1001;  end// s1 <= 4 
                                7: begin s7<=8'b0001_1001;  end// s1 <= 4 
                                8: begin s8<=8'b0001_1001;  end// 1
                               default: begin     end// 4
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                   end
                  //5
                  10'b101_0000_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=8'b0001_0010; end// s1 <= 5 
                                       2: begin s2<=8'b0001_0010; end// s1 <= 5
                                      3: begin s3<=8'b0001_0010;  end// s1 <= 5
                                      4: begin s4<=8'b0001_0010;  end// s1 <= 5 
                                      5: begin s5<=8'b0001_0010; end// s1 <= 5 
                                       6: begin s6<=8'b0001_0010; end// s1 <= 5
                                       7: begin s7<=8'b0001_0010; end// s1 <= 5 
                                       8: begin s8<=8'b0001_0010;   end// s1 <= 5 
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //6
                  10'b101_0000_001:  
                  begin 
                 led[9] <= 0;
                     case(count)  
                          1:  begin s1<=a6; end// s1 <= 5 
                          2: begin s2<=a6; end// s1 <= 5
                          3: begin s3<=a6;  end// s1 <= 5
                          4: begin s4<=a6;  end// s1 <= 5 
                          5: begin s5<=a6; end// s1 <= 5 
                          6: begin s6<=a6; end// s1 <= 5
                          7: begin s7<=a6; end// s1 <= 5 
                          8: begin s8<=a6;   end// s1 <= 5 
                          default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                  end
                  
                  //7
                  10'b101_0000_011:  
                  begin 
                 led[9] <= 0;
                     case(count)  
                                        1:  begin s1<=a7; end// s1 <= 5 
                                       2: begin s2<=a7; end// s1 <= 5
                                      3: begin s3<=a7;  end// s1 <= 5
                                      4: begin s4<=a7;  end// s1 <= 5 
                                      5: begin s5<=a7; end// s1 <= 5 
                                       6: begin s6<=a7; end// s1 <= 5
                                       7: begin s7<=a7; end// s1 <= 5 
                                       8: begin s8<=a7;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                  end
                  //8
                  10'b101_0000_111:  
                  begin 
                 led[9] <= 0;
                     case(count)  
                                        1:  begin s1<=a8; end// s1 <= 5 
                                       2: begin s2<=a8; end// s1 <= 5
                                      3: begin s3<=a8;  end// s1 <= 5
                                      4: begin s4<=a8;  end// s1 <= 5 
                                      5: begin s5<=a8; end// s1 <= 5 
                                       6: begin s6<=a8; end// s1 <= 5
                                       7: begin s7<=a8; end// s1 <= 5 
                                       8: begin s8<=a8;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                  end
                  //9
                  10'b101_0001_111:  
                  begin 
                 led[9] <= 0;
                     case(count)  
                                        1:  begin s1<=a9; end// s1 <= 5 
                                       2: begin s2<=a9; end// s1 <= 5
                                      3: begin s3<=a9;  end// s1 <= 5
                                      4: begin s4<=a9;  end// s1 <= 5 
                                      5: begin s5<=a9; end// s1 <= 5 
                                       6: begin s6<=a9; end// s1 <= 5
                                       7: begin s7<=a9; end// s1 <= 5 
                                       8: begin s8<=a9;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                  end
                  
                  //a
                  10'b010_0000_010:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=a; end// s1 <= 5 
                                       2: begin s2<=a; end// s1 <= 5
                                      3: begin s3<=a;  end// s1 <= 5
                                      4: begin s4<=a;  end// s1 <= 5 
                                      5: begin s5<=a; end// s1 <= 5 
                                       6: begin s6<=a; end// s1 <= 5
                                       7: begin s7<=a; end// s1 <= 5 
                                       8: begin s8<=a;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //b
                  10'b100_0000_001:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=b; end// s1 <= 5 
                                       2: begin s2<=b; end// s1 <= 5
                                      3: begin s3<=b;  end// s1 <= 5
                                      4: begin s4<=b;  end// s1 <= 5 
                                      5: begin s5<=b; end// s1 <= 5 
                                       6: begin s6<=b; end// s1 <= 5
                                       7: begin s7<=b; end// s1 <= 5 
                                       8: begin s8<=b;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //c
                  10'b100_0000_101:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=c; end// s1 <= 5 
                                       2: begin s2<=c; end// s1 <= 5
                                      3: begin s3<=c;  end// s1 <= 5
                                      4: begin s4<=c;  end// s1 <= 5 
                                      5: begin s5<=c; end// s1 <= 5 
                                       6: begin s6<=c; end// s1 <= 5
                                       7: begin s7<=c; end// s1 <= 5 
                                       8: begin s8<=c;   end// s1 <= 5 
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //d
                  10'b011_0000_001:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=d; end// s1 <= 5 
                                       2: begin s2<=d; end// s1 <= 5
                                      3: begin s3<=d;  end// s1 <= 5
                                      4: begin s4<=d;  end// s1 <= 5 
                                      5: begin s5<=d; end// s1 <= 5 
                                       6: begin s6<=d; end// s1 <= 5
                                       7: begin s7<=d; end// s1 <= 5 
                                       8: begin s8<=d;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //e
                  10'b001_0000_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=e; end// s1 <= 5 
                                       2: begin s2<=e; end// s1 <= 5
                                      3: begin s3<=e;  end// s1 <= 5
                                      4: begin s4<=e;  end// s1 <= 5 
                                      5: begin s5<=e; end// s1 <= 5 
                                       6: begin s6<=e; end// s1 <= 5
                                       7: begin s7<=e; end// s1 <= 5 
                                       8: begin s8<=e;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //f
                  10'b100_0000_100:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=f; end// s1 <= 5 
                                       2: begin s2<=f; end// s1 <= 5
                                      3: begin s3<=f;  end// s1 <= 5
                                      4: begin s4<=f;  end// s1 <= 5 
                                      5: begin s5<=f; end// s1 <= 5 
                                       6: begin s6<=f; end// s1 <= 5
                                       7: begin s7<=f; end// s1 <= 5 
                                       8: begin s8<=f;   end// s1 <= 5 
                                      9: begin   end// 0 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //g
                  10'b011_0000_011:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=g; end// s1 <= 5 
                                       2: begin s2<=g; end// s1 <= 5
                                      3: begin s3<=g;  end// s1 <= 5
                                      4: begin s4<=g;  end// s1 <= 5 
                                      5: begin s5<=g; end// s1 <= 5 
                                       6: begin s6<=g; end// s1 <= 5
                                       7: begin s7<=g; end// s1 <= 5 
                                       8: begin s8<=g;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 0;
                                  end  
                    end
                  
                  //h
                  10'b100_0000_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=h; end// s1 <= 5 
                                       2: begin s2<=h; end// s1 <= 5
                                      3: begin s3<=h;  end// s1 <= 5
                                      4: begin s4<=h;  end// s1 <= 5 
                                      5: begin s5<=h; end// s1 <= 5 
                                       6: begin s6<=h; end// s1 <= 5
                                       7: begin s7<=h; end// s1 <= 5 
                                       8: begin s8<=h;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //ci
                  10'b010_0000_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=ci; end// s1 <= 5 
                                       2: begin s2<=ci; end// s1 <= 5
                                      3: begin s3<=ci;  end// s1 <= 5
                                      4: begin s4<=ci;  end// s1 <= 5 
                                      5: begin s5<=ci; end// s1 <= 5 
                                       6: begin s6<=ci; end// s1 <= 5
                                       7: begin s7<=ci; end// s1 <= 5 
                                       8: begin s8<=ci;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //j
                  10'b100_0001_110:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=j; end// s1 <= 5 
                                       2: begin s2<=j; end// s1 <= 5
                                      3: begin s3<=j;  end// s1 <= 5
                                      4: begin s4<=j;  end// s1 <= 5 
                                      5: begin s5<=j; end// s1 <= 5 
                                       6: begin s6<=j; end// s1 <= 5
                                       7: begin s7<=j; end// s1 <= 5 
                                       8: begin s8<=j;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //k
                  10'b011_0000_101:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=k; end// s1 <= 5 
                                       2: begin s2<=k; end// s1 <= 5
                                      3: begin s3<=k;  end// s1 <= 5
                                      4: begin s4<=k;  end// s1 <= 5 
                                      5: begin s5<=k; end// s1 <= 5 
                                       6: begin s6<=k; end// s1 <= 5
                                       7: begin s7<=k; end// s1 <= 5 
                                       8: begin s8<=k;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //l
                  10'b100_0000_010:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=l; end// s1 <= 5 
                                       2: begin s2<=l; end// s1 <= 5
                                      3: begin s3<=l;  end// s1 <= 5
                                      4: begin s4<=l;  end// s1 <= 5 
                                      5: begin s5<=l; end// s1 <= 5 
                                       6: begin s6<=l; end// s1 <= 5
                                       7: begin s7<=l; end// s1 <= 5 
                                       8: begin s8<=l;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //m
                  10'b010_0000_011:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=m; end// s1 <= 5 
                                       2: begin s2<=m; end// s1 <= 5
                                      3: begin s3<=m;  end// s1 <= 5
                                      4: begin s4<=m;  end// s1 <= 5 
                                      5: begin s5<=m; end// s1 <= 5 
                                       6: begin s6<=m; end// s1 <= 5
                                       7: begin s7<=m; end// s1 <= 5 
                                       8: begin s8<=m;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //n
                  10'b010_0000_001:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=n; end// s1 <= 5 
                                       2: begin s2<=n; end// s1 <= 5
                                      3: begin s3<=n;  end// s1 <= 5
                                      4: begin s4<=n;  end// s1 <= 5 
                                      5: begin s5<=n; end// s1 <= 5 
                                       6: begin s6<=n; end// s1 <= 5
                                       7: begin s7<=n; end// s1 <= 5 
                                       8: begin s8<=n;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //o
                  10'b011_0000_111:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=o; end// s1 <= 5 
                                       2: begin s2<=o; end// s1 <= 5
                                      3: begin s3<=o;  end// s1 <= 5
                                      4: begin s4<=o;  end// s1 <= 5 
                                      5: begin s5<=o; end// s1 <= 5 
                                       6: begin s6<=o; end// s1 <= 5
                                       7: begin s7<=o; end// s1 <= 5 
                                       8: begin s8<=o;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //p
                  10'b100_0000_110:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=p; end// s1 <= 5 
                                       2: begin s2<=p; end// s1 <= 5
                                      3: begin s3<=p;  end// s1 <= 5
                                      4: begin s4<=p;  end// s1 <= 5 
                                      5: begin s5<=p; end// s1 <= 5 
                                       6: begin s6<=p; end// s1 <= 5
                                       7: begin s7<=p; end// s1 <= 5 
                                       8: begin s8<=p;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //q
                  10'b100_0001_011:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=q; end// s1 <= 5 
                                       2: begin s2<=q; end// s1 <= 5
                                      3: begin s3<=q;  end// s1 <= 5
                                      4: begin s4<=q;  end// s1 <= 5 
                                      5: begin s5<=q; end// s1 <= 5 
                                       6: begin s6<=q; end// s1 <= 5
                                       7: begin s7<=q; end// s1 <= 5 
                                       8: begin s8<=q;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //r
                  10'b011_0000_010:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=r; end// s1 <= 5 
                                       2: begin s2<=r; end// s1 <= 5
                                      3: begin s3<=r;  end// s1 <= 5
                                      4: begin s4<=r;  end// s1 <= 5 
                                      5: begin s5<=r; end// s1 <= 5 
                                       6: begin s6<=r; end// s1 <= 5
                                       7: begin s7<=r; end// s1 <= 5 
                                       8: begin s8<=r;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //s
                  10'b011_0000_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=s; end// s1 <= 5 
                                       2: begin s2<=s; end// s1 <= 5
                                      3: begin s3<=s;  end// s1 <= 5
                                      4: begin s4<=s;  end// s1 <= 5 
                                      5: begin s5<=s; end// s1 <= 5 
                                       6: begin s6<=s; end// s1 <= 5
                                       7: begin s7<=s; end// s1 <= 5 
                                       8: begin s8<=s;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //t
                  10'b001_0000_001:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=t; end// s1 <= 5 
                                       2: begin s2<=t; end// s1 <= 5
                                      3: begin s3<=t;  end// s1 <= 5
                                      4: begin s4<=t;  end// s1 <= 5 
                                      5: begin s5<=t; end// s1 <= 5 
                                       6: begin s6<=t; end// s1 <= 5
                                       7: begin s7<=t; end// s1 <= 5 
                                       8: begin s8<=t;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //u
                  10'b011_0000_100:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=u; end// s1 <= 5 
                                       2: begin s2<=u; end// s1 <= 5
                                      3: begin s3<=u;  end// s1 <= 5
                                      4: begin s4<=u;  end// s1 <= 5 
                                      5: begin s5<=u; end// s1 <= 5 
                                       6: begin s6<=u; end// s1 <= 5
                                       7: begin s7<=u; end// s1 <= 5 
                                       8: begin s8<=u;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //v
                  10'b100_0001_000:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=v; end// s1 <= 5 
                                       2: begin s2<=v; end// s1 <= 5
                                      3: begin s3<=v;  end// s1 <= 5
                                      4: begin s4<=v;  end// s1 <= 5 
                                      5: begin s5<=v; end// s1 <= 5 
                                       6: begin s6<=v; end// s1 <= 5
                                       7: begin s7<=v; end// s1 <= 5 
                                       8: begin s8<=v;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //w
                  10'b011_0000_110:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=w; end// s1 <= 5 
                                       2: begin s2<=w; end// s1 <= 5
                                      3: begin s3<=w;  end// s1 <= 5
                                      4: begin s4<=w;  end// s1 <= 5 
                                      5: begin s5<=w; end// s1 <= 5 
                                       6: begin s6<=w; end// s1 <= 5
                                       7: begin s7<=w; end// s1 <= 5 
                                       8: begin s8<=w;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //x
                  10'b100_0001_001:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=x; end// s1 <= 5 
                                       2: begin s2<=x; end// s1 <= 5
                                      3: begin s3<=x;  end// s1 <= 5
                                      4: begin s4<=x;  end// s1 <= 5 
                                      5: begin s5<=x; end// s1 <= 5 
                                       6: begin s6<=x; end// s1 <= 5
                                       7: begin s7<=x; end// s1 <= 5 
                                       8: begin s8<=x;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //y
                  10'b100_0001_101:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                        1:  begin s1<=y; end// s1 <= 5 
                                       2: begin s2<=y; end// s1 <= 5
                                      3: begin s3<=y;  end// s1 <= 5
                                      4: begin s4<=y;  end// s1 <= 5 
                                      5: begin s5<=y; end// s1 <= 5 
                                       6: begin s6<=y; end// s1 <= 5
                                       7: begin s7<=y; end// s1 <= 5 
                                       8: begin s8<=y;   end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                    end
                  
                  //z
                  10'b100_0000_011:  
                  begin 
                    led[9] <= 0;
                         case(count)  
                                      1:  begin s1<=z;   end// s1 <= 5 
                                      2: begin s2<=z;    end// s1 <= 5
                                      3: begin s3<=z;    end// s1 <= 5
                                      4: begin s4<=z;    end// s1 <= 5 
                                      5: begin s5<=z;    end// s1 <= 5 
                                      6: begin s6<=z;    end// s1 <= 5
                                      7: begin s7<=z;    end// s1 <= 5 
                                      8: begin s8<=z;    end// s1 <= 5 
                  
                                     default: begin    end  // 5
                          endcase
                          count  <= count+1;
                                  if (count >= 9) begin
                                    led[8] <= 1;
                                  end  
                   end
         default: begin 
           if (temp != 0) begin
              led[9] <= 1;
           end  
         end 
     endcase  
    end
 end
        
        
        //-------------------------------------
        // 解码判断�??????? 结束
        //--------------------------------------
        
        endmodule
        
        
