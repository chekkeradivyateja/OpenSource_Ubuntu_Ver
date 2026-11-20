// EXPECT: output Illegal bin 'il' hit
module t; logic clk = 0; always #5 clk = ~clk; logic [3:0] v = 0;
covergroup cg @(posedge clk); cp: coverpoint v { bins lo = {[0:3]}; illegal_bins il = {14}; } endgroup
cg c = new; initial begin @(negedge clk) v = 14; repeat (2) @(negedge clk); $display("end cov=%0.1f", c.get_coverage()); $finish; end endmodule
