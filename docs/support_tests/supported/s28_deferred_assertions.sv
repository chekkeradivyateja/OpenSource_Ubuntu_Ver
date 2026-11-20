// EXPECT: output FIRED final
// EXPECT: output FIRED #0
module t; logic a = 1; always_comb af: assert final (a) else $error("FIRED final"); always_comb a0: assert #0 (a) else $error("FIRED #0");
initial begin #2 a = 0; #2 $finish; end endmodule
