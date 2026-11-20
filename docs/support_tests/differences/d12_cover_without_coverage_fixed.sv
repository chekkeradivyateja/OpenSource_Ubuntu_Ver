// BUILD: --coverage
// EXPECT: output COVER hit at 25
// Fix: build with --coverage (the Makefile templates always do).
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
  c0: cover property (@(posedge clk) a ##1 b) $display("COVER hit at %0t", $time);
  initial begin
    @(negedge clk) a = 1; @(negedge clk) begin a = 0; b = 1; end
    @(negedge clk) b = 0; repeat (2) @(negedge clk); $finish;
  end
endmodule
