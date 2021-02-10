`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2021 02:20:23 PM
// Design Name: 
// Module Name: CRAS_top
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


module CRAS_top #(
	parameter int W = 32,
	parameter int NKW = 4
)(
	riscv_bus rbus,
	mmio_bus mbus
//	input logic clk, rst,
	 
//	input logic [W-1:0] addr_in, 
//	input logic branch, ret,
//	output logic stack_full, stack_empty, stack_mismatch, 
	
//	input logic mem_rdy,
//	input logic [W-1:0] mem_dout,
//	output logic mem_rd, mem_wr,
//	output logic [W-1:0] mem_din,
//	output logic [31:0] mem_addr, 
	
//	output logic rdy
	
    );
    
    logic clk, rst, branch, ret, stack_full, stack_empty, stack_mismatch; 
    logic [W-1:0] addr_in; 
    
    logic mem_rdy, mem_rd, mem_wr, rdy; 
    logic [W-1:0] mem_dout, mem_din;
    logic [31:0] mem_addr; 
    
    logic [3:0] wea; 
    
    logic [2:0] config_addr; 
    logic [31:0] config_din; 
    logic config_wr; 
    logic RAS_ena; 
    
    assign wea = mem_wr ? 4'b1111 : 4'b0000;
    
    always_comb begin
    	clk = rbus.clk;
    	rst = rbus.Rst; 
    	branch = rbus.RAS_branch;
    	ret = rbus.ret;
    	rbus.stack_full = stack_full;
    	rbus.stack_empty = stack_empty;
    	rbus.stack_mismatch = stack_mismatch; 
    	addr_in = rbus.RAS_addr_in; 
    	mem_rdy = rbus.RAS_mem_rdy;
//    	mem_dout = rbus.RAS_mem_dout; 
    	rbus.RAS_mem_rd = mem_rd;
    	rbus.RAS_mem_wr = mem_wr; 
    	rbus.RAS_mem_din = mem_din;
    	rbus.RAS_mem_addr = mem_addr;
    	rbus.RAS_rdy = rdy;
    	config_addr = mbus.RAS_config_addr;
    	config_din = mbus.RAS_config_din;
    	config_wr = mbus.RAS_config_wr; 
    end
    
    //state enum
    enum {idle, enc_pop1, enc_pop2, enc_begin, enc_wait, 
    	enc_write_lower, enc_write_upper, enc_push_temp, dec_read_lower, dec_read_lower_2, 
    	dec_read_upper, dec_begin, dec_wait, dec_push1, 
    	dec_push2, dec_check} state, next_state; 
    
    //simon core signals
    logic arst_n, active_o, valid_i, ready_o, mode_i;
    logic [1:0][W-1:0] pt_i;
    logic [NKW-1:0][W-1:0] key_i; 
    logic valid_o, ready_i, mode_o;
    logic [1:0][W-1:0] ct_o;  
    
    //stack signals 
    logic stack_ena, stack_push, stack_pop, stack_ret;
    logic [W-1:0] stack_din, stack_dout;
    
    logic [W-1:0] raddr_temp_reg;
    
    logic [31:0] base_addr, cur_addr;
    logic [31:0] page_count;
    logic enc_last;
    
    logic [1:0][W-1:0] IV; 
    logic [1:0][W-1:0] Ck; 
    
    
    simon_top #(.WW(W), .NKW(NKW)) crypto_core(.*);
    ra_stack #(.DATA_WIDTH(32), .DEPTH(32)) ras(clk, rst, stack_ena, stack_push, stack_pop, stack_ret, 
    	stack_din, stack_dout, stack_mismatch, stack_full, stack_empty);
    	
    blk_mem_RAS mem0(.addra(mem_addr), .clka(clk), .dina(mem_din), .douta(mem_dout), .ena(1), .wea(wea));
    	
//    assign key_i = {32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef};
    assign IV = {32'hbaddab69, 32'hbaddab69}; 
    assign rdy = (state == idle) ? 1 : 0;
    
    //combinational assignments
    always_comb begin
    	arst_n = ~rst;
    end
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		RAS_ena <= 1; 
    		key_i <= {32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef, 32'hdeadbeef};
    	end else if (config_wr) begin
    		case(config_addr)
    			3'b000: RAS_ena <= config_din[0]; 
    			3'b100: key_i[0] <= config_din;
    			3'b101: key_i[1] <= config_din;
    			3'b110: key_i[2] <= config_din;
    			3'b111: key_i[3] <= config_din;
    			default: begin
    			end
    		endcase
    	end
    end
    
    always_comb begin
    	stack_ena = 0;
    	stack_push = 0;
    	stack_pop = 0;
    	stack_ret = 0; 
    	valid_i = 0; 
    	mode_i = 0; 
    	ready_i = 0;
    	mem_wr = 0;
    	mem_rd = 0; 
    	mem_addr = 0;
    	mem_din = 0;
    	stack_din = 0;
    	unique case (state)
    		idle: begin
    			if (RAS_ena) begin
					if (stack_full & branch) begin
						next_state = enc_pop1; 
					end else if (stack_empty & (page_count != 0)) begin
						next_state = dec_read_upper;
					end else begin
						next_state = idle;
						stack_din = addr_in;
						stack_ena = (branch | ret); 
						stack_push = branch;
						stack_ret = ret;  
					end
    			end else begin
    				next_state = idle; 
    			end
    		end
    		enc_pop1: begin
    			next_state = enc_pop2; 
    			stack_ena = 1;
    			stack_pop = 1; 
    		end
    		enc_pop2: begin
    			next_state = enc_begin;
    			stack_ena = 1;
    			stack_pop = 1;
//    			pt_i[0] = stack_dout; 
    		end
    		enc_begin: begin
    			valid_i = 1;
    			mode_i = 0; 
    			if (ready_o) begin
    				next_state = enc_wait;
//    				valid_i = 0; 
    			end else begin
    				next_state = enc_begin;
    			end
    		end
    		enc_wait: begin
    			if (valid_o) begin
    				ready_i = 1;
    				next_state = enc_write_lower;
    			end else begin 
    				next_state = enc_wait;
    			end
    		end
    		enc_write_lower: begin
    			if (mem_rdy) begin
    				mem_wr = 1;
    				mem_din = ct_o[0]; 
    				mem_addr = cur_addr;
    				next_state = enc_write_upper;
    			end else begin
    				next_state = enc_write_lower; 
    			end
    		end
    		enc_write_upper: begin
    			if (mem_rdy) begin
    				mem_wr = 1;
    				mem_din = ct_o[1]; 
    				mem_addr = cur_addr; 
    				if (stack_empty) 
    					next_state = enc_push_temp;
    				else
    					next_state = enc_pop1; 
    			end else begin
    				next_state = enc_write_upper;
    			end
    		end
    		enc_push_temp: begin
    			next_state = idle;
    			stack_ena = 1;
    			stack_push = 1;
    			stack_din = raddr_temp_reg;
    		end
    		dec_read_lower: begin
    			if (mem_rdy) begin
    				mem_rd = 1; 
    				mem_addr = cur_addr - 4;
    				next_state = dec_read_lower_2;  
    			end else begin
    				next_state = dec_read_lower;
    			end
    		end
    		dec_read_lower_2: begin
    			next_state = dec_begin;
    		end
    		dec_read_upper: begin
    			if (mem_rdy) begin
    				mem_rd = 1;
    				mem_addr = cur_addr - 4; 
    				next_state <= dec_read_lower; 
    			end else begin
    				next_state = dec_read_upper;
    			end
    		end
    		dec_begin: begin
    			valid_i = 1;
    			mode_i = 1; 
    			if (ready_o) begin
    				next_state = dec_wait;
    			end else begin 
    				next_state = dec_begin;
    			end
    		end
    		dec_wait: begin
    			if (valid_o) begin
    				ready_i = 1;
    				next_state <= dec_push1;
    			end else begin
    				next_state <= dec_wait;
    			end
    		end
    		dec_push1: begin
    			stack_ena = 1;
    			stack_push = 1; 
    			stack_din = ct_o[0];
    			next_state = dec_push2; 
    		end
    		dec_push2: begin
    			stack_ena = 1;
    			stack_push = 1;
    			stack_din = ct_o[1];
    			next_state = dec_check;
    		end
    		dec_check: begin
    			if (stack_full) begin
    				next_state = idle;
    			end else begin
    				next_state = dec_read_upper;
    			end
    		end
    	endcase
    end
    
    //state logic
    always_ff @(posedge clk) begin
    	if (rst) begin
    		state <= idle; 
    		base_addr <= 0;
    		cur_addr <= 0;
    		page_count <= 0;
    		raddr_temp_reg <= 0;
    		enc_last <= 0;
    	end else begin
    		case(state)
    			idle: begin
    				raddr_temp_reg <= addr_in;
    				/*if ((next_state == dec_read_upper) & enc_last) cur_addr <= cur_addr - 4;
    				if (next_state == enc_pop1) enc_last <= 1;
    				else if (next_state == dec_read_upper) enc_last <= 0;*/
    			end 
    			enc_pop1: begin
    				pt_i[0] <= stack_dout;
    			end
    			enc_pop2: begin
    				pt_i[1] <= stack_dout;
    			end
    			enc_begin: begin
    			
    			end
    			enc_wait: begin
    			
    			end
    			enc_write_lower: begin
    				if (mem_rdy) cur_addr <= cur_addr + 4; 
    			end
    			enc_write_upper: begin
    				if (mem_rdy) cur_addr <= cur_addr + 4; 
    			end
    			enc_push_temp: begin
    				page_count <= page_count + 1;
    			end
    			dec_read_lower: begin
    				if (mem_rdy) begin 
    					cur_addr <= cur_addr - 4; 
    					pt_i[0] <= mem_dout;
    				end 
    			end
    			dec_read_lower_2: begin
    				pt_i[1] <= mem_dout;
    			end
    			dec_read_upper: begin
    				if (mem_rdy) begin
    					cur_addr <= cur_addr - 4; 
//    					pt_i[1] <= mem_dout;
    				end
    			end
    			dec_begin: begin
    			
    			end
    			dec_wait: begin 
    			end
    			dec_push1: begin
    			
    			end
    			dec_push2: begin
    			
    			end
    			dec_check: begin
    				if (stack_full) page_count <= page_count - 1; 
    			end
    			default: begin
    			
    			end
    		endcase
    		state <= next_state;
    	end
    end
    
    
endmodule
