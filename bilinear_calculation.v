`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/29 15:39:51
// Design Name: 
// Module Name: bilinear_calculation
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
module bilinear_calculation
(
    input vin_clk,
    input rst_n,
    input frame_sync_n,

    input coo_valid,
	input [16:0] coefficient1,
	input [16:0] coefficient2,
	input [16:0] coefficient3,
	input [16:0] coefficient4,

    input [15:0] doutbx,
	input [15:0] doutbx1,
	input [15:0] doutby,
	input [15:0] doutby1,

    output reg [15:0] vout_dat,
    output reg vout_valid
);

wire [47:0]	vin_r1 = coefficient1*coefficient3*doutbx[15:11];
wire [47:0]	vin_r2 = coefficient2*coefficient3*doutbx1[15:11];
wire [47:0]	vin_r3 = coefficient1*coefficient4*doutby[15:11];
wire [47:0]	vin_r4 = coefficient2*coefficient4*doutby1[15:11];

wire [47:0]	vin_g1 = coefficient1*coefficient3*doutbx[10:5];
wire [47:0]	vin_g2 = coefficient2*coefficient3*doutbx1[10:5];
wire [47:0]	vin_g3 = coefficient1*coefficient4*doutby[10:5];
wire [47:0]	vin_g4 = coefficient2*coefficient4*doutby1[10:5];

wire [47:0]	vin_b1 = coefficient1*coefficient3*doutbx[4:0];
wire [47:0]	vin_b2 = coefficient2*coefficient3*doutbx1[4:0];
wire [47:0]	vin_b3 = coefficient1*coefficient4*doutby[4:0];
wire [47:0]	vin_b4 = coefficient2*coefficient4*doutby1[4:0];

wire [47:0] reg_r = vin_r1 + vin_r2 + vin_r3 + vin_r4;
wire [47:0] reg_g = vin_g1 + vin_g2 + vin_g3 + vin_g4;
wire [47:0] reg_b = vin_b1 + vin_b2 + vin_b3 + vin_b4;

always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        vout_valid <= 0;
        vout_dat <= 16'hFF00;
    end
    else begin
        if(coo_valid) begin
            vout_valid <= 1;
            vout_dat <= {reg_r[36:32], reg_g[36:32], reg_b[36:32]};
        end
        else begin
            vout_valid <= 0;
            vout_dat <= 16'hFF00;
        end
    end
end

endmodule