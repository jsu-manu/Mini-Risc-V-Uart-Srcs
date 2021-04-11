module Divider
(
  input         clk,
  input         rst,
  input  [2:0]  divsel,
  input  [31:0] a,
  input  [31:0] b,
  output        ready,
  output [31:0] res
);

  reg [31:0] numerator;
  reg [31:0] divisor;
  reg [31:0] quotient;
  reg [31:0] remainder;
  reg [31:0] op_a;
  reg [31:0] op_b;
  reg [5:0]  index;
  reg        div_inst;
  reg        invert_res;
  reg        count;
  reg        rdy;
  reg        busy;
  reg [31:0] div_result;
  reg [31:0] rem_result;

  wire div  = (divsel == 3'b001); // div
  wire divu = (divsel == 3'b010); // divu
  wire rem  = (divsel == 3'b011); // rem
  wire remu = (divsel == 3'b100); // remu

  wire divrem_op = div || divu || rem || remu;
  wire div_op    = div || divu;
  wire neg_q     = a[31] != b[31];
  wire neg_r     = a[31];

  always_comb
  begin
    case (divsel)
      3'b001:
      begin
        op_a <= a[31] ? -a : a;
        op_b <= b[31] ? -b : b;
      end
      3'b011:
      begin
        op_a <= a[31] ? -a : a;
        op_b <= b[31] ? -b : b;
      end
      default:
      begin
        op_a <= a;
        op_b <= b;
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
    else if (rst || !divrem_op) // Reset
    begin
      numerator  <= 32'b0;
      divisor    <= 32'b0;
      quotient   <= 32'b0;
      remainder  <= 32'b0;
      index      <= 5'b0;
      div_inst   <= 1'b0;
      invert_res <= 1'b0;
      count      <= 1'b0;
      rdy        <= 1'b0;
      busy       <= 1'b0;
    end
    else if (busy) // Stage 2: Calculate multiplication.
    begin
      remainder    = remainder << 1'b1;
      remainder[0] = numerator[index];

      if (divisor <= remainder)
      begin
        remainder       = remainder - divisor;
        quotient[index] = 1'b1;
      end

      count = ~(|index);
      rdy   = ~(|index);
      busy  = |index;
      index = ~(|index) ? 5'd0 : index - 5'd1;
    end
    else // Stage 1: Set operands and result formatting conditions.
    begin
      numerator  <= op_a;
      divisor    <= op_b;
      quotient   <= 32'b0;
      remainder  <= 32'b0;
      div_inst   <= div_op;
      invert_res <= (div && neg_q && |b) || (rem && neg_r);
      index      <= 5'd31;
      busy       <= 1'b1;
    end
  end

  assign div_result = invert_res ? -quotient : quotient;
  assign rem_result = invert_res ? -remainder : remainder;

  assign ready = rdy;
  assign res   = div_inst ? div_result : rem_result;
endmodule