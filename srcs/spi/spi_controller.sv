`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2021 01:22:39 PM
// Design Name: 
// Module Name: spi_controller
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
`default_nettype wire

module spi_controller(
	mmio_bus mbus
//	input logic clk, rst, 
//	input logic rd, wr, 
//	input logic [7:0] din, 
//	input logic ignore_response,
//	output logic data_avail,
//	output logic buffer_empty, buffer_full,
//	output logic [7:0] dout, 
	
//	output logic cs, sck, mosi,
//	input logic miso
    );
    
    logic clk, rst, rd, wr;
    logic [7:0] din;
    logic ignore_response, data_avail, buffer_empty, buffer_full;
    logic [7:0] dout; 
    logic cs, sck, mosi, miso; 
    
    always_comb begin
    	clk = mbus.clk; 
    	rst = mbus.Rst; 
    	rd = mbus.spi_rd;
    	wr = mbus.spi_wr; 
    	din = mbus.spi_din; 
    	ignore_response = mbus.spi_ignore_response; 
    	mbus.spi_data_avail = data_avail; 
    	mbus.spi_buffer_empty = buffer_empty;
    	mbus.spi_buffer_full = buffer_full; 
    	mbus.spi_dout = dout; 
    	miso = mbus.spi_miso; 
    	mbus.spi_mosi = mosi;
    	mbus.spi_cs = cs;
    	mbus.spi_sck = sck;
    end
    
    logic mosi_RD, mosi_WR;
    logic mosi_empty, mosi_full; 
    logic mosi_avail; 
    logic mosi_ignore_response;
    logic [8:0] mosi_din, mosi_dout; 
    
    logic miso_RD;
    logic miso_empty, miso_full;
    logic miso_avail;
    logic [7:0] miso_din, miso_dout;
    
    logic spi_en;
    logic [7:0] mosi_data_i, miso_data_o;
    logic spi_data_ready;
    
    logic ctrl_state; 
    
    spi_master spi0(clk, spi_en, mosi_data_i, miso_data_o, spi_data_ready, cs, sck, mosi, miso);
    gh_fifo_sync_sr #(.add_width(4), .data_width(9)) mosi_fifo(clk, rst, rst, mosi_WR, mosi_RD, mosi_din, mosi_dout, mosi_empty, mosi_full); 
    gh_fifo_sync_sr #(.add_width(4), .data_width(8)) miso_fifo(clk, rst, rst, (spi_data_ready & ~mosi_ignore_response), miso_RD, miso_din, miso_dout, miso_empty, miso_full); 
    
    assign mosi_avail = ~mosi_empty;
    assign miso_avail = ~miso_empty;
//    assign mosi_data_i = mosi_dout; 
    assign miso_din = miso_data_o; 
    assign mosi_WR = wr;
    assign mosi_din = {ignore_response, din}; 
    assign buffer_empty = mosi_empty;
    assign buffer_full = mosi_full;
    assign data_avail = miso_avail;
//    assign dout = miso_dout;
    assign miso_RD = miso_avail & rd;
    
    always_ff @(posedge miso_RD or posedge rst) begin
    	if (rst) begin
    		dout <= 0;
    	end else begin
    		dout <= miso_dout;
    	end
    end
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		ctrl_state <= 0;
    		mosi_RD <= 0; 
//    		miso_RD = 0; 
    		spi_en <= 0; 
    		mosi_ignore_response <= 1;
    		mosi_data_i <= 0;
//    		dout <= 0;
    	end else begin
    		if ((ctrl_state == 0) && (mosi_avail)) begin
    			ctrl_state <= 1; 
    			mosi_RD <= 1; 
    			spi_en <= 1;
    			mosi_data_i <= mosi_dout[7:0];
    			mosi_ignore_response <= mosi_dout[8];
    		end else if (ctrl_state & spi_data_ready) begin
    			if (mosi_empty) begin
    				ctrl_state <= 0;
    				spi_en <= 0; 
    			end else begin
    				mosi_RD <= 1; 
    				mosi_data_i <= mosi_dout[7:0];
    				mosi_ignore_response <= mosi_dout[8];
    			end
    		end else begin
    			mosi_RD <= 0;
    		end
    		
//    		if (miso_RD) begin
//    			dout <= miso_dout;
//    		end
//    		if (miso_avail & rd) begin
//    			miso_RD <= 1;
//    		end else begin
//    			miso_RD <= 0;
//    		end
    	end
    end
    
endmodule
