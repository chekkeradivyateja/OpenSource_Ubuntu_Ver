// EXPECT: output done
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0;
sequence s1; a ##1 !a; endsequence c1: cover property (@(posedge clk) s1); as1: assume property (@(posedge clk) !$isunknown(a));
initial begin @(negedge clk) a = 1; @(negedge clk) a = 0; repeat (2) @(negedge clk); $display("done"); $finish; end endmodule
