`timescale 1ns / 1ps 

module Memory_Controller (
    riscv_bus rbus, 
    mmio_bus mbus
);

logic clk, rst;
logic mem_wea, mem_rea;
logic [3:0] mem_en, mem_en_last;
logic [11:0] mem_addr_lower;
logic [19:0] mem_addr_upper;
logic [31:0] mem_din, mem_dout; 

logic disp_wea;
logic [31:0] disp_dat;

logic [31:0] imem_addr, imem_dout, imem_din; 
logic imem_en, imem_state;


logic mmio_region, kernel_region, prog_region, uart_region;
logic [31:0] blkmem_dout, doutb, blkmem_din; 
logic [7:0] uart_dout;
logic uart_last_cond;
logic [11:0] uart_last_addr; 
logic [31:0] uart_last_out;

logic [2:0] cache_storecntrl = 3'b000;
logic [4:0] cache_loadcntrl = 5'b00100; 

logic [7:0] cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout;
logic [7:0] cell_0_din, cell_1_din, cell_2_din, cell_3_din;
logic [8:0] cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr;
logic cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en; 
logic cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen;

logic [31:0] cache_mem_dout, cache_mem_din;
logic cache_mem_ren, cache_mem_wen; 
logic [31:0] cache_mem_addr;

logic mem_hold;

logic cache_rdy;
assign mem_hold = ~cache_rdy;
//assign mem_hold = 0;

always_comb begin
    clk = rbus.clk;
    rst = rbus.Rst; 
    mem_wea = rbus.mem_wea;
    mem_rea = rbus.mem_rea;
    mem_din = rbus.mem_din; 
    rbus.mem_dout = mem_dout; 
    mem_addr_lower = rbus.mem_addr[11:0]; 
    mem_addr_upper = rbus.mem_addr[31:12]; 
//    mem_en = (mem_addr_upper < 20'haaaaa) & (mem_wea) ? rbus.mem_en : 4'b0000; 
    mem_en = ((kernel_region | prog_region) & mem_wea) ? rbus.mem_en : 4'b0000;
    imem_en = rbus.imem_en; 
    imem_addr = rbus.imem_addr; 
    imem_din = rbus.imem_din; 
    rbus.imem_dout = imem_dout;
    rbus.mem_hold = mem_hold;
end

always_comb begin : mem_region
    mmio_region = (mem_addr_upper == 20'haaaaa); 
    kernel_region = (rbus.mem_addr[31:16] == 16'h0000);
    prog_region = (rbus.mem_addr[31:16] == 16'h0001); 
    uart_region = (mem_addr_upper == 20'haaaaa) & (mem_addr_lower >= 12'h400) & 
        (mem_addr_lower < 12'h408); 
end

//always_comb begin
//    mbus.disp_wea = disp_wea;
//    mbus.disp_dat = disp_dat; 
    
//end

always_comb begin
//    if (mmio_region) begin
//        if ((mem_addr_lower == 12'h400) & (mem_wea == 1)) begin
            
//        end
//    end
//    mbus.tx_wen = (mmio_region & (mem_addr_lower == 12'h400)) ? mem_wea : 1'b0;
//    mbus.uart_din = (mmio_region & (mem_addr_lower == 12'h400)) ? mem_din[7:0] : 8'h00;
//    mbus.rx_ren = (mmio_region & (mem_addr_lower == 12'h400)) ? mem_rea : 1'b0;
    mbus.tx_wen = (uart_region) ? mem_wea : 1'b0; 
    mbus.rx_ren = uart_region ? mem_rea : 1'b0; 
//    mbus.uart_din = uart_region ? mem_din[7:0] : 8'h00; 
    mbus.uart_din = mem_din[7:0];
    mbus.uart_addr = mem_addr_lower[2:0];
//    mbus.uart_addr = uart_region ? mem_addr_lower[2:0] : 8'h00; 
    mbus.disp_wea = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_wea : 1'b0;
    mbus.disp_dat = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_din : 32'h0;
//    if (mmio_region) begin
//        if (mem_addr_lower == 12'h400) begin
//            mem_dout = mbus.uart_dout;
//        end else if (mem_addr_lower == 12'h404) begin
//            mem_dout = {7'b0000000, mbus.rx_data_present};
//        end else begin
//            mem_dout = blkmem_dout;
//        end
//    end else begin
//        mem_dout = blkmem_dout;
//    end
//    uart_dout = (mmio_region & (mem_addr_lower == 12'h404)) ? {6'b000000, mbus.tx_full, mbus.rx_data_present} : mbus.uart_dout;
//    mem_dout = uart_last_cond ? uart_dout : blkmem_dout;
    mem_dout = uart_last_cond ? uart_last_out : blkmem_dout;
end

always_ff @(posedge clk) begin
    if (rst) begin
//        mem_hold <= 0;
    end else if (~mem_hold) begin
//        if ((mem_wea == 1) && (mem_addr_upper == 20'haaaaa)) begin 
////            if ((mem_addr_lower == 12'h004)) begin
////                disp_wea = mem_din[0]; 
////            end
////            else 
//            if ((mem_addr_lower == 12'h008)) begin
//                disp_dat = mem_din;
//            end
//            else if ((mem_addr_lower == 12'h00c)) begin
//                mbus.led = mem_din[15:0];
//            end
//        end
//        if (mmio_region && ((mem_addr_lower == 12'h400) || (mem_addr_lower == 12'h404))) begin
        if (uart_region && (mem_wea | mem_rea)) begin
            uart_last_cond <= 1;
            uart_last_addr <= mem_addr_lower;
            uart_last_out <= mbus.uart_dout;
//            case (mem_addr_lower[1:0])
//                2'b00: uart_last_out <= {24'h0, mbus.uart_dout };
//                2'b01: uart_last_out <= {16'h0, mbus.uart_dout, 8'h0 }; 
//                2'b10: uart_last_out <= {8'h0, mbus.uart_dout, 16'h0 };
//                2'b11: uart_last_out <= {mbus.uart_dout, 24'h0 };
//            endcase            
//            if (mem_addr_lower == 12'h400) uart_dout <= mbus.uart_dout; 
//            else uart_dout <= {6'b000000, mbus.tx_full, mbus.rx_data_present};
        end else begin
            uart_last_cond <= 0; 
        end
        mem_en_last <= mem_en;
        
//        if (mem_hold == 1) begin
//            mem_hold <= 0;
//        end
//        else if (((mem_rea == 1) || (mem_wea == 1)) && (~mmio_region)) begin
//            mem_hold <= 1;
//        end
    end
end

always_comb begin
//    case (mem_en_last) 
//        4'b0001: begin
//            blkmem_dout = {24'h0, doutb[7:0]}; 
//        end
//        4'b0010: begin 
//            blkmem_dout = {24'h0, doutb[15:8]};
//        end
//        4'b0100: begin
//            blkmem_dout = {24'h0, doutb[23:16]};
//        end
//        4'b1000: begin
//            blkmem_dout = {24'h0, doutb[31:24]};
//        end
//        4'b0011: begin 
//            blkmem_dout = {16'h0, doutb[15:0]};
//        end
//        4'b0110: begin 
//            blkmem_dout = {16'h0, doutb[23:8]};
//        end
//        4'b1100: begin
//            blkmem_dout = {16'h0, doutb[31:16]}; 
//        end
//        default: begin
//            blkmem_dout = doutb;
//        end 
//    endcase
	blkmem_dout = doutb;
end

always_comb begin
	blkmem_din = mem_din;
//    case (mem_en) 
//        4'b0001: begin
//            blkmem_din = {24'h0, mem_din[7:0]};
//        end
//        4'b0010: begin 
//            blkmem_din = {16'h0, mem_din[7:0], 8'h0};  
//        end
//        4'b0100: begin
//            blkmem_din = {8'h0, mem_din[7:0], 16'h0};
//        end
//        4'b1000: begin
//            blkmem_din = {mem_din[7:0], 24'h0};
//        end
//        4'b0011: begin 
//            blkmem_din = {16'h0, mem_din[15:0]}; 
//        end
//        4'b0110: begin 
//            blkmem_din = {8'h0, mem_din[15:0], 8'h0};
//        end
//        4'b1100: begin
//            blkmem_din = {mem_din[15:0], 16'h0};
//        end
//        default: begin
//            blkmem_din = mem_din;
//        end 
//    endcase
end


//blk_mem_gen_1 sharedmem(.clka(clk), .ena(imem_en), .wea(4'b0000), .addra(imem_addr), .dina(32'hz), 
//    .douta(imem_dout), .clkb(clk), .enb((mem_wea | mem_rea) & (~mmio_region)), 
//    .web(mem_en), .addrb(rbus.mem_addr[12:2]), .dinb(blkmem_din), .doutb(doutb));
//    .web(mem_en), .addrb(rbus.mem_addr[12:2]), .dinb(blkmem_din), .doutb(doutb));

//  blk_mem_gen_0 sharedmem(.clka(clk), .ena(imem_en), .wea(4'b0000), .addra(imem_addr), .dina(32'hz), 
//    .douta(imem_dout), .clkb(clk), .enb((mem_wea | mem_rea) & (kernel_region | prog_region)), 
//    .web(mem_en), .addrb(rbus.mem_addr), .dinb(blkmem_din), .doutb(doutb));  




    
    cache cache_inst(.clk(clk), .rst(rst), .ren(imem_en), .wen(0), .din(0), .addr(imem_addr),
    	.storecntrl(cache_storecntrl), .loadcntrl(cache_loadcntrl), .cache_rdy(cache_rdy), 
    	.dout(imem_dout), .mem_dout(cache_mem_dout), .mem_ren(cache_mem_ren), .mem_wen(cache_mem_wen),
    	.mem_din(cache_mem_din), .mem_addr(cache_mem_addr), .*);
    
//    Mem_Interface sharedmem(.clk(clk), .imem_en(imem_en), .mem_en((mem_wea | mem_rea) & (~mmio_region)), 
//    	.storecntrl_a(3'b000), .storecntrl_b(rbus.storecntrl), .imem_addr(imem_addr), .imem_din(32'hz), .mem_addr(rbus.mem_addr), 
//    	.mem_din(blkmem_din), .imem_wen(4'b0000), .mem_wen(mem_en), .imem_dout(imem_dout), .mem_dout(doutb) 
//    	);
	Mem_Interface sharedmem(.clk(clk), .imem_en(cache_mem_ren), .mem_en((mem_wea | mem_rea) & (~mmio_region) & ~mem_hold), 
    	.storecntrl_a(3'b000), .storecntrl_b(rbus.storecntrl), .imem_addr(cache_mem_addr), .imem_din(32'hz), .mem_addr(rbus.mem_addr), 
    	.mem_din(blkmem_din), .imem_wen(4'b0000), .mem_wen(mem_en), .imem_dout(cache_mem_dout), .mem_dout(doutb) 
    	);
    	
    	
    	
    	
    	
    sram_behav cell0(.clk(clk), .rst(rst), .din(cell_0_din), .sense_en(cell_0_sense_en), 
    	.wen(cell_0_wen), .addr(cell_0_addr), .dout(cell_0_dout));
    	
    sram_behav cell1(.clk(clk), .rst(rst), .din(cell_1_din), .sense_en(cell_1_sense_en), 
    	.wen(cell_1_wen), .addr(cell_1_addr), .dout(cell_1_dout));
    	
    sram_behav cell2(.clk(clk), .rst(rst), .din(cell_2_din), .sense_en(cell_2_sense_en), 
    	.wen(cell_2_wen), .addr(cell_2_addr), .dout(cell_2_dout));
    	
    sram_behav cell3(.clk(clk), .rst(rst), .din(cell_3_din), .sense_en(cell_3_sense_en), 
    	.wen(cell_3_wen), .addr(cell_3_addr), .dout(cell_3_dout));

//Memory_byteaddress mem0(.clk(clk), .rst(rst), .wea(mem_wea), .en(mem_en), .addr(mem_addr_lower), 
//    .din(mem_din), .dout(mem_dout));
    
//blk_mem_gen_0 imem0(.clka(clk), .ena(imem_en), .wea(4'b0000), .addra(imem_addr), .dina(32'hz), 
//    .douta(imem_dout));
    
    
//IRAM_Controller imem0(.clk(clk), .rst(rst), .ena(imem_en), .prog_ena(rbus.imem_prog_ena), 
//    .wea_in(4'b0000), .dina(imem_din), .addr_in(imem_addr), .state_load_prog(imem_state),
//    .douta(imem_dout));
    

endmodule : Memory_Controller