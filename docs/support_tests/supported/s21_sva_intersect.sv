// EXPECT: output FIRED intersect
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
a1: assert property (@(posedge clk) a |-> ((##1 b) intersect (##1 b))) else $error("FIRED intersect");
initial begin @(negedge clk) a = 1; @(negedge clk) a = 0; repeat (3) @(negedge clk); $finish; end endmodule
