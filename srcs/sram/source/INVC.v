//Verilog HDL for "sram_logic", "INVC" "functional"


module INVC ( Y, A );

  input A;
  output Y;

 assign Y = ~A;
endmodule
