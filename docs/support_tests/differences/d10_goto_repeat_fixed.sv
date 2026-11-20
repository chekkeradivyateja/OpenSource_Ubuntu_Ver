// EXPECT: output FIRED bad
// EXPECT: nooutput FIRED good
// Fix: use a bounded window with the rest of the sequence in parentheses.
module t;
  logic clk = 0; always #5 clk = ~clk;
  logic a = 0, b = 0, c = 0, c2 = 0;    // c2 never comes: must fire
  a_good: assert property (@(posedge clk) a |-> ##[1:8] (b ##1 c))  else $error("FIRED good");
  a_bad:  assert property (@(posedge clk) a |-> ##[1:8] (b ##1 c2)) else $error("FIRED bad");
  initial begin
    @(negedge clk) a = 1; @(negedge clk) a = 0;
    @(negedge clk) b = 1; @(negedge clk) begin b = 0; c = 1; end
    @(negedge clk) c = 0;
    repeat (10) @(negedge clk);
    $finish;
  end
endmodule
