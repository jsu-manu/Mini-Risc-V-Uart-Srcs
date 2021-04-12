`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Regfile
// Description:
//   Implements the RISC-V register file as an array of 32 32-bit registers
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   adr_rs1 -- 5-bit address for source register 1 (rs1)
//   adr_rs2 -- 5-bit address for source register 2 (rs2)
//   adr_rd -- 5-bit address for destination register (rd)
//   din_rd -- 32-bit value to be written to desitination register (rd)
//   regwrite -- 1-bit register write control
// Output:
//   dout_rs1 -- 32-bit value read from source register 1 (rs1)
//   dout_rs2 -- 32-bit value read from source register 2 (rs2)
// 
//////////////////////////////////////////////////////////////////////////////////

//modport regfile(
//        input clk, adr_rs1, IF_ID_rs2, MEM_WB_rd,
//        input WB_res, MEM_WB_regwrite,
//        output IF_ID_dout_rs1, IF_ID_dout_rs2 ); 

module Regfile(main_bus bus);
  
  
  logic [31:0] regdata[31:0];  // array of 32 32-bit registers
  logic        wen;

  //write enable if regwrite is asserted and read address is not zero
  assign wen = bus.MEM_WB_regwrite && |bus.MEM_WB_rd;
    
  assign bus.IF_ID_dout_rs1 = |bus.adr_rs1 ? regdata[bus.adr_rs1] : |bus.adr_photon_rs1 ? regdata[bus.adr_photon_rs1] : 0;
  assign bus.IF_ID_dout_rs2 = |bus.IF_ID_rs2 ? regdata[bus.IF_ID_rs2] : 0;

  always_ff @(posedge bus.clk)begin
    if(bus.Rst)
        regdata[2] <= 1020;
    if(wen && ~bus.mem_hold)
      regdata[bus.MEM_WB_rd] <= bus.WB_res;
    if (bus.photon_regwrite)
      regdata[bus.addr_corereg_photon] <= bus.photon_data_out;
  end
  `ifndef SYNTHESIS
    integer i;
    initial begin
      for(i=0; i<32 ;i=i+1)begin
      	regdata[i] = 0;
//        if (i == 2)
//            regdata[i] = 511; 
//        else
//            regdata[i] = $random;
      end
        end
      `endif
    endmodule: Regfile

