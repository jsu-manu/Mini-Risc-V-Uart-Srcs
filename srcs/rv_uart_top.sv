`timescale 1ns / 1ps

interface riscv_bus (
    input logic clk, Rst, debug, prog, //rx, prog, 
    input logic [4:0] debug_input,
//    output logic [31:0] debug_output
    input logic [95:0] key
    );

    logic mem_wea, mem_rea;
    logic [3:0] mem_en; 
    logic [31:0] mem_addr;
    logic [31:0] mem_din, mem_dout; 
    logic [2:0] storecntrl;
    logic [31:0] debug_output;
    
    logic imem_en, imem_prog_ena;
    logic [31:0] imem_addr;
    logic [31:0] imem_dout, imem_din; 
    
    logic mem_hold;
    logic uart_IRQ;
    logic trapping;
    
    //RAS signals 
    logic RAS_branch, ret, stack_full, stack_empty, stack_mismatch; 
    logic [31:0] RAS_addr_in, RAS_mem_dout, RAS_mem_din, RAS_mem_addr; 
    logic RAS_mem_rdy, RAS_mem_rd, RAS_mem_wr, RAS_rdy; 
    logic [31:0] IF_ID_pres_addr, ins, IF_ID_dout_rs1, branoff, next_addr; 
    logic branch, IF_ID_jal;
    logic [4:0] IF_ID_rd;
    
    assign ret = (branch & (ins == 32'h8082));
//    assign RAS_branch = (branch & (~ret));
	assign RAS_branch = branch & IF_ID_jal & (IF_ID_rd == 1); 
    assign RAS_mem_rdy = 1;
    assign RAS_addr_in = RAS_branch ? (next_addr) : (ret ? branoff : 1'b0);
//    assign RAS_addr_in = RAS_branch ? ret_addr : (ret ? IF_ID_dout_rs1 : 1'b0);
    
    modport core(
        input clk, Rst, debug, prog, debug_input, mem_dout, imem_dout, //rx,
        output debug_output, mem_wea, mem_rea, mem_en, mem_addr, mem_din, imem_en, 
        output imem_addr, imem_din, imem_prog_ena, storecntrl,
        input key, input mem_hold, uart_IRQ, 
        output trapping, 
        output IF_ID_pres_addr, ins, IF_ID_dout_rs1, branch, IF_ID_jal, IF_ID_rd, branoff, next_addr,
        input stack_mismatch, RAS_rdy, RAS_branch, ret
    );
    
    modport memcon(
        input clk, Rst, mem_wea, mem_en, mem_addr, mem_din, imem_en, 
        input imem_addr, imem_din, imem_prog_ena, mem_rea, storecntrl,
        output mem_dout, imem_dout, mem_hold
    );
    
    modport CRAS(
    	input clk, Rst, RAS_branch, ret, RAS_addr_in, RAS_mem_dout,
    	input RAS_mem_rdy, 
    	output stack_full, stack_empty, stack_mismatch, RAS_mem_din, RAS_mem_addr,
    	output RAS_mem_rd, RAS_mem_wr, RAS_rdy 
    );
    
    modport uart(
    	output uart_IRQ
    );
endinterface

interface mmio_bus (
        input logic clk, Rst, rx,// uart_clk,
        input logic [4:0] debug_input, BR_clk,
        output logic tx, 
        input logic spi_miso, 
        output logic spi_mosi, spi_cs, spi_sck
        //output logic[31:0] led
    );
    logic [31:0] led;
    logic disp_wea;
    logic [31:0] disp_dat; 
    logic [31:0] disp_out;
    
    //uart ports
    logic [7:0] uart_din, uart_dout; 
    logic rx_ren, tx_wen, rx_data_present;
    logic tx_full;
    logic [2:0] uart_addr;
//    logic BR_clk;
    
    //SPI interface
    logic spi_rd, spi_wr;
    logic [7:0] spi_din;
    logic spi_ignore_response; 
    logic spi_data_avail, spi_buffer_empty, spi_buffer_full;
    logic [7:0] spi_dout;  
    
    //CRAS interface
    logic [31:0] RAS_config_din; 
    logic [2:0] RAS_config_addr; 
    logic RAS_config_wr;
    
    
    modport memcon(
        input clk, Rst,
        output disp_dat, disp_wea, led, 
        
        input uart_dout, rx_data_present , tx_full,
        output uart_din, rx_ren, tx_wen, uart_addr, 
        
        input spi_data_avail, spi_buffer_empty, spi_buffer_full, spi_dout, 
        output spi_rd, spi_wr, spi_din, spi_ignore_response, 
        
        output RAS_config_din, RAS_config_addr, RAS_config_wr
    );
    
    modport display(
        input clk, Rst, disp_wea, disp_dat, debug_input, 
        output disp_out
    );
    
    modport uart(
        input clk, Rst, rx, rx_ren, tx_wen, uart_din, uart_addr, BR_clk, //uart_clk,
        output rx_data_present, tx, uart_dout, tx_full
    );
    
    modport spi(
    	input clk, Rst, spi_rd, spi_wr, spi_din, spi_ignore_response, spi_miso, 
    	output spi_data_avail, spi_buffer_empty, spi_buffer_full, spi_dout, spi_mosi, spi_cs, spi_sck
    );
    
    modport CRAS(
    	input RAS_config_din, RAS_config_addr, RAS_config_wr
    );
    
endinterface

module rv_uart_top
 (input  logic       clk,
  input  logic       Rst,
  input  logic       debug,
  input  logic       rx, //uart recv pin
  input  logic       prog, //similar to debug, but shows mem addr, and allows reprogramming
//  input  logic       addr_dn,
//  input  logic       addr_up,
  input  logic [4:0] debug_input,
  output logic tx, clk_out,
  output logic [6:0] sev_out,
  output logic [7:0] an,
  output logic [15:0] led,
//  input logic [95:0] key

	//SPI STUFF
	input logic miso, 
	output logic mosi, cs
  );

  logic [31:0] debug_output;
  logic [3:0]  seg_cur, seg_nxt;
  logic        clk_50M, clk_5M,clk_7seg;// clk_disp;
  logic addr_dn, addr_up;
  //clock divider variable
//  integer      count;
  logic [95:0] key; 
  
  
assign key[95:48]=48'h3cf3cf3cf3cf;
assign key[47:24]=24'h30c30c;
assign key[23:12]=12'hbae;
assign key[11:0]=12'h3cf;
//  assign key[95:48]=48'haaaaaaaaaaaa;
//assign key[47:24]=24'h000000;
//assign key[23:12]=12'h000;
//assign key[11:0] = 12'h000;
  logic rst_in, rst_last;
  
  
  logic spi_mosi, spi_miso, spi_cs, spi_sck;
//  assign spi_miso = spi_mosi;
	assign spi_miso = miso;
	assign mosi = spi_mosi; 
	assign cs = spi_cs; 
//	assign cs = 1;
//	assign mosi = 1;
	
	
STARTUPE2 startup_i(.CFGCLK(), .CFGMCLK(), .EOS(), .PREQ(), .CLK(0), .GSR(0), .GTS(0), .KEYCLEARB(0), .PACK(0), .USRCCLKO(spi_sck), .USRCCLKTS(0), .USRDONEO(0), .USRDONETS(0));
//  logic mem_wea;
//  logic [3:0] mem_en;
//  logic [11:0] mem_addr;
//  logic [31:0] mem_din, mem_dout;


//`ifndef SYNTHESIS

clk_wiz_0 c0(.*);
//initial begin
//	clk_50M = 0;
//end
  riscv_bus rbus(.clk(clk_50M), .*);
  mmio_bus mbus(.clk(clk_50M), .BR_clk(clk), .*);
clk_div cdiv(clk,Rst,16'd500,clk_7seg);  
//`else
// riscv_bus rbus(.*);
// mmio_bus mbus(.*);

 // riscv_bus rbus(.*);
 // mmio_bus mbus(.*);
//`else
// clk_wiz_0 c0(.*);
 // riscv_bus rbus(.clk(clk_50M), .*);
  //mmio_bus mbus(.clk(clk_50M),  .*);

//`endif
  
  assign led = {14'h0, rbus.trapping, rbus.uart_IRQ};
  
  assign debug_output = (prog | debug ) ? rbus.debug_output : mbus.disp_out;
  

  enum logic [7:0] {a0=8'b11111110, a1=8'b11111101,
                    a2=8'b11111011, a3=8'b11110111,
                    a4=8'b11101111, a5=8'b11011111,
                    a6=8'b10111111, a7=8'b01111111} 
                    an_cur, an_nxt;

  //RISCVcore rv_core(.clk(clk), .*);
//  RISCVcore_uart rv_core(.*);
//    RISCVcore_uart rv_core(.clk(clk_50M), .*);  
    RISCVcore_uart rv_core(rbus.core);    
    Memory_Controller memcon0(rbus.memcon, mbus.memcon);
    
    Debug_Display d0(mbus.display);
    
    uart_controller u0(mbus.uart, rbus.uart);
    
    spi_controller spi0(mbus.spi);
    
    CRAS_top CRAS(rbus.CRAS, mbus.CRAS);
    
//    Memory_byteaddress mem0(.clk(clk_50M), .rst(Rst), .wea(mem_wea), .en(mem_en), .addr(mem_addr),
//        .din(mem_din), .dout(mem_dout));
    
  //clock divider logic
//  always @(posedge clk) begin
//  	if (Rst) clk_50M <= 0;
//  	else clk_50M<=!clk_50M;
////    rst_last <= Rst;
////    if (Rst == 1'b1 && rst_in == 1'b0 && rst_last == 1'b0) 
////        rst_in <= 1;
////    else
////        rst_in <= 0;
////     count <= count + 1;
////     clk_50M<=!clk_50M;
////     if(count==500)
////     begin
////        count<=0;
////        clk_disp <= !clk_disp;
////     end
//  end
 

  //clk_wiz_0 clk_div0(clk_50M, clk);
  //clk_wiz_1 clk_div1(clk_5M, clk_50M);

  assign an = an_cur;
//  assign led = debug_output[15:0];
  assign clk_out = clk_50M;
  
  always_ff @(posedge clk_7seg) begin
    if (Rst) begin
      an_cur <= a0;
      seg_cur <= debug_output[3:0];
    end
    else begin
      an_cur <= an_nxt;
      seg_cur <= seg_nxt;
    end
  end

  always_comb begin
    case(an_cur)
      a0: begin 
            an_nxt = a1;
            seg_nxt = debug_output[7:4];
          end
      a1: begin 
            an_nxt = a2;
            seg_nxt = debug_output[11:8];
          end
      a2: begin 
            an_nxt = a3;
            seg_nxt = debug_output[15:12];
          end
      a3: begin 
            an_nxt = a4;
            seg_nxt = debug_output[19:16];
          end
      a4: begin 
            an_nxt = a5;
            seg_nxt = debug_output[23:20];
          end
      a5: begin 
            an_nxt = a6;
            seg_nxt = debug_output[27:24];
          end
      a6: begin 
            an_nxt = a7;
            seg_nxt = debug_output[31:28];
          end
      a7: begin 
            an_nxt = a0;
            seg_nxt = debug_output[3:0];
          end
      default: begin 
            an_nxt = a0;
            seg_nxt = debug_output[3:0];
          end
    endcase
  end

  always_comb begin
    case (seg_cur)
      4'b0000: sev_out = 7'b0000001;
      4'b0001: sev_out = 7'b1001111; 
      4'b0010: sev_out = 7'b0010010; 
      4'b0011: sev_out = 7'b0000110; 
      4'b0100: sev_out = 7'b1001100; 
      4'b0101: sev_out = 7'b0100100; 
      4'b0110: sev_out = 7'b0100000; 
      4'b0111: sev_out = 7'b0001111; 
      4'b1000: sev_out = 7'b0000000; 
      4'b1001: sev_out = 7'b0000100; 
      4'b1010: sev_out = 7'b0001000;
      4'b1011: sev_out = 7'b1100000;
      4'b1100: sev_out = 7'b0110001;
      4'b1101: sev_out = 7'b1000010;
      4'b1110: sev_out = 7'b0110000;
      4'b1111: sev_out = 7'b0111000;
      default: sev_out = 7'b0000000;
    endcase
  end
  
//  integer cnt = 0;
//    integer maxcnt = 100000000;
//    always_ff @(posedge clk) begin
//        if (Rst) begin
//            cnt = 0;
//        end else if (~(debug || prog)) begin
//            if (cnt == maxcnt) begin
//                cnt <= 0;
//                addr_dn <= 1;
//            end else begin
//                cnt <= cnt + 1;
//                addr_dn <= 0;
//            end
//        end
//    end
endmodule: rv_uart_top
			  
