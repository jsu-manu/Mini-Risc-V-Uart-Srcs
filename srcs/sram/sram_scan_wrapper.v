`timescale 1ns / 10ps 
module sram_scan_wrapper ( scan_clk, scan_rst_n, scan_in, scan_out );

parameter N_addr = 32;  //number of bits in addr
parameter N_cnt = 31;  // bits reserved for storing count for subsequent addresses + 1 bit specifying read/write

parameter N_data = 32;   //number of bits in data bus
parameter N_clk = 16;   //half the number of bits in data bus

input scan_clk, scan_rst_n, scan_in;
output scan_out;
reg scan_out;
reg write_en, sense_en;
reg [N_addr + N_cnt-1 : 0] addr_cnt_reg;
reg [N_data-1 : 0] data_scan_reg, data_in_reg, data_out_reg;
wire  [N_data-1 : 0]  dout;

reg  [N_addr-1 : 0]  addr;
integer addr_cnt_pointer;

reg rst_n_sync;
reg scan_in_sync;
reg [N_data-1:0] clk_count;
reg clk_div;
reg [N_cnt-1:0] addr_counter;

wire clk_1 = scan_rst_n & scan_clk;
//sync inputs with negedge of scan_clk
always @(negedge scan_clk) begin
    rst_n_sync <= scan_rst_n;
    scan_in_sync <= scan_rst_n & scan_in;
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
    else
        data_in_reg <= data_scan_reg;
end


//addr_counter count value
always@(posedge scan_select) begin
    addr_counter <= addr_cnt_reg[N_cnt-1:1];
end

//Addr generator from addr_cnt_reg
always @(negedge clk_div) begin
    if(!rst_n_sync) begin
        addr <= 'd0;
        write_en <= 'b0;
        sense_en <= 'b1;
        addr_counter <= 'd0;
    end else if(scan_select)begin
        addr[N_addr-1:0] = addr_cnt_reg[N_addr+N_cnt-1:N_cnt] + (addr_cnt_reg[N_cnt-1:0] - addr_counter[N_cnt-1:0]);
        addr_counter = addr_counter -1;
        write_en = addr_cnt_reg[0];
        sense_en = addr_cnt_reg[0];
    end
end

//data out load register
always @(posedge clk_div) begin
    if(!rst_n_sync)
        data_out_reg <= 'd0;
    else if (scan_select & !sense_en)
        data_out_reg <= dout;
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

wire    clk_w = clk_div;
wire    write_en_w = write_en;
wire    sense_en_w = sense_en;
wire [N_addr-1:0]   addr_w = addr[N_addr-1:0];
wire [N_data-1:0]   din_w = data_in_reg[N_data-1:0];

sram_compiled_array imem0 ( .dout7(dout[7]), .dout6(dout[6]),
     .dout5(dout[5]), .dout4(dout[4]), .dout3(dout[3]),
     .dout2(dout[2]), .dout1(dout[1]), .dout0(dout[0]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[7]), .din6(din_w[6]), .din5(din_w[5]), .din4(din_w[4]),
     .din3(din_w[3]), .din2(din_w[2]), .din1(din_w[1]), .din0(din_w[0]),
     .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));
     
sram_compiled_array imem1 ( .dout7(dout[15]), .dout6(dout[14]),
     .dout5(dout[13]), .dout4(dout[12]), .dout3(dout[11]),
     .dout2(dout[10]), .dout1(dout[9]), .dout0(dout[8]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[15]), .din6(din_w[14]), .din5(din_w[13]), .din4(din_w[12]),
     .din3(din_w[11]), .din2(din_w[10]), .din1(din_w[9]), .din0(din_w[8]),
     .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));

sram_compiled_array imem2 ( .dout7(dout[23]), .dout6(dout[22]),
     .dout5(dout[21]), .dout4(dout[20]), .dout3(dout[19]),
     .dout2(dout[18]), .dout1(dout[17]), .dout0(dout[16]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[23]), .din6(din_w[22]), .din5(din_w[21]), .din4(din_w[20]),
     .din3(din_w[19]), .din2(din_w[18]), .din1(din_w[17]), .din0(din_w[16]),
     .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));

sram_compiled_array imem3 ( .dout7(dout[31]), .dout6(dout[30]),
     .dout5(dout[29]), .dout4(dout[28]), .dout3(dout[27]),
     .dout2(dout[26]), .dout1(dout[25]), .dout0(dout[24]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[31]), .din6(din_w[30]), .din5(din_w[29]), .din4(din_w[28]),
     .din3(din_w[27]), .din2(din_w[26]), .din1(din_w[25]), .din0(din_w[24]),
     .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));

endmodule
