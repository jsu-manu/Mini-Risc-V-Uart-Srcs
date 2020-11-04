`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose. Grayson Bruner
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// Modified:
//   May 20, 2019
// 
// Module name: Fetch_Reprogrammable
// Description:
//   Implements the RISC-V fetch pipeline stage. This functions almost identically
//   to the original fetch module, however this one has added functionality
//   to reprogram the instruction memory through UART.
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   En -- enable signal
//   debug -- debug I/O control
//   prog -- debug or reprogram instruction memory
//   Rst -- system reset
//   branch -- branch single
//   IF_ID_jalr -- flag jump and link for subrouting return
//   rx -- uart recv pin
//   branoff -- 16-bit offset for branching
// Output:
//   IF_ID_pres_adr -- 16-bit program counter address
//   ins -- 32-bit instruction operation code
// 
//////////////////////////////////////////////////////////////////////////////////

//This functions almost identically to the original fetch module, however this one has added functionality
//to reprogram the instruction memory through UART.
module Fetch_Reprogrammable(main_bus bus);

logic [31:0] pc_incr;
logic [31:0] memdout;
logic [31:0] next_addr;
logic [31:0] pres_addr;
logic [31:0] imem_addr;
logic [31:0] imem_next_addr, imem_incr;
logic [31:0] ins_last;
logic imem_en;
logic [31:0] addr_in;
logic En_sig, En_mem, state_load_prog;
logic [31:0] debug_addr_imm;
//logic [11:0] branoff;
logic comp_sig; 
logic bg;
logic lower, next_comp, comp;

logic branch_next;
logic [31:0] branch_addr; 
//assign lower = (pres_addr[1:0] == 0);
//assign comp = (lower & (memdout[1:0] != 2'b11) & (memdout[15:0] != 0)) | (~lower & (memdout[17:16] != 2'b11) & (memdout[31:16] != 0));
assign comp = (memdout[1:0] != 2'b11) & (memdout != 0);
//assign next_comp = (lower & comp & (memdout[17:16] != 2'b11));
assign comp_sig = comp;
assign bus.comp_sig = comp_sig;
assign debug_addr_imm[9:5] = 5'b00000;
assign debug_addr_imm[4:0] = bus.debug_input;

//assign branoff[11] = bus.branoff[7];
//assign branoff[10:7] = 4'b0000;
//assign branoff[6:0] = bus.branoff[6:0];
assign memdout = bus.imem_dout;

//assign bus.IF_ID_pres_addr = pres_addr;
//assign pc_incr=bg ? 0 : bus.branch?bus.branoff:(comp_sig ? 12'h002 : 12'h004);
assign pc_incr = bg ? 0 : comp_sig ? 12'h002 : 12'h004;
assign imem_incr = bus.branch? bus.branoff : 12'h004;
//assign next_addr=bus.IF_ID_jalr?bus.branoff: bus.IF_ID_jal ? (bus.IF_ID_pres_addr + pc_incr) : (pres_addr+pc_incr);

//assign next_addr=bus.trap ? bus.mtvec : bus.IF_ID_jalr?bus.branoff: bus.IF_ID_jal ? (bus.IF_ID_pres_addr + pc_incr)
//     : bus.branch ? (bus.IF_ID_pres_addr+pc_incr) : (bus.IF_ID_pres_addr+pc_incr);
     
assign next_addr = branch_next ? branch_addr : bus.IF_ID_pres_addr + pc_incr;
     
assign En_sig=(bus.PC_En&&(!bus.debug)&&(!bus.dbg)&&(!bus.mem_hold)); 
//assign En_sig=(bus.PC_En&&(!bus.dbg));
assign En_mem=En_sig || bus.prog;
assign bus.ins=bus.Rst?32'h00000000: comp_sig ? {16'h0000, memdout[15:0]} : memdout;

//assign bus.ins=bus.Rst?32'h0: ((bus.IF_ID_pres_addr[1:0]) ?  {16'h0, memdout[31:16]} : memdout);
//assign bus.ins=bus.Rst?32'h00000000:En_sig?memdout:32'h00000013;
//assign addr_in=bus.prog?debug_addr_imm:pres_addr[11:2];
assign addr_in=bus.prog?debug_addr_imm:imem_addr;
assign imem_addr = next_addr;
assign bus.imem_en = En_mem; 
//assign imem_en = (~next_comp) & (~bus.Rst) & En_mem;
//assign bus.imem_en = imem_en;
assign bus.imem_addr = addr_in; 

//assign bus.IF_ID_pres_addr = pres_addr;

//always_comb begin
//	if (bus.Rst) bus.ins = 32'h00000000;
//	else if (lower) begin
//		if (comp) bus.ins = {16'h0, memdout[15:0]};
//		else bus.ins = memdout; 
//	end else begin
//		if (comp) bus.ins = {16'h0, memdout[31:16]};
//		else bus.ins = {memdout[15:0], ins_last[31:16]};
//	end
//end

always_ff @(posedge bus.clk) begin
	if (bus.Rst || bus.memcon_prog_ena) begin
	bg <= 1;
	   bus.IF_ID_pres_addr <= 32'h000;
//	   imem_addr <= 0;
	   ins_last <= 0;
	   branch_addr <= 0;
	   branch_next <= 0;
//	   bus.ins<=32'h00000000;
	end
	else if (En_sig) begin
	   bg <= 0;
	   bus.IF_ID_pres_addr <= next_addr; 
	   branch_addr <= bus.trap ? bus.mtvec : bus.IF_ID_jalr ? bus.branoff : bus.IF_ID_jal ? (bus.IF_ID_pres_addr + bus.branoff) 
	   	: bus.branch ? (bus.IF_ID_pres_addr + bus.branoff) : 0;
	   	branch_next <= bus.trap | bus.IF_ID_jalr | bus.IF_ID_jal | bus.branch; 
//	   pres_addr <= next_addr;
//	   pres_addr <= next_addr;
//        if (imem_en) begin
//            imem_addr <= imem_next_addr;
//            ins_last = memdout;
//        end
//	    bus.ins<=memdout;
    end 
    else begin
//        bus.ins <= 32'h00000013;
    end
end

//UART_Programmer mem(.clk(bus.clk), .rx(bus.rx), .rst(bus.Rst), .ena(En_mem), .addra(addr_in), .douta(memdout), .*);
//IRAM_Controller mem(.clk(bus.clk), .rst(bus.Rst), .ena(En_mem), .prog_ena(bus.memcon_prog_ena), .wea_in(4'b0000), 
//        .dina(bus.uart_dout), .addr_in(addr_in), .state_load_prog(state_load_prog), .douta(memdout));

endmodule
