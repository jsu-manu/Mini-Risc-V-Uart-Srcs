`timescale 1ns / 1ps
module tb_photon_wrapper();

    logic clk = 0;
    logic reset = 0;
    photon_bus bus(clk, reset);
    photon pho(bus);
    
    always begin
        clk <= ~clk; #1;
        clk <= ~clk; #1;
    end
    
    initial begin
        $monitor($time, " Read %h", bus.data_out);
        $monitor($time, " Ready state changed %h", bus.ready);
    end
    
    initial begin
        $display($time, " Resetting");
        bus.addr = 3'b000;
        bus.data_in = 32'hffffffff;
        reset = 0; #2;
        reset = 1; #2;
        reset = 0; #2;
        
        // Load
        bus.opcode = WRITE; bus.addr = 3'b000; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b001; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b010; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b011; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b100; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b101; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b110; bus.data_in = 32'h00000000; #2;
        bus.opcode = WRITE; bus.addr = 3'b111; bus.data_in = 32'h00382020; #2;
        
        // Hash
        bus.opcode = HASH; #2;
        
        // Wait
        @(posedge bus.ready);
        
        // Read
        bus.opcode = READ; bus.addr = 3'b000; #2;
        bus.opcode = READ; bus.addr = 3'b001; #2;
        bus.opcode = READ; bus.addr = 3'b010; #2;
        bus.opcode = READ; bus.addr = 3'b011; #2;
        bus.opcode = READ; bus.addr = 3'b100; #2;
        bus.opcode = READ; bus.addr = 3'b101; #2;
        bus.opcode = READ; bus.addr = 3'b110; #2;
        bus.opcode = READ; bus.addr = 3'b111; #2;
    end

endmodule
