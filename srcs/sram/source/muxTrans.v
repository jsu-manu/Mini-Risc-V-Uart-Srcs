//Verilog HDL for "sram_logic", "muxTrans" "functional"


module muxTrans ( A, Y, S );

  inout A;
  input S;
  inout Y;
  wire A_int;// = 1'b0;
  wire Y_int;// = 1'b0;
  wire dir;

/*  always @ (S) begin
   if (S) begin
	A_int = Y;
	Y_int = A;
   end else begin
	A_int = A;
	Y_int = Y;
   end
  end*/

  assign A_int = S ? Y : A;
  assign Y_int = S ? A : Y;
/*  always @ (*) begin
	if (dir) begin
	  A_int = S & Y;
	end else if (A === 1'b1 || A === 1'b0) begin
	  Y_int = S & A;
    end
  end
*/
  assign dir = (sram_compiled_array.write_en && S);
  assign not_dir = (!sram_compiled_array.write_en && S);
  assign (supply1, supply0) A = dir ? A_int : 1'bz;
  assign (supply1, supply0) Y = not_dir ? Y_int : 1'bz;

endmodule
