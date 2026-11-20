// EXPECT: output FIRED rose
// EXPECT: output FIRED fell
// EXPECT: output FIRED stable
// EXPECT: output FIRED changed
// Each assertion is written to fail once, to prove that the check really runs.
module t;
  logic clk = 0; always #5 clk = ~clk;
  logic s = 0, d = 0;
  a_rose:    assert property (@(posedge clk) $rose(s)    |-> d)  else $error("FIRED rose");
  a_fell:    assert property (@(posedge clk) $fell(s)    |-> d)  else $error("FIRED fell");
  a_stable:  assert property (@(posedge clk) !s |-> $stable(d))  else $error("FIRED stable");
  a_changed: assert property (@(posedge clk) s  |-> $changed(d)) else $error("FIRED changed");
  initial begin
    @(negedge clk) s = 1;          // rose with d=0 -> rose fails; s=1 and d unchanged -> changed fails
    @(negedge clk) s = 0;          // fell with d=0 -> fell fails
    @(negedge clk) d = 1;          // s=0 and d changed -> stable fails
    repeat (2) @(negedge clk);
    $finish;
  end
endmodule
