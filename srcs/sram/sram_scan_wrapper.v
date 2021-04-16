`timescale 1ns / 10ps 
module sram_scan_wrapper ( clk, rst_n, scan_in, scan_out );

parameter N_addr = 12;  //number of bits in addr
parameter N_cnt = 13;  // bits reserved for storing count for subsequent addresses + 1 bit specifying read/write

parameter N_data = 8;   //number of bits in data bus
parameter N_clk = 4;   //half the number of bits in data bus

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
reg [N_data-1:0] clk_count;
reg clk_div;
reg [N_cnt-1:0] addr_counter;

wire clk_1 = rst_n & clk;
//sync inputs with negedge of clk
always @(negedge clk) begin
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

//clk divide logic
always @(posedge clk) begin
    if (!rst_n_sync) clk_count <= 'd0;
    else if (clk_count == N_clk-1) clk_count <= 'd0;
    else clk_count <= clk_count + 1;
end
always @(posedge clk) begin
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

sram_compiled_array SRAM_inst ( .dout7(dout[7]), .dout6(dout[6]),
     .dout5(dout[5]), .dout4(dout[4]), .dout3(dout[3]),
     .dout2(dout[2]), .dout1(dout[1]), .dout0(dout[0]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[7]), .din6(din_w[6]), .din5(din_w[5]), .din4(din_w[4]),
     .din3(din_w[3]), .din2(din_w[2]), .din1(din_w[1]), .din0(din_w[0]),
     .addr11(addr_w[11]), .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));

endmodule
 


//reg [1:0] CUR_SCAN_STATE;
//reg [1:0] NXT_SCAN_STATE;
//
//localparam LD_ADDR_CNT = 2'b00,
//           SCAN_DATA_IN = 2'b01,
//           SCAN_DATA_OUT = 2'b01,
//           RESET_SCAN = 2'b11;
//always @(*) begin
//    NXT_SCAN_STATE = CUR_SCAN_STATE;
//    case (CUR_SCAN_STATE)
//        RESET_SCAN : begin
//            
//        end
//        LD_ADDR_CNT : begin
//        end
//        SCAN_DATA_IN : begin
//        end
//        SCAN_DATA_OUT : begin
//        end
//end

