`timescale 1ns / 1ps
`include "system_axi_slave_mem_stimulus.sv"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/29 18:59:54
// Design Name: 
// Module Name: scale_down_bilinear_tb
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
module scale_down_bilinear_tb();

wire [15:0] mem_data;
system_axi_slave_mem_stimulus slv_mem(mem_data);

reg clk;
reg rst_n;
reg frame_sync_n;

reg [15:0] vin_xres = 'd6;
reg [15:0] vin_yres = 'd6;
reg [15:0] vout_xres = 'd3;
reg [15:0] vout_yres = 'd3;

wire wr_valid;
reg [31:0] wr_addr;
reg [15:0] wr_dat;

wire coo_valid;
wire [15:0] coordinate_x;
wire [15:0] coordinate_y;
wire [16:0] coefficient1;
wire [16:0] coefficient2;
wire [16:0] coefficient3;
wire [16:0] coefficient4; 

reg [15:0] vin_dat;
reg vin_valid;
reg vout_ready;


vin_vout_ctrl io_ctrl
(
    .vin_clk(clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .vin_dat(vin_dat),
    .vin_valid(vin_valid),
    .vout_ready(vout_ready),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),
    .vout_xres(vout_xres),
    .vout_yres(vout_yres),

    .wr_valid(wr_valid),
    .vin_addr(wr_addr),
    .vin_wr_dat(wr_dat),

    .coo_valid(coo_valid),
    .coordinate_x(coordinate_x),
    .coordinate_y(coordinate_y),
    .coefficient1(coefficient1),
    .coefficient2(coefficient2),
    .coefficient3(coefficient3),
    .coefficient4(coefficient4)
);

always @(*) begin
    if(wr_valid)
        slv_mem.backdoor_mem_write(wr_addr, wr_dat);
end

reg [31:0] addr_x;
reg [15:0] doutbx;

reg [31:0] addr_x1;
reg [15:0] doutbx1;

reg [31:0] addr_y;
reg [15:0] doutby;

reg [31:0] addr_y1;
reg [15:0] doutby1;


always @(*) begin
    addr_x = {coordinate_y, (coordinate_x << 2)};
    addr_x1 = {coordinate_y, ((coordinate_x + 1) << 2)};
    addr_y = {coordinate_y+1, (coordinate_x << 2)};
    addr_y1 = {coordinate_y+1, ((coordinate_x + 1) << 2)};
    if(coo_valid) begin
        slv_mem.backdoor_mem_read(addr_x, doutbx);
        slv_mem.backdoor_mem_read(addr_x1, doutbx1);
        slv_mem.backdoor_mem_read(addr_y, doutby);
        slv_mem.backdoor_mem_read(addr_y1, doutby1);
    end
end

wire [15:0] vout_dat;
wire vout_valid;

bilinear_calculation vout_cal
(
    .vin_clk(clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .coo_valid(coo_valid),
    .coefficient1(coefficient1),
    .coefficient2(coefficient2),
    .coefficient3(coefficient3),
    .coefficient4(coefficient4),

    .doutbx(doutbx),
    .doutbx1(doutbx1),
    .doutby(doutby),
    .doutby1(doutby1),

    .vout_dat(vout_dat),
    .vout_valid(vout_valid)
);

axi_vip_slave ddr_vin
(
    .aclk(clk),                   
    .aresetn(rst_n),    

    .s_axi_awaddr(0),     
    .s_axi_awlen(0),       
    .s_axi_awsize(0),     
    .s_axi_awburst(0),   
    .s_axi_awlock(0),     
    .s_axi_awcache(0),   
    .s_axi_awprot(0),     
    .s_axi_awregion(0), 
    .s_axi_awqos(0),       
    .s_axi_awvalid(0),   
    .s_axi_awready(),   
    .s_axi_wdata(0),       
    .s_axi_wstrb(0),       
    .s_axi_wlast(0),       
    .s_axi_wvalid(0),     
    .s_axi_wready(),     
    .s_axi_bresp(),       
    .s_axi_bvalid(),     
    .s_axi_bready(1),     
    .s_axi_araddr(0),     
    .s_axi_arlen(0),       
    .s_axi_arsize(0),     
    .s_axi_arburst(0),   
    .s_axi_arlock(0),     
    .s_axi_arcache(0),   
    .s_axi_arprot(0),     
    .s_axi_arregion(0), 
    .s_axi_arqos(0),       
    .s_axi_arvalid(0),   
    .s_axi_arready(),   
    .s_axi_rdata(),       
    .s_axi_rresp(),       
    .s_axi_rlast(),       
    .s_axi_rvalid(),     
    .s_axi_rready(1)      
);

always #5 clk = ~clk;
initial begin
    clk = 1;
    rst_n = 0;
    frame_sync_n = 0;
    vin_valid = 0;
    vout_ready = 0;
    #160;
    rst_n = 1;
    frame_sync_n =1;
    #20;

    vin_valid = 1;
    vout_ready = 1;
    vin_dat = 'd15;
    #100;
end

endmodule