// EXPECT: output expect ok
// Fix: wait for the condition with a clock-count timeout.
module t;
  logic clk = 0; always #5 clk = ~clk; logic b = 0;
  initial #12 b = 1;
  initial begin
    bit ok = 0;
    repeat (3) begin @(posedge clk); if (b) begin ok = 1; break; end end
    if (ok) $display("expect ok"); else $error("b not seen within 3 clocks");
    $finish;
  end
endmodule
