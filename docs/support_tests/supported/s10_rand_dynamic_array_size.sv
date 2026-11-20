// EXPECT: output size=
// EXPECT: nooutput FAIL
class c; rand bit [7:0] q[]; constraint cs { q.size() inside {[2:4]}; foreach (q[i]) q[i] > 10; } endclass
module t; initial begin c o = new; if (!o.randomize()) $display("FAIL"); else $display("size=%0d q=%p", o.q.size(), o.q); $finish; end endmodule
