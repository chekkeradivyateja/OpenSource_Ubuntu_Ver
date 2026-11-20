// EXPECT: output cp cov=25.0
// Fix: call get_coverage() on the whole covergroup (put the coverpoint in its own covergroup
// if you need its number), or read per-coverpoint numbers from: verilator_coverage --report hier
module t;
  covergroup cg_x with function sample(int x);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup
  cg_x c = new;
  initial begin c.sample(1); $display("cp cov=%0.1f", c.get_coverage()); $finish; end
endmodule
