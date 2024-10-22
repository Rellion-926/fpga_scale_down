`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/23 17:06:32
// Design Name: 
// Module Name: virtual_coordinate
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
module virtual_coordinate
(
	input vin_clk,
	input frame_sync_n,

	input [15:0] vin_xres,			//输入视频水平分辨率
	input [15:0] vin_yres,			//输入视频垂直分辨率
	input [15:0] vout_xres,			//输出视频水平分辨率
	input [15:0] vout_yres,			//输出视频垂直分辨率

	input [15:0] vout_x,				//缩放后图像待输出坐标点
	input [15:0] vout_y,				//缩放后图像待输出坐标点

	output [15:0] coordinate_x,
	output [15:0] coordinate_y,
	output [16:0] coefficient1,	//[15:0]是小数部分，[16]是用于进位的整数部分
	output [16:0] coefficient2,
	output [16:0] coefficient3,
	output [16:0] coefficient4
);

	reg	[31:0] srcX;	//[31:16]高16位是整数，低16位是小数
	reg [31:0] srcY;	//[31:16]高16位是整数，低16位是小数

	reg	[31:0] scaler_height= 0;	//垂直缩放系数，[31:16]高16位是整数，低16位是小数
	reg	[31:0] scaler_width	= 0;	//水平缩放系数，[31:16]高16位是整数，低16位是小数
	
	always @(posedge frame_sync_n) begin
		scaler_width <= ((vin_xres << 16 ) / vout_xres);	//视频水平缩放比例，2^16*输入宽度/输出宽度
		scaler_height <= ((vin_yres << 16 ) / vout_yres);	//视频垂直缩放比例，2^16*输入高度/输出高度
	end

	always @(posedge vin_clk) begin
		srcX <= (((vout_x << 1) + 1) * scaler_width - 1) >> 1;
		srcY <= (((vout_y << 1) + 1) * scaler_height - 1) >> 1;
	end

	assign	coordinate_x = (srcX[31:16] >= (vin_xres-1)) ? (vin_xres-2) : srcX[31:16];
	assign	coordinate_y = (srcY[31:16] >= (vin_yres-1)) ? (vin_yres-2) : srcY[31:16];

	assign	coefficient2 = {1'b0, srcX[15:0]};
	assign	coefficient1 = 'd65536 - coefficient2;
	
	assign	coefficient4 = {1'b0, srcY[15:0]};
	assign	coefficient3 = 'd65536 - coefficient4;

endmodule
