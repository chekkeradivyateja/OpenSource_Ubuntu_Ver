// BUILD: --coverage
// EXPECT: output a then b seen at 25
// Fix: a cover property with an action block (needs --coverage, see d12).
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
  c_ab: cover property (@(posedge clk) a ##1 b) $display("a then b seen at %0t", $time);
  initial begin
    @(negedge clk) a = 1; @(negedge clk) begin a = 0; b = 1; end
    @(negedge clk) b = 0; repeat (2) @(negedge clk); $finish;
  end
endmodule
