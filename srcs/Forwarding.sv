`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Forwarding
// Description:
//   Implements the RISC-V forwarding logic
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   EX_MEM_regwrite --
//   EX_MEM_memread --
//   EX_MEM_rd -- destination register number
//   MEM_WB_rd -- write back destination register number
//   ID_EX_rs1 -- source 1 register number
//   ID_EX_rs2 -- source 2 register number
//   alures -- 32-bit result from ALU
//   memres -- 32-bit result from memory
//   alusrc -- 1-bit control for ALU source
//   imm -- 32-bit immediate value
//   rs1 -- 32-bit value from source register 1
//   rs2 -- 32-bit value from source register 2
// Output:
//   fw_rs1 -- 32-bit forwarding value, potentially for source register 1 (rs1)
//   fw_rs2 -- 32-bit forwarding value, potentially for source register 2 (rs2)
// 
//////////////////////////////////////////////////////////////////////////////////

module Forwarding
 (input  logic        EX_MEM_regwrite,
  input  logic        EX_MEM_memread,
  input  logic        MEM_WB_regwrite,
  input  logic        WB_ID_regwrite,
  input  logic [4:0]  EX_MEM_rd,
  input  logic [4:0]  MEM_WB_rd,
  input  logic [4:0]  WB_ID_rd,
  input  logic [4:0]  ID_EX_rs1,
  input  logic [4:0]  ID_EX_rs2,
  input  logic [31:0] alures,
  input  logic [31:0] memres,
  input  logic [31:0] wbres,
  input  logic        alusrc,
  input  logic [31:0] imm,
  input  logic [31:0] rs1,
  input  logic [31:0] rs2,
  input  logic [31:0] EX_MEM_CSR,
  input  logic        EX_MEM_CSR_read,
  output logic [31:0] fw_rs1,
  output logic [31:0] fw_rs2,
  output logic [31:0] rs2_mod);
  
  //logic [31:0] rs2_mod;
  logic [1:0]  sel_fw1,sel_fw2;
  logic        cond1_1, cond1_2, cond1_3, cond2_1, cond2_2, cond2_3, cond2_4;

  //selecting between immediate and rs2
  assign fw_rs2 = (alusrc) ? imm : rs2_mod;

  //takes operands of ALU from rs1 or forwarded from subsequent stages
  assign cond1_1 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && 
                   (EX_MEM_rd==ID_EX_rs1 ) && (EX_MEM_rd != 0));
  assign cond1_2 = ((MEM_WB_regwrite) && (MEM_WB_rd==ID_EX_rs1)
                    && (MEM_WB_rd != 0));
  assign cond1_3 = ((WB_ID_regwrite) && (WB_ID_rd==ID_EX_rs1)
                    && (WB_ID_rd != 0));
  assign cond2_1 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && 
                   (EX_MEM_rd==ID_EX_rs2));
  assign cond2_2 = ((MEM_WB_regwrite) && (MEM_WB_rd==ID_EX_rs2));
  assign cond2_3 = ((WB_ID_regwrite) && (WB_ID_rd==ID_EX_rs2));
  assign sel_fw1 = (ID_EX_rs1==0) ? 2'b00: cond1_1 ? 2'b10 : cond1_2 ? 2'b11 : cond1_3 ? 2'b01 : 2'b00;
  assign sel_fw2 = (ID_EX_rs2==0) ? 2'b00: cond2_1 ? 2'b10 : cond2_2 ? 2'b11 : cond2_3 ? 2'b01 : 2'b00;
    
  always_comb
    case(sel_fw1)
      2'b00 : fw_rs1 = rs1;
      2'b10 : fw_rs1 = EX_MEM_CSR_read ? EX_MEM_CSR : alures;
      2'b11 : fw_rs1 = memres;
      2'b01 : fw_rs1 = wbres;
    endcase
   
  always_comb
    case(sel_fw2)
      2'b00 : rs2_mod = rs2;
      2'b10 : rs2_mod = alures;
      2'b11 : rs2_mod = memres;
      2'b01 : rs2_mod = wbres;
    endcase
endmodule: Forwarding
