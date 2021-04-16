`timescale 1ns / 1ns 
module tb_sram_scan ( );

reg clk, rst_n, scan_in;
wire scan_out;

initial begin
    clk = 'b0;
    rst_n = 'b0;
    scan_in = 'b0;
    repeat(10) @(posedge clk); // Reset scanchain
    rst_n = 'b1;
    //write_en/sense_en
    scan_in = 'b1; // First bit as 1 for write
    @(posedge clk);
    //addr_count
    scan_in = 'b1; // Number of addresses to write
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    //address
    scan_in = 'b0; // Initial address to begin writing at
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    //data in
    scan_in = $random; // Start actually writing data
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    //2
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    //3
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    //4
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    //5
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    scan_in = $random;
    @(posedge clk);
    #2000;
    rst_n = 'b0;
    repeat(10) @(posedge clk); // Reset sram scan chain again
    rst_n = 'b1;
    //@(posedge clk);
    //write_en/sense_en
    scan_in = 'b0; // First bit 0 to read
    @(posedge clk);
    //addr_count
    scan_in = 'b1; // Number of addresses to read
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    scan_in = 'b1;
    @(posedge clk);
    //address
    scan_in = 'b0; // Address to start reading at
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    scan_in = 'b0;
    @(posedge clk);
    #10000;
    $finish;
end


always #50 clk = ~clk;
//always #100 scan_in = ~scan_in;


sram_scan_wrapper SRAM_wrapper_inst ( clk, rst_n, scan_in, scan_out );

endmodule
 


