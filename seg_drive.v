`timescale 1ns / 1ps
module seg_drive(
  input         i_clk,
  input         i_rst,
  
  input  [3:0]  i_turn_off,             // 熄灭位[2进制]
  input  [3:0]  i_dp,                   // 小数点位[2进制]
  input  [15:0] i_data,                 // 欲显数据[16进制]  

  output [7:0]  o_seg,                  // 段脚
  output [3:0]  o_sel                   // 位脚
);

//++++++++++++++++++++++++++++++++++++++
// 分频部分 开始
//++++++++++++++++++++++++++++++++++++++
reg [10:0] cnt;                         

always @ (posedge i_clk or posedge i_rst)
  if (i_rst)
    cnt <= 0;
  else cnt <= cnt + 1'b1;

wire seg7_clk = cnt[10];                
//--------------------------------------
// 分频部分 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 动态扫描, 生成seg7_addr 开始
//++++++++++++++++++++++++++++++++++++++
reg [2:0]  seg7_addr;                   // 第几个seg7

always @ (posedge seg7_clk or posedge i_rst)
  if (i_rst)
    seg7_addr <= 0;
  else
    seg7_addr <= seg7_addr + 1'b1;      
//--------------------------------------
// 动态扫描, 生成seg7_addr 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 根据seg7_addr, 译出位码 开始
//++++++++++++++++++++++++++++++++++++++
reg [3:0] o_sel_r;                      // 位选码寄存器
always @ (seg7_addr)
	begin
        o_sel_r = 4'b1111;
  case (seg7_addr)
    0 : o_sel_r = 4'b1110;               
    1 : o_sel_r = 4'b1101;               
    2 : o_sel_r = 4'b1011;               
    3 : o_sel_r = 4'b0111;
  endcase
  end
//--------------------------------------
// 根据seg7_addr, 译出位码 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 根据seg7_addr, 选择熄灭码 开始
//++++++++++++++++++++++++++++++++++++++
reg turn_off_r;                         // 熄灭码

always @ (seg7_addr or i_turn_off)
begin
        turn_off_r = 1'b0;
  case (seg7_addr)
    0 : turn_off_r = i_turn_off[0];
    1 : turn_off_r = i_turn_off[1];
    2 : turn_off_r = i_turn_off[2];
    3 : turn_off_r = i_turn_off[3];
  endcase
end
//--------------------------------------
// 根据seg7_addr, 选择熄灭码 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 根据seg7_addr, 选择小数点码 开始
//++++++++++++++++++++++++++++++++++++++
reg dp_r;                               // 小数点码

always @ (seg7_addr or i_dp)
  begin
        dp_r = 1'b0;
  case (seg7_addr)
    0 : dp_r = i_dp[0];
    1 : dp_r = i_dp[1];
    2 : dp_r = i_dp[2];
    3 : dp_r = i_dp[3];
  endcase
  end
//--------------------------------------
// 根据seg7_addr, 选择小数点码 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 根据seg7_addr, 选择待译段码 开始
//++++++++++++++++++++++++++++++++++++++
reg [3:0] seg_data_r;                   // 待译段码

always @ (seg7_addr or i_data)
  begin
        seg_data_r = 4'b0000;
  case (seg7_addr)
    0 : seg_data_r = i_data[3:0];
    1 : seg_data_r = i_data[7:4];
    2 : seg_data_r = i_data[11:8];
    3 : seg_data_r = i_data[15:12];
  endcase
  end
//--------------------------------------
// 根据seg7_addr, 选择待译段码 结束
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// 根据熄灭码/小数点码/待译段码
// 译出段码，开始
//++++++++++++++++++++++++++++++++++++++
reg [7:0] o_seg_r;                      // 段码寄存器

/*
*     0
*  -------
*  |     |
* 5|  6  |1 
*  -------
*  |     |
* 4|     |2
*  ------- . 7
*    3
*/
always @ (posedge i_clk or posedge i_rst)
  if (i_rst)
    o_seg_r <= 8'hFF;                   // 送熄灭码
  else
    if(turn_off_r)                      // 送熄灭码
      o_seg_r <= 8'hFF;
    else
      if(!dp_r)
      begin
        case(seg_data_r)                // 无小数点
          4'h0 : o_seg_r <= 8'hC0;
          4'h1 : o_seg_r <= 8'hF9;
          4'h2 : o_seg_r <= 8'hA4;
          4'h3 : o_seg_r <= 8'hB0;
          4'h4 : o_seg_r <= 8'h99;
          4'h5 : o_seg_r <= 8'h92;
          4'h6 : o_seg_r <= 8'h82;
          4'h7 : o_seg_r <= 8'hF8;
          4'h8 : o_seg_r <= 8'h80;
          4'h9 : o_seg_r <= 8'h90;
          4'hA : o_seg_r <= 8'hFE;
          4'hB : o_seg_r <= 8'hFD;
          4'hC : o_seg_r <= 8'hFB;
          4'hD : o_seg_r <= 8'hF7;
          4'hE : o_seg_r <= 8'hEF;
          4'hF : o_seg_r <= 8'hDF;
        endcase
      end
      else
      begin
        case(seg_data_r)                // 加小数点
          4'h0 : o_seg_r <= 8'hC0 ^ 8'h80;
          4'h1 : o_seg_r <= 8'hF9 ^ 8'h80;
          4'h2 : o_seg_r <= 8'hA4 ^ 8'h80;
          4'h3 : o_seg_r <= 8'hB0 ^ 8'h80;
          4'h4 : o_seg_r <= 8'h99 ^ 8'h80;
          4'h5 : o_seg_r <= 8'h92 ^ 8'h80;
          4'h6 : o_seg_r <= 8'h82 ^ 8'h80;
          4'h7 : o_seg_r <= 8'hF8 ^ 8'h80;
          4'h8 : o_seg_r <= 8'h80 ^ 8'h80;
          4'h9 : o_seg_r <= 8'h90 ^ 8'h80;
          4'hA : o_seg_r <= 8'hFE ^ 8'h80;
          4'hB : o_seg_r <= 8'hFD ^ 8'h80;
          4'hC : o_seg_r <= 8'hFB ^ 8'h80;
          4'hD : o_seg_r <= 8'hF7 ^ 8'h80;
          4'hE : o_seg_r <= 8'hEF ^ 8'h80;
          4'hF : o_seg_r <= 8'hDF ^ 8'h80;
        endcase
      end
//--------------------------------------
// 根据熄灭码/小数点码/待译段码
// 译出段码，结束
//--------------------------------------

assign o_sel = o_sel_r;                 // 寄存器输出位选码
assign o_seg = o_seg_r;                 // 寄存器输出段码

endmodule
