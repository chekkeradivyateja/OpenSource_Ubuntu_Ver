// EXPECT: nooutput [5] %Error
// EXPECT: output [35] %Error
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0;
a1: assert property (@(posedge clk) a) else $error("FIRED a1");
initial begin $assertoff(0, t.a1); repeat (3) @(negedge clk); $asserton(0, t.a1); @(negedge clk); @(negedge clk); $finish; end endmodule
