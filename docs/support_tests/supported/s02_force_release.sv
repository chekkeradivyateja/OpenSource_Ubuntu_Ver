// EXPECT: output forced a=7
// EXPECT: output released a=2
module t; logic [3:0] a; initial begin a = 1; force a = 7; #1 $display("forced a=%0d", a); release a; a = 2; #1 $display("released a=%0d", a); $finish; end endmodule
