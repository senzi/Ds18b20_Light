`timescale 1ns / 1ps

module top(clk,rst,ds18b20,the_btn,SEG7_SEG,SEG7_SEL,ADC549_DATA,ADC549_CLK,ADC549_CS_N,led);

input  clk,rst,the_btn,ADC549_DATA;
inout  ds18b20;
output ADC549_CLK,ADC549_CS_N;
output [7:0] led;
output [7:0] SEG7_SEG;
output [3:0] SEG7_SEL;

wire [15:0] t_buf_inside;
reg [7:0] led;

ds18b20_drive ds18b20_0(
	.clk(clk),
	.rst(rst),
	.one_wire(ds18b20),
	.temperature(t_buf_inside));

wire   [7 :0] ad_data;
wire   [15:0] segdata;
wire   [11:0] wire_bcd;
wire   [7 :0] change;

assign change = 8'b11111111-ad_data;
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
    .DATA_IN          (change),
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


always @(*) begin
	led = 0;
	if (rst) begin
	led = 0;		
	end
	else if (change>8'b11011111) begin led[7:0] = 8'b11111111; end
	else if (change>8'b10111111) begin led[6:0] = 7'b1111111; end
	else if (change>8'b10011111) begin led[5:0] = 6'b111111; end
	else if (change>8'b01111111) begin led[4:0] = 5'b11111; end
	else if (change>8'b01011111) begin led[3:0] = 4'b1111; end
	else if (change>8'b00111111) begin led[2:0] = 3'b111; end
	else if (change>8'b00011111) begin led[1:0] = 2'b11; end
	else if (change>8'b00000010) begin led[0:0] = 1'b1; end
	else led = 1'b0;
end
endmodule
