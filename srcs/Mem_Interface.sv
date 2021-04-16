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
	
//sram_compiled_array icell0(
//    .addr0(addra0[0]), .addr1(addra0[1]), .addr2(addra0[2]), .addr3(addra0[3]),
//    .addr4(addra0[4]), .addr5(addra0[5]), .addr6(addra0[6]), .addr7(addra0[7]),
//    .addr8(addra0[8]), .addr9(addra0[9]), .addr10(addra0[10]),
//    .din0(dina0[0]),   .din1(dina0[1]),   .din2(dina0[2]),   .din3(dina0[3]),
//    .din4(dina0[4]),   .din5(dina0[5]),   .din6(dina0[6]),   .din7(dina0[7]),
//    .dout0(douta0[0]), .dout1(douta0[1]), .dout2(douta0[2]), .dout3(douta0[3]),
//    .dout4(douta0[4]), .dout5(douta0[5]), .dout6(douta0[6]), .dout7(douta0[7]),
//    .clk(clk), .write_en(imem_wen[0]), .sense_en(!(clk & ena[0])));

//sram_compiled_array icell1(
//    .addr0(addra1[0]), .addr1(addra1[1]), .addr2(addra1[2]), .addr3(addra1[3]),
//    .addr4(addra1[4]), .addr5(addra1[5]), .addr6(addra1[6]), .addr7(addra1[7]),
//    .addr8(addra1[8]), .addr9(addra1[9]), .addr10(addra1[10]),
//    .din0(dina1[0]),   .din1(dina1[1]),   .din2(dina1[2]),   .din3(dina1[3]),
//    .din4(dina1[4]),   .din5(dina1[5]),   .din6(dina1[6]),   .din7(dina1[7]),
//    .dout0(douta1[0]), .dout1(douta1[1]), .dout2(douta1[2]), .dout3(douta1[3]),
//    .dout4(douta1[4]), .dout5(douta1[5]), .dout6(douta1[6]), .dout7(douta1[7]),
//    .clk(clk), .write_en(imem_wen[1]), .sense_en(!(clk & ena[1])));

//sram_compiled_array icell2(
//    .addr0(addra2[0]), .addr1(addra2[1]), .addr2(addra2[2]), .addr3(addra2[3]),
//    .addr4(addra2[4]), .addr5(addra2[5]), .addr6(addra2[6]), .addr7(addra2[7]),
//    .addr8(addra2[8]), .addr9(addra2[9]), .addr10(addra2[10]),
//    .din0(dina2[0]),   .din1(dina2[1]),   .din2(dina2[2]),   .din3(dina2[3]),
//    .din4(dina2[4]),   .din5(dina2[5]),   .din6(dina2[6]),   .din7(dina2[7]),
//    .dout0(douta2[0]), .dout1(douta2[1]), .dout2(douta2[2]), .dout3(douta2[3]),
//    .dout4(douta2[4]), .dout5(douta2[5]), .dout6(douta2[6]), .dout7(douta2[7]),
//    .clk(clk), .write_en(imem_wen[2]), .sense_en(!(clk & ena[2])));

//sram_compiled_array icell3(
//    .addr0(addra3[0]), .addr1(addra3[1]), .addr2(addra3[2]), .addr3(addra3[3]),
//    .addr4(addra3[4]), .addr5(addra3[5]), .addr6(addra3[6]), .addr7(addra3[7]),
//    .addr8(addra3[8]), .addr9(addra3[9]), .addr10(addra3[10]),
//    .din0(dina3[0]),   .din1(dina3[1]),   .din2(dina3[2]),   .din3(dina3[3]),
//    .din4(dina3[4]),   .din5(dina3[5]),   .din6(dina3[6]),   .din7(dina3[7]),
//    .dout0(douta3[0]), .dout1(douta3[1]), .dout2(douta3[2]), .dout3(douta3[3]),
//    .dout4(douta3[4]), .dout5(douta3[5]), .dout6(douta3[6]), .dout7(douta3[7]),
//    .clk(clk), .write_en(imem_wen[3]), .sense_en(!(clk & ena[3])));

// Data Memory Cells
mem_cell_0 cell0(.clka(clk), .addra(addrb0), .dina(dinb0),
	.douta(doutb0), .ena(enb[0]), .wea(mem_wen[0]));
mem_cell_1 cell1(.clka(clk), .addra(addrb1), .dina(dinb1),
	.douta(doutb1), .ena(enb[1]), .wea(mem_wen[1]));
mem_cell_2 cell2(.clka(clk), .addra(addrb2), .dina(dinb2),
	.douta(doutb2), .ena(enb[2]), .wea(mem_wen[2]));
mem_cell_3 cell3(.clka(clk), .addra(addrb3), .dina(dinb3),
	.douta(doutb3), .ena(enb[3]), .wea(mem_wen[3]));

//sram_compiled_array cell0(
//    .addr0(addrb0[0]), .addr1(addrb0[1]), .addr2(addrb0[2]), .addr3(addrb0[3]),
//    .addr4(addrb0[4]), .addr5(addrb0[5]), .addr6(addrb0[6]), .addr7(addrb0[7]),
//    .addr8(addrb0[8]), .addr9(addrb0[9]), .addr10(addrb0[10]),
//    .din0(dinb0[0]),   .din1(dinb0[1]),   .din2(dinb0[2]),   .din3(dinb0[3]),
//    .din4(dinb0[4]),   .din5(dinb0[5]),   .din6(dinb0[6]),   .din7(dinb0[7]),
//    .dout0(doutb0[0]), .dout1(doutb0[1]), .dout2(doutb0[2]), .dout3(doutb0[3]),
//    .dout4(doutb0[4]), .dout5(doutb0[5]), .dout6(doutb0[6]), .dout7(doutb0[7]),
//    .clk(clk), .write_en(mem_wen[0]), .sense_en(!(clk & enb[0])));

//sram_compiled_array cell1(
//    .addr0(addrb1[0]), .addr1(addrb1[1]), .addr2(addrb1[2]), .addr3(addrb1[3]),
//    .addr4(addrb1[4]), .addr5(addrb1[5]), .addr6(addrb1[6]), .addr7(addrb1[7]),
//    .addr8(addrb1[8]), .addr9(addrb1[9]), .addr10(addrb1[10]),
//    .din0(dinb1[0]),   .din1(dinb1[1]),   .din2(dinb1[2]),   .din3(dinb1[3]),
//    .din4(dinb1[4]),   .din5(dinb1[5]),   .din6(dinb1[6]),   .din7(dinb1[7]),
//    .dout0(doutb1[0]), .dout1(doutb1[1]), .dout2(doutb1[2]), .dout3(doutb1[3]),
//    .dout4(doutb1[4]), .dout5(doutb1[5]), .dout6(doutb1[6]), .dout7(doutb1[7]),
//    .clk(clk), .write_en(mem_wen[1]), .sense_en(!(clk & enb[1])));

//sram_compiled_array cell2(
//    .addr0(addrb2[0]), .addr1(addrb2[1]), .addr2(addrb2[2]), .addr3(addrb2[3]),
//    .addr4(addrb2[4]), .addr5(addrb2[5]), .addr6(addrb2[6]), .addr7(addrb2[7]),
//    .addr8(addrb2[8]), .addr9(addrb2[9]), .addr10(addrb2[10]),
//    .din0(dinb2[0]),   .din1(dinb2[1]),   .din2(dinb2[2]),   .din3(dinb2[3]),
//    .din4(dinb2[4]),   .din5(dinb2[5]),   .din6(dinb2[6]),   .din7(dinb2[7]),
//    .dout0(doutb2[0]), .dout1(doutb2[1]), .dout2(doutb2[2]), .dout3(doutb2[3]),
//    .dout4(doutb2[4]), .dout5(doutb2[5]), .dout6(doutb2[6]), .dout7(doutb2[7]),
//    .clk(clk), .write_en(mem_wen[2]), .sense_en(!(clk & enb[2])));

//sram_compiled_array cell3(
//    .addr0(addrb3[0]), .addr1(addrb3[1]), .addr2(addrb3[2]), .addr3(addrb3[3]),
//    .addr4(addrb3[4]), .addr5(addrb3[5]), .addr6(addrb3[6]), .addr7(addrb3[7]),
//    .addr8(addrb3[8]), .addr9(addrb3[9]), .addr10(addrb3[10]),
//    .din0(dinb3[0]),   .din1(dinb3[1]),   .din2(dinb3[2]),   .din3(dinb3[3]),
//    .din4(dinb3[4]),   .din5(dinb3[5]),   .din6(dinb3[6]),   .din7(dinb3[7]),
//    .dout0(doutb3[0]), .dout1(doutb3[1]), .dout2(doutb3[2]), .dout3(doutb3[3]),
//    .dout4(doutb3[4]), .dout5(doutb3[5]), .dout6(doutb3[6]), .dout7(doutb3[7]),
//    .clk(clk), .write_en(mem_wen[3]), .sense_en(!(clk & enb[3])));

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