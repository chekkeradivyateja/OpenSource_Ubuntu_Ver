// EXPECT: output FIRED within
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
a1: assert property (@(posedge clk) a |-> ((##1 b) within (##3 c))) else $error("FIRED within");
initial begin @(negedge clk) a = 1; @(negedge clk) a = 0; repeat (5) @(negedge clk); $finish; end endmodule
