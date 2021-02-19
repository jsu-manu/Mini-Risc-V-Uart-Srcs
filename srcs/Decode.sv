`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Decode
// Description:
//   Implements the RISC-V decode pipeline stage
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- debug I/O control
//   IF_ID_pres_adr -- 16-bit program counter address from fetch stage
//   ins -- 32-bit instruction operation code
//   WB_res -- 32-bit results for write back
//   EX_MEM_memread --
//   EX_MEM_regwrite --
//   EX_MEM_alures -- 32-bit ALU result
//   EX_MEM_rd -- 5-bit destination register (rd) address
//   IF_ID_dout_rs1 -- 32-bit source register (rs1) value from fetch stage
//   IF_ID_dout_rs2 -- 32-bit source register (rs2) value from fetch stage
// Output:
//   ID_EX_pres_adr -- 16-bit program counter address to execute stage
//   IF_ID_jalr -- fetch to decode flag for jump and link for subroutine return
//   ID_EX_jalr -- decode to execute flag for jump and link for subroutine return
//   branch_taken -- flag indicating branch taken
//   IF_ID_rs1 -- source register (rs1) address
//   IF_ID_rs2 -- source register (rs2) address
//   ID_EX_dout_rs1 -- 32-bit source register (rs1) value to execute stage
//   ID_EX_dout_rs2 -- 32-bit source register (rs2) value to execute stage
//   branoff -- 16-bit branch offset
//   ID_EX_rs1 -- 5-bit source register (rs1) address to execute stage
//   ID_EX_rs2 -- 5-bit source register (rs2) address to execute stage
//   ID_EX_alusel2 -- 
//   ID_EX_alusel1 -- 
//   ID_EX_alusel0 -- 
//   ID_EX_addb -- 
//   ID_EX_logicb -- 
//   ID_EX_rightb -- 
//   ID_EX_alusrc -- 
//   ID_EX_memread -- 
//   ID_EX_memwrite -- 
//   hz -- 
// Input/Output (Bidirectional):
//   ID_EX_rd -- 5-bit destination register (rd) address
// 
//////////////////////////////////////////////////////////////////////////////////



module Decode(main_bus bus);
 
logic IF_ID_lui, lui;
logic ID_EX_memread_sig, ID_EX_regwrite_sig;
//logic[4:0] ID_EX_rd_sig;

//fluhed instruction detector
logic flush;

//logic debug;
logic ins_zero;
logic flush_sig;
logic [31:0]rs1_mod,rs2_mod;

//logic jal,jalr;
logic [1:0] funct2;
logic [2:0]funct3;
logic [3:0] funct4;
logic [5:0] funct6;
logic [6:0]funct7;
logic [11:0] funct12;
logic [31:0] comp_imm;

logic IF_ID_jal, IF_ID_compare;
logic jal, compare, jalr_sig;
logic IF_ID_jalr_sig;

//hazard detection and compare unit
logic zero1,zero2,zero3,zero4,zeroa,zerob;

//register file
logic [4:0]IF_ID_rd;
logic [31:0]dout_rs1,dout_rs2;

//control
logic [2:0]IF_ID_alusel, alusel;
logic      IF_ID_branch, branch;
logic      IF_ID_memwrite,IF_ID_memread,IF_ID_regwrite,IF_ID_alusrc;
logic memwrite, memread, regwrite, alusrc;
logic [2:0]IF_ID_storecntrl, storecntrl;
logic [4:0]IF_ID_loadcntrl, loadcntrl;
logic [3:0]IF_ID_cmpcntrl;
logic      IF_ID_auipc;

logic [2:0] csrsel;
logic csrwrite;
logic csrread;
logic [11:0] IF_ID_CSR_addr;

//imm gen
logic [31:0]imm, IF_ID_imm;
logic hz_sig;
logic branch_taken_sig;


//Compressed signals
logic [4:0] c_rd, c_rs1, c_rs2;
logic [1:0] c_funct2;
logic [2:0] c_funct3;
logic [3:0] c_funct4;
logic [5:0] c_funct6;
logic [6:0] c_funct7; 
logic [2:0] c_alusel; 
logic [2:0] c_storecntrl;
logic [4:0] c_loadcntrl;
logic c_branch, c_beq, c_bne, c_memread, c_memwrite, c_regwrite, c_alusrc, c_compare;
logic c_lui, c_jal, c_jalr;
logic [31:0] c_imm;

logic trap_ret;

//separating different field of instruction
//assign funct3=bus.ins[14:12];
//assign funct7=bus.ins[31:25];
//assign bus.IF_ID_rs1=bus.ins[19:15];
//assign bus.IF_ID_rs2=bus.ins[24:20];
//assign IF_ID_rd=bus.ins[11:7];
//assign bus.IF_ID_rd=IF_ID_rd;

function logic [4:0] RVC_Reg(input logic [2:0] rs);
	case (rs)
		3'b000: return 8;
		3'b001: return 9;
		3'b010: return 10;
		3'b011: return 11;
		3'b100: return 12; 
		3'b101: return 13;
		3'b110: return 14;
		3'b111: return 15;
	endcase
endfunction

assign IF_ID_CSR_addr = bus.ins[31:20];
assign bus.IF_ID_CSR_addr = IF_ID_CSR_addr;

always_comb begin
	if (bus.comp_sig) begin
		funct2 = c_funct2;
		funct3 = c_funct3;
		funct4 = c_funct4;
		funct6 = c_funct6;
		funct7 = c_funct7; 
		bus.IF_ID_rs1 = c_rs1;
		bus.IF_ID_rs2 = c_rs2;
		IF_ID_rd = c_rd;
		bus.IF_ID_rd = IF_ID_rd; 
		IF_ID_alusel = c_alusel;
		IF_ID_storecntrl=c_storecntrl;
		IF_ID_loadcntrl = c_loadcntrl; 
		IF_ID_branch = c_branch;
		IF_ID_memread = c_memread;
		IF_ID_memwrite = c_memwrite;
		IF_ID_regwrite = c_regwrite;
		IF_ID_alusrc = c_alusrc; 
		IF_ID_compare = c_compare;
		IF_ID_lui = c_lui;
		IF_ID_jal = c_jal;
		IF_ID_jalr_sig = c_jalr;
		IF_ID_imm = c_imm;
	end else begin
		funct3=bus.ins[14:12];
		funct7=bus.ins[31:25];
		funct12 = bus.ins[31:20];
		bus.IF_ID_rs1 = bus.ins[19:15];
		bus.IF_ID_rs2 = bus.ins[24:20]; 
		IF_ID_rd=bus.ins[11:7];
		bus.IF_ID_rd=IF_ID_rd;
		IF_ID_alusel=alusel;
		IF_ID_storecntrl=storecntrl;
		IF_ID_loadcntrl=loadcntrl;
		IF_ID_branch=branch;
		IF_ID_memread = memread;
		IF_ID_memwrite=memwrite;
		IF_ID_regwrite=regwrite;
		IF_ID_alusrc=alusrc;
		IF_ID_compare=compare;
		IF_ID_lui=lui;
		IF_ID_jal=jal;
		IF_ID_jalr_sig=jalr_sig;
		IF_ID_imm = imm;
	end
end

//assign flush=branch_taken_sig;
//assign debug_out=debug;
assign bus.branch=branch_taken_sig;
assign ins_zero=!(|bus.ins);
assign bus.hz=hz_sig;
assign bus.ecall = flush ? 1'b0 : (bus.ins == 32'b00000000000000000000000001110011);
//assign bus.trap_ret = trap_ret;
   
   
   
   //control signal generation
   Control u1(
       .opcode(bus.ins[6:0]),
       .funct3(funct3),
       .funct7(funct7),
       .funct12(funct12),
       .ins_zero(ins_zero),
       .flush(flush),
       .hazard(hz_sig),
       .rs1(bus.ins[19:15]),
       .rd(bus.ins[11:7]), 
       .alusel(alusel),
       .branch(branch),
       .memwrite(memwrite),
       .memread(memread),
       .regwrite(regwrite),
       .alusrc(alusrc),
       .compare(compare),
       .lui(lui),
       .auipc(IF_ID_auipc),
       .jal(jal),
       .jalr(jalr_sig),
       .storecntrl(storecntrl),
       .loadcntrl(loadcntrl),
       .cmpcntrl(IF_ID_cmpcntrl), 
       .csrsel(csrsel), 
       .csrwrite(csrwrite),
       .csrread(csrread),
       .trap_ret(trap_ret)
   );
   
   Compressed_Control u7(
    	.ins(bus.ins), .ins_zero(ins_zero), .flush(flush), .hazard(hz_sig), 
    	.rd(c_rd), .rs1(c_rs1), .rs2(c_rs2), .funct2(c_funct2), .funct3(c_funct3), 
    	.funct4(c_funct4), .funct6(c_funct6), .funct7(c_funct7), .alusel(c_alusel), 
    	.storecntrl(c_storecntrl), .loadcntrl(c_loadcntrl), .branch(c_branch), .beq(c_beq),
    	.bne(c_bne), .memread(c_memread), .memwrite(c_memwrite), .regwrite(c_regwrite),
    	.alusrc(c_alusrc), .compare(c_compare), .lui(c_lui), .jal(c_jal), 
    	.jalr(c_jalr), .imm(c_imm)
   );
   
   //branchforward
   branchforward u0(
       .rs1(bus.IF_ID_dout_rs1),
       .rs2(bus.IF_ID_dout_rs2),
       .zero3(zero3),
       .zero4(zero4),
       .zeroa(zeroa),
       .zerob(zerob),
       .alusrc(IF_ID_alusrc),
       .imm(IF_ID_imm),
       .alures(bus.EX_MEM_alures),
       .wbres(bus.WB_res),
       .EX_MEM_regwrite(bus.EX_MEM_regwrite),
       .EX_MEM_memread(bus.EX_MEM_memread),
       .MEM_WB_regwrite(bus.MEM_WB_regwrite),
       .rs1_mod(rs1_mod),
       .rs2_mod(rs2_mod)
       );
   
   //Branch decision module
   Branchdecision u2(
        .rs1_mod(rs1_mod),
        .rs2_mod(rs2_mod),
        .hazard(hz_sig),
        .branch(IF_ID_branch),
        .funct3(funct3),
        .jal(IF_ID_jal),
        .jalr(IF_ID_jalr_sig),
        .branch_taken(branch_taken_sig)
   );
   //Hazard detection unit
   Hazard u3(
        .zero1(zero1),
        .zero2(zero2),
        .zero3(zero3),
        .zero4(zero4),
        .IF_ID_alusrc(IF_ID_alusrc),
        .IF_ID_jalr(IF_ID_jalr_sig),
        .IF_ID_branch(IF_ID_branch),
        .ID_EX_memread(bus.ID_EX_memread),
        .ID_EX_regwrite(bus.ID_EX_regwrite),
        .EX_MEM_memread(bus.EX_MEM_memread),
        .hz(hz_sig)
   );
   //Branchoffgen
   Branoffgen u4(
       .ins(bus.ins),
       .rs1_mod(rs1_mod),
       .comp_sig(bus.comp_sig),
       .comp_imm(c_imm),
       .jal(IF_ID_jal),
       .jalr(IF_ID_jalr_sig),
       .branoff(bus.branoff)
   );
   //Immediate generation
   Immgen u5(
        .ins(bus.ins),
        .imm(imm)        
   );
   //Compare unit for branch decision and hazard detection
   compare u6(
        .IF_ID_rs1(bus.IF_ID_rs1),
        .IF_ID_rs2(bus.IF_ID_rs2),
        //.ID_EX_rs1(bus.ID_EX_rs1),
        .ID_EX_rd(bus.ID_EX_rd),
        .EX_MEM_rd(bus.EX_MEM_rd),
        .MEM_WB_rd(bus.MEM_WB_rd),
        .zero1(zero1),
        .zero2(zero2),
        .zero3(zero3),
        .zero4(zero4),
        .zeroa(zeroa),
        .zerob(zerob)
   ); 
   
   //Compressed Instruction Control Unit
   
   
   always_ff @(posedge bus.clk)begin
        if(bus.Rst)begin
            bus.ID_EX_alusel<=3'h0;
            bus.ID_EX_alusrc<=1'b0;
            ID_EX_memread_sig<=1'b0;
            bus.ID_EX_memwrite<=1'b0;
            ID_EX_regwrite_sig<=1'b0;
            bus.ID_EX_storecntrl<=3'h0;
            bus.ID_EX_loadcntrl<=5'h0;
            bus.ID_EX_cmpcntrl<=4'h0;
            bus.ID_EX_rs1<=5'b00000;
            bus.ID_EX_rs2<=5'b00000;
            //ID_EX_rd_sig<=5'b00000;
            bus.ID_EX_rd<=5'b00000;
            bus.ID_EX_dout_rs1<=32'h00000000;
            bus.ID_EX_dout_rs2<=32'h00000000;
            bus.ID_EX_pres_addr<=8'h00;
            bus.ID_EX_compare<=1'b0;
            bus.ID_EX_imm<=32'h00000000;
            bus.ID_EX_jal<=1'b0;
            bus.ID_EX_jalr<=1'b0;
            bus.ID_EX_lui<=1'b0;
            bus.ID_EX_auipc<=1'b0;
            bus.ID_EX_CSR_addr <= 12'b0;
            bus.ID_EX_CSR <= 32'b0; 
            bus.ID_EX_CSR_write <= 1'b0;
            bus.csrsel <= 3'b000;
            bus.ID_EX_CSR_read <= 0;
            bus.ID_EX_comp_sig <= 0;
            bus.trap_ret <= 0;
            end
        else if(!bus.dbg && !bus.mem_hold) begin
            if ((!hz_sig) & bus.RAS_rdy) begin
                bus.ID_EX_alusel<=IF_ID_alusel;
                bus.ID_EX_alusrc<=IF_ID_alusrc;
                ID_EX_memread_sig<=IF_ID_memread;
                bus.ID_EX_memwrite<=IF_ID_memwrite;
                ID_EX_regwrite_sig<=IF_ID_regwrite;
                bus.ID_EX_storecntrl<=IF_ID_storecntrl;
                bus.ID_EX_loadcntrl<=IF_ID_loadcntrl;
                bus.ID_EX_cmpcntrl<=IF_ID_cmpcntrl;
                bus.ID_EX_rs1<=bus.IF_ID_rs1;
                bus.ID_EX_rs2<=bus.IF_ID_rs2;
               // ID_EX_rd_sig<=IF_ID_rd;
                bus.ID_EX_rd<=IF_ID_rd;
                bus.ID_EX_compare<=IF_ID_compare;
                bus.ID_EX_dout_rs1<=bus.IF_ID_dout_rs1;
                bus.ID_EX_dout_rs2<=bus.IF_ID_dout_rs2;
                bus.ID_EX_imm<=IF_ID_imm;
                bus.ID_EX_pres_addr<=bus.IF_ID_pres_addr;
                flush_sig<=branch_taken_sig;// | bus.trap_ret;// | bus.trigger_trap;
                bus.ID_EX_jal<=IF_ID_jal;
                bus.ID_EX_jalr<=IF_ID_jalr_sig;
                bus.ID_EX_lui<=IF_ID_lui;
                bus.ID_EX_auipc<=IF_ID_auipc;
                bus.ID_EX_CSR_addr <= IF_ID_CSR_addr; 
                bus.ID_EX_CSR <= bus.IF_ID_CSR;
                bus.ID_EX_CSR_write <= csrwrite;
                bus.csrsel <= csrsel;
                bus.ID_EX_CSR_read <= csrread;
                bus.ID_EX_comp_sig <= bus.comp_sig;
                bus.trap_ret <= trap_ret;
            end else begin
                bus.ID_EX_alusel<=3'b000;
                bus.ID_EX_alusrc<=1'b1;
                ID_EX_memread_sig<=1'b0;
                bus.ID_EX_memwrite<=1'b0;;
                ID_EX_regwrite_sig<=1'b0;
                bus.ID_EX_storecntrl<=3'b000;
                bus.ID_EX_loadcntrl<=3'b000;
                bus.ID_EX_cmpcntrl<=2'b00;
                bus.ID_EX_rs1<=5'b00000;
                bus.ID_EX_rs2<=5'b00000;
               // ID_EX_rd_sig<=IF_ID_rd;
                bus.ID_EX_rd<=5'b00000;
                bus.ID_EX_compare<=1'b0;
                bus.ID_EX_dout_rs1<=32'h00000000;
                bus.ID_EX_dout_rs2<=32'h00000000;
                bus.ID_EX_imm<=32'h00000000;
                bus.ID_EX_pres_addr<=bus.IF_ID_pres_addr;
                flush_sig<=1'b0;
                bus.ID_EX_jal<=1'b0;
                bus.ID_EX_jalr<=1'b0;
                bus.ID_EX_lui<=1'b0;
                bus.ID_EX_auipc<=1'b0;
                bus.ID_EX_CSR_addr <= 12'b0;
                bus.ID_EX_CSR <= 32'b0; 
                bus.ID_EX_CSR_write <= 1'b0;
                bus.csrsel <= 3'b000;
                bus.ID_EX_CSR_read <= 0;
                bus.ID_EX_comp_sig <= bus.comp_sig;
                bus.trap_ret <= 0;
            end
        end
    end
        
    assign bus.ID_EX_memread=ID_EX_memread_sig;
    assign bus.ID_EX_regwrite=ID_EX_regwrite_sig;
   // assign ID_EX_rd=ID_EX_rd_sig;
    assign flush=flush_sig | bus.trigger_trap | bus.trap_ret;
    assign bus.IF_ID_jalr=IF_ID_jalr_sig;
    assign bus.IF_ID_jal = IF_ID_jal;
endmodule
