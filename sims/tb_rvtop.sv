`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 10:07:43 AM
// Design Name: 
// Module Name: tb_rvtop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_rvtop();

logic clk, Rst, debug, rx, prog;
logic[ 4:0] debug_input; 
logic tx, clk_out; 
logic [6:0] sev_out;
logic [7:0] an;
logic [15:0] led; 
logic [95:0] key;

assign key[95:48]=48'h3cf3cf3cf3cf;
assign key[47:24]=24'h30c30c;
assign key[23:12]=12'hbae;
assign key[11:0]=12'h3cf;
//assign key[95:48]=48'haaaaaaaaaaaa;
//assign key[47:24]=24'h000000;
//assign key[23:12]=12'h000;
//assign key[11:0] = 12'h000;
rv_uart_top dut(.*); 

always #5 clk=!clk; 

//int cache_hits = 0;
//int cache_misses = 0; 
//real hit_rate = 0; 
//logic cache_access;
//logic cache_hit;
//logic cache_miss; 

//logic done = 0;

//assign cache_access = dut.memcon0.cache_inst.ren | dut.memcon0.cache_inst.wen; 
//assign cache_hit = dut.memcon0.cache_inst.cache_hit; 
//assign cache_miss = dut.memcon0.cache_inst.cache_miss; 

//always_ff @(posedge dut.clk_50M) begin
//	if (cache_access) begin
//		if (cache_hit) cache_hits += 1; 
//		else if (cache_miss) cache_misses += 1; 
//	end
	
//	if (dut.rv_core.bus.IF_ID_pres_addr == 32'h14 && !dut.rv_core.u2.flush) done = 1;
//end

//always_ff @(posedge done) begin
//	hit_rate = real'(cache_hits) / real'(cache_hits + cache_misses); 
//	$display("Total Hits: %d", cache_hits);
//	$display("Total Misses: %d", cache_misses); 
//	$display("Hit Rate: %f", hit_rate); 
//end

initial begin
    $display("Begin simulaton");
//    readfile("/home/gray/Projects/Mini-Risc-V-Uart-Srcs/gcc/test1.hex");
    clk = 0;
    Rst = 1; 
    debug = 0;
    rx = 1; 
    prog = 0;
    debug_input = 0; 
    #10;
    Rst=0;
    
//    #1000
//    dut.rv_core.trap = 1;
//    #10
//    dut.rv_core.trap = 0;
    
//    #5000;
//    rxchar(8'hef);
//    rxchar(8'hbe);
//    rxchar(8'had);
//    rxchar(8'hde);
    
//    readfile("/home/gray/Projects/Mini-Risc-V-Uart-Srcs/gcc/rop1.hex");

    
//    rxchar(8'hef);
//    rxchar(8'hbe);
//    rxchar(8'had);
//    rxchar(8'hde);



    #9000;
    rx = 0; //start bit
    #9000;
    rx = 1; //d0
    #9000;
    rx = 0; //d1
    #9000;
    rx = 1; //d2
    #9000;
    rx = 0; //d3
    #9000;
    rx = 1; //d4
    #9000;
    rx = 0; //d5
    #9000;
    rx = 1; //d6
    #9000;
    rx = 0; //d7
    #9000;
    rx = 1; //stop bit
    
//    #1500
    
//    debug_input=5'b00001;
//    #10
//    debug_input=5'b00010;
//    #10
//    debug_input=5'b00011;

end

endmodule
