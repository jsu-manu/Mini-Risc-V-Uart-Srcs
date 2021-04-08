module Mem_Interface (
	input logic clk, imem_en, mem_en, 
	input logic [2:0] storecntrl_a, storecntrl_b,
	input logic [31:0] imem_addr, imem_din, mem_addr, mem_din, 
	input logic [3:0] imem_wen, mem_wen, 
	output logic [31:0] imem_dout, mem_dout
);


logic [29:0] addra0, addra1, addra2, addra3;
logic [29:0] addrb0, addrb1, addrb2, addrb3;

logic [3:0] ena, enb, wea, web; 

logic [7:0] dina0, dina1, dina2, dina3;
logic [7:0] dinb0, dinb1, dinb2, dinb3;
logic [7:0] douta0, douta1, douta2, douta3; 
logic [7:0] doutb0, doutb1, doutb2, doutb3;

logic [1:0] last_imem_addr, last_mem_addr;


logic [29:0] wraparound_a, wraparound_b;

// Instruction Memory Cells
imem_cell_0 icell0(.clka(clk), .addra(addra0), .dina(dina0),
	.douta(douta0), .ena(ena[0]), .wea(imem_wen[0]));
imem_cell_1 icell1(.clka(clk), .addra(addra1), .dina(dina1),
	.douta(douta1), .ena(ena[1]), .wea(imem_wen[1]));
imem_cell_2 icell2(.clka(clk), .addra(addra2), .dina(dina2),
	.douta(douta2), .ena(ena[2]), .wea(imem_wen[2]));
imem_cell_3 icell3(.clka(clk), .addra(addra3), .dina(dina3),
	.douta(douta3), .ena(ena[3]), .wea(imem_wen[3]));

// Data Memory Cells
mem_cell_0 cell0(.clka(clk), .addra(addrb0), .dina(dinb0),
	.douta(doutb0), .ena(enb[0]), .wea(mem_wen[0]));
mem_cell_1 cell1(.clka(clk), .addra(addrb1), .dina(dinb1),
	.douta(doutb1), .ena(enb[1]), .wea(mem_wen[1]));
mem_cell_2 cell2(.clka(clk), .addra(addrb2), .dina(dinb2),
	.douta(doutb2), .ena(enb[2]), .wea(mem_wen[2]));
mem_cell_3 cell3(.clka(clk), .addra(addrb3), .dina(dinb3),
	.douta(doutb3), .ena(enb[3]), .wea(mem_wen[3]));
//mem_cell_3 cell3(.clka(clk), .addra(addra3), .dina(dina3),
//	.douta(douta3), .ena(ena[3]), .wea(imem_wen[3]), 
//	.clkb(clk), .addrb(addrb3), .dinb(dinb3), .doutb(doutb3), .enb(enb[3]), .web(mem_wen[3]));

assign wraparound_a = imem_addr + 4;
assign ena = imem_en ? 4'b1111 : 4'b0000;
assign enb = mem_en ? 4'b1111: 4'b0000;
//assign enb = mem_en;
always_ff @(posedge clk) begin
    if (imem_en) last_imem_addr <= imem_addr[1:0];
    if (mem_en) last_mem_addr <= mem_addr[1:0];
end

always_comb begin

	case(storecntrl_a)
		3'b001: begin // store byte
			case(imem_addr[1:0])
				2'b00: wea = 4'b0001;
				2'b01: wea = 4'b0010;
				2'b10: wea = 4'b0100;
				2'b11: wea = 4'b1000; 
			endcase
		end
		3'b010: begin // store halfword
			case(imem_addr[1:0])
				2'b00: wea = 4'b0011;
				2'b01: wea = 4'b0110;
				2'b10: wea = 4'b1100;
				2'b11: wea = 4'b1001; 
			endcase
		end
		3'b100: wea = 4'b1111;
		default: wea = 4'b0000; 
	endcase

    case(last_imem_addr)
        2'b00: imem_dout = {douta3, douta2, douta1, douta0};
        2'b01: imem_dout = {douta0, douta3, douta2, douta1};
        2'b10: imem_dout = {douta1, douta0, douta3, douta2};
        2'b11: imem_dout = {douta2, douta1, douta0, douta3};
    endcase

	//Addressing stuff
	case(imem_addr[1:0])
		2'b00: begin
			addra0 = imem_addr[31:2];
			addra1 = imem_addr[31:2];
			addra2 = imem_addr[31:2];
			addra3 = imem_addr[31:2];
			dina0 = imem_din[7:0];
			dina1 = imem_din[15:8];
			dina2 = imem_din[23:16];
			dina3 = imem_din[31:24];
			
		end
		2'b01: begin
			addra0 = imem_addr[31:2] + 1;
			addra1 = imem_addr[31:2];
			addra2 = imem_addr[31:2];
			addra3 = imem_addr[31:2]; 
			dina1 = imem_din[7:0];
			dina2 = imem_din[15:8];
			dina3 = imem_din[23:16];
			dina0 = imem_din[31:24];
			
		end
		2'b10: begin
			addra0 = imem_addr[31:2] + 1;
			addra1 = imem_addr[31:2] + 1;
			addra2 = imem_addr[31:2];
			addra3 = imem_addr[31:2];
			dina2 = imem_din[7:0];
			dina3 = imem_din[15:8];
			dina0 = imem_din[23:16];
			dina1 = imem_din[31:24];
			
		end
		2'b11: begin
			addra0 = imem_addr[31:2] + 1;
			addra1 = imem_addr[31:2] + 1;
			addra2 = imem_addr[31:2] + 1;
			addra3 = imem_addr[31:2];
			dina3 = imem_din[7:0];
			dina0 = imem_din[15:8];
			dina1 = imem_din[23:16];
			dina2 = imem_din[31:24];
			
		end
	endcase

	case(storecntrl_b)
		3'b001: begin // store byte
			case(mem_addr[1:0])
				2'b00: web = 4'b0001;
				2'b01: web = 4'b0010;
				2'b10: web = 4'b0100;
				2'b11: web = 4'b1000; 
			endcase
		end
		3'b010: begin // store halfword
			case(mem_addr[1:0])
				2'b00: web = 4'b0011;
				2'b01: web = 4'b0110;
				2'b10: web = 4'b1100;
				2'b11: web = 4'b1001; 
			endcase
		end
		3'b100: web = 4'b1111;
		default: web = 4'b0000; 
	endcase
	
	case(last_mem_addr)
	   2'b00: mem_dout = {doutb3, doutb2, doutb1, doutb0};
	   2'b01: mem_dout = {doutb0, doutb3, doutb2, doutb1};
	   2'b10: mem_dout = {doutb1, doutb0, doutb3, doutb2};
	   2'b11: mem_dout = {doutb2, doutb1, doutb0, doutb3};
	endcase

	case(mem_addr[1:0])
		2'b00: begin
			addrb0 = mem_addr[31:2];
			addrb1 = mem_addr[31:2];
			addrb2 = mem_addr[31:2];
			addrb3 = mem_addr[31:2];
			dinb0 = mem_din[7:0];
			dinb1 = mem_din[15:8];
			dinb2 = mem_din[23:16];
			dinb3 = mem_din[31:24];
			
		end
		2'b01: begin
			addrb0 = mem_addr[31:2] + 1;
			addrb1 = mem_addr[31:2];
			addrb2 = mem_addr[31:2];
			addrb3 = mem_addr[31:2]; 
			dinb1 = mem_din[7:0];
			dinb2 = mem_din[15:8];
			dinb3 = mem_din[23:16];
			dinb0 = mem_din[31:24];
			
		end
		2'b10: begin
			addrb0 = mem_addr[31:2] + 1;
			addrb1 = mem_addr[31:2] + 1;
			addrb2 = mem_addr[31:2];
			addrb3 = mem_addr[31:2];
			dinb2 = mem_din[7:0];
			dinb3 = mem_din[15:8];
			dinb0 = mem_din[23:16];
			dinb1 = mem_din[31:24];
			
		end
		2'b11: begin
			addrb0 = mem_addr[31:2] + 1;
			addrb1 = mem_addr[31:2] + 1;
			addrb2 = mem_addr[31:2] + 1;
			addrb3 = mem_addr[31:2];
			dinb3 = mem_din[7:0];
			dinb0 = mem_din[15:8];
			dinb1 = mem_din[23:16];
			dinb2 = mem_din[31:24];
			
		end
	endcase

end


endmodule