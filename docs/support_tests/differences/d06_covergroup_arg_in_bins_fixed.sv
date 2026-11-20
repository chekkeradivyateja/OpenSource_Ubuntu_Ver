// EXPECT: output cov=12.5
// Fix: constant bins; use the argument in an iff condition (or a parameter).
module t;
  covergroup cg (int lim) with function sample(int x);
    cp: coverpoint x iff (x <= lim) { bins b[] = {[0:7]}; }
  endgroup
  cg c = new(3);
  initial begin c.sample(1); c.sample(6); $display("cov=%0.1f", c.get_coverage()); $finish; end
endmodule
