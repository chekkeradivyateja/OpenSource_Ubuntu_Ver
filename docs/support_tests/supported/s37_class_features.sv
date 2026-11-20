// EXPECT: output cast ok der cnt=1 pv=s w=8
virtual class base; pure virtual function string name(); static int cnt; function new(); cnt++; endfunction endclass
class der extends base; local int secret = 3; protected int p = 1; function string name(); return "der"; endfunction endclass
class par #(type T = int, int W = 4); T v; bit [W-1:0] w; endclass
module t; initial begin der d = new; base b = d; der d2; par #(string, 8) pp = new; pp.v = "s";
if ($cast(d2, b)) $display("cast ok %s cnt=%0d pv=%s w=%0d", d2.name(), base::cnt, pp.v, $bits(pp.w)); $finish; end endmodule
