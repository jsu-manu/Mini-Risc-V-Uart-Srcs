module counter (
	mmio_bus mbus
	);

	logic clk, rst; 
	logic zero, ovflw;
	logic [31:0] cnt; 

	always_comb begin
		clk = mbus.clk;
		rst = mbus.Rst; 
		zero = mbus.cnt_zero;
		mbus.cnt_ovflw = ovflw; 
		mbus.cnt_dout = cnt; 
	end

	always_ff @(posedge clk) begin
		if (zero | rst) begin
			cnt <= 0;
			ovflw <= 0; 
		end else begin
			if (cnt == 32'hffffffff) ovflw <= 1;
			cnt <= cnt + 1; 
		end
	end

endmodule : counter