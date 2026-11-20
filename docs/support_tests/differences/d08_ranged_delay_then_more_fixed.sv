// EXPECT: output FIRED bad
// EXPECT: nooutput FIRED good
// Fix: put the rest of the sequence in parentheses after the range: ##[1:5] (b ##1 c).
// "good" signals follow the rule (no error); "bad" signals break it (error expected).
module t;
  logic clk = 0; always #5 clk = ~clk;
  logic a = 0, b = 0, c = 0;      // good: b then c
  logic a2 = 0, b2 = 0, c2 = 0;   // bad: b but no c
  a_good: assert property (@(posedge clk) a  |-> ##[1:5] (b  ##1 c))  else $error("FIRED good");
  a_bad:  assert property (@(posedge clk) a2 |-> ##[1:5] (b2 ##1 c2)) else $error("FIRED bad");
  initial begin
    @(negedge clk) begin a = 1; a2 = 1; end
    @(negedge clk) begin a = 0; a2 = 0; end
    @(negedge clk) begin b = 1; b2 = 1; end
    @(negedge clk) begin b = 0; b2 = 0; c = 1; end
    @(negedge clk) c = 0;
    repeat (6) @(negedge clk);
    $finish;
  end
endmodule
