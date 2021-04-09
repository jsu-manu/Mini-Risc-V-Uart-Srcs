//Verilog HDL for "sram_cells", "sram_cell_6t" "functional"


module sram_cell_6t_3 (BL, BLN, WL );

  input WL;
  inout BL, BLN;

  reg Q = 1'b0;
  reg Qbar = 1'b0;
  reg BL_int, BLN_int;

  reg drive = 1'b0;

  always @ (*) begin
   if (WL) begin
	if ((BL === 1'b0) && sram_compiled_array.write_en) begin
		Q <= 1'b0;
		Qbar <= 1'b1;
		drive <= 1'b0;
	end 	else if((BLN === 1'b0) && sram_compiled_array.write_en) begin
		Q <= 1'b1;
		Qbar <= 1'b0;
		drive <= 1'b0;
	end else if (!sram_compiled_array.sense_en) begin
		BL_int <= Q;
		BLN_int <= Qbar;
		drive <= 1'b1;
	end// else drive <= 1'b0;
   end
  end

  always @ (negedge WL) drive <= 1'b0;
/*  always @ (WL) begin
   if (WL) begin
	if (BL === 1'b1 && BLN === 1'b1) begin
		BL_int <= Q;
		BLN_int <= Qbar;
		drive = 1'b1;
	end else if ((BL === 1'b1 && BLN === 1'b0) || (BL === 1'b0 && BLN === 1'b1)) begin
		Q <= BL;
		Qbar <= BLN;
		drive = 1'b0;
	end
   end
  end
*/

  assign (strong1,strong0) BL = drive ? BL_int : 1'bz;
  assign (strong1,strong0) BLN = drive ?  BLN_int : 1'bz;

endmodule
