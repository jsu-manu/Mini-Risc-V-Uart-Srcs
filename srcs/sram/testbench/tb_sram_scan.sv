`timescale 1ns / 1ns 
module tb_sram_scan ( );

reg clk, rst_n, scan_in;
wire scan_out;

task scan_bits(input logic[31:0] word, integer bit_length);
    for (int i = 0; i < bit_length; i++) begin
        scan_in = word[i];
        @(posedge clk);
    end;
endtask

task scan_word(input logic[31:0] word);
    scan_bits(word, 32);
endtask

initial begin
    // Initialize/reset scanchain
    clk = 'b0;
    rst_n = 'b0;
    scan_in = 'b0;
    repeat(10) @(posedge clk);
    rst_n = 'b1;
    
    // First bit as 1 for write (write_en/sense_en)
    scan_bits(1'b1, 1);
    
    // Number of addresses to write (addr_count)
    //scan_bits(11'b1111_1111_1111_1111, 11);
    scan_bits(32'hFFFF_FFFF, 31);
    
    // Initial address to begin writing at (address)
    //scan_bits(11'b000_0000_0000, 11);
    scan_bits(32'h0000_0000, 32);
    
    // Start actually wtiting data
    scan_word(32'h00012117);
    scan_word(32'h04010113);
    scan_word(32'h00022517);
    scan_word(32'h03c50513);
    #2000;
    
    // Reset sram scan chain again
    rst_n = 'b0;
    repeat(10) @(posedge clk);
    rst_n = 'b1;
    
    // First bit 0 to read (write_en/sense_en)
    scan_bits(1'b0, 1);
    
    // Number of addresses to read (addr_count)
    scan_bits(32'hFFFF_FFFF, 31);
    
    // Address to start reading at (address)
    scan_bits(32'h0000_0000, 32);
    
    // Read data
    #40000;
    $finish;
end


always #50 clk = ~clk;

sram_scan_wrapper SRAM_wrapper_inst ( clk, rst_n, scan_in, scan_out );

endmodule
 


