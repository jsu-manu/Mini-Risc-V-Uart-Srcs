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
(
  input  logic        EX_MEM_regwrite,
  input  logic        EX_MEM_memread,
  input  logic        MEM_WB_regwrite,
  input  logic        WB_ID_regwrite,
  input  logic [4:0]  EX_MEM_rd,
  input  logic [4:0]  MEM_WB_rd,
  input  logic [4:0]  WB_ID_rd,
  input  logic [4:0]  ID_EX_rs1,
  input  logic [4:0]  ID_EX_rs2,
  input  logic [31:0] alures,
  input  logic [31:0] divres,
  input  logic [31:0] mulres,
  input  logic [31:0] memres,
  input  logic [31:0] wbres,
  input  logic        alusrc,
  input  logic [31:0] imm,
  input  logic [31:0] rs1,
  input  logic [31:0] rs2,
  input  logic        div_ready,
  input  logic        mul_ready,
  output logic [31:0] fw_rs1,
  output logic [31:0] fw_rs2,
  output logic [31:0] rs2_mod
);
  
  logic [2:0] sel_fw1, sel_fw2;
  logic       cond1_1, cond1_2, cond1_3, cond1_4, cond1_5, cond2_1, cond2_2, cond2_3, cond2_4, cond2_5;

  //selecting between immediate and rs2
  assign fw_rs2 = (alusrc) ? imm : rs2_mod;

  //takes operands of ALU from rs1 or forwarded from subsequent stages
  assign cond1_1 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs1) && (EX_MEM_rd != 0) && (!div_ready) && (!mul_ready));
  assign cond1_2 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs1) && (EX_MEM_rd != 0) && div_ready && (!mul_ready));
  assign cond1_3 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs1) && (EX_MEM_rd != 0) && (!div_ready) && mul_ready);
  assign cond1_4 = ((MEM_WB_regwrite) && (MEM_WB_rd == ID_EX_rs1) && (MEM_WB_rd != 0));
  assign cond1_5 = ((WB_ID_regwrite) && (WB_ID_rd == ID_EX_rs1) && (WB_ID_rd != 0));
  assign cond2_1 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs2) && (!div_ready) && (!mul_ready));
  assign cond2_2 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs2) && div_ready && (!mul_ready));
  assign cond2_3 = ((EX_MEM_regwrite && (!EX_MEM_memread)) && (EX_MEM_rd == ID_EX_rs2) && (!div_ready) && mul_ready);
  assign cond2_4 = ((MEM_WB_regwrite) && (MEM_WB_rd == ID_EX_rs2));
  assign cond2_5 = ((WB_ID_regwrite) && (WB_ID_rd == ID_EX_rs2));

  assign sel_fw1 = (ID_EX_rs1 == 0) ? 3'b000 :
                   cond1_1          ? 3'b010 :
                   cond1_2          ? 3'b011 :
                   cond1_3          ? 3'b100 :
                   cond1_4          ? 3'b101 :
                   cond1_5          ? 3'b001 : 3'b000;
  assign sel_fw2 = (ID_EX_rs2 == 0) ? 3'b000 :
                   cond2_1          ? 3'b010 :
                   cond2_2          ? 3'b011 :
                   cond2_3          ? 3'b100 :
                   cond2_4          ? 3'b101 :
                   cond2_5          ? 3'b001 : 3'b000;
    
  always_comb
    case(sel_fw1)
      3'b000:  fw_rs1 = rs1;
      3'b010:  fw_rs1 = alures;
      3'b011:  fw_rs1 = divres;
      3'b100:  fw_rs1 = mulres;
      3'b101:  fw_rs1 = memres;
      3'b001:  fw_rs1 = wbres;
      default: fw_rs1 = rs1;
    endcase
   
  always_comb
    case(sel_fw2)
      3'b000:  rs2_mod = rs2;
      3'b010:  rs2_mod = alures;
      3'b011:  rs2_mod = divres;
      3'b100:  rs2_mod = mulres;
      3'b101:  rs2_mod = memres;
      3'b001:  rs2_mod = wbres;
      default: rs2_mod = rs2;
    endcase
endmodule: Forwarding
