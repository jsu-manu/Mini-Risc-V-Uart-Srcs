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
logic spi_region; 
logic spi_last_cond;
logic [7:0] spi_last;
logic [31:0] blkmem_dout, doutb, blkmem_din, blkmem_addr; 
logic [7:0] uart_dout;
logic uart_last_cond;
logic [11:0] uart_last_addr; 
logic [31:0] uart_last_out;

logic CRAS_region;
logic RAS_wr, RAS_rd, RAS_mem_rdy;
logic [31:0] RAS_din, RAS_dout, RAS_addr;

logic blkmem_wr, blkmem_rd;
logic [2:0] blkmem_strctrl;
logic [3:0] blkmem_en;

logic cnt_region, cnt_last;
logic [31:0] cnt_last_out;

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
assign mem_hold = 0;

always_comb begin
    clk = rbus.clk;
    rst = rbus.Rst; 
    mem_wea = rbus.mem_wea;
    mem_rea = rbus.mem_rea;
    mem_din = rbus.mem_din; 
    rbus.mem_dout = mem_dout; 
    mem_addr_lower = rbus.mem_addr[11:0]; 
    mem_addr_upper = rbus.mem_addr[31:12]; 
    mem_en = ((kernel_region | prog_region) & mem_wea) ? rbus.mem_en : 4'b0000;
    imem_en = rbus.imem_en; 
    imem_addr = rbus.imem_addr; 
    imem_din = rbus.imem_din; 
    rbus.imem_dout = imem_dout;
    rbus.mem_hold = mem_hold;
    RAS_din = mbus.RAS_mem_din; 
    RAS_addr = mbus.RAS_mem_addr;
    RAS_rd = mbus.RAS_mem_rd;
    RAS_wr = mbus.RAS_mem_wr; 
    mbus.RAS_mem_dout = RAS_dout;
    mbus.RAS_mem_rdy = RAS_mem_rdy; 
end

always_comb begin : mem_region
    mmio_region = (mem_addr_upper == 20'haaaaa); 
    kernel_region = (rbus.mem_addr[31:30] == 2'b00);
    prog_region = (rbus.mem_addr[31:16] == 16'h0001); 
    uart_region = (mem_addr_upper == 20'haaaaa) & (mem_addr_lower >= 12'h400) & 
        (mem_addr_lower < 12'h408); 
    spi_region = (mem_addr_upper == 20'haaaaa) & (mem_addr_lower >= 12'h500) & 
    	(mem_addr_lower < 12'h502);
    CRAS_region = (mem_addr_upper == 20'haaaaa) & (mem_addr_lower >= 12'h600) & 
    	(mem_addr_lower <= 12'h61c);
    cnt_region = (mem_addr_upper == 20'haaaaa) & (mem_addr_lower >= 12'h700) & 
    	(mem_addr_lower < 12'h708); 
end

always_comb begin
	RAS_mem_rdy = ~(mem_wea | mem_rea);
	RAS_dout = blkmem_dout;
end

always_comb begin
    mbus.tx_wen = (uart_region) ? mem_wea : 1'b0; 
    mbus.rx_ren = uart_region ? mem_rea : 1'b0; 
    mbus.uart_din = mem_din[7:0];
    mbus.uart_addr = mem_addr_lower[2:0];
    mbus.disp_wea = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_wea : 1'b0;
    mbus.disp_dat = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_din : 32'h0;
    
    mbus.spi_rd = spi_region ? mem_rea : 1'b0; 
    mbus.spi_wr = spi_region ? mem_wea : 1'b0; 
    mbus.spi_din = spi_region ? mem_din[7:0] : 8'h00;
    mbus.spi_ignore_response = spi_region ? mem_din[8] : 1'b0;  
    
    mbus.RAS_config_din = CRAS_region ? mem_din : 32'h0; 
    mbus.RAS_config_addr = CRAS_region ? mem_addr_lower[4:2]: 3'b000;
    mbus.RAS_config_wr = CRAS_region ? mem_wea : 0;
    mbus.cnt_zero = (cnt_region & (mem_addr_lower == 12'h704)) ? mem_wea : 0;
    mem_dout = uart_last_cond ? uart_last_out : (spi_last_cond ? {24'h0, spi_last} : (cnt_last ? cnt_last_out : blkmem_dout));
end

always_ff @(posedge clk) begin
    if (rst) begin
//        mem_hold <= 0;
    end else if (~mem_hold) begin
        if (uart_region && (mem_wea | mem_rea)) begin
            uart_last_cond <= 1;
            uart_last_addr <= mem_addr_lower;
            uart_last_out <= mbus.uart_dout;
        end else begin
            uart_last_cond <= 0; 
        end
        
        if (spi_region && (mem_wea | mem_rea)) begin
        	spi_last_cond <= 1; 
        	if (mem_addr_lower == 12'h500) 
        		spi_last = mbus.spi_dout; 
        	else
        		spi_last = {5'b0, mbus.spi_buffer_full, mbus.spi_buffer_empty, mbus.spi_data_avail};
        end else spi_last_cond <= 0;
        
        if (cnt_region & (mem_rea)) begin
        	cnt_last <= 1; 
        	if (mem_addr_lower == 12'h700)
        		cnt_last_out <= mbus.cnt_dout;
        	else
        		cnt_last_out <= {31'h0, mbus.cnt_ovflw};
        end else cnt_last <= 0; 
        
        mem_en_last <= mem_en;
    end
end

assign blkmem_dout = doutb;

always_comb begin
	blkmem_din = RAS_mem_rdy ? RAS_din : mem_din;
	blkmem_addr = RAS_mem_rdy ? RAS_addr : rbus.mem_addr;
	blkmem_en = RAS_mem_rdy ? (RAS_wr ? 4'b1111 : 4'b0000) : mem_en;
	blkmem_wr = RAS_mem_rdy ? RAS_wr : mem_wea;
	blkmem_rd = RAS_mem_rdy ? RAS_rd : mem_rea;
	blkmem_strctrl = RAS_mem_rdy ? (RAS_wr ? 3'b100 : 3'b000) : rbus.storecntrl;
end



// Scanchain
logic [31:0] scan_in_word;
logic [31:0] scan_in_addr; // 0-16383, or 14 bits minimum
bit   [4:0]  scan_in_bit_of_word; // 0-31
logic scan_in_word_ready;
logic [31:0] imem_addr_mux;
logic [3:0] scan_in_wen;
logic scan_finished;
logic imem_en_mux;

assign imem_addr_mux = (scan_in_word_ready & rbus.scan_en) ? scan_in_addr : (imem_addr | 32'h00000000);
assign scan_in_wen = (scan_in_word_ready & rbus.scan_en) ? 4'b1111 : 4'b0000;
assign imem_en_mux = (scan_in_word_ready & rbus.scan_en) ? 1 : imem_en;

always @(posedge rbus.scan_clk or negedge rbus.scan_rst_n) begin
    if (!rbus.scan_rst_n) begin
        // Reset everything, start scanning from beginning
        scan_in_word = 0;
        scan_in_addr = 0;
        scan_in_bit_of_word = 0;
        scan_in_word_ready = 0;
        scan_finished = 0;
        $display($time, " [SC_IMEM] Reset instr. mem. scan chain");
    end else if (rbus.scan_clk & rbus.scan_en & !scan_finished) begin
        // Scan in current bit to word register
        scan_in_word[scan_in_bit_of_word] = rbus.scan_in;
        // Set next bit to read into and check if word finished
        if (scan_in_bit_of_word == 31) begin
            scan_in_bit_of_word = 0;
            scan_in_word_ready = 1;
            $display($time, " [SC_IMEM] Scanned %h into addr %h", scan_in_word, scan_in_addr);
            // Check if scanned into entire instruction memory
            //if (scan_in_addr == 32'd16383) begin
            if (scan_in_addr == 32'd8) begin
                scan_finished = 1;
                $display($time, " [SC_IMEM] Finished scanning in instructions");
            end else begin
                scan_in_addr = scan_in_addr + 1;
                // TODO +1 or +4?
            end
        end else begin
            scan_in_word_ready = 0;
            scan_in_bit_of_word = scan_in_bit_of_word + 1;
        end
    end
end



Mem_Interface sharedmem(.clk(clk), .imem_en(imem_en_mux), .mem_en((blkmem_wr | blkmem_rd) & (~mmio_region)), 
    .storecntrl_a(3'b000), .storecntrl_b(blkmem_strctrl), .imem_addr(imem_addr_mux), .imem_din(scan_in_word), .mem_addr(blkmem_addr - 'h2000), 
    .mem_din(blkmem_din), .imem_wen(scan_in_wen), .mem_wen(blkmem_en), .imem_dout(imem_dout), .mem_dout(doutb) 
    );

endmodule : Memory_Controller