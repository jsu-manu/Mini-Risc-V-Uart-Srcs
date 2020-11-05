`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: Memory
// Description:
//   Implements the RISC-V register file as an array of 32 32-bit registers
//   Specifically designed for Xilinx FPGA implementation using Block RAM
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset
//   debug -- 1-bit debug control signal
//   EX_MEM_alures -- 32-bit result from ALU
//   EX_MEM_alusec -- second 32-bit operand for ALU
//   EX_MEM_rd -- 5-bit destination register number
//   EX_MEM_regwrite -- 1-bit register write control
//   EX_MEM_memread -- 1-bit memory read control
//   EX_MEM_memwrite -- 1-bit memory write control
// Output:
//   MEM_WB_regwrite -- 1-bit control for register writeback control
//   MEM_WB_memread -- 1-bit memory read writeback control
//   MEM_WB_rd -- 5-bit destination register number
//   MEM_WB_alures -- 32-bit registered value from ALU
//   MEM_WB_memres -- 32-bit value from memory
// 
//////////////////////////////////////////////////////////////////////////////////

module Memory(main_bus bus);
  
  logic [31:0] MEM_WB_memres_sig,MEM_WB_memres_temp;
  logic [31:0] MEM_WB_memres;
  logic [1:0]  MEM_WB_dout_sel;
  logic        En;
  logic [4:0]  load_control;
  logic        MEM_WB_lb,MEM_WB_lh,MEM_WB_lw,MEM_WB_lbu,MEM_WB_lhu;
  logic [4:0]  MEM_WB_loadcntrl;
  logic [3:0]  byte_write;
  logic [7:0]  d0,d1,d2,d3;
  logic [31:0] memforward; 
  logic MEM_WB_memwrite;
  logic [31:0] MEM_WB_dout_rs2;
//  logic [11:0] addr;
  logic mmio_wea;
  logic set_mmio_wea;
  logic [31:0] mmio_dat;
  logic set_mmio_dat;
  assign En=1'b1;
  
//  logic [31:0] MEM_WB_alures;
  
//   initial begin
//    mmio_dat = 32'h00000000;
//    mmio_wea = 0;
//    set_mmio_wea = 0;
//    set_mmio_dat = 0;
//   end
 /*
  always_comb
  unique casez(EX_MEM_storecntrl)
        3'b001: byte_write=4'b0001;
        3'b010: byte_write=4'b0011;
        3'b100: byte_write=4'b1111;
        3'b000: byte_write=4'b0000;
  endcase   
  */
   always_comb 
   
       unique case(bus.EX_MEM_storecntrl)
             3'b001: // store byte (sb)
                 begin
                      unique case(bus.EX_MEM_alures[1:0])
                         2'b00: byte_write = 4'b0001;
                         2'b01: byte_write = 4'b0010;
                         2'b10: byte_write = 4'b0100;
                         2'b11: byte_write = 4'b1000;
                       endcase
                 end
             3'b010: // store half word (sh)
                 begin
                      unique case(bus.EX_MEM_alures[1:0])
                         2'b00: byte_write = 4'b0011;
                         2'b01: byte_write = 4'b0110;
                         2'b10: byte_write = 4'b1100;
                         2'b11: byte_write = 4'b1001;
                      endcase
                 end
//             3'b100:  byte_write=(bus.EX_MEM_alures == 32'haaaaa004 || bus.EX_MEM_alures == 32'haaaaa008) ? 4'b0000: 4'b1111; // store word (sw)
             3'b100: byte_write = 4'b1111; 
             3'b000:  byte_write=4'b1111; // not store
             default: byte_write=4'b1111;
       endcase
      
    
//    assign set_mmio_wea = ((bus.EX_MEM_storecntrl == 3'b100) && (bus.EX_MEM_alures == 32'haaaaa004)) ? 1 : 0;
//    assign set_mmio_dat = ((bus.EX_MEM_storecntrl == 3'b100) && (bus.EX_MEM_alures == 32'haaaaa008)) ? 1 : 0;
//    assign bus.mmio_wea = mmio_wea;
//    assign bus.mmio_dat = mmio_dat;
 /* blk_mem_gen_0 datamem (
          .clka(clk),    // input wire clka
          .ena(En),      // input wire ena
          .wea(byte_write),      // input wire [ 2: 0] wea
          .addra(EX_MEM_alures[7:2]),  // input wire [15 : 0] addra
          .dina(EX_MEM_alusec),    // input wire [31 : 0] dina
          .douta(MEM_WB_memres_temp) // output wire [31 : 0] douta
        );
   */
   
   
  /* Memory_byteaddress datamem(
           .clk(bus.clk),
           .rst(bus.Rst),
           .wea(bus.EX_MEM_memwrite),
           .en(byte_write),
           .addr(bus.EX_MEM_alures[11:0]),
//           .addr(addr),
           .din(memforward),
           .dout(MEM_WB_memres_temp)
           );*/
           
    assign bus.mem_wea = bus.EX_MEM_memwrite;
    assign bus.mem_rea = bus.EX_MEM_memread;
    assign bus.mem_en = byte_write; 
//    assign bus.mem_addr = bus.EX_MEM_alures[11:0]; 
    assign bus.mem_addr = bus.EX_MEM_alures;
    assign bus.mem_din = memforward; 
    assign MEM_WB_memres_temp = bus.mem_dout;
           
 assign d0=MEM_WB_memres_temp[7:0];
 assign d1=MEM_WB_memres_temp[15:8];
 assign d2=MEM_WB_memres_temp[23:16];
 assign d3=MEM_WB_memres_temp[31:24];
 
 assign bus.MEM_WB_memres = MEM_WB_memres;
// assign bus.MEM_WB_memres = memforward;
 
 logic ctrl_fwd; 
 
 assign ctrl_fwd = (bus.EX_MEM_memwrite && bus.MEM_WB_regwrite) && (bus.MEM_WB_rd == bus.EX_MEM_rs2);
// assign ctrl_fwd = (bus.EX_MEM_memwrite && bus.MEM_WB_regwrite) && ((bus.MEM_WB_rd == bus.EX_MEM_rs2) || (bus.EX_MEM_alures == bus.MEM_WB_alures));    
// assign ctrl_fwd = (bus.EX_MEM_memwrite && bus.MEM_WB_regwrite) && (bus.MEM_WB_rd != bus.EX_MEM_rs1) &&
//    ((bus.MEM_WB_rd == bus.EX_MEM_rs2) || (bus.EX_MEM_alures == bus.MEM_WB_alures));    
// assign ctrl_fwd = (bus.EX_MEM_memwrite && bus.MEM_WB_regwrite) && (bus.MEM_WB_alures == bus.EX_MEM_alures);
 assign memforward = ctrl_fwd ? bus.WB_res: bus.EX_MEM_dout_rs2;
 
//   always_comb
//       case(MEM_WB_dout_sel)
//            2'b00: MEM_WB_memres_sig  = {d3,d2,d1,d0};
//            2'b01: MEM_WB_memres_sig  = {d0,d3,d2,d1};
//            2'b10: MEM_WB_memres_sig  = {d1,d0,d3,d2};
//            2'b11: MEM_WB_memres_sig = {d2,d1,d0,d3};
//        endcase
  always_comb MEM_WB_memres_sig = MEM_WB_memres_temp;
  always_comb
  case(MEM_WB_loadcntrl)
        5'b00001:   MEM_WB_memres={{24{MEM_WB_memres_sig[7]}},MEM_WB_memres_sig[7:0]};
        5'b00010:   MEM_WB_memres={{16{MEM_WB_memres_sig[15]}},MEM_WB_memres_sig[15:0]};
        5'b00100:   MEM_WB_memres=MEM_WB_memres_sig;
        5'b01000:   MEM_WB_memres={{24{1'b0}},MEM_WB_memres_sig[7:0]};
        5'b10000:   MEM_WB_memres={{16{1'b0}},MEM_WB_memres_sig[15:0]};
        default :   MEM_WB_memres=32'h0;
  endcase;
        
  //assign MEM_WB_memres=(Rst)?32'h00000000:MEM_WB_memres_sig;
  
  //passing to the next pipeline stage
  always_ff @(posedge bus.clk) begin
        if(bus.Rst)begin
            bus.MEM_WB_alures<=32'h00000000;
            bus.MEM_WB_memread<=1'b0;
            bus.MEM_WB_regwrite<=1'b0;
            bus.MEM_WB_rd<=5'b00000;
            MEM_WB_loadcntrl<=5'b00000;
            MEM_WB_dout_sel<=2'b00;
            MEM_WB_memwrite<=1'b0;
            MEM_WB_dout_rs2 <= 32'h00000000;
            mmio_wea <= 0;
            mmio_dat <= 0;
            bus.MEM_WB_pres_addr<= 32'h0;
//            MEM_WB_alures<=32'h00000000;
            bus.MEM_WB_CSR <= 0;
            bus.MEM_WB_CSR_read <= 0;
        end
        else if(!bus.dbg && !bus.mem_hold) begin
            bus.MEM_WB_alures<=bus.EX_MEM_alures;
            bus.MEM_WB_memread<=bus.EX_MEM_memread;
            bus.MEM_WB_regwrite<=bus.EX_MEM_regwrite;
            bus.MEM_WB_rd<=bus.EX_MEM_rd;
            MEM_WB_loadcntrl<=bus.EX_MEM_loadcntrl;
            MEM_WB_dout_sel<=bus.EX_MEM_alures[1:0];
            MEM_WB_memwrite<=bus.EX_MEM_memwrite;
            MEM_WB_dout_rs2 <= bus.EX_MEM_dout_rs2;
            bus.MEM_WB_pres_addr<=bus.EX_MEM_pres_addr;
//            mmio_wea <= set_mmio_wea ? memforward[0] : mmio_wea;
//            mmio_dat <= set_mmio_dat ? memforward : mmio_dat;
//            MEM_WB_alures <= bus.EX_MEM_alures;
            bus.MEM_WB_CSR <= bus.EX_MEM_CSR;
            bus.MEM_WB_CSR_read <= bus.EX_MEM_CSR_read;
        end
     end
        
        
endmodule: Memory
