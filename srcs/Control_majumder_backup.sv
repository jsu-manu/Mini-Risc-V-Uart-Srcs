`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// Revised:
//   November 20, 2018
// 
// Module name: Control
// Description:
//   Implements the RISC-V control logic (part of decoder pipeline stage)
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   opcode -- 7-bit opcode field from the 32-bit instruction 
//   funct3 -- 3-bit funct3 field from the 32-bit instruction
//   funct7 -- 7-bit funct7 field from the 32-bit instruction
//   ins_zero -- 
//   flush -- 
//   hazard -- 
// Output:
//   alusel2 -- 
//   alusel1 -- 
//   alusel0 -- 
//   addb -- 
//   rightb -- 
//   logicb -- 
//   branch -- 
//   memwrite -- 
//   memread -- 
//   regwrite -- 
//   alusrc -- 
//   compare -- 
//   jal -- 
//   jalr -- 
// 
//////////////////////////////////////////////////////////////////////////////////


module Control
 (input  logic [6:0] opcode,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic [11:0] funct12,
  input  logic ins_zero,
  input  logic flush,
  input  logic hazard,
  input  logic [4:0] rs1,rd,
  output logic [2:0]alusel,
  output logic [2:0]storecntrl, //sw,sh,sb
  output logic [4:0]loadcntrl, //lhu,lbu,lw,lh,lb
  output logic [3:0]cmpcntrl, //slt,slti,sltu,sltiu
  output logic      branch,
  output logic      beq,
  output logic      bne,
  output logic      blt,
  output logic      bge,
  output logic      bltu,
  output logic      bgeu,
  output logic      memread,
  output logic      memwrite,
  output logic      regwrite,
  output logic      alusrc,
  output logic      compare,
  output logic      auipc,
  output logic      lui,
  output logic      jal,
  output logic      jalr,
  output logic      illegal_ins, 
  output logic [2:0] csrsel, 
  output logic      csrwrite, 
  output logic      csrread,
  output logic trap_ret);

  // intruction classification signal
  
  logic stall;

  always_comb begin
    alusel=3'b000;
    storecntrl=3'b000;
    loadcntrl=5'b00000;
    cmpcntrl=2'b00;
    branch=1'b0;
    beq=1'b0;
    bne=1'b0;
    blt=1'b0;
    bge=1'b0;
    bltu=1'b0;
    bgeu=1'b0;
	memread=1'b0;
	memwrite=1'b0;
	regwrite=1'b0;
	alusrc=1'b0;
	compare=1'b0;
	auipc=1'b0;
	lui=1'b0;
	jal=1'b0;
	jalr=1'b0;
	illegal_ins=1'b0;
	csrsel = 3'b000;
	csrwrite = 1'b0;
	csrread = 0;
  	trap_ret = 0;
    unique case (opcode)
      7'b0000011:               // load
        begin
        memread=1'b1;
        regwrite=(!stall)&&(1'b1);
        alusel=3'b000;
        alusrc=1'b1; 
            unique case(funct3)
                3'b000: loadcntrl=5'b00001;
                3'b001: loadcntrl=5'b00010;
                3'b010: loadcntrl=5'b00100;
                3'b100: loadcntrl=5'b01000;
                3'b101: loadcntrl=5'b10000;
                default: illegal_ins=(!flush)&&(1'b1); 
            endcase 
        end
      7'b0110011:               // R-type (arith & compare)
		begin
		regwrite=(!stall)&&(1'b1);
          unique case({funct7,funct3})
			{7'h00,3'b000}:
				//add
				alusel=3'b000;
			
			{7'h20,3'b000}:
				//sub
				alusel=3'b001;
			{7'b00,3'b001}:
				//sll
				alusel=3'b101;
			{7'b00,3'b010}:
				//slt	
				begin
					compare=1'b1;
					cmpcntrl=4'b0001;
				end
			{7'b00,3'b011}:
				//sltu
				begin
					compare=1'b1;
					cmpcntrl=4'b0010;
				end
			{7'b00,3'b100}:
				//xor
				alusel=3'b100;
			{7'b00,3'b101}:
				//srl
				alusel=3'b110;
			{7'h20,3'b101}:
				//sra
				alusel=3'b111;
			{7'h00,3'b110}:
				//or
				alusel=3'b011;
			{7'h00,3'b111}:
				//and
				alusel=3'b010;
		    default:
		      illegal_ins=1'b1;				
            endcase
        end		
      7'b0010011:               // I-arith
		begin
		regwrite=(!stall)&&(1'b1);
        alusrc=1'b1;
          unique case(funct3)
			3'b000:
				//addi
				alusel=3'b000;
			3'b001:
				//slli
				if (funct7==7'h00)
				    alusel=3'b101;
				else
				    illegal_ins=(!flush)&&(1'b1);
				
			3'b010:
				//slti	
				begin
					compare=1'b1;
					cmpcntrl=4'b0100;
				end
			3'b011:
				//sltiu
				begin
					compare=1'b1;
					cmpcntrl=4'b1000;
				end
			3'b100:
				//xori
				alusel=3'b100;
			3'b101:
				unique case(funct7)
					7'h00: alusel=3'b110; //srli
					7'h20: alusel=3'b111; //srai
					default: illegal_ins=(!flush)&&(1'b1);
			    endcase
			3'b110:
				//ori
				alusel=3'b011;
			3'b111:
				//andi
				alusel=3'b010;						
           endcase
        end
      7'b0100011:               // store
        begin
          memwrite = (!stall)&&1'b1;
          alusrc=1'b1;
          alusel=3'b000;
          unique case(funct3)
              3'b000: storecntrl=3'b001;
              3'b001: storecntrl=3'b010;
              3'b010: storecntrl=3'b100;
              default: illegal_ins=(!flush)&&(1'b1);
          endcase 
        end
      7'b1100011:               // branch 
        begin
          branch = (!flush)&&1'b1;
          unique case(funct3)
            3'b000: beq=1'b1;
            3'b001: bne=1'b1;
            3'b010: blt=1'b1;
            3'b011: bge=1'b1;
            3'b100: bltu=1'b1;
            3'b101: bgeu=1'b1;
            default: illegal_ins=(!flush)&&(1'b1);
          endcase
        end
      7'b1101111:               // jal 
        begin
          jal = (!flush)&&1'b1;
          regwrite=stall ? 1'b0 : 1'b1;
        end
      7'b1100111:               // jalr
        begin
          jalr = (!flush)&&1'b1;
          regwrite=stall ? 1'b0 : 1'b1;
        end
      7'b0110111:               //lui
        begin
            lui=1'b1;
            alusrc=1'b1;
            regwrite=stall ? 1'b0 : 1'b1;
        end
      7'b0010111:               //auipc
        begin
            auipc=1'b1;
            alusrc=1'b1;
            regwrite=stall ? 1'b0 : 1'b1;
        end
      7'b1110011:               //SYSTEM
        begin
            csrsel = funct3;
//            regwrite = ~stall;
//            csrwrite = ~stall;
//            csrread = ~stall;
            unique case(funct3) 
            	3'b000: begin //MRET/SRET/URET
            		if (funct12 == 12'h302) begin //MRET
            			trap_ret = 1; 
            		end
            	end
                3'b001: begin //CSRRW
//                regwrite=stall ? 1'b0: 1'b1;
                    regwrite = (rd == 0) ? 1'b0 : ~stall;
                    csrread = (rd == 0) ? 1'b0 : ~stall; 
                    csrwrite = ~stall;
                end
                3'b010: begin //CSRRS
//                regwrite = ~stall;
                    regwrite = ~stall;
                    csrread = ~stall; 
                    csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
                end
                3'b011: begin //CSRRC
                    regwrite = ~stall;
                    csrread = ~stall; 
                    csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
                end
                3'b101: begin //CSRRWI
                    alusrc = 1'b1;
                    regwrite = (rd == 0) ? 1'b0 : ~stall;
                    csrread = (rd == 0) ? 1'b0 : ~stall; 
                    csrwrite = ~stall;
                end
                3'b110: begin //CSRRSI
                    alusrc = 1'b1;
                    regwrite = ~stall;
                    csrread = ~stall; 
                    csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
                end
                3'b111: begin //CSRRCI
                    alusrc = 1'b1;
                    regwrite = ~stall;
                    csrread = ~stall; 
                    csrwrite = (rs1 == 0) ? 1'b0 : ~stall;
                end
                default: begin
                    regwrite = 0;
                    csrread = 0;
                    csrwrite = 0; 
                end 
            endcase
        end
     default:
        illegal_ins=(!flush)&&(1'b1);
    endcase
  end

  
  assign stall = flush || hazard || ins_zero;
    


endmodule: Control
