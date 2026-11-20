// EXPECT: warning SPECIFYIGN
// EXPECT: nooutput setup
// specify blocks and timing checks ($setup, $hold, path delays) are ignored with a warning;
// no violation is reported. No equivalent in this flow: use static timing analysis instead.
module ff(input clk, input d, output reg q);
  always @(posedge clk) q <= d;
  specify
    (posedge clk => (q +: d)) = (1, 1);
    $setup(d, posedge clk, 2);
  endspecify
endmodule
module t;
  logic clk = 0, d = 0; wire q;
  ff u(clk, d, q);
  initial begin #9 d = 1; #1 clk = 1; #1 $display("q=%b", q); $finish; end
endmodule
