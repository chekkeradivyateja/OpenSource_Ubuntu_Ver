// EXPECT: error Unsupported: 'get_coverage' of coverpoint or cross
module t;
  covergroup cg with function sample(int x);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  cg c = new;
  initial begin c.sample(1); $display("cp cov=%0.1f", c.cp.get_coverage()); $finish; end
endmodule
