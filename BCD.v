`timescale 1ns / 1ps
module BCD(clk,DATA_IN,DATA_OUT);

input              clk;
input    [7 :0]    DATA_IN;
output   [11:0]    DATA_OUT;
//++++++++++++++++++++++++++++++++++++++
// 对采集到的模拟值进行处理 开始 转BCD码
//++++++++++++++++++++++++++++++++++++++
  reg [11:0] DATA_OUT;

  wire[2:0]  c_in;
  wire[2:0]  c_out;
  reg [3:0]  dec_sreg0;
  reg [3:0]  dec_sreg1;
  reg [3:0]  dec_sreg2;
  wire[3:0]  next_sreg0,next_sreg1,next_sreg2;
  
  reg [3:0]  bit_cnt;
  reg [7:0]  bin_sreg;
  
wire load=~|bit_cnt;//读入二进制数据，准备转换
wire convert_ready= (bit_cnt==4'h9);//转换成功
wire convert_end= (bit_cnt==4'ha);//完毕，重新开始
/********************************************************/
always @ (posedge clk)
begin
  if(convert_end) bit_cnt<=4'h0;
  else bit_cnt<=bit_cnt+4'h1; 
end
/*******************************************************/ 
always @ (posedge clk)
begin
  if(load) bin_sreg<=DATA_IN[7:0];
  else bin_sreg <={bin_sreg[6:0],1'b0};
end

assign c_in[0] =bin_sreg[7];
assign c_in[1] =(dec_sreg0>=5);
assign c_in[2] =(dec_sreg1>=5);

assign c_out[0]=c_in[1];
assign c_out[1]=c_in[2];
assign c_out[2]=(dec_sreg2>=5);

//确定移位输出
assign next_sreg0=c_out[0]? ({dec_sreg0[2:0],c_in[0]}+4'h6):({dec_sreg0[2:0],c_in[0]});
assign next_sreg1=c_out[1]? ({dec_sreg1[2:0],c_in[1]}+4'h6):({dec_sreg1[2:0],c_in[1]});
assign next_sreg2=c_out[2]? ({dec_sreg2[2:0],c_in[2]}+4'h6):({dec_sreg2[2:0],c_in[2]});


//装入数据
/********************************************************************/
always @ (posedge clk)
begin
  if(load) 
    begin 
      dec_sreg0<=4'h0;
      dec_sreg1<=4'h0;
      dec_sreg2<=4'h0;
    end     
  else  
    begin
      dec_sreg0<=next_sreg0;
      dec_sreg1<=next_sreg1;
      dec_sreg2<=next_sreg2;
    end
end

//输出
/*******************************************************************/

always @ (posedge clk)
begin
  if(convert_ready) 
    begin 
      DATA_OUT[3:0]<=dec_sreg0;
      DATA_OUT[7:4]<=dec_sreg1;
      DATA_OUT[11:8]<=dec_sreg2;
    end     
end
//--------------------------------------
// 对采集到的模拟值进行处理 结束
//--------------------------------------

endmodule
