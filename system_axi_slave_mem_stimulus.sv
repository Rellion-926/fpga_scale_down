import axi_vip_pkg::*;
import axi_vip_slave_pkg::*;

module	system_axi_slave_mem_stimulus#(
	parameter MAX_FILE_SIZE = 1024*1024 //1024 * 4KB
)(output	bit [15:0] reg_data);

	axi_vip_slave_slv_mem_t 	agent;
	// reg	[15:0] file_data  [0 : MAX_FILE_SIZE-1];
	xil_axi_ulong		 mem_wr_addr;
	xil_axi_ulong		 mem_rd_addr;

	initial begin
		agent = new("slave vip mem agent", scale_down_bilinear_tb.ddr_vin.inst.IF);
		agent.start_slave();  

		// $readmemh("/home/lfc/Desktop/Capstone/tool/RV32I_auto_compile/final.hex", file_data);

		// for(int i = 0; i < MAX_FILE_SIZE; i++)begin
		// 	mem_wr_addr = i * 4;
		// 	// reg_data = file_data[i];
		// 	backdoor_mem_write(mem_wr_addr, file_data[i]);
		// end

		// for(int i = 0; i<10; i++)begin
		// 	mem_rd_addr = i*4;
		// 	backdoor_mem_read(mem_rd_addr, reg_data);
		// 	#10 ;
		// end

	end


	task backdoor_mem_write(
		input xil_axi_ulong     	addr, 
		input bit [32-1:0]      	wr_data,
		input bit [4-1:0]       	wr_strb = 4'b1111
	);
		agent.mem_model.backdoor_memory_write(addr, wr_data, wr_strb);
	endtask

	task backdoor_mem_read(
		input xil_axi_ulong mem_rd_addr,
		output bit [32-1:0] mem_rd_data
	);
		mem_rd_data= agent.mem_model.backdoor_memory_read(mem_rd_addr);
	endtask
	
endmodule
