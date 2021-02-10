`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2020 02:52:54 PM
// Design Name: 
// Module Name: ra_stack
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


module ra_stack #(
    DATA_WIDTH = 32, 
    DEPTH = 512
)(
    input logic clk, rst, ena,
    input logic push, pop, ret, 
    input logic [DATA_WIDTH-1:0] din, 
    output logic [DATA_WIDTH-1:0] dout,
    output logic mismatch, full, empty
//        main_bus bus
    );
    
//    logic clk, rst, ena, push, pop, mismatch, full, empty; 
//    logic [DATA_WIDTH - 1:0] din; 
    
//    always_comb begin : bus_interface
//        clk = bus.clk;
//        rst = bus.Rst; 
//        ena = bus.stack_ena; 
//        push = bus.push;
//        pop = bus.pop; 
//        din = bus.stack_din; 
//        bus.stack_mismatch = mismatch;
//        bus.stack_full = full;
//        bus.stack_empty = empty; 
//    end
    
    logic [DATA_WIDTH-1:0] data [DEPTH-1:0]; 
    
    integer cnt = 0;
    
//    assign full = ~(cnt < DEPTH);
    assign empty = (cnt == 0); 
	assign full = (cnt == DEPTH);
    
    task stack_push;
    begin
    	data[cnt] = din;
    	cnt++; 
//        for (int i = DEPTH - 1; i > 0; i--) begin
//            data[i] = data[i-1]; 
//        end 
//        data[0] = din;
//        cnt++; 
    end
    endtask
    
    task stack_pop(input logic is_ret); 
    begin
    	logic [DATA_WIDTH-1:0] tmp;
    	cnt--;
    	dout = data[cnt]; 
    	tmp = data[cnt];
    	data[cnt] = 0; 
    	if ((tmp != din) & is_ret) mismatch = 1;
//        logic [DATA_WIDTH-1:0] tmp; 
//        tmp = data[0]; 
//        dout = data[0];
//        for (int i = 0; i < DEPTH - 2; i++) begin
//            data[i] = data[i+1];
//        end
//        cnt--; 
//        if ((tmp != din) & is_ret) begin
//            mismatch = 1;
//        end
    end 
    endtask
    
    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0; 
            mismatch <= 0;
            for (int i = 0; i < DEPTH; i++)
            	data[i] <= 0;
        end else if (ena & ~mismatch) begin
            if (push & ~full) begin
                stack_push(); 
            end else if ((pop | ret) & ~empty) begin
                stack_pop(ret);
            end
        end 
    end
    
    
endmodule
