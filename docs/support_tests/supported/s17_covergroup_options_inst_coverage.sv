// EXPECT: output cov=50.0 inst=50.0
module t; covergroup cg with function sample(int x); option.per_instance = 1; option.goal = 90; option.comment = "demo"; cp: coverpoint x { bins b[] = {[0:3]}; } endgroup
cg c = new; initial begin c.sample(1); c.sample(2); $display("cov=%0.1f inst=%0.1f", c.get_coverage(), c.get_inst_coverage()); $finish; end endmodule
