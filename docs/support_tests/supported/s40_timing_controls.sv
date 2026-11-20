// EXPECT: output t=5000
// EXPECT: output a=0 t=9000
`timescale 1ns/1ps
module t; logic clk = 0; always #5 clk = ~clk; logic a = 0; initial begin #2.5 a = 1; @(posedge clk iff a); $display("t=%0t", $time);
wait (a == 1); a <= #3 0; #4 $display("a=%0d t=%0t", a, $time); repeat (2) @(posedge clk); $finish; end endmodule
