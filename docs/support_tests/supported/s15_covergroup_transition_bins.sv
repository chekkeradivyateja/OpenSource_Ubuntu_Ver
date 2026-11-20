// EXPECT: output cov=100.0
module t; logic clk = 0; always #5 clk = ~clk; logic [1:0] v;
covergroup cg @(posedge clk); cp: coverpoint v { bins t01 = (0 => 1); bins seq = (0 => 1 => 2); } endgroup
cg c = new; initial begin v = 0; @(negedge clk) v = 1; @(negedge clk) v = 2; @(negedge clk); $display("cov=%0.1f", c.get_coverage()); $finish; end endmodule
