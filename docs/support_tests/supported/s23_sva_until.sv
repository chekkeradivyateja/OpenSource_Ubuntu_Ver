// EXPECT: output FIRED until
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
a1: assert property (@(posedge clk) a |-> (c until b)) else $error("FIRED until");
initial begin @(negedge clk) begin a = 1; c = 1; end @(negedge clk) begin a = 0; c = 0; end repeat (2) @(negedge clk); b = 1; repeat (2) @(negedge clk); $finish; end endmodule
