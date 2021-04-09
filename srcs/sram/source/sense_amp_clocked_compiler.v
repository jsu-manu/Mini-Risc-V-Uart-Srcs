//Verilog HDL for "sram_logic", "sense_amp_clocked_compiler" "functional"


module sense_amp_clocked_compiler ( sense, sense_b, bit, bit_bar, sense_en );


  input sense_en;
  output reg sense_b;
  output reg sense;
  input bit;
  input bit_bar;

  always @ (sense_en or bit) begin
    if (!sense_en) begin
		sense <= bit;
		sense_b <= bit_bar;
	end
  end

endmodule
