// EXPECT: output FIRED first_match
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
a1: assert property (@(posedge clk) a |-> first_match(##[1:3] b)) else $error("FIRED first_match");
initial begin @(negedge clk) a = 1; @(negedge clk) a = 0; repeat (5) @(negedge clk); $finish; end endmodule
