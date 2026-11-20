// EXPECT: output FIRED rep[*2]
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
a1: assert property (@(posedge clk) a |=> b[*2]) else $error("FIRED rep[*2]");
initial begin @(negedge clk) a = 1; @(negedge clk) begin a = 0; b = 1; end @(negedge clk) b = 0; repeat (3) @(negedge clk); $finish; end endmodule
