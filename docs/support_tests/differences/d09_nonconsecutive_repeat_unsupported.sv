// EXPECT: error Usage of cycle delays requires default clocking
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
  a1: assert property (@(posedge clk) a |=> b[=2] ##1 c);
  initial #50 $finish;
endmodule
