`timescale 1ns / 1ps 
module sram_compiled_array_test ( );

reg clk, resetn;
reg write_en, sense_en;
wire  [0:7]  dout;

reg [7:0]  din;

reg  [11:0]  addr;
integer i=0;


initial begin
    clk = 'b0;
    resetn = 'b1;
    write_en = 'b0;
    sense_en = 'b1;
    addr = 'd0;
    din = 'd0;
end


always #20 clk = ~clk;

initial begin
    @(posedge clk);
    for (i=0; i<100; i=i+1) begin
        addr = $random;
        din = $random;
        write_en = 'b1;
        //repeat(2) @(posedge clk);
        @(posedge clk);
        write_en = 'b0;
        @(posedge clk);
        sense_en = 'b0;
        @(posedge clk);
        sense_en = 'b1;
        @(posedge clk);
    end
    repeat(50) @(posedge clk);
    $finish;
end

wire    clk_w = clk;
wire    resetn_w = resetn;
wire    write_en_w = write_en;
wire    sense_en_w = sense_en;
wire [11:0]   addr_w = addr[11:0];
wire [7:0]   din_w = din[7:0];


sram_compiled_array SRAM_inst ( .dout7(dout[7]), .dout6(dout[6]),
     .dout5(dout[5]), .dout4(dout[4]), .dout3(dout[3]),
     .dout2(dout[2]), .dout1(dout[1]), .dout0(dout[0]),
     .sense_en(sense_en_w), .write_en(write_en_w), .clk(clk_w),
     .din7(din_w[7]), .din6(din_w[6]), .din5(din_w[5]), .din4(din_w[4]),
     .din3(din_w[3]), .din2(din_w[2]), .din1(din_w[1]), .din0(din_w[0]),
     .addr10(addr_w[10]), .addr9(addr_w[9]),
     .addr8(addr_w[8]), .addr7(addr_w[7]), .addr6(addr_w[6]),
     .addr5(addr_w[5]), .addr4(addr_w[4]), .addr3(addr_w[3]),
     .addr2(addr_w[2]), .addr1(addr_w[1]), .addr0(addr_w[0]));
endmodule
 


