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
interface main_bus (
    input logic clk, Rst, debug, dbg, prog, mem_hold, uart_IRQ, //rx, //addr_dn, addr_up,
    input logic[4:0] debug_input, 
    input logic [95:0] key
//    output logic tx
    );
    
    logic         PC_En;
    logic         hz;
    logic         branch;
    logic  [31:0]  branoff;
    logic  [31:0]  ID_EX_pres_addr;
    logic  [31:0] ins;
    logic  [4:0]  ID_EX_rd;
    logic         ID_EX_memread,ID_EX_regwrite;
    logic  [4:0]  EX_MEM_rd,MEM_WB_rd,WB_ID_rd;
    logic  [4:0]  ID_EX_rs1,ID_EX_rs2;
    logic  [31:0] ID_EX_dout_rs1,ID_EX_dout_rs2,EX_MEM_dout_rs2;
    logic  [31:0] IF_ID_dout_rs1,IF_ID_dout_rs2;
    logic  [31:0]  IF_ID_pres_addr;
    logic         IF_ID_jalr;
    logic         ID_EX_jal,ID_EX_jalr;
    logic         ID_EX_compare;
    logic  [31:0] EX_MEM_alures,MEM_WB_alures,MEM_WB_memres;
    logic         EX_MEM_comp_res;
    
    logic [31:0] EX_MEM_pres_addr;
    logic [31:0] MEM_WB_pres_addr;
    
    logic  [4:0]  EX_MEM_rs1, EX_MEM_rs2;
    
    logic  [2:0]  ID_EX_alusel;
    logic  [4:0]  ID_EX_loadcntrl;
    logic  [2:0]  ID_EX_storecntrl;
    logic  [3:0]  ID_EX_cmpcntrl;
    logic  [4:0]  EX_MEM_loadcntrl;
    logic  [2:0]  EX_MEM_storecntrl;
    logic         ID_EX_alusrc;
    logic         EX_MEM_memread,MEM_WB_memread;
    logic         ID_EX_memwrite,EX_MEM_memwrite;
    logic         EX_MEM_regwrite,MEM_WB_regwrite,WB_ID_regwrite;
    logic         ID_EX_lui;
    logic         ID_EX_auipc;
    logic  [31:0] ID_EX_imm;
    logic  [31:0] WB_res,WB_ID_res;
    logic  [4:0]  adr_rs1;//used for debug option
    logic  [4:0]  IF_ID_rs1,IF_ID_rs2, IF_ID_rd;
    logic         ID_EX_lb,ID_EX_lh,ID_EX_lw,ID_EX_lbu,ID_EX_lhu,ID_EX_sb,ID_EX_sh,ID_EX_sw;
    logic         EX_MEM_lb,EX_MEM_lh,EX_MEM_lw,EX_MEM_lbu,EX_MEM_lhu,EX_MEM_sb,EX_MEM_sh,EX_MEM_sw;
//    logic dbg;
    logic [31:0] uart_dout;
    logic memcon_prog_ena;
    
    logic IF_ID_jal;
    
    logic mmio_wea;
    logic [31:0] mmio_dat;
    logic mmio_read;
    
    logic [31:0] DD_out;
    
    logic [31:0] mem_din, mem_dout; 
    logic [31:0] mem_addr; 
    logic [3:0] mem_en; 
    logic mem_wea;
    logic mem_rea; 
       
    logic [31:0] imem_dout;
    logic imem_en;
    logic [31:0] imem_addr;
    
    logic comp_sig;
    logic ID_EX_comp_sig;
    
//    logic push, pop, stack_ena; 
//    logic stack_mismatch, stack_full, stack_empty; 
//    logic [31:0] stack_din; 
    
    
    //CSR signals 
    logic [11:0] IF_ID_CSR_addr, ID_EX_CSR_addr; 
    logic [31:0] IF_ID_CSR, ID_EX_CSR;
    logic [31:0] EX_CSR_res;
    logic [31:0] EX_MEM_CSR, MEM_WB_CSR;
    logic [11:0] EX_CSR_addr;
    logic ID_EX_CSR_write;
    logic EX_CSR_write;
    logic MEM_WB_CSR_write;
    logic ID_EX_CSR_read, EX_MEM_CSR_read, MEM_WB_CSR_read;
    
    logic [2:0] csrsel;
    
    logic trap, ecall;
    logic [31:0] mtvec, mepc;
    
    logic trapping, trigger_trap, trap_ret, trigger_trap_ret; 
    
//    assign rbus.trapping = trapping;
    
//    assign trigger_trap = (~trapping) & trap;

	assign trap = uart_IRQ | ecall;

	always_ff @(posedge clk) begin
		if (Rst) begin
			trapping <= 0;
			trigger_trap <= 0;
			trigger_trap_ret <= 0;
		end else begin
			if (trap & (~trapping)) begin
				trapping <= 1;
				trigger_trap <= 1;
			end else trigger_trap <= 0;
			
			if (trap_ret & (trapping)) begin
				trapping <= 0;
				trigger_trap_ret <= 1;
			end else trigger_trap_ret <= 0;
		end
	end
    
//    always_ff @(posedge trigger_trap or posedge trap_ret or posedge Rst) begin
//    	if (Rst) trapping <= 0;
//    	else if (trigger_trap) trapping <= 1;
//    	else if (trap_ret) trapping <= 0;
//    end
//    logic ID_EX_CSR_write;

    //modport declarations. These ensure each pipeline stage only sees and has access to the 
    //ports and signals that it needs
    
    
    
    //modport for fetch stage
    modport fetch(
        input clk, PC_En, debug, prog, Rst, branch, IF_ID_jalr, IF_ID_jal,
        input dbg, mem_hold,
        input trap, mtvec, mepc, trigger_trap,  trap_ret, trigger_trap_ret,
        //input rx,
        input uart_dout, memcon_prog_ena, 
        input debug_input, branoff,
        output IF_ID_pres_addr, ins, 
        input imem_dout,
        output imem_en, imem_addr, comp_sig
    );
    
    //modport for register file
    modport regfile(
        input clk, adr_rs1, IF_ID_rs2, MEM_WB_rd, Rst,
        input WB_res, MEM_WB_regwrite, mem_hold,
        output IF_ID_dout_rs1, IF_ID_dout_rs2 
    ); 
        
    //modport for decode stage
    modport decode(
        input clk, Rst, dbg, ins, IF_ID_pres_addr, MEM_WB_rd, WB_res, mem_hold, comp_sig,
        input EX_MEM_memread, EX_MEM_regwrite, MEM_WB_regwrite, EX_MEM_alures,
        input EX_MEM_rd, IF_ID_dout_rs1, IF_ID_dout_rs2, 
        input IF_ID_CSR, trap, trigger_trap,
        inout ID_EX_memread, ID_EX_regwrite,
        output ID_EX_pres_addr, IF_ID_jalr, ID_EX_jalr, branch, IF_ID_jal,
        output IF_ID_rs1, IF_ID_rs2, IF_ID_rd,
        output ID_EX_dout_rs1, ID_EX_dout_rs2, branoff, hz,
        output ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_alusel,
        output ID_EX_storecntrl, ID_EX_loadcntrl, ID_EX_cmpcntrl,
        output ID_EX_auipc, ID_EX_lui, ID_EX_alusrc, 
        output ID_EX_memwrite, ID_EX_imm, ID_EX_compare, ID_EX_jal, 
        output IF_ID_CSR_addr, ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read, ecall, ID_EX_comp_sig, 
        output trap_ret
    );
     
    //modport for execute stage    
    modport execute(
        input clk, Rst, dbg, ID_EX_lui, ID_EX_auipc, ID_EX_loadcntrl, mem_hold,
        input ID_EX_storecntrl, ID_EX_cmpcntrl, 
        output EX_MEM_loadcntrl, EX_MEM_storecntrl, 
        input ID_EX_compare, ID_EX_pres_addr, ID_EX_alusel, ID_EX_alusrc,
        input ID_EX_memread, ID_EX_memwrite, ID_EX_regwrite, ID_EX_jal,
        input ID_EX_jalr, ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_dout_rs1, ID_EX_dout_rs2,
        output EX_MEM_dout_rs2, EX_MEM_rs2, EX_MEM_rs1,
        input ID_EX_imm, MEM_WB_regwrite, WB_ID_regwrite,
        output EX_MEM_alures,
        input WB_res, WB_ID_res, 
        output EX_MEM_memread, EX_MEM_rd,
        input MEM_WB_rd, WB_ID_rd,
        output EX_MEM_memwrite, EX_MEM_regwrite, EX_MEM_comp_res, 
        output EX_MEM_pres_addr,
        input key, 
        input ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read,
        output EX_CSR_res, EX_CSR_addr, EX_CSR_write, EX_MEM_CSR, EX_MEM_CSR_read,
        input ID_EX_comp_sig
    );
    
    //modport for memory stage
    modport memory (
        input clk, Rst, dbg, EX_MEM_storecntrl, mmio_read, mem_hold,
        input EX_MEM_pres_addr,
        input EX_MEM_loadcntrl, EX_MEM_alures, EX_MEM_dout_rs2, EX_MEM_rs2, WB_res, EX_MEM_rs1,
        input EX_MEM_rd, EX_MEM_regwrite, EX_MEM_memread, EX_MEM_memwrite,
        output MEM_WB_regwrite, MEM_WB_memread, MEM_WB_rd, MEM_WB_alures, MEM_WB_memres,
        output mmio_wea, mmio_dat, 
        
        input mem_dout, 
        output MEM_WB_pres_addr,
        output mem_din, mem_addr, mem_wea, mem_en, mem_rea,
        
        input EX_MEM_CSR, EX_MEM_CSR_read,
        output MEM_WB_CSR, MEM_WB_CSR_read
    );
    
    //modport for writeback stage
    modport writeback(
        input clk, Rst, dbg, MEM_WB_alures, MEM_WB_memres, MEM_WB_memread, mem_hold,
        input MEM_WB_regwrite, MEM_WB_rd,
        input MEM_WB_CSR, MEM_WB_CSR_read,
        output WB_ID_regwrite, WB_ID_rd, WB_res, WB_ID_res
    );
    
//    modport rstack(
//        input clk, Rst, stack_ena, push, pop, stack_din,
//        output stack_mismatch, stack_full, stack_empty
//    );
    
    //modport for UART programmer
//    modport UART_Programmer(
//        input clk, Rst, rx,
//        output uart_dout, memcon_prog_ena
//    );
    
//    modport tx_control(
//        input clk, Rst, mmio_wea, mmio_dat,
//        output tx, mmio_read
//    );
    
//    modport Debug_Display(
//        input clk, Rst, mmio_wea, mmio_dat, 
////        input addr_dn, addr_up,
//        input debug_input, prog,
//        output DD_out
//    );
   
    
endinterface

module RISCVcore_uart(    
    riscv_bus rbus 
//    input   logic         clk,
//    input   logic         Rst,
//    input   logic         debug,
//    input   logic         rx, //uart recv
//    input   logic         prog, //reprogram or view instruction memory
//    input   logic [4:0]   debug_input,
//    output  logic [31:0]  debug_output,
    
//    output logic mem_wea,
//    output logic [3:0] mem_en, 
//    output logic [11:0] mem_addr, 
//    output logic [31:0] mem_din, 
//    input logic [31:0] mem_dout
//    input logic addr_dn, addr_up
//    output  logic         tx
    );
    //logic addr_dn = 0, addr_up = 0;
    
    logic clk, Rst, debug, prog, mem_wea, dbg; //rx,
    logic [4:0] debug_input;
    logic [31:0] debug_output, mem_addr, mem_din, mem_dout; 
    logic [3:0] mem_en; 
    
    logic trap;
    
   
    
    always_comb begin
        clk = rbus.clk; 
        Rst = rbus.Rst; 
        debug = rbus.debug; 
        //rx = rbus.rx; 
        prog = rbus.prog; 
        debug_input = rbus.debug_input; 
//        rbus.debug_output = debug_output; 
		rbus.debug_output = bus.mepc;
        rbus.mem_wea = mem_wea; 
        rbus.mem_rea = bus.mem_rea;
        rbus.mem_en = mem_en; 
        rbus.mem_addr = mem_addr; 
        rbus.mem_din = mem_din; 
        mem_dout = rbus.mem_dout; 
        rbus.imem_en = bus.imem_en;
        rbus.imem_addr = bus.imem_addr;
        bus.imem_dout = rbus.imem_dout;
        rbus.imem_din = bus.uart_dout;
        rbus.imem_prog_ena = bus.memcon_prog_ena;
    end
    
    
    main_bus bus(.key(rbus.key), .mem_hold(rbus.mem_hold), .uart_IRQ(rbus.uart_IRQ), .*);
    
     assign rbus.storecntrl = bus.EX_MEM_storecntrl;
     assign rbus.trapping = bus.trapping;
    
    assign mem_wea = bus.mem_wea;
//    assign mem_clk = bus.clk;
    assign mem_en = bus.mem_en;
    assign mem_addr = bus.mem_addr;
    assign mem_din = bus.mem_din;
    assign bus.mem_dout = mem_dout;
    
    
//    assign bus.PC_En=!bus.hz;
    assign bus.PC_En=(!bus.hz);
    assign dbg=(debug || prog); //added to stop pipeline on prog and/or debug
    //debugging resister
    assign bus.adr_rs1=debug ? debug_input:bus.IF_ID_rs1;
    
//    assign bus.trap = trap;
    
//    always_comb begin : stackstuff
//        bus.push = (bus.IF_ID_jal | bus.IF_ID_jalr) & (bus.IF_ID_rd != 0);
//        bus.pop = (bus.IF_ID_jalr) & (bus.IF_ID_rd == 0); 
//        bus.stack_ena = 1;
//        bus.stack_din = bus.push ? (bus.IF_ID_pres_addr + 4) : bus.pop ? (bus.branoff) : 32'h0; 
//    end
    
    always_ff @(posedge clk) begin
        if(Rst) begin
            debug_output<=32'h00000000;
//            trap <= 0;
//            bus.trapping <= 0;
        end
        else if (prog) begin //debug instruction memory
            debug_output<=bus.ins;
        end
        else if(debug) begin //debug register
            debug_output<= bus.IF_ID_dout_rs1;
        end
        else begin
//            debug_output<=bus.mmio_dat;
            debug_output<=32'h00000000;
        end
    end

    Fetch_Reprogrammable u1(bus.fetch);
    
    //register file
    Regfile u0(bus.regfile);
    
    Decode u2(bus.decode);
    
    Execute u3(bus.execute);
    
    Memory u4(bus.memory);
    
    Writeback u5(bus.writeback);
    
//    ra_stack uS(bus.rstack);
    
    CSR uC(.bus(bus));
    
//    UART_Programmer uart(bus.UART_Programmer);
   
//    tx_control txc(bus.tx_control);
    
//    Debug_Display DD(bus.Debug_Display);
    
    
    
endmodule
