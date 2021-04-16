module Mem_Interface #(
    // Scanchain Parameters
    parameter N_addr=31, // Number of bits in address
    parameter N_cnt=32,  // Number of bits for storing number of subsequent addresses + 1 bit for specifying read/write
    parameter N_data=32, // Number of bits in data bus/word
    parameter N_clk=16,  // Half the number of bits in data bus (for clk divider)
    parameter data_sep='h2000   // Address where instr mem ends and data begins 
    ) (
    // Regular RISC-V Interaction
	input logic clk, imem_en, mem_en, 
	input logic [2:0] storecntrl_a, storecntrl_b,
	input logic [N_addr-1:0] imem_addr, imem_din, mem_addr, mem_din, 
	input logic [3:0] imem_wen, mem_wen, 
	output logic [N_data-1:0] imem_dout, mem_dout,
	// Scanchain Interaction
	input logic scan_en, scan_clk, scan_in, // scan_en acts as a reset for scanchain state when low
	output logic scan_out
);


logic [29:0] addra0_rv, addra1_rv, addra2_rv, addra3_rv;
logic [29:0] addra0, addra1, addra2, addra3;
logic [29:0] addrb0_rv, addrb1_rv, addrb2_rv, addrb3_rv;
logic [29:0] addrb0, addrb1, addrb2, addrb3;

logic [3:0] ena_rv, enb_rv, wea_rv, web_rv; 
logic [3:0] ena, enb, wea, web; 
logic mem_clk;

logic [7:0] dina0_rv, dina1_rv, dina2_rv, dina3_rv;
logic [7:0] dina0, dina1, dina2, dina3;
logic [7:0] dinb0_rv, dinb1_rv, dinb2_rv, dinb3_rv;
logic [7:0] dinb0, dinb1, dinb2, dinb3;
logic [7:0] douta0, douta1, douta2, douta3; 
logic [7:0] doutb0, doutb1, doutb2, doutb3;
logic [N_data-1:0] imem_dout_buf, mem_dout_buf;

logic [1:0] last_imem_addr, last_mem_addr;


logic [29:0] wraparound_a, wraparound_b;

// Instruction Memory Cells
imem_cell_0 icell0(.clka(mem_clk), .addra(addra0), .dina(dina0),
	.douta(douta0), .ena(ena[0]), .wea(wea[0]));
imem_cell_1 icell1(.clka(mem_clk), .addra(addra1), .dina(dina1),
	.douta(douta1), .ena(ena[1]), .wea(wea[1]));
imem_cell_2 icell2(.clka(mem_clk), .addra(addra2), .dina(dina2),
	.douta(douta2), .ena(ena[2]), .wea(wea[2]));
imem_cell_3 icell3(.clka(mem_clk), .addra(addra3), .dina(dina3),
	.douta(douta3), .ena(ena[3]), .wea(wea[3]));
	
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
mem_cell_0 cell0(.clka(mem_clk), .addra(addrb0), .dina(dinb0),
	.douta(doutb0), .ena(enb[0]), .wea(web[0]));
mem_cell_1 cell1(.clka(mem_clk), .addra(addrb1), .dina(dinb1),
	.douta(doutb1), .ena(enb[1]), .wea(web[1]));
mem_cell_2 cell2(.clka(mem_clk), .addra(addrb2), .dina(dinb2),
	.douta(doutb2), .ena(enb[2]), .wea(web[2]));
mem_cell_3 cell3(.clka(mem_clk), .addra(addrb3), .dina(dinb3),
	.douta(doutb3), .ena(enb[3]), .wea(web[3]));

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
assign ena_rv = imem_en ? 4'b1111 : 4'b0000;
assign enb_rv = mem_en ? 4'b1111: 4'b0000;
//assign enb = mem_en;
always_ff @(posedge clk) begin
    if (imem_en) last_imem_addr <= imem_addr[1:0];
    if (mem_en) last_mem_addr <= mem_addr[1:0];
end

always_comb begin

	case(storecntrl_a)
		3'b001: begin // store byte
			case(imem_addr[1:0])
				2'b00: wea_rv = 4'b0001;
				2'b01: wea_rv = 4'b0010;
				2'b10: wea_rv = 4'b0100;
				2'b11: wea_rv = 4'b1000; 
			endcase
		end
		3'b010: begin // store halfword
			case(imem_addr[1:0])
				2'b00: wea_rv = 4'b0011;
				2'b01: wea_rv = 4'b0110;
				2'b10: wea_rv = 4'b1100;
				2'b11: wea_rv = 4'b1001; 
			endcase
		end
		3'b100: wea_rv = 4'b1111;
		default: wea_rv = 4'b0000; 
	endcase

    case(last_imem_addr)
        2'b00: imem_dout_buf = {douta3, douta2, douta1, douta0};
        2'b01: imem_dout_buf = {douta0, douta3, douta2, douta1};
        2'b10: imem_dout_buf = {douta1, douta0, douta3, douta2};
        2'b11: imem_dout_buf = {douta2, douta1, douta0, douta3};
    endcase
    imem_dout = imem_dout_buf;

	//Addressing stuff
	case(imem_addr[1:0])
		2'b00: begin
			addra0_rv = imem_addr[31:2];
			addra1_rv = imem_addr[31:2];
			addra2_rv = imem_addr[31:2];
			addra3_rv = imem_addr[31:2];
			dina0_rv = imem_din[7:0];
			dina1_rv = imem_din[15:8];
			dina2_rv = imem_din[23:16];
			dina3_rv = imem_din[31:24];
			
		end
		2'b01: begin
			addra0_rv = imem_addr[31:2] + 1;
			addra1_rv = imem_addr[31:2];
			addra2_rv = imem_addr[31:2];
			addra3_rv = imem_addr[31:2]; 
			dina1_rv = imem_din[7:0];
			dina2_rv = imem_din[15:8];
			dina3_rv = imem_din[23:16];
			dina0_rv = imem_din[31:24];
			
		end
		2'b10: begin
			addra0_rv = imem_addr[31:2] + 1;
			addra1_rv = imem_addr[31:2] + 1;
			addra2_rv = imem_addr[31:2];
			addra3_rv = imem_addr[31:2];
			dina2_rv = imem_din[7:0];
			dina3_rv = imem_din[15:8];
			dina0_rv = imem_din[23:16];
			dina1_rv = imem_din[31:24];
			
		end
		2'b11: begin
			addra0_rv = imem_addr[31:2] + 1;
			addra1_rv = imem_addr[31:2] + 1;
			addra2_rv = imem_addr[31:2] + 1;
			addra3_rv = imem_addr[31:2];
			dina3_rv = imem_din[7:0];
			dina0_rv = imem_din[15:8];
			dina1_rv = imem_din[23:16];
			dina2_rv = imem_din[31:24];
			
		end
	endcase

	case(storecntrl_b)
		3'b001: begin // store byte
			case(mem_addr[1:0])
				2'b00: web_rv = 4'b0001;
				2'b01: web_rv = 4'b0010;
				2'b10: web_rv = 4'b0100;
				2'b11: web_rv = 4'b1000; 
			endcase
		end
		3'b010: begin // store halfword
			case(mem_addr[1:0])
				2'b00: web_rv = 4'b0011;
				2'b01: web_rv = 4'b0110;
				2'b10: web_rv = 4'b1100;
				2'b11: web_rv = 4'b1001; 
			endcase
		end
		3'b100: web_rv = 4'b1111;
		default: web_rv = 4'b0000; 
	endcase
	
	case(last_mem_addr)
	   2'b00: mem_dout_buf = {doutb3, doutb2, doutb1, doutb0};
	   2'b01: mem_dout_buf = {doutb0, doutb3, doutb2, doutb1};
	   2'b10: mem_dout_buf = {doutb1, doutb0, doutb3, doutb2};
	   2'b11: mem_dout_buf = {doutb2, doutb1, doutb0, doutb3};
	endcase
	mem_dout = mem_dout_buf;

	case(mem_addr[1:0])
		2'b00: begin
			addrb0_rv = mem_addr[31:2];
			addrb1_rv = mem_addr[31:2];
			addrb2_rv = mem_addr[31:2];
			addrb3_rv = mem_addr[31:2];
			dinb0_rv = mem_din[7:0];
			dinb1_rv = mem_din[15:8];
			dinb2_rv = mem_din[23:16];
			dinb3_rv = mem_din[31:24];
			
		end
		2'b01: begin
			addrb0_rv = mem_addr[31:2] + 1;
			addrb1_rv = mem_addr[31:2];
			addrb2_rv = mem_addr[31:2];
			addrb3_rv = mem_addr[31:2]; 
			dinb1_rv = mem_din[7:0];
			dinb2_rv = mem_din[15:8];
			dinb3_rv = mem_din[23:16];
			dinb0_rv = mem_din[31:24];
			
		end
		2'b10: begin
			addrb0_rv = mem_addr[31:2] + 1;
			addrb1_rv = mem_addr[31:2] + 1;
			addrb2_rv = mem_addr[31:2];
			addrb3_rv = mem_addr[31:2];
			dinb2_rv = mem_din[7:0];
			dinb3_rv = mem_din[15:8];
			dinb0_rv = mem_din[23:16];
			dinb1_rv = mem_din[31:24];
			
		end
		2'b11: begin
			addrb0_rv = mem_addr[31:2] + 1;
			addrb1_rv = mem_addr[31:2] + 1;
			addrb2_rv = mem_addr[31:2] + 1;
			addrb3_rv = mem_addr[31:2];
			dinb3_rv = mem_din[7:0];
			dinb0_rv = mem_din[15:8];
			dinb1_rv = mem_din[23:16];
			dinb2_rv = mem_din[31:24];
			
		end
	endcase

end



// Scanchain Control Logic
reg scan_out;
reg we_sc, en_sc;
reg [N_addr + N_cnt-1 : 0] addr_cnt_reg;
reg [N_data-1 : 0] data_scan_reg, data_in_reg, data_out_reg;

reg  [N_addr-1 : 0] addr;
integer addr_cnt_pointer;

reg rst_n_sync;
reg scan_in_sync;
reg [N_data-1:0] clk_count;
reg clk_div;
reg [N_cnt-1:0] addr_counter;

wire clk_1 = scan_en & scan_clk;
//sync inputs with negedge of scan_clk
always @(negedge scan_clk) begin
    rst_n_sync <= scan_en;
    scan_in_sync <= scan_en & scan_in;
end

//counter for addr cnt register scan in
always @(posedge clk_1) begin
    if (!rst_n_sync)
        addr_cnt_pointer <= 'd0;
    else if(addr_cnt_pointer < N_addr + N_cnt)
        addr_cnt_pointer <= addr_cnt_pointer + 1;
end

reg scan_select;
//demux select logic
always @(negedge clk_1) begin
    if (!rst_n_sync)
        scan_select <= 'b0;
    else if (addr_cnt_pointer == N_addr + N_cnt)
        scan_select <= 'b1;
end

wire demux_out_addr = !scan_select & scan_in_sync;
wire demux_out_data = scan_select & scan_in_sync;

//Load Addr_cnt register
always @(posedge clk_1 or negedge rst_n_sync) begin
    if (!rst_n_sync)
        addr_cnt_reg <= 'd0;
    else if (!scan_select)
        addr_cnt_reg[N_addr + N_cnt-1 : 0] <= {demux_out_addr, addr_cnt_reg[N_addr + N_cnt-1 : 1]};
end

//Load data_in scan register
always @(posedge clk_1 or negedge rst_n_sync) begin
    if (!rst_n_sync)
        data_scan_reg <= 'd0;
    else if (scan_select)
        data_scan_reg[N_data-1 : 0] <= {demux_out_data, data_scan_reg[N_data-1 : 1]};
end

//scan_clk divide logic
always @(posedge scan_clk) begin
    if (!rst_n_sync) clk_count <= 'd0;
    else if (clk_count == N_clk-1) clk_count <= 'd0;
    else clk_count <= clk_count + 1;
end
always @(posedge scan_clk) begin
    if (!rst_n_sync) clk_div <= 'd0;
    if(clk_count == N_clk-1) clk_div <= ~clk_div;
end

//Load data_in load register to drive SRAM inputs
always @(negedge clk_div) begin
    if (!rst_n_sync)
        data_in_reg <= 'd0;
    else begin
        data_in_reg <= data_scan_reg;
        $display($time, " [SC_IMEM] Scanned %h into addr %h", data_scan_reg, addr);
    end
end


//addr_counter count value
always@(posedge scan_select) begin
    addr_counter <= addr_cnt_reg[N_cnt-1:1];
end

//Addr generator from addr_cnt_reg
always @(negedge clk_div) begin
    if(!rst_n_sync) begin
        addr <= 'd0;
        we_sc <= 'b0;
        en_sc <= 'b1;
        addr_counter <= 'd0;
    end else if(scan_select)begin
        addr[N_addr-1:0] = addr_cnt_reg[N_addr+N_cnt-1:N_cnt] + (addr_cnt_reg[N_cnt-1:0] - addr_counter[N_cnt-1:0]);
        addr_counter = addr_counter -1;
        we_sc = addr_cnt_reg[0];
        en_sc = addr_cnt_reg[0];
    end
end

//data out load register
always @(posedge clk_div) begin
    if(!rst_n_sync)
        data_out_reg <= 'd0;
    else if (scan_select & !en_sc)
        data_out_reg <= addr_sc < data_sep ? imem_dout_buf : mem_dout_buf;
end

//Scan out data output register
always @(posedge clk_1) begin
    if(!rst_n_sync) begin
        scan_out <= 'b0;
        data_out_reg <= 'd0;
    end else begin
        scan_out <= rst_n_sync & data_out_reg[0];
        data_out_reg[N_data-1:0] <= {data_out_reg[0], data_out_reg[N_data-1:1]};
    end
end

wire clk_w = clk_div;
wire [N_addr-1:0] addr_sc = addr[N_addr-1:0];
wire [N_data-1:0] din_sc = data_in_reg[N_data-1:0];



// Multiplex memory inputs by scan_en
always_comb begin
    // Instruction Memory
    addra0 = addra0_rv;
    addra1 = addra1_rv;
    addra2 = addra2_rv;
    addra3 = addra3_rv;
    dina0  = dina0_rv;
    dina1  = dina1_rv;
    dina2  = dina2_rv;
    dina3  = dina3_rv;
    ena = ena_rv;
    wea = wea_rv;
    // Data Memory
    addrb0 = addrb0_rv;
    addrb1 = addrb1_rv;
    addrb2 = addrb2_rv;
    addrb3 = addrb3_rv;
    dinb0  = dinb0_rv;
    dinb1  = dinb1_rv;
    dinb2  = dinb2_rv;
    dinb3  = dinb3_rv;
    enb = enb_rv;
    web = web_rv;
    
    mem_clk = clk;
    if (scan_en == 1) begin
        if (addr_sc < data_sep) begin
            // Scanning instr mem
            addra0 = addr_sc;
            addra1 = addr_sc;
            addra2 = addr_sc;
            addra3 = addr_sc;
            ena = en_sc == 1 ? 4'b1111 : 4'b0000;
            wea = we_sc == 1 ? 4'b1111 : 4'b0000;
        end else begin
            // Scanning data mem
            addrb0 = addr_sc - data_sep;
            addrb1 = addr_sc - data_sep;
            addrb2 = addr_sc - data_sep;
            addrb3 = addr_sc - data_sep;
            enb = en_sc == 1 ? 4'b1111 : 4'b0000;
            web = we_sc == 1 ? 4'b1111 : 4'b0000;
        end
        dina0 = din_sc[7:0];
        dina1 = din_sc[15:8];
        dina2 = din_sc[23:16];
        dina3 = din_sc[31:24];
        mem_clk = scan_clk;
    end
end

endmodule