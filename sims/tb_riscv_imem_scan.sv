`timescale 1ns / 1ns

module tb_riscv_imem_scan();

logic clk, Rst;
logic rx, tx;
logic scan_en, scan_in;
logic miso, mosi, cs;

rv_uart_top dut(.*); 

always #5 clk = !clk;

task scan_word(input logic[31:0] word);
    for (int i = 0; i < 32; i++) begin
        scan_in = word[i]; #10;
    end;
endtask

initial begin
    $display("Begin simulaton");
//    readfile("/home/gray/Projects/Mini-Risc-V-Uart-Srcs/gcc/test1.hex");
    clk = 0;
    Rst = 1;
    scan_en = 1;
    scan_in = 0;
    rx = 0;
    miso = 0;
    
    // Reset
    #50; Rst = 0;
    
    // Load IMEM
    scan_word(32'h00012117);
    scan_word(32'h04010113);
    scan_word(32'h00022517);
    scan_word(32'h03c50513);
    scan_word(32'h2f5000ef);
    scan_word(32'h00000097);
    scan_word(32'h00c08093);
    scan_word(32'h008000ef);
    
    // Execute instructions
    scan_en = 0; #9000;
    $display("End simulaton");
end

endmodule
