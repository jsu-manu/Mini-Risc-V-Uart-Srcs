//Verilog HDL for "sram_logic", "precharge_compiler" "functional"


module precharge_compiler ( B, B_bar, clk );

  output B_bar;
  input clk;
  output B;

  wire (weak1,weak0) B = 1'b1;	// : 1'b0;
  wire (weak1,weak0) B_bar = 1'b1;	// : 1'b0;

endmodule
