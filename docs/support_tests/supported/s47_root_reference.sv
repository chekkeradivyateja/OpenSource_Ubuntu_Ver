// EXPECT: output root=6
module sub; logic [3:0] v = 4'd6; endmodule
module t; sub u(); initial begin #1 $display("hier=%0d root=%0d", u.v, $root.t.u.v); $finish; end endmodule
