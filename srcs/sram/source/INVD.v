//Verilog HDL for "sram_logic", "INVC" "functional"


module INVD ( Y, A );

  input A;
  output Y;

 assign Y = ~A;
endmodule
