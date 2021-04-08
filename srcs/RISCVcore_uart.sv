`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: RISCVcore
// Description:
//   Implements top Mini-RISC-V core logic
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset signal
//   debug -- 1-bit debug control signal
//   debug_input -- 5-bit register address for viewing via debug port
// Output:
//   debug_output -- 32-bit output port for viewing contents of register
// 
//////////////////////////////////////////////////////////////////////////////////

//Interface bus between all pipeline stages
interface main_bus
(
  input logic        clk, Rst, debug, dbg, prog, mem_hold,
  input logic [4:0]  debug_input, 
  input logic [95:0] key
);
    
  logic        PC_En;
  logic        hz;
  logic        branch;
  logic [31:0] branoff;
  logic [31:0] ID_EX_pres_addr;
  logic [31:0] ins;
  logic [4:0]  ID_EX_rd;
  logic        ID_EX_memread, ID_EX_regwrite;
  logic [4:0]  EX_MEM_rd, MEM_WB_rd, WB_ID_rd;
  logic [4:0]  ID_EX_rs1, ID_EX_rs2;
  logic [31:0] ID_EX_dout_rs1, ID_EX_dout_rs2, EX_MEM_dout_rs2;
  logic [31:0] IF_ID_dout_rs1, IF_ID_dout_rs2;
  logic [31:0] IF_ID_pres_addr;
  logic        IF_ID_jalr;
  logic        ID_EX_jal, ID_EX_jalr;
  logic        ID_EX_compare;
  logic [31:0] EX_MEM_alures, MEM_WB_alures, MEM_WB_memres;
  logic [31:0] EX_MEM_mulres, MEM_WB_mulres;
  logic        EX_MEM_mulvalid;
  logic [31:0] EX_MEM_divres, MEM_WB_divres;
  logic        EX_MEM_divvalid;
  logic        EX_MEM_comp_res;
    
  logic [31:0] EX_MEM_pres_addr;
  logic [31:0] MEM_WB_pres_addr;
    
  logic [4:0]  EX_MEM_rs1, EX_MEM_rs2;
    
  logic [2:0]  ID_EX_alusel;
  logic [2:0]  ID_EX_mulsel;
  logic [2:0]  ID_EX_divsel;
  logic [4:0]  ID_EX_loadcntrl;
  logic [2:0]  ID_EX_storecntrl;
  logic [3:0]  ID_EX_cmpcntrl;
  logic [4:0]  EX_MEM_loadcntrl;
  logic [2:0]  EX_MEM_storecntrl;
  logic        ID_EX_alusrc;
  logic        EX_MEM_memread, MEM_WB_memread;
  logic        ID_EX_memwrite, EX_MEM_memwrite;
  logic        EX_MEM_regwrite, MEM_WB_regwrite, WB_ID_regwrite;
  logic        ID_EX_lui;
  logic        ID_EX_auipc;
  logic [31:0] ID_EX_imm;
  logic [31:0] WB_res, WB_ID_res;
  logic [4:0]  adr_rs1; //used for debug option
  logic [4:0]  IF_ID_rs1, IF_ID_rs2, IF_ID_rd;
  logic        ID_EX_lb, ID_EX_lh, ID_EX_lw, ID_EX_lbu, ID_EX_lhu, ID_EX_sb, ID_EX_sh, ID_EX_sw;
  logic        EX_MEM_lb, EX_MEM_lh, EX_MEM_lw, EX_MEM_lbu, EX_MEM_lhu, EX_MEM_sb, EX_MEM_sh, EX_MEM_sw;
  logic [31:0] uart_dout;
  logic        memcon_prog_ena;
    
  logic        IF_ID_jal;
    
  logic        mmio_wea;
  logic [31:0] mmio_dat;
  logic        mmio_read;
    
  logic [31:0] DD_out;
    
  logic [31:0] mem_din, mem_dout; 
  logic [31:0] mem_addr; 
  logic [3:0]  mem_en; 
  logic        mem_wea;
  logic        mem_rea; 
       
  logic [31:0] imem_dout;
  logic        imem_en;
  logic [31:0] imem_addr;
    
  //CSR signals 
  logic [11:0] IF_ID_CSR_addr, ID_EX_CSR_addr; 
  logic [31:0] IF_ID_CSR, ID_EX_CSR;
  logic [31:0] EX_CSR_res;
  logic [31:0] EX_MEM_CSR, MEM_WB_CSR;
  logic [11:0] EX_CSR_addr;
  logic        ID_EX_CSR_write;
  logic        EX_CSR_write;
  logic        MEM_WB_CSR_write;
  logic        ID_EX_CSR_read, EX_MEM_CSR_read, MEM_WB_CSR_read;
    
  logic [2:0]  csrsel;
    
  logic        trap, ecall;
  logic [31:0] mtvec;
  
  logic        mul_ready;
  logic        EX_MEM_mul_ready, MEM_WB_mul_ready;
  logic        div_ready;
  logic        EX_MEM_div_ready, MEM_WB_div_ready;

  //modport declarations. These ensure each pipeline stage only sees and has access to the 
  //ports and signals that it needs

  //modport for fetch stage
  modport fetch
  (
    input  clk, PC_En, debug, prog, Rst, branch, IF_ID_jalr, IF_ID_jal,
    input  dbg, mem_hold,
    input  trap, mtvec,
    input  uart_dout, memcon_prog_ena,
    input  debug_input, branoff,
    output IF_ID_pres_addr, ins, 
    input  imem_dout, 
    output imem_en, imem_addr
  );
  
  //modport for register file
  modport regfile
  (
    input  clk, adr_rs1, IF_ID_rs2, MEM_WB_rd, Rst,
    input  WB_res, MEM_WB_regwrite,
    output IF_ID_dout_rs1, IF_ID_dout_rs2 
  ); 
      
  //modport for decode stage
  modport decode
  (
    input  clk, Rst, dbg, ins, IF_ID_pres_addr, MEM_WB_rd, WB_res, mem_hold,
    input  EX_MEM_memread, EX_MEM_regwrite, MEM_WB_regwrite, EX_MEM_alures, EX_MEM_divres, EX_MEM_mulres,
    input  EX_MEM_rd, IF_ID_dout_rs1, IF_ID_dout_rs2, 
    input  IF_ID_CSR, trap,
    input  mul_ready, div_ready,
    inout  ID_EX_memread, ID_EX_regwrite,
    output ID_EX_pres_addr, IF_ID_jalr, ID_EX_jalr, branch, IF_ID_jal,
    output IF_ID_rs1, IF_ID_rs2, IF_ID_rd,
    output ID_EX_dout_rs1, ID_EX_dout_rs2, branoff, hz,
    output ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_alusel,
    output ID_EX_storecntrl, ID_EX_loadcntrl, ID_EX_cmpcntrl,
    output ID_EX_auipc, ID_EX_lui, ID_EX_alusrc, 
    output ID_EX_memwrite, ID_EX_imm, ID_EX_compare, ID_EX_jal, 
    output IF_ID_CSR_addr, ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read, ecall,
    output ID_EX_mulsel, ID_EX_divsel
  );
   
  //modport for execute stage    
  modport execute
  (
    input  clk, Rst, dbg, ID_EX_lui, ID_EX_auipc, ID_EX_loadcntrl, mem_hold,
    input  ID_EX_storecntrl, ID_EX_cmpcntrl, 
    output EX_MEM_loadcntrl, EX_MEM_storecntrl, 
    input  ID_EX_compare, ID_EX_pres_addr, ID_EX_alusel, ID_EX_alusrc,
    input  ID_EX_mulsel, ID_EX_divsel,
    input  ID_EX_memread, ID_EX_memwrite, ID_EX_regwrite, ID_EX_jal,
    input  ID_EX_jalr, ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_dout_rs1, ID_EX_dout_rs2,
    output EX_MEM_dout_rs2, EX_MEM_rs2, EX_MEM_rs1,
    input  ID_EX_imm, MEM_WB_regwrite, WB_ID_regwrite,
    output EX_MEM_alures,
    input  WB_res, WB_ID_res, 
    output EX_MEM_memread, EX_MEM_rd,
    input  MEM_WB_rd, WB_ID_rd,
    output EX_MEM_memwrite, EX_MEM_regwrite, EX_MEM_comp_res, 
    output EX_MEM_pres_addr,
    input  key, 
    input  ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read,
    output EX_CSR_res, EX_CSR_addr, EX_CSR_write, EX_MEM_CSR, EX_MEM_CSR_read,
    output mul_ready, EX_MEM_mul_ready, div_ready, EX_MEM_div_ready,
    output EX_MEM_mulres, EX_MEM_divres
  );
  
  //modport for memory stage
  modport memory
  (
    input  clk, Rst, dbg, EX_MEM_storecntrl, mmio_read, mem_hold,
    input  EX_MEM_pres_addr,
    input  EX_MEM_loadcntrl, EX_MEM_alures, EX_MEM_dout_rs2, EX_MEM_rs2, WB_res, EX_MEM_rs1,
    input  EX_MEM_rd, EX_MEM_regwrite, EX_MEM_memread, EX_MEM_memwrite,
    output MEM_WB_regwrite, MEM_WB_memread, MEM_WB_rd, MEM_WB_alures, MEM_WB_memres,
    output mmio_wea, mmio_dat, 
    
    input  mem_dout, 
    output MEM_WB_pres_addr,
    output mem_din, mem_addr, mem_wea, mem_en, mem_rea,
    
    input  EX_MEM_CSR, EX_MEM_CSR_read,
    output MEM_WB_CSR, MEM_WB_CSR_read,
    input  EX_MEM_mul_ready, EX_MEM_div_ready,
    input  EX_MEM_mulres, EX_MEM_divres,
    output MEM_WB_mul_ready, MEM_WB_div_ready,
    output MEM_WB_mulres, MEM_WB_divres
  );
  
  //modport for writeback stage
  modport writeback
  (
    input  clk, Rst, dbg, MEM_WB_alures, MEM_WB_memres, MEM_WB_memread, mem_hold,
    input  MEM_WB_regwrite, MEM_WB_rd,
    input  MEM_WB_CSR, MEM_WB_CSR_read,
    input  MEM_WB_mul_ready, MEM_WB_div_ready,
    input  MEM_WB_mulres, MEM_WB_divres,
    output WB_ID_regwrite, WB_ID_rd, WB_res, WB_ID_res
  );
endinterface

module RISCVcore_uart(riscv_bus rbus);
  logic        clk, Rst, debug, prog, mem_wea, dbg;
  logic [4:0]  debug_input;
  logic [31:0] debug_output, mem_addr, mem_din, mem_dout; 
  logic [3:0]  mem_en; 
    
  logic trap;
    
  always_comb
  begin
    clk                = rbus.clk; 
    Rst                = rbus.Rst; 
    debug              = rbus.debug;
    prog               = rbus.prog; 
    debug_input        = rbus.debug_input; 
    rbus.debug_output  = debug_output; 
    rbus.mem_wea       = mem_wea; 
    rbus.mem_rea       = bus.mem_rea;
    rbus.mem_en        = mem_en; 
    rbus.mem_addr      = mem_addr; 
    rbus.mem_din       = mem_din; 
    mem_dout           = rbus.mem_dout; 
    rbus.imem_en       = bus.imem_en;
    rbus.imem_addr     = bus.imem_addr;
    bus.imem_dout      = rbus.imem_dout;
    rbus.imem_din      = bus.uart_dout;
    rbus.imem_prog_ena = bus.memcon_prog_ena;
  end
    
    
  main_bus bus(.key(rbus.key), .mem_hold(rbus.mem_hold), .*);
  
  assign mem_wea      = bus.mem_wea;
  assign mem_en       = bus.mem_en;
  assign mem_addr     = bus.mem_addr;
  assign mem_din      = bus.mem_din;
  assign bus.mem_dout = mem_dout;
  
  assign bus.PC_En = (!bus.hz);
  assign dbg       = (debug || prog); //added to stop pipeline on prog and/or debug
  //debugging resister
  assign bus.adr_rs1 = debug ? debug_input : bus.IF_ID_rs1;
  
  assign bus.trap = trap;
  
  always_ff @(posedge clk)
  begin
    if (Rst)
    begin
      debug_output <= 32'h00000000;
      trap         <= 0;
    end
    else if (prog) //debug instruction memory
    begin
      debug_output <= bus.ins;
    end
    else if (debug) //debug register
    begin
      debug_output <= bus.IF_ID_dout_rs1;
    end
    else
    begin
      debug_output <= 32'h00000000;
    end
  end

  Fetch_Reprogrammable u1(bus.fetch);
  
  //register file
  Regfile u0(bus.regfile);
  
  Decode u2(bus.decode);
  
  Execute u3(bus.execute);

  Memory u4(bus.memory);
  
  Writeback u5(bus.writeback);   
endmodule
