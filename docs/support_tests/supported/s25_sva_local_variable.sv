// EXPECT: output FIRED local var
module t; logic clk = 0; always #5 clk = ~clk; logic v = 0; logic [7:0] d = 0, q = 0;
property p; logic [7:0] x; @(posedge clk) (v, x = d) |=> (q == x); endproperty
a1: assert property (p) else $error("FIRED local var");
always @(posedge clk) q <= d + 1;
initial begin @(negedge clk) begin v = 1; d = 5; end @(negedge clk) v = 0; repeat (2) @(negedge clk); $finish; end endmodule
