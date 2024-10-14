`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/23 17:06:32
// Design Name: 
// Module Name: vout_ctrl
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
module vout_ctrl
(
    input vin_clk,
    input rst_n,
    input frame_sync_n,

    input [31:0] vin_addr,

    input [15:0] vin_xres,
    input [15:0] vin_yres,
    input [15:0] vout_xres,
    input [15:0] vout_yres,

    output coo_valid,
    output [15:0] coordinate_x,
	output [15:0] coordinate_y,
	output [16:0] coefficient1,	//[15:0]是小数部分，[16]是用于进位的整数部分
	output [16:0] coefficient2,
	output [16:0] coefficient3,
	output [16:0] coefficient4
);

wire [15:0] vin_y;
assign vin_y = vin_addr[31:16];

reg cnt_en;
reg [15:0] vout_x;
reg [15:0] vout_y;
always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        cnt_en <= 0;
    end
    else begin
        if(vout_y <= vout_yres - 1) begin
            if(~cnt_en) begin
                if(coordinate_y <= vin_y - 1 && vin_y > 0)
                    cnt_en <= 1;
                else
                    cnt_en <= 0;
            end
            else begin
                if(vout_x == vout_xres - 1)
                    cnt_en <= 0;
            end
        end
        else
            cnt_en <= 0;
    end
end

always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        vout_x <= 0;
        vout_y <= 0;
    end
    else begin
        if(cnt_en) begin
            if(vout_x < vout_xres-1) begin
                vout_x <= vout_x + 1;
            end
            else begin
                vout_x <= 0;
                vout_y <= vout_y + 1;
            end
        end
        else begin
            vout_x <= vout_x;
            vout_y <= vout_y;
        end
    end
end

wire [15:0] vt_x = vout_x;
wire [15:0] vt_y = vout_y;

virtual_coordinate coo_transform
(
    .vin_clk(vin_clk),
    .frame_sync_n(frame_sync_n),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),
    .vout_xres(vout_xres),
    .vout_yres(vout_yres),

    .vout_x(vt_x),
    .vout_y(vt_y),

    .coordinate_x(coordinate_x),
    .coordinate_y(coordinate_y),
    .coefficient1(coefficient1),
    .coefficient2(coefficient2),
    .coefficient3(coefficient3),
    .coefficient4(coefficient4)
);

assign coo_valid = cnt_en;

endmodule