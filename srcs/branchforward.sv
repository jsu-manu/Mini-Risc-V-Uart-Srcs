`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: branchforward
// Description:
//   Implements the RISC-V branch forward logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   rs1 -- 32-bit source register 1 (rs1) value
//   rs2 -- 32-bit source register 2 (rs2) value
//   zero3 -- 
//   zero4 --
//   alusrc -- 
//   imm -- 32-bit immediate value
//   alures -- 32-bit ALU operation result
//   EX_MEM_regwrite -- indicates write
//   EX_MEM_memread -- indicates read
// Output:
//   rs1_mod -- modified 32-bit value for rs1
//   rs2_mod -- modified 32-bit value for rs2
// 
//////////////////////////////////////////////////////////////////////////////////

module branchforward
(
  input  logic [31:0] rs1,
  input  logic [31:0] rs2,
  input  logic        zero3,
  input  logic        zero4,
  input  logic        zeroa,
  input  logic        zerob,
  input  logic        alusrc,
  input  logic [31:0] imm,
  input  logic [31:0] alures,
  input  logic [31:0] wbres,
  input  logic [31:0] divres,
  input  logic        EX_MEM_regwrite,
  input  logic        MEM_WB_regwrite,
  input  logic        EX_MEM_memread,
  input  logic        div_ready,
  output logic [31:0] rs1_mod,
  output logic [31:0] rs2_mod
);
  
  logic [1:0] sel1, sel2;
  
  assign sel1 = (zero3 && EX_MEM_regwrite && (!EX_MEM_memread) && (!div_ready)) ? 2'b00 :
                (zero3 && EX_MEM_regwrite && (!EX_MEM_memread) && div_ready)    ? 2'b10 :
                (zeroa && MEM_WB_regwrite)                                     ? 2'b01 : 2'b11;

  assign sel2 = (zero4 && EX_MEM_regwrite && (!EX_MEM_memread) && (!div_ready)) ? 2'b00 :
                (zero4 && EX_MEM_regwrite && (!EX_MEM_memread) && div_ready) ? 2'b10 :
                (zerob && MEM_WB_regwrite)                      ? 2'b01 : 2'b11;


  always_comb
    case(sel1)
      2'b00:   rs1_mod = alures;
      2'b01:   rs1_mod = wbres;
      2'b10:   rs1_mod = divres;
      2'b11:   rs1_mod = rs1;
      default: rs1_mod = rs1; 
    endcase  
      
  always_comb
    case(sel2)
      2'b00:   rs2_mod = alures;
      2'b01:   rs2_mod = wbres;
      2'b10:   rs2_mod = divres;
      2'b11:   rs2_mod = rs2;
      default: rs2_mod = rs2; 
    endcase
endmodule: branchforward
