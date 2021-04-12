`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Writeback
// Description:
//   Implements the writeback function of a RISC-V pipeline
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   MEM_WB_alures -- 32-bit registered value from ALU
//   MEM_WB_memres -- 32-bit value from memory
//   MEM_WB_memread -- 1-bit signal indicating writeback from memory or ALU
// Output:
//   WB_res -- 32-bit value to be written back to register file
// 
//////////////////////////////////////////////////////////////////////////////////


module Writeback(main_bus bus);
  
  logic [31:0] WB_res_sig; 
  assign WB_res_sig = (bus.MEM_WB_memread)  ? bus.MEM_WB_memres :
                      (bus.MEM_WB_CSR_read) ? bus.MEM_WB_CSR :
                      (bus.MEM_WB_mul_ready) ? bus.MEM_WB_mulres :
                      (bus.MEM_WB_div_ready) ? bus.MEM_WB_divres : bus.MEM_WB_alures;
  assign bus.WB_res     = WB_res_sig;
  
  always_ff @(posedge bus.clk) begin
        if (bus.Rst)begin
            bus.WB_ID_rd<=5'b00000;
            bus.WB_ID_res<=32'h00000000;
            bus.WB_ID_regwrite<=1'b0;
        end
        
        else if (!bus.dbg && !bus.mem_hold)begin
            bus.WB_ID_rd<=bus.MEM_WB_rd;
            bus.WB_ID_res<=WB_res_sig;
            bus.WB_ID_regwrite<=bus.MEM_WB_regwrite;
        end
  end
endmodule: Writeback
