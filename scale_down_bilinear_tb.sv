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

reg [15:0] vin_xres = 'd4;
reg [15:0] vin_yres = 'd4;
reg [15:0] vout_xres = 'd8;
reg [15:0] vout_yres = 'd8;

reg [15:0] vin_dat;
reg vin_valid;
reg vout_ready;

reg ddr_ready;

wire fetch_en;
reg [15:0] fetch_line;

reg wr_ram_en;
reg [15:0] ram_dat;
reg fetch_done;

wire vin_wr_valid;
wire [15:0] vin_wr_x;
wire [15:0] vin_wr_y;
wire [15:0] vin_wr_dat;

wire vout_wr_valid;
wire [15:0] vout_wr_x;
wire [15:0] vout_wr_y;
wire [15:0] vout_wr_dat;

scale_down_bilinear scale_down_bilinear
(
    .vin_clk(clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),
    .vout_xres(vout_xres),
    .vout_yres(vout_yres),

    .ddr_ready(ddr_ready),

    .fetch_en(fetch_en),
    .fetch_line(fetch_line),

    .wr_ram_en(wr_ram_en),
    .ram_dat(ram_dat),
    .fetch_done(fetch_done),

    .vout_wr_valid(vout_wr_valid),
    .vout_wr_x(vout_wr_x),
    .vout_wr_y(vout_wr_y),
    .vout_wr_dat(vout_wr_dat)
);

vin_ctrl vin_ctrl
(
    .vin_clk(clk),
    .rst_n(rst_n),
    .frame_sync_n(frame_sync_n),

    .vin_dat(vin_dat),
    .vin_valid(vin_valid),
    .vout_ready(vout_ready),

    .vin_xres(vin_xres),
    .vin_yres(vin_yres),

    .wr_valid(vin_wr_valid),
    .vin_wr_x(vin_wr_x),
    .vin_wr_y(vin_wr_y),
    .vin_wr_dat(vin_wr_dat)
);

reg [31:0] vin_wr_addr;
always @(*) begin
    if(vin_wr_valid) begin
        vin_wr_addr = {vin_wr_y, (vin_wr_x << 2)};
        slv_mem.backdoor_mem_write(vin_wr_addr, vin_wr_dat);
    end
end

always @(negedge vin_wr_valid) ddr_ready <= 1;
always @(posedge clk) ddr_ready <= 0;

reg vin_cnt_en;
reg vin_cnt_flag;
reg [15:0] vin_x;
reg [15:0] vin_y;
reg [31:0] vin_r_addr;
always @(posedge clk) begin
    if(~rst_n) begin
        vin_cnt_en <= 0;
        vin_cnt_flag <= 0;
    end
    else begin
        if(~vin_cnt_en) begin
            if(fetch_en) begin
                vin_cnt_en <= 1;
                vin_y <= fetch_line;
            end
            else begin
                fetch_done <= 0;
                vin_cnt_flag <= 0;
            end
        end
        else begin
            if(vin_cnt_flag == 1 && vin_x == vin_xres-1) begin
                vin_cnt_en <= 0;
                fetch_done <= 1;
            end
        end
    end
end
assign wr_ram_en = vin_cnt_en;

always @(posedge clk) begin
    if(~frame_sync_n || ~rst_n)
        vin_x <= 0;
    else begin
        if(vin_cnt_en) begin
            if(vin_x < vin_xres-1) begin
                vin_x <= vin_x + 1;
            end
            else begin
                vin_x <= 0;
                vin_y <= vin_y + 1;
                vin_cnt_flag <= vin_cnt_flag + 1;
            end
        end
    end
end

always @(*) begin
    if(vin_cnt_en) begin
        vin_r_addr = {vin_y, (vin_x << 2)};
        slv_mem.backdoor_mem_read(vin_r_addr, ram_dat);
    end
end

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
