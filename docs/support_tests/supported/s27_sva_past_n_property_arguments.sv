// EXPECT: output FIRED past2
// EXPECT: output FIRED args
module t; logic clk = 0; always #5 clk = ~clk; logic [3:0] d = 0; logic a = 0, b = 0;
property p_follow(x, y); @(posedge clk) x |=> y; endproperty
a_past2: assert property (@(posedge clk) d == 3 |-> $past(d, 2) == 9) else $error("FIRED past2");
a_args:  assert property (p_follow(a, b)) else $error("FIRED args");
initial begin @(negedge clk) d = 1; @(negedge clk) begin d = 2; a = 1; end @(negedge clk) d = 3; repeat (2) @(negedge clk); $finish; end endmodule
