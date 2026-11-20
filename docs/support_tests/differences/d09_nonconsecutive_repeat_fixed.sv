// EXPECT: output FIRED bad
// EXPECT: nooutput FIRED good
// Fix: count the b pulses with a small counter and check c after the 2nd one.
module t;
  logic clk = 0; always #5 clk = ~clk;
  logic a = 0, b = 0, c = 0, c2 = 0;    // c2: the "bad" case never sends c
  logic arm = 0; logic [3:0] nb = 0;
  always @(posedge clk) begin
    if (a) begin arm <= 1; nb <= 0; end
    else if (arm && b) nb <= nb + 1;
    if (arm && nb == 2) arm <= 0;
  end
  a_good: assert property (@(posedge clk) (arm && b && nb == 1) |=> c)  else $error("FIRED good");
  a_bad:  assert property (@(posedge clk) (arm && b && nb == 1) |=> c2) else $error("FIRED bad");
  initial begin
    @(negedge clk) a = 1;
    @(negedge clk) begin a = 0; b = 1; end
    @(negedge clk) b = 0;
    @(negedge clk) b = 1;
    @(negedge clk) begin b = 0; c = 1; end
    @(negedge clk) c = 0;
    repeat (3) @(negedge clk);
    $finish;
  end
endmodule
