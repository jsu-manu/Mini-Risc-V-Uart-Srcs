`timescale 1ns / 1ps 
module sram_compiled_array_test ( );

reg clk, resetn;
reg write_en, sense_en;
wire  [0:7]  dout;

reg [7:0]  din;

reg  [11:0]  addr;


initial begin
    clk = 'b0;
    resetn = 'b1;
    write_en = 'b0;
    sense_en = 'b1;
    addr[0] = 'b0;
    addr[1] = 'b0;
    addr[2] = 'b0;
    addr[3] = 'b0;
    addr[4] = 'b0;
    addr[5] = 'b0;
    addr[6] = 'b0;
    addr[7] = 'b0;
    addr[8] = 'b0;
    addr[9] = 'b0;
    addr[10] = 'b0;
    addr[11] = 'b0;
    din[0] = 'b0;
    din[1] = 'b0;
    din[2] = 'b0;
    din[3] = 'b0;
    din[4] = 'b0;
    din[5] = 'b0;
    din[6] = 'b0;
    din[7] = 'b0;
end


always #20 clk = ~clk;
always #160 write_en = ~write_en;
always #10 sense_en = (~sense_en || write_en);
always #40 addr[0] = $random;
always #80 addr[1] = $random;
always #40 addr[2] = $random;
always #80 addr[3] = $random;
always #40 addr[4] = $random;
always #80 addr[5] = $random;
always #40 addr[6] = $random;
always #80 addr[7] = $random;
always #40 addr[8] = $random;
always #80 addr[9] = $random;
always #40 addr[10] = $random;
always #80 addr[11] = $random;
always #40 din[0] = $random;
always #80 din[1] = $random;
always #120 din[2] = $random;
always #160 din[3] = $random;
always #200 din[4] = $random;
always #240 din[5] = $random;
always #280 din[6] = $random;
always #320 din[7] = $random;

initial begin
   // force addr[0] = 1'b0;
   // force addr[1] = 1'b0;
   // #500;
   // release addr[0];
   // release addr[1];
    #2000;
    $finish;
end

wire    clk_w = clk;
wire    resetn_w = resetn;
wire    write_en_w = write_en;
wire    sense_en_w = sense_en;
wire [11:0]   addr_w = addr[11:0];
//wire    addr_w[1] = addr[1];
//wire    addr_w[2] = addr[2];
//wire    addr_w[3] = addr[3];
//wire    addr_w[4] = addr[4];
//wire    addr_w[5] = addr[5];
//wire    addr_w[6] = addr[6];
//wire    addr_w[7] = addr[7];
//wire    addr_w[8] = addr[8];
//wire    addr_w[9] = addr[9];
//wire    addr_w[10] = addr[10];
//wire    addr_w[11] = addr[11];
wire [7:0]   din_w = din[7:0];
//wire    din_w[1] = din[1];
//wire    din_w[2] = din[2];
//wire    din_w[3] = din[3];
//wire    din_w[4] = din[4];
//wire    din_w[5] = din[5];
//wire    din_w[6] = din[6];
//wire    din_w[7] = din[7];


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
 


