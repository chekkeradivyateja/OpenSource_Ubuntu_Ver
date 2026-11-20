// EXPECT: error Unsupported: expect
module t;
  logic clk = 0; always #5 clk = ~clk; logic b = 0;
  initial #12 b = 1;
  initial begin
    expect (@(posedge clk) ##[1:3] b) $display("expect ok"); else $display("expect fail");
    $finish;
  end
endmodule
