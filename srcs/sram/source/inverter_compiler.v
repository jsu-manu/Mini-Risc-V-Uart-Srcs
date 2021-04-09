//Verilog HDL for "sram_logic", "inverter_1" "functional"


module inverter_compiler ( A0_bar, A0 );

  input A0;
  output A0_bar;

  assign A0_bar = !A0;

endmodule
