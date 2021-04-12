module Fetch_Compressed (
	input logic clk,    // Clock
	input logic rst, 
	input logic [31:0] ins, 
	input logic [31:0] branoff,
	output logic [31:0] imem_addr, ins_out,
	output logic imem_en, comp_sig
);

logic [31:0] ins_last;
logic [31:0] pres_addr;
logic comp, next_comp, lower;
logic [31:0] pc_incr, next_addr; 

assign comp_sig = comp;

assign lower = (pres_addr[1:0] == 0) ; 
// assign comp = (ins[1:0] != 2'b11) & (ins != 32'h0);
assign comp = (lower & (ins[1:0] != 2'b11) & (ins[15:0] != 0)) | (~lower & (ins[17:16] != 2'b11) & (ins[31:16] != 0)); 
assign next_comp = (lower & comp & (ins[17:16] != 2'b11));
assign imem_en = (~next_comp) & (~rst); 

always_comb begin
	if (lower) begin
		if (comp) ins_out = {16'h0, ins[15:0]};
		else ins_out = ins; 
	end else begin
		if (comp) ins_out = {16'h0, ins[31:16]};
		else ins_out = {ins[15:0], ins_last[31:16]};
	end
end

always_ff @(posedge clk) begin
	if (rst) begin
		imem_addr <= 0;
		pres_addr <= 0; 
		ins_last <= 0;
	end else begin
		if (comp) pres_addr <= pres_addr + 2;
		else pres_addr <= imem_addr; 

		if (imem_en) begin

			imem_addr <= imem_addr + 4; 
			//Need to do this because of the weird way the FPGA blockram works. Comment it out and uncomment the above line 
			//for not weird byte-addressable memory
			// if (imem_addr[1:0] == 0) imem_addr <= imem_addr + 4; 
			// else imem_addr <= imem_addr + 2; 
			
			ins_last <= ins;
		end

	end
end

endmodule