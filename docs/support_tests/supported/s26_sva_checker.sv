// EXPECT: output FIRED checker
checker my_chk(logic clk, logic a); a1: assert property (@(posedge clk) a) else $error("FIRED checker"); endchecker
module t; logic clk = 0; always #5 clk = ~clk; logic a = 1; my_chk u(clk, a); initial begin #22 a = 0; #20 $finish; end endmodule
