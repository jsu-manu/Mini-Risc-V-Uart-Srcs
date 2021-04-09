//Verilog HDL for "sram_logic", "NANDC2x1" "functional"


module NANDC2x1 ( Y, A, B );

  input A;
  output Y;
  input B;


  assign Y = !(A & B);

endmodule
