// EXPECT: output w=1
// Two drivers on one wire: no error, not even with -Wall; one value wins.
// In VCS/Questa: w=x (contention is visible).
module t;
  wire w;
  assign w = 1'b1;
  assign w = 1'b0;
  initial begin #1 $display("w=%b", w); $finish; end
endmodule
