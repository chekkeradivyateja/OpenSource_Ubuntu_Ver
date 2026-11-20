// EXPECT: output FIRED eventually
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0;
a1: assert property (@(posedge clk) a |-> s_eventually b) else $error("FIRED eventually");
initial begin @(negedge clk) a = 1; @(negedge clk) a = 0; repeat (5) @(negedge clk); $finish; end
final $display("final reached"); endmodule
