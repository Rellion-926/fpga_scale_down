`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/29 10:40:03
// Design Name: 
// Module Name: vin_vout_ctrl
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
module vin_vout_ctrl
(
    input vin_clk,
    input rst_n,
    input frame_sync_n,

    input [15:0] vin_dat,
    input vin_valid,
    input vout_ready,

    input [15:0] vin_xres,
    input [15:0] vin_yres,
    input [15:0] vout_xres,
    input [15:0] vout_yres,

    output wr_valid,
    output [31:0] vin_addr,
    output [15:0] vin_wr_dat,

    output coo_valid,
    output [15:0] coordinate_x,
	output [15:0] coordinate_y,
	output [16:0] coefficient1,
	output [16:0] coefficient2,
	output [16:0] coefficient3,
	output [16:0] coefficient4
);

wire [31:0] data_addr;

vin_ctrl vin_ctrl
(
    .vin_clk(vin_clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .vin_dat(vin_dat),
    .vin_valid(vin_valid),
    .vout_ready(vout_ready),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),

    .wr_valid(wr_valid),
    .vin_addr(data_addr),
    .vin_wr_dat(vin_wr_dat)
);

assign vin_addr = data_addr;

vout_ctrl vout_ctrl
(
    .vin_clk(vin_clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .vin_addr(data_addr),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),
    .vout_xres(vout_xres),
    .vout_yres(vout_yres),

    .coo_valid(coo_valid),

    .coordinate_x(coordinate_x),
    .coordinate_y(coordinate_y),
    .coefficient1(coefficient1),
    .coefficient2(coefficient2),
    .coefficient3(coefficient3),
    .coefficient4(coefficient4)
);

endmodule