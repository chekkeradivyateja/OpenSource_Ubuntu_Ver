// EXPECT: output cb.q=9
module t; logic clk = 0; always #5 clk = ~clk; logic [3:0] d = 0, q;
clocking cb @(posedge clk); default input #1 output #2; output d; input q; endclocking
always @(posedge clk) q <= d;
initial begin @(cb); cb.d <= 4'd9; repeat (3) @(cb); $display("cb.q=%0d", cb.q); $finish; end endmodule
