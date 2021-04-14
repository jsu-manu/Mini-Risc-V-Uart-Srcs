`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2020 04:14:45 PM
// Design Name: 
// Module Name: clk_div
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


module clk_div(
    input  logic clk_in,
    input  logic rst,
    input  logic [15:0] div,
    output logic clk_out
    );
    
    logic clk_sig;
    logic [15:0] cnt;
    always_ff@(posedge clk_in)
    begin
        if(rst)
        begin
            clk_sig<=1;
            cnt<=0;
        end
	
        else if(cnt==div)begin
            cnt<=0;
            clk_sig<=~clk_sig;
        end
	
	else
		cnt<=cnt+1;
    end

    assign clk_out = clk_sig;
endmodule

