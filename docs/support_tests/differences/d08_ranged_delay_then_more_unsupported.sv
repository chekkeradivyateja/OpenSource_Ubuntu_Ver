// EXPECT: error Unsupported: Bounded ranged cycle delay in a sequence prefix
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
  a1: assert property (@(posedge clk) a |-> ##[1:5] b ##1 c);
  initial #50 $finish;
endmodule
