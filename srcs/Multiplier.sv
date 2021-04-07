module Multiplier
(
  input         clk,
  input         rst,
  input  [2:0]  mulsel,
  input  [31:0] a,
  input  [31:0] b,
  output        ready,
  output [31:0] res
);

  reg [32:0] factor_a;
  reg [32:0] factor_b;
  reg [32:0] op_a;
  reg [32:0] op_b;
  reg        high_bits;
  reg        count;
  reg        rdy;
  reg        busy;
  reg [64:0] full_res;

  wire mul    = (mulsel == 3'b001); // mul
  wire mulh   = (mulsel == 3'b010); // mulh
  wire mulhsu = (mulsel == 3'b011); // mulhsu
  wire mulhu  = (mulsel == 3'b100); // mulhu

  wire mul_op = mul || mulh || mulhsu || mulhu; 

  always_comb // Set operands' sign bits based on instruction type.
  begin
    case (mulsel)
      3'b011:
      begin
        op_a = {a[31], a[31:0]};
        op_b = {1'b0, b[31:0]};
      end
      3'b010:
      begin
        op_a = {a[31], a[31:0]};
        op_b = {b[31], b[31:0]};
      end
      default:
      begin
        op_a = {1'b0, a[31:0]};
        op_b = {1'b0, b[31:0]};
      end
    endcase
  end

  always @(posedge clk or posedge rst)
  begin
    if (rdy) // Stage 3: Wait 2 clock cycles.
    begin
      if (count)
        count <= 0;
      else
        rdy <= 0;
    end
    else if (rst || !mul_op) // Reset
    begin
      factor_a  <= 32'b0;
      factor_b  <= 32'b0;
      high_bits <= 1'b0;
      count     <= 1'b0;
      rdy       <= 1'b0;
      busy      <= 1'b0;
      full_res  <= 32'h0;
    end
    else if (busy) // Stage 2: Calculate multiplication.
    begin
      full_res = {{32{factor_a[32]}}, factor_a} * {{32{factor_b[32]}}, factor_b};
      count    = 1'b1;
      rdy      = 1'b1;
      busy     = 1'b0;
    end
    else // Stage 1: Set operands and result formatting conditions.
    begin
      factor_a  <= op_a;
      factor_b  <= op_b;
      high_bits <= ~mul;
      busy      <= 1'b1;
    end
  end

  assign ready = rdy;
  assign res   = high_bits ? full_res[63:32] : full_res[31:0];
endmodule