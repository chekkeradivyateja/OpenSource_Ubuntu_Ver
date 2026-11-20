// EXPECT: output w=0
// Fix: one driver per net; choose the source with a select signal.
module t;
  wire w; logic sel = 1;
  assign w = sel ? 1'b0 : 1'b1;
  initial begin #1 $display("w=%b", w); $finish; end
endmodule
