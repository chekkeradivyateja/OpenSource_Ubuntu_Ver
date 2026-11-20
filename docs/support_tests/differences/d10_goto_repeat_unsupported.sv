// EXPECT: nooutput FIRED goto
// EXPECT: output end
// SILENT WRONG RESULT: goto repetition b[->1] compiles, but this assertion does NOT fire
// although c never comes after b. VCS/Questa report the failure. Do not use [->n].
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 0, b = 0, c = 0;
  a1: assert property (@(posedge clk) a |-> b[->1] ##1 c) else $error("FIRED goto");
  initial begin
    @(negedge clk) a = 1; @(negedge clk) a = 0;
    @(negedge clk) b = 1; @(negedge clk) b = 0;
    repeat (4) @(negedge clk);
    $display("end"); $finish;
  end
endmodule
