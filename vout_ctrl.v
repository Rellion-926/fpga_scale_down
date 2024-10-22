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

    input [15:0] vin_xres,
    input [15:0] vin_yres,
    input [15:0] vout_xres,
    input [15:0] vout_yres,

    input ddr_ready,
    input ram_ready,

    output reg fetch_en,
    output reg [15:0] fetch_line,

    output reg coo_valid,
    output reg [15:0] vout_t_x,
    output reg [15:0] vout_t_y,

    output [15:0] coordinate_x,
	output [15:0] coordinate_y,
	output [16:0] coefficient1,	//[15:0]是小数部分，[16]是用于进位的整数部分
	output [16:0] coefficient2,
	output [16:0] coefficient3,
	output [16:0] coefficient4
);

localparam s0 = 3'b000;
localparam s1 = 3'b001;
localparam s2 = 3'b010;
localparam s3 = 3'b011;
localparam s4 = 3'b100;

reg [2:0] st_cur;
reg [2:0] st_next;
always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        st_cur <= s0;
        st_next <= s0;
    end
    else
        st_cur <= st_next;
end

always @(*) begin
    case(st_cur)
        s0: begin
            if(ddr_ready)
                st_next = s1;
        end

        s1: st_next = s2;

        s2: begin
            if(vout_y <= vout_yres-1)
                st_next = s3;
            else
                st_next = s0;
        end

        s3: begin
            if(ram_ready)
                st_next = s4;
            else
                st_next = s3;
        end

        s4: begin
            if(vout_x < vout_xres-1)
                st_next = s4;
            else
                st_next = s1;
        end

        default: st_next = s0;
    endcase
end

reg [15:0] vout_x;
reg [15:0] vout_y;
always @(posedge vin_clk) begin
    case(st_cur)
        s0: begin
            vout_x <= 0;
            vout_y <= 0;
        end

        s1: begin
            if(vout_x) begin
                vout_x <= 0;
                vout_y <= vout_y + 1;
            end
        end

        s4: vout_x <= vout_x + 1;

        default: begin
            vout_x <= vout_x;
            vout_y <= vout_y;
        end
    endcase
end

always @(posedge vin_clk) begin
    if(st_cur == s2) begin
        if(vout_y <= vout_yres) begin
            fetch_en <= 1;
            fetch_line <= coo_y;
        end
        else begin
            fetch_en <= 0;
            fetch_line <= 0;
        end
    end
    else begin
        fetch_en <= 0;
        fetch_line <= 0;
    end
end

always @(posedge vin_clk) begin
    if(st_cur == s4) begin
        coo_valid <= 1;
        vout_t_x <= vout_x;
        vout_t_y <= vout_y;
    end
    else begin
        coo_valid <= 0;
        vout_t_x <= 0;
        vout_t_y <= 0;
    end
end

wire [15:0] coo_y;
virtual_coordinate coo_transform
(
    .vin_clk(vin_clk),
    .frame_sync_n(frame_sync_n),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),
    .vout_xres(vout_xres),
    .vout_yres(vout_yres),

    .vout_x(vout_x),
    .vout_y(vout_y),

    .coordinate_x(coordinate_x),
    .coordinate_y(coo_y),
    .coefficient1(coefficient1),
    .coefficient2(coefficient2),
    .coefficient3(coefficient3),
    .coefficient4(coefficient4)
);
assign coordinate_y = coo_y;

endmodule
