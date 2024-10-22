`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 20:00:22
// Design Name: 
// Module Name: vin_ctrl
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
module vin_ctrl
(
    input vin_clk,
    input rst_n,
    input frame_sync_n,

    input [15:0] vin_dat,
    input vin_valid,
    input vout_ready,

    input [15:0] vin_xres,
    input [15:0] vin_yres,

    output reg wr_valid,
    output [15:0] vin_wr_x,
    output [15:0] vin_wr_y,
    output [15:0] vin_wr_dat
);

reg [15:0] vin_x;
reg [15:0] vin_y;
reg ini_stat;
always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        vin_x <= 0;
        vin_y <= 0;
    end
    else 
        if(vin_valid && vout_ready) begin
            if(ini_stat) begin
                vin_x <= 0;
            end
            else begin
                if(vin_valid && vout_ready) begin
                    if(vin_x < vin_xres - 1) begin
                        vin_x <= vin_x + 1;
                    end
                    else begin
                        vin_x <= 0;
                        vin_y <= vin_y + 1;
                    end
                end
                else begin
                    vin_x <= 0;
                    vin_y <= 0;
                end
            end
        end
end

always @(posedge vin_clk) begin
    if(~frame_sync_n || ~rst_n) begin
        ini_stat <= 1;
    end
    else 
        if(vin_valid && vout_ready) begin
            if(ini_stat) begin
                ini_stat <= 0;
            end
        end
        else
            ini_stat <= 1;
end

always @(*) begin
    if(~frame_sync_n || ~rst_n)
        wr_valid <= 0;
    else begin
        if(vin_valid && vout_ready) begin
            if(vin_y <= vin_yres - 1)
                wr_valid <= 1;
            else
                wr_valid <= 0;
        end
        else
            wr_valid <= 0;
    end
end

assign vin_wr_y = vin_y;
assign vin_wr_x = vin_x;
assign vin_wr_dat = vin_dat;

endmodule
