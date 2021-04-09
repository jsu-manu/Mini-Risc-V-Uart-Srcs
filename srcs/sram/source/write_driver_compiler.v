//Verilog HDL for "sram_logic", "write_driver_compiler" "functional"


module write_driver_compiler ( BL, BLN, clk, data, write_en );

  input data;
  inout BLN;
  input write_en;
  inout BL;
  input clk;


  wire data_bar = !data;

  wire S_net09 = clk & write_en & data_bar;
  wire (highz1,supply0) BL = S_net09 ? 1'b0 : 1'b1;


  wire S_net015 = clk & write_en & data;
  wire (highz1,supply0) BLN = S_net015 ? 1'b0 : 1'b1;


endmodule
