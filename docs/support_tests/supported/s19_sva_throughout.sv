// EXPECT: output FIRED throughout
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
a1: assert property (@(posedge clk) a |-> (b throughout (##2 c))) else $error("FIRED throughout");
initial begin @(negedge clk) begin a = 1; b = 1; end @(negedge clk) begin a = 0; b = 0; end @(negedge clk) c = 1; repeat (3) @(negedge clk); $finish; end endmodule
