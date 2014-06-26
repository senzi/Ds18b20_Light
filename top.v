`timescale 1ns / 1ps

module top(clk,rst,ds18b20,the_btn,SEG7_SEG,SEG7_SEL,ADC549_DATA,ADC549_CLK,ADC549_CS_N);

input  clk,rst,the_btn,ADC549_DATA;
inout  ds18b20;
output ADC549_CLK,ADC549_CS_N;
output [7:0] SEG7_SEG;
output [3:0] SEG7_SEL;

wire [15:0] t_buf_inside;

ds18b20_drive ds18b20_0(
	.clk(clk),
	.rst(rst),
	.one_wire(ds18b20),
	.temperature(t_buf_inside));

wire   [7 :0] ad_data;
wire   [15:0] segdata;
wire   [11:0] wire_bcd;
assign segdata = {4'b0000,wire_bcd};
tlc549_drive tlc549(
    .clk              (clk),
    .reset            (1'b1),
    .dateout          (ad_data),
    .cs               (ADC549_CS_N),
    .clk_ad           (ADC549_CLK),
    .sdate            (ADC549_DATA));

BCD bcd(
    .clk              (clk),
    .DATA_IN          (ad_data),
    .DATA_OUT         (wire_bcd));

wire xd_btn;
btn_xd btn_xd(
	.i_clk(clk),
	.i_btn(the_btn),
	.o_btn(xd_btn));

wire [15:0] data_display;
wire flag;
data_c data(
	.clk(clk),
	.rst(rst),
	.flag(flag),
	.data_DS(t_buf_inside),
	.data_Light(segdata),
	.dataout(data_display),
	.btn(xd_btn));

wire [3:0] dp_in,turn_off_in;
assign dp_in = flag?(4'b0010):(4'b0000) ;
assign turn_off_in =4'b0000;

seg_drive seg(
  .i_clk            (clk),
  .i_rst            (rst),

  .i_turn_off       (turn_off_in),
  .i_dp             (dp_in),
  .i_data           (data_display),
  .o_seg            (SEG7_SEG),
  .o_sel            (SEG7_SEL)
);
endmodule
