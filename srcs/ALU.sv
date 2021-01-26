`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2018 05:58:47 PM
// Design Name: 
// Module Name: ALU
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
//   Implements the RISC-V ALU block (part of execute pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   a -- 32-bit input "a"
//   b -- 32-bit input "b"
//   ID_EX_pres_adr -- present address (program counter) from decoder
//   sel -- ALU select bits from decoder stage
//   addb -- 
//   logicb --
//   rightb --
//   ID_EX_jal --
//   ID_EX_jalr --
//   ID_EX_compare --
// Output:
//   res -- ALU operation result
//   comp_res -- ALU result of comparison
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU
 (input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [31:0]  ID_EX_pres_adr, //jal instr
  input  logic [2:0]  alusel,
  input  logic        ID_EX_lui,
  input  logic        ID_EX_jal,
  input  logic        ID_EX_jalr,
  input  logic        ID_EX_auipc,
  input  logic        ID_EX_compare,
  //input logic [95:0] key,
  input logic [2:0] csrsel,
  output logic [31:0] res,
  output logic        comp_res, 
  output logic [31:0] CSR_res, 
  input logic [31:0] CSR_in, 
  input logic ID_EX_comp_sig);
  
  logic [31:0] s;
  logic [32:0] comp_res_temp;
//  logic [31:0] csr_s; 

//  assign comp_res_temp = a - b;
//  assign comp_res= (a < b);
    assign comp_res_temp = (a < b);
    
    logic [31:0] addr_incr;
    
    assign addr_incr = ID_EX_comp_sig ? 2 : 4;

  always_comb
    case(alusel)
      3'b000 : s = a+b;
      3'b001 : s = a-b;
      3'b010 : s = a&b;
      3'b011 : s = a|b;
      3'b100 : s = a^b;
      3'b101 : s = a<<b[4:0];
      3'b110 : s = a>>b[4:0];
      3'b111 : s = a>>>b[4:0];
    endcase
    
 always_comb begin
    case (csrsel)
        3'b001: CSR_res = a; //CSRRW
        3'b010: CSR_res = CSR_in | a; //CSRRS
        3'b011: CSR_res = CSR_in | ~a; //CSRRC
        3'b101: CSR_res = b; //CSRRWI
        3'b110: CSR_res = CSR_in | b; //CSRRSI
        3'b111: CSR_res = CSR_in | ~b; //CSRRCI
        default: CSR_res = 0;
    endcase
 end

//    logic [95:0] key;

//    ALU_chaos ac0(.a(a), .b(b), .opcode(alusel), .key(key), .y(s));

//  assign res = (ID_EX_lui) ? b : (ID_EX_jal||ID_EX_jalr) ? {24'h000000,ID_EX_pres_adr} : 
//                                         ((ID_EX_compare&&comp_res) ? 
//                                          32'h1 : s);
//    assign res = (ID_EX_lui) ? b : (ID_EX_jal||ID_EX_jalr) ? {24'h000000,ID_EX_pres_adr} : 
//                                         ((ID_EX_compare&&comp_res_temp) ? 
//                                          32'h1 : s);
    assign res = (ID_EX_lui) ? b : (ID_EX_auipc) ? (b + ID_EX_pres_adr[11:0]) :  (ID_EX_jal) ? (ID_EX_pres_adr+addr_incr) : (ID_EX_jalr) ? (ID_EX_pres_adr+addr_incr) : 
                                         ((ID_EX_compare&&comp_res_temp) ? 
                                          32'h1 : s);
endmodule: ALU