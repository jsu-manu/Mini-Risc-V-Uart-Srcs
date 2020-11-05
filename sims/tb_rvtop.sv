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

//task readfile(input string fname);
//begin
//    int fd, i; 
//    int idx; 
//    fd = $fopen(fname, "rb");
//    idx = 0;
//    while ($fscanf (fd, "%08x", i) == 1) begin
//        $display ("%08x: %08x", idx, i);
//        rxword(i);
//        idx = idx + 4;
//    end 
//    $fclose(fd);
    
//end
//endtask


//task rxchar(input [7:0] c);
//begin
//    while(dut.u0.rx_fifo_full) #10; 
    
//    dut.u0.rx_dout = c;
//    dut.u0.rx_pres = 1'b1;
//    #10; 
//    dut.u0.rx_pres = 1'b0;
//    dut.u0.rx_dout = 8'h00; 
//    #10;
//end
//endtask

//task rxword(input [31:0] w); 
//begin
//    rxchar(w[7:0]); 
//    rxchar(w[15:8]);
//    rxchar(w[23:16]);
//    rxchar(w[31:24]);
//end
//endtask

//    always_ff @(posedge dut.mbus.tx_wen) begin
//        $strobe("%h", dut.mbus.uart_din);
//    end

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



//    #9000;
//    rx = 0; //start bit
//    #9000;
//    rx = 1; //d0
//    #9000;
//    rx = 0; //d1
//    #9000;
//    rx = 1; //d2
//    #9000;
//    rx = 0; //d3
//    #9000;
//    rx = 1; //d4
//    #9000;
//    rx = 0; //d5
//    #9000;
//    rx = 1; //d6
//    #9000;
//    rx = 0; //d7
//    #9000;
//    rx = 1; //stop bit
    
//    #1500
    
//    debug_input=5'b00001;
//    #10
//    debug_input=5'b00010;
//    #10
//    debug_input=5'b00011;

end

endmodule
