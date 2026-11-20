// EXPECT: error Non-constant expression in array bins range
module t;
  covergroup cg (int lim) with function sample(int x);
    cp: coverpoint x { bins b[] = {[0:lim]}; }
  endgroup
  cg c = new(3);
  initial begin c.sample(1); $display("cov=%0.1f", c.get_coverage()); $finish; end
endmodule
