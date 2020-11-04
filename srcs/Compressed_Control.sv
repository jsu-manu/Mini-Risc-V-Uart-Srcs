module Compressed_Control (
	input logic [31:0] ins, 
	input logic ins_zero, flush, hazard,
	output logic [4:0] rd, rs1, rs2,
	output logic [1:0] funct2,
	output logic [2:0] funct3,
	output logic [3:0] funct4,
	output logic [5:0] funct6,
	output logic [6:0] funct7,
	
	output logic [2:0] alusel, 
	output logic [2:0] storecntrl,
	output logic [4:0] loadcntrl, 
	output logic branch, beq, bne, 
	output logic memread, memwrite, regwrite, 
	output logic alusrc, compare, lui, 
	output logic jal, jalr,
	
	output logic [31:0] imm
);

logic stall;

assign stall = flush || hazard || ins_zero;

function logic [4:0] RVC_Reg(input logic [2:0] rs);
	case (rs)
		3'b000: return 8;
		3'b001: return 9;
		3'b010: return 10;
		3'b011: return 11;
		3'b100: return 12; 
		3'b101: return 13;
		3'b110: return 14;
		3'b111: return 15;
	endcase
endfunction

always_comb begin
	funct2 = ins[6:5];
	funct3 = ins[15:13];
	funct4 = ins[15:12]; 
	funct6 = ins[15:10];
	rd = 0;
	rs1 = 0;
	rs2 = 0;
	imm = 0;
	alusel = 0;
	storecntrl = 0;
	loadcntrl = 0;
	branch = 0;
	beq = 0;
	bne = 0;
	memread = 0;
	memwrite = 0;
	regwrite = 0;
	alusrc = 0;
	compare = 0;
	lui = 0;
	jal = 0;
	jalr = 0;
	case (ins[1:0])
		2'b00: begin
			casez (ins[15:13])
				3'b000: begin //C.ADDI4SPN
					rd = RVC_Reg(ins[4:2]); 
					rs1 = 2;
					rs2 = 0;
					imm = {22'h0, ins[10:7], ins[12:11], ins[5], ins[6], 2'b00};
					regwrite=(!stall) && 1'b1; 
					alusrc=1'b1;
					alusel=3'b000;
				end
				3'b010: begin //C.LW
					rd = RVC_Reg(ins[4:2]);
					rs1 = RVC_Reg(ins[9:7]);
					rs2 = 0; 
					imm = {25'h0, ins[5], ins[12:10], ins[6], 2'b00};
					memread=1'b1;
					regwrite=(!stall)&&(1'b1);
					alusel=3'b000;
					alusrc=1'b1;
					loadcntrl=5'b00100;
				end
				3'b1??: begin //C.SW
					rd = 0;
					rs1 = RVC_Reg(ins[9:7]);
					rs2 = RVC_Reg(ins[4:2]);
					imm = {25'h0, ins[5], ins[12:10], ins[6], 2'b00};
					memwrite=(!stall)&&1'b1;
					alusrc=1'b1;
					alusel=3'b000;
					storecntrl=3'b111;
				end
			endcase
		end
		2'b01: begin
			casez (ins[15:13])
				3'b000: begin //C.NOP, C.ADDI
					rd = ins[11:7];
					rs1 = ins[11:7];
					rs2 = 0; 
					imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};
					regwrite=(!stall)&&1'b1;
					alusrc=1'b1;
					alusel=3'b000;
				end
				3'b001: begin //C.JAL
					imm = {20'h0, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0};
					rd = 0;
					rs1 = 0;
					rs2 = 0;
					jal = (!flush)&&1'b1;
					regwrite=stall ? 1'b0 : 1'b1;
				end
				3'b010: begin //C.LI
					rd = ins[11:7];
					rs1 = 0;
					rs2 = 0;
					imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};		
					regwrite=(!stall)&&1'b1;
					alusrc=1;
					alusel=3'b000;			
				end
				3'b011: begin //C.ADDI16SP, C.LUI
					if (ins[11:7] == 2) begin
						rd = ins[11:7];
						rs1 = ins[11:7];
						rs2 = 0;
						imm = ins[12] ? {22'h3fffff, ins[12], ins[4:3], ins[5], ins[2], ins[6], 4'h0} : {22'h0, ins[12], ins[4:3], ins[5], ins[2], ins[6], 4'h0};
						regwrite=(!stall)&&1'b1;
						alusrc=1;
						alusel=3'b000;
					end else begin
						rd = ins[11:7];
						rs1 = 0;
						rs2 = 0; 
						imm = ins[17] ? {14'h3fff, ins[17], ins[6:2], 12'h0}:{14'h0, ins[17], ins[6:2], 12'h0};
						lui=1'b1;
						alusrc=1'b1;
						regwrite = stall? 0 : 1;
					end
					
				end
				3'b100: begin
					rd = RVC_Reg(ins[9:7]);
					rs1 = RVC_Reg(ins[9:7]);
					rs2 = RVC_Reg(ins[4:2]); 
					imm = {26'h0, ins[12], ins[6:2]};
					regwrite=(!stall) &&(1'b1);
					case (ins[11:10]) 
						2'b00: begin //SRLI
							alusrc = 1;
							alusel=3'b110;
						end
						2'b01: begin //SRAI
							alusrc = 1;
							alusel = 3'b111;
						end
						2'b10: begin //ANDI
							alusrc = 1;
							alusel = 3'b010;
							imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};
						end
						2'b11: begin
							alusrc = 0;
							case (ins[6:5])
								2'b00: begin //C.SUB
									alusel = 3'b001;
								end
								2'b01: alusel=3'b100; //C.XOR
								2'b10: alusel=3'b011; //C.OR
								2'b11: alusel=3'b010; //C.AND
							endcase
						end
					endcase
				end
				3'b101: begin //C.J
					imm = {20'h0, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0};
					jal = (!flush)&&1;
				end
				3'b110: begin //C.BEQZ
					rs1 = RVC_Reg(ins[9:7]);
					imm = {23'h0, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0};
					branch=(!flush)&&1;
					beq=1;
				end
				3'b111: begin //C.BNEZ
					rs1 = RVC_Reg(ins[9:7]);
					imm = {23'h0, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0};
					branch=(!flush)&&1;
					bne=1;
				end
			endcase
		end
		2'b10: begin
			case (ins[15:13])
				3'b000: begin //C.SLLI
					rd = ins[11:7];
					rs1 = ins[11:7];
					imm = {26'h0, ins[12], ins[6:2]};
					regwrite=(!stall)&&1'b1;
					alusrc=1;
					alusel=3'b101;
				end
				3'b001: begin //C.FLDSP - UNSUPPORTED
					
				end
				3'b010: begin //C.LWSP
					rd = ins[11:7];
					rs1= 2;
					imm = {26'h0, ins[12], ins[6:2]};
					memread=1'b1;
					regwrite=(!stall)&&(1'b1);
					alusel=3'b000;
					alusrc=1'b1;
					loadcntrl=5'b00100;
				end
				3'b100: begin
					if (ins[12]) begin
						if (ins[11:7] == 0) begin //C.EBREAK
							
						end else begin
							if (ins[6:2] == 0) begin //C.JALR
								rd = 1;
								rs1 = ins[11:7];
								jalr=(!flush)&&1;
								regwrite=stall ? 0: 1;
							end else begin //C.ADD
								rd = ins[11:7];
								rs1 = ins[11:7];
								rs2 = ins[6:2]; 
								alusrc = 0;
								regwrite=(!stall)&&1;
								alusel=3'b000;
							end
						end
					end else begin
						if (ins[6:2] == 0) begin //C.JR
							rs1 = ins[11:7];
							jalr = (!flush)&&1; 
						end else begin //C.MV
							rd = ins[11:7];
							rs2 = ins[6:2]; 
							regwrite=(!stall)&&1'b1;
							alusel=3'b000;
							alusrc=0;
						end
					end
				end
				3'b110: begin //C.SWSP
					rs1 = 2;
					rs2 = ins[6:2]; 
					imm = {24'h0, ins[8:7], ins[12:9], 2'b00};
					memwrite=(!stall)&&1'b1;
					alusrc=1'b1;
					alusel=3'b000;
					storecntrl=3'b111;
				end
			endcase
		end
		endcase
end

endmodule