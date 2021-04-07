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
 
logic IF_ID_lui;
logic ID_EX_memread_sig, ID_EX_regwrite_sig;
//logic[4:0] ID_EX_rd_sig;

//fluhed instruction detector
logic flush;

//logic debug;
logic ins_zero;
logic flush_sig;
logic [31:0]rs1_mod,rs2_mod;

//logic jal,jalr;
logic [2:0]funct3;
logic [6:0]funct7;

logic IF_ID_jal, IF_ID_compare;
logic IF_ID_jalr_sig;

//hazard detection and compare unit
logic zero1,zero2,zero3,zero4,zeroa,zerob;

//register file
logic [4:0]IF_ID_rd;
logic [31:0]dout_rs1,dout_rs2;

//control
logic [2:0]IF_ID_alusel;
logic [2:0]IF_ID_mulsel;
logic      IF_ID_branch;
logic      IF_ID_memwrite,IF_ID_memread,IF_ID_regwrite,IF_ID_alusrc;
logic [2:0]IF_ID_storecntrl;
logic [4:0]IF_ID_loadcntrl;
logic [3:0]IF_ID_cmpcntrl;
logic      IF_ID_auipc;

//imm gen
logic [31:0]imm;
logic hz_sig;
logic branch_taken_sig;
logic div_ready_sig;
logic div_ready;

//separating different field of instruction
assign funct3=bus.ins[14:12];
assign funct7=bus.ins[31:25];
assign bus.IF_ID_rs1=bus.ins[19:15];
assign bus.IF_ID_rs2=bus.ins[24:20];
assign IF_ID_rd=bus.ins[11:7];

//assign flush=branch_taken_sig;
//assign debug_out=debug;
assign bus.branch=branch_taken_sig;
assign ins_zero=!(|bus.ins);
assign bus.hz=hz_sig || (mul_inst && !bus.mul_ready) || (div_inst && !bus.div_ready);
   
   
   //control signal generation
   Control u1(
       .clk(bus.clk),
       .opcode(bus.ins[6:0]),
       .funct3(funct3),
       .funct7(funct7),
       .ins_zero(ins_zero),
       .flush(flush),
       .hazard(hz_sig),
       .alusel(IF_ID_alusel),
       .mulsel(IF_ID_mulsel),
       .divsel(IF_ID_divsel),
       .branch(IF_ID_branch),
       .memwrite(IF_ID_memwrite),
       .memread(IF_ID_memread),
       .regwrite(IF_ID_regwrite),
       .alusrc(IF_ID_alusrc),
       .compare(IF_ID_compare),
       .lui(IF_ID_lui),
       .auipc(IF_ID_auipc),
       .jal(IF_ID_jal),
       .jalr(IF_ID_jalr_sig),
       .storecntrl(IF_ID_storecntrl),
       .loadcntrl(IF_ID_loadcntrl),
       .cmpcntrl(IF_ID_cmpcntrl),
       .mul_inst(mul_inst),
       .div_inst(div_inst)
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
       .imm(imm),
       .alures(bus.EX_MEM_alures),
       .wbres(bus.WB_res),
       .divres(bus.EX_MEM_divres),
       .EX_MEM_regwrite(bus.EX_MEM_regwrite),
       .EX_MEM_memread(bus.EX_MEM_memread),
       .MEM_WB_regwrite(bus.MEM_WB_regwrite),
       .div_ready(div_ready_sig),
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
   
   always_ff @(posedge bus.clk)begin
        if(bus.Rst)begin
            bus.ID_EX_alusel<=3'h0;
            bus.ID_EX_mulsel<=3'h0;
            bus.ID_EX_divsel<=3'h0;
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
            div_ready_sig<=0;
            end
        else if(!bus.dbg && !bus.mem_hold) begin
            if (!hz_sig) begin
                bus.ID_EX_alusel<=IF_ID_alusel;
                bus.ID_EX_mulsel<=IF_ID_mulsel;
                bus.ID_EX_divsel<=IF_ID_divsel;
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
                bus.ID_EX_imm<=imm;
                bus.ID_EX_pres_addr<=bus.IF_ID_pres_addr;
                flush_sig<=branch_taken_sig;
                bus.ID_EX_jal<=IF_ID_jal;
                bus.ID_EX_jalr<=IF_ID_jalr_sig;
                bus.ID_EX_lui<=IF_ID_lui;
                bus.ID_EX_auipc<=IF_ID_auipc;
                div_ready_sig<=bus.div_ready;
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
                div_ready_sig<=div_ready;
            end
        end
    end
        
    assign bus.ID_EX_memread=ID_EX_memread_sig;
    assign bus.ID_EX_regwrite=ID_EX_regwrite_sig;
   // assign ID_EX_rd=ID_EX_rd_sig;
    assign flush=flush_sig;
    assign bus.IF_ID_jalr=IF_ID_jalr_sig;
    assign bus.IF_ID_jal = IF_ID_jal;
    assign div_ready=div_ready_sig;
endmodule
