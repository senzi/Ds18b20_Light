`timescale 1ns / 1ps

module data_c(clk,rst,data_DS,data_Light,dataout,btn,flag);

input clk,rst,btn;

input [15:0] data_Light,data_DS;
output[15:0] dataout;
output flag;

reg flag;
reg [8:0] count; 
reg [15:0] dataout;
always @(posedge clk or posedge rst) begin
	if (rst) begin
	flag <= 1'b1;
	end
	else if (btn) begin
	flag <= !flag;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
	count <= 0;		
	end
	else if (count[8] == 1'b1) begin
		if(flag)
		dataout <= data_DS;
		else begin
		dataout <= data_Light;
		end	
	end
	else begin
	count <= count + 1'b1;
	end
end


endmodule
