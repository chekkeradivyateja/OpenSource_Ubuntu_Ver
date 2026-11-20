// EXPECT: output cov=100.0
module t; logic clk = 0; always #5 clk = ~clk; logic [3:0] v;
covergroup cg @(posedge clk); cp: coverpoint v { bins lo = {[0:3]}; ignore_bins ig = {15}; illegal_bins il = {14}; wildcard bins w = {4'b1??1}; } endgroup
cg c = new; initial begin v = 0; repeat (3) @(negedge clk); v = 9; @(negedge clk); $display("cov=%0.1f", c.get_coverage()); $finish; end endmodule
