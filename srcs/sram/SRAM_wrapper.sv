`timescale 1ns / 10ps 
module sram_scan_wrapper ( clk, rst_n, scan_in, scan_out );

parameter N_addr = 12;  //number of bits in addr
parameter N_cnt = 13;  // bits reserved for storing count for subsequent addresses + 1 bit specifying read/write

parameter N_data = 8;   //number of bits in data bus
parameter N_clk = 3;   //number of bits in data bus

input clk, rst_n, scan_in;
output scan_out;
reg scan_out;
reg write_en, sense_en;
reg [N_addr + N_cnt-1 : 0] addr_cnt_reg;
reg [N_data-1 : 0] data_scan_reg, data_in_reg, data_out_reg;
wire  [N_data-1 : 0]  dout;
reg [N_data-1 : 0]  din;

reg  [N_addr-1 : 0]  addr;
integer addr_cnt_pointer;

reg rst_n_sync;
reg scan_in_sync;
reg scan_addr_data_switch;
reg [N_data-1:0] clk_count;
reg clk_div;
reg [N_cnt-1:0] addr_counter;

wire clk_1 = rst_n & clk;
//sync inputs with negedge of clk
always @(negedge clk_1) begin
    rst_n_sync <= rst_n;
    scan_in_sync <= rst_n & scan_in;
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
    if (!rst_n)
        scan_select <= 'b0;
    else if (addr_cnt_pointer == N_addr + N_cnt)
        scan_select <= 'b1;
end

wire demux_out_addr = !scan_select & scan_in_sync;
wire demux_out_data = scan_select & scan_in_sync;



//Load Addr_cnt register
always @(posedge clk_1 or negedge rst_n) begin
    if (!rst_n)
        addr_cnt_reg <= 'd0;
    else if (!scan_select)
        addr_cnt_reg[N_addr + N_cnt-1 : 0] <= {demux_out_addr, addr_cnt_reg[N_addr + N_cnt-1 : 1]};
end

//Load data_in scan register
always @(posedge clk_1 or negedge rst_n) begin
    if (!rst_n)
        data_scan_reg <= 'd0;
    else if (scan_select)
        data_scan_reg[N_data-1 : 0] <= {demux_out_data, data_scan_reg[N_data-1 : 1]};
end

//Load data_in load register to drive SRAM inputs
always @(posedge clk_div) begin
    if (!rst_n)
        data_in_reg <= 'd0;
    else
        data_in_reg <= data_scan_reg;
end

//clk divide logic
always @(posedge clk_1) begin
    if (!rst_n) clk_count <= 'd0;
    else if (clk_count == N_data) clk_count <= 'd0;
    else clk_count <= clk_count + 1;
end
always @(posedge clk_1) begin
    if (!rst_n) clk_div <= 'd0;
    if(clk_count == N_data-1) clk_div <= ~clk_div;
end


//addr_counter count value
always@(posedge scan_select) begin
    addr_counter <= addr_cnt_reg[N_cnt-1:1];
end

//Addr generator from addr_cnt_reg
always @(negedge clk_div) begin
    if(scan_select)begin
        addr[N_addr-1:0] = addr_cnt_reg[N_addr+N_cnt-1:N_cnt] + (addr_cnt_reg[N_cnt-1:0] - addr_counter[N_cnt-1:0]);
        addr_counter = addr_counter -1;
        write_en = addr_cnt_reg[0];
        sense_en = addr_cnt_reg[0];

    end
end

//data out load register
always @(posedge clk_div) begin
    if(!rst_n)
        data_out_reg <= 'd0;
    else if (scan_select & !sense_en)
        data_out_reg <= dout;
end

//Scan out data output register
always @(posedge clk_1) begin
    scan_out <= rst_n & data_out_reg[0];
    data_out_reg[N_data-1:0] <= {data_out_reg[0], data_out_reg[N_data-1:1]};
end

wire    clk_w = clk_div;
wire    write_en_w = write_en;
wire    sense_en_w = sense_en;
wire [N_addr-1:0]   addr_w = addr[N_addr-1:0];

wire [N_data-1:0]   din_w = data_in_reg[N_data-1:0];

sram_compiled_array SRAM_inst ( .dout1(dout[1]), .dout0(dout[0]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din1(din_w[1]), .din0(din_w[0]),
     .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));
endmodule
 

