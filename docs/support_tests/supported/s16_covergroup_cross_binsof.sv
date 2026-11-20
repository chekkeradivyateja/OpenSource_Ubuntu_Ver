// EXPECT: output cov=
module t; logic clk = 0; always #5 clk = ~clk; logic [1:0] a, b;
covergroup cg @(posedge clk); ca: coverpoint a; cb: coverpoint b; x: cross ca, cb { ignore_bins i = binsof(ca) intersect {3}; } endgroup
cg c = new; initial begin a = 0; b = 0; @(negedge clk); $display("cov=%0.1f", c.get_coverage()); $finish; end endmodule
