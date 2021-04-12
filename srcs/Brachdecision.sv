`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
//
// Created:
//   October 30, 2018
//
// Module name: Branchdecision
// Description:
//   Implements the RISC-V branch decision logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   rs1_mod -- modified rs1 value from branchforward
//   rs2_mod -- modified rs1 value from branchforward
//   branch -- indicates branch
//   funct3 -- funct3 opcode field
//   jal -- indicates jump and link
//   jalr -- indicates jump and link for subrouting return
// Output:
//   branch_taken -- flag branch taken
//
//////////////////////////////////////////////////////////////////////////////////

module Branchdecision
 (input  logic [31:0] rs1_mod,
  input  logic [31:0] rs2_mod,
  input  logic        branch,
  input  logic [2:0]  funct3,
  output logic        branch_taken,
  input  logic        hazard,
  input  logic        jal,
  input  logic        jalr);

  logic [32:0] sub_res; //comparison result of rs1 and rs2 including carry out;
  logic sel,zero,less,lessu;
  logic beq, bne, blt, bge, bltu, bgeu;

  assign sub_res = rs1_mod - rs2_mod;

  assign zero = !(|sub_res[31:0]);
  assign less = ($signed(rs1_mod) < $signed(rs2_mod));
  assign lessu= (rs1_mod < rs2_mod);
  assign beq = !(|funct3) && branch;
  assign bne = (!funct3[2]) && (!funct3[1]) && (funct3[0]) && branch;
  assign blt = (funct3[2]) && (!funct3[1]) && (!funct3[0]) && branch;
  assign bge = (funct3[2]) && (!funct3[1]) && funct3[0] && branch;
  assign bltu= (funct3[2]) && (funct3[1]) && (!funct3[0]) && branch;
  assign bgeu= (funct3[2]) && (funct3[1]) && (funct3[0]) && branch;


  assign branch_taken = ((beq && zero) || (bne && (!zero)) || (blt && less) ||
                        (bge &&  (!less)) || (bltu && lessu) || (bgeu && (!lessu)) || jal || jalr) && (!hazard);


endmodule: Branchdecision
