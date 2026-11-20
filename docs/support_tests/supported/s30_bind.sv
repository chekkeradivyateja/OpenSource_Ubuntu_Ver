// EXPECT: output FIRED a low
// bind attaches the checker module to every instance of dut without editing dut.
module dut(input logic clk, input logic a); endmodule
module chk(input logic clk, input logic a);
  a1: assert property (@(posedge clk) a) else $error("FIRED a low");
endmodule
bind dut chk u_chk(.*);
module t;
  logic clk = 0; always #5 clk = ~clk; logic a = 1;
  dut u(.*);
  initial begin #22 a = 0; #10 $finish; end
endmodule
