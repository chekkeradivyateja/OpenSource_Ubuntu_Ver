// EXPECT: output rs a
// EXPECT: output rs b
module t; int n0, n1; initial begin repeat (100) randcase 1: n0++; 3: n1++; endcase $display("randcase %0d %0d", n0, n1);
randsequence (main) main: a b; a: { $display("rs a"); }; b: { $display("rs b"); }; endsequence $finish; end endmodule
