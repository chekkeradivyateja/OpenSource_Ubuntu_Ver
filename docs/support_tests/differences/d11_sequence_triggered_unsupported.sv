// EXPECT: error Can't find definition of variable/method: 'triggered'
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
  sequence s_ab; @(posedge clk) a ##1 b; endsequence
  always @(posedge clk) if (s_ab.triggered) $display("a then b");
  initial #50 $finish;
endmodule
