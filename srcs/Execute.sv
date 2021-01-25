`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Execute
// Description:
//   Implements the RISC-V execution pipeline stage
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- debug I/O control
//   ID_EX_compare --
//   ID_EX_pres_adr -- 16-bit program counter (present address) from decode stage
//   ID_EX_alusel2 -- 
//   ID_EX_alusel1 -- 
//   ID_EX_alusel0 -- 
//   ID_EX_addb --
//   ID_EX_rightb --
//   ID_EX_logicb --
//   ID_EX_alusrc --
//   ID_EX_memread --
//   ID_EX_memwrite --
//   ID_EX_regwrite --
//   ID_EX_rs1 -- 5-bit source register 1 address (rs1)
//   ID_EX_rs2 -- 5-bit source register 2 address (rs2)
//   ID_EX_rd -- 5-bit destination register address (rd)
//   ID_EX_dout_rs1 -- 32-bit value from source register 1 (rs1)
//   ID_EX_dout_rs2 -- 32-bit value from source register 2 (rs2)
//   ID_EX_imm -- 32-bit immediate value
//   MEM_WB_regwrite --
//   EX_MEM_alures -- 32-bit
//   WB_res -- 32-bit
//   ID_EX_jal -- jump and link indicator
//   ID_EX_jalr -- jump and link for subrouting return indicator
//   MEM_WB_rd -- 5-bit destination register address for write back
// Output:
//   EX_MEM_dout_rs2 -- 32-bit value output to memory
//   ins -- 32-bit instruction operation code
//   EX_MEM_memread --
//   EX_MEM_rd -- 5-bit destination register address for memory access
//   EX_MEM_memwrite -- memory write signal
//   EX_MEM_regwrite -- register write signal
//   EX_MEM_comp_res --
//   dbg_ALUop1 -- 32-bit ALU operation for debugging
//   dbg_ALUop2 -- 32-bit ALU operation for debugging
// 
//////////////////////////////////////////////////////////////////////////////////


module Execute(main_bus bus);
 
  logic EX_MEM_memread_sig, EX_MEM_regwrite_sig;
  logic [31:0] EX_MEM_alures_sig;
  logic [4:0]  EX_MEM_rd_sig;
  logic comp_res;
  logic [31:0] alures;
  logic [2:0]  sel;
  logic [31:0] ALUop1,ALUop2,rs2_mod;
  logic [31:0] rs2_mod_final;//new
  
  logic [31:0] CSR_res;
  
  logic [31:0] CSR_mod; 
  
  
 
  

  Forwarding dut(
         .EX_MEM_regwrite(EX_MEM_regwrite_sig),
         .EX_MEM_memread(EX_MEM_memread_sig),
         .MEM_WB_regwrite(bus.MEM_WB_regwrite),
         .WB_ID_regwrite(bus.WB_ID_regwrite),
         .EX_MEM_rd(EX_MEM_rd_sig),
         .MEM_WB_rd(bus.MEM_WB_rd),
         .WB_ID_rd(bus.WB_ID_rd),
         .ID_EX_rs1(bus.ID_EX_rs1),
         .ID_EX_rs2(bus.ID_EX_rs2),
         .alures(bus.EX_MEM_alures),
         .memres(bus.WB_res),
         .wbres(bus.WB_ID_res),
         .alusrc(bus.ID_EX_alusrc),
         .imm(bus.ID_EX_imm),
         .rs1(bus.ID_EX_dout_rs1),
         .rs2(bus.ID_EX_dout_rs2),
         .EX_MEM_CSR(bus.EX_MEM_CSR),
         .EX_MEM_CSR_read(bus.EX_MEM_CSR_read),
         .fw_rs1(ALUop1),
         .fw_rs2(ALUop2),
         .rs2_mod(rs2_mod)
  );
  
 ALU uut(
        .a(ALUop1),
        .b(ALUop2),
        .alusel(bus.ID_EX_alusel),
        .ID_EX_compare(bus.ID_EX_compare),
        .ID_EX_pres_adr(bus.ID_EX_pres_addr),
        .ID_EX_lui(bus.ID_EX_lui),
        .ID_EX_jal(bus.ID_EX_jal),
        .ID_EX_jalr(bus.ID_EX_jalr),
        .ID_EX_auipc(bus.ID_EX_auipc),
        .key(bus.key),
        .res(alures),
        .comp_res(comp_res), 
        .CSR_res(CSR_res),
        .CSR_in(bus.ID_EX_CSR), 
        .csrsel(bus.csrsel),
        .ID_EX_comp_sig(bus.ID_EX_comp_sig)
        );
        
 always_ff @(posedge bus.clk) begin
        if(bus.Rst) begin
            EX_MEM_rd_sig<=5'b00000;
            EX_MEM_memread_sig<=1'b0;
            bus.EX_MEM_memwrite<=1'b0;
            EX_MEM_regwrite_sig<=1'b0;
            EX_MEM_alures_sig<=32'h00000000;
            bus.EX_MEM_dout_rs2<=32'h00000000;
            bus.EX_MEM_rs2 <= 5'h0;
            bus.EX_MEM_rs1 <= 5'h0;
            bus.EX_MEM_comp_res<=1'b0;
            bus.EX_MEM_loadcntrl<=5'h0;
            bus.EX_MEM_storecntrl<=3'h0;
            bus.EX_MEM_pres_addr<= 32'h0;
            bus.EX_CSR_res <= 0;
            bus.EX_CSR_addr <= 0;
            bus.EX_CSR_write <= 0;
            bus.EX_MEM_CSR <= 0;
            bus.EX_MEM_CSR_read <= 0;
        end
        else if(!bus.dbg && !bus.mem_hold) begin
            EX_MEM_rd_sig<=bus.ID_EX_rd;
            EX_MEM_memread_sig<=bus.ID_EX_memread;
            bus.EX_MEM_memwrite<=bus.ID_EX_memwrite;
            EX_MEM_regwrite_sig<=(bus.ID_EX_regwrite&&(!bus.ID_EX_compare))+(bus.ID_EX_regwrite&&bus.ID_EX_compare&&comp_res);
            EX_MEM_alures_sig<=alures;
            bus.EX_MEM_dout_rs2<=rs2_mod;//new
            bus.EX_MEM_rs2<=bus.ID_EX_rs2;
            bus.EX_MEM_rs1<=bus.ID_EX_rs1;
            bus.EX_MEM_comp_res<=comp_res;
            bus.EX_MEM_loadcntrl<=bus.ID_EX_loadcntrl;
            bus.EX_MEM_storecntrl<=bus.ID_EX_storecntrl;
            bus.EX_MEM_pres_addr<=bus.ID_EX_pres_addr; 
            bus.EX_CSR_res <= CSR_res;
            bus.EX_CSR_addr <= bus.ID_EX_CSR_addr;
            bus.EX_CSR_write <= bus.ID_EX_CSR_write;
            bus.EX_MEM_CSR <= bus.ID_EX_CSR;
            bus.EX_MEM_CSR_read <= bus.ID_EX_CSR_read;
        end
  end
  
  assign bus.EX_MEM_rd=EX_MEM_rd_sig;
  assign bus.EX_MEM_alures=EX_MEM_alures_sig;
  assign bus.EX_MEM_memread=EX_MEM_memread_sig;
  assign bus.EX_MEM_regwrite=EX_MEM_regwrite_sig;
endmodule: Execute
