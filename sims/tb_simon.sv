`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2021 12:17:14 PM
// Design Name: 
// Module Name: tb_simon
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


interface tb_riscv_bus(
	input logic clk, Rst, RAS_branch, ret, 
	input logic [31:0] RAS_addr_in, RAS_mem_dout, 
	input logic RAS_mem_rdy, 
	output logic stack_full, stack_empty, stack_mismatch, 
	output logic [31:0] RAS_mem_din, RAS_mem_addr, 
	output logic RAS_mem_rd, RAS_mem_wr, RAS_rdy
);

	modport CRAS(
	input clk, Rst, RAS_branch, ret, RAS_addr_in, RAS_mem_dout,
    	input RAS_mem_rdy, 
    	output stack_full, stack_empty, stack_mismatch, RAS_mem_din, RAS_mem_addr,
    	output RAS_mem_rd, RAS_mem_wr, RAS_rdy);

endinterface

interface tb_mmio_bus(
	input logic [31:0] RAS_config_din, 
	input logic [2:0] RAS_config_addr, 
	input logic RAS_config_wr, 
	output logic RAS_ena);

	modport CRAS(
		input RAS_config_din, RAS_config_addr, RAS_config_wr, 
		output RAS_ena
	);

endinterface

module tb_simon(

    );
    
    parameter int WW = 32;
    parameter int NKW = 4;
    
    logic clk, rst; 
    logic [WW-1:0] addr_in;
    logic branch, ret, stack_full, stack_empty, stack_mismatch, rdy; 
    
    logic mem_rdy, mem_rd, mem_wr; 
    logic [WW-1:0] mem_dout, mem_din, mem_addr; 
    
    logic [2:0] config_addr;
    logic [31:0] config_din;
    logic config_wr, RAS_ena; 
    

    
    always #5 clk=~clk; 
    
    CRAS_top #(.W(WW), .NKW(NKW), .DEPTH(64), .FILL_THRESH(48), .EMPTY_THRESH(32)) dut(.*);
    
    parameter int TEST_VECTOR = 128;
    logic [31:0] test_addr [TEST_VECTOR]; 
    
//    blk_mem_gen_0 mem0(clk, 1'b1, wea, mem_addr, mem_din, mem_dout);
//    blk_mem_gen_0 mem0(mem_addr, clk, mem_din, mem_dout, 1'b1, wea); 
    
    task push(input logic [31:0] raddr);
		addr_in = raddr;
		branch = 1;
		@(posedge clk);
		branch = 0;    
    endtask
    
    task pop(input logic [31:0] raddr);
    	ret = 1;
    	addr_in = raddr;
    	@(posedge clk);
    	ret = 0;
    endtask
    
    task init_test();
    	for (int i = 0; i < TEST_VECTOR; i++) begin
//    		test_addr[i] = $urandom();
			test_addr[i] = i + 1; 
    	end
    endtask
    
    int i = 0; 
    int cnt = 0; 
    
    task runtests(); 
// 		while(cnt < (2 * TEST_VECTOR)) begin
//			@(posedge clk); 
//			#10;
//			while(rdy == 0) @(posedge clk); 
// 			if (i < 2) begin
// 				push(test_addr[i]);
// 				i++;
// 			end else begin
// 				if ($urandom_range(0, TEST_VECTOR) > i) begin
// 					push(test_addr[i]); 
// 					i++;
// 				end else begin
// 					pop(test_addr[i-1]);
// 					i--; 
// 				end
// 			end
// 			cnt++;
// 		end
// 		while(i >= 0) begin
// 			@(posedge clk);
// 			#10;
// 			while(rdy == 0) @(posedge clk); 
// 			pop(test_addr[i-1]);
// 			i--; 
// 		end
    	for (int i = 0; i < TEST_VECTOR; i++) begin
    		@(posedge clk);
    		#10;
    		while(rdy == 0) @(posedge clk); 
    		#5;
    		push(test_addr[i]); 
    	end
    	for (int i = TEST_VECTOR; i > 0; i--) begin
    		@(posedge clk);
    		#10
    		while(rdy == 0) @(posedge clk); 
    		#5;
    		pop(test_addr[i-1]);
    	end
    	$display("Test successful!");
    	$stop;
    endtask
    
    always_ff @(posedge stack_mismatch) begin
    	$display("ERROR!");
    	$stop;
    end
    
    initial begin
    	clk = 0;
    	rst = 1; 
    	addr_in = 0;
    	branch = 0;
    	ret = 0; 
    	mem_rdy = 0; 
    	#10;
    	rst = 0; 
    	#20;
    	mem_rdy = 1;
		init_test();
		runtests();
    	
    	
//    	addr_in = 32'h12341234; 
//    	branch = 1; 
//    	mem_rdy = 1; 
//    	#10
//    	branch = 0; 
//    	#10
//    	addr_in = 32'hbaddab69; 
//    	branch = 1; 
//    	#10
//    	branch = 0;
    end
    
    
//    logic clk, arst_n; 
//    logic active_o, valid_i, ready_o, mode_i; 
//    logic [1:0][WW-1:0] pt_i; 
//    logic [3:0][WW-1:0] key_i; 
//    logic valid_o, ready_i, mode_o; 
//    logic [1:0][WW-1:0] ct_o; 
    
//    logic [1:0][WW-1:0] plaintext; 
//    logic [1:0][WW-1:0] ciphertext; 
    
//    always #5 clk=~clk; 
    
//    simon_top #(.WW(WW), .NKW(NKW)) dut(.*);
    
//    initial begin
//    	clk = 0;
//    	arst_n = 0; 
//    	valid_i = 0;
//    	mode_i = 0; 
//    	pt_i = 0;
//    	key_i = 0; 
//    	ready_i = 0; 
//    	plaintext = {32'hace1ace2, 32'hace3ace4}; 
//    	#10
//    	arst_n = 1; 
//    	#10; 
//    	pt_i = plaintext;
//    	key_i = {32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef};
//    	valid_i = 1; 
//    	while(ready_o == 0) @(posedge clk); 
//    	valid_i = 0; 
//    	while(valid_o == 0) @(posedge clk); 
//    	ready_i = 1; 
//    	ciphertext = ct_o; 
//    	@(posedge clk); 
//    	ready_i = 0; 
//    	@(posedge clk); 
//    	pt_i = {ciphertext[0], ciphertext[1]};
//    	mode_i = 1; 
//    	valid_i = 1; 
//    	while(ready_o == 0) @(posedge clk); 
//    	valid_i = 0;
//    end
    
endmodule
