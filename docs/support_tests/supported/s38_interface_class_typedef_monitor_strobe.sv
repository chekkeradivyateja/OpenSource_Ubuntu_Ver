// EXPECT: output area=4
// EXPECT: output strobe a=3
interface class shape; pure virtual function int area(); endclass
class sq implements shape; virtual function int area(); return 4; endfunction endclass
typedef class fwd; class user; fwd f; endclass class fwd; int v = 1; endclass
module t; logic [3:0] a = 0; initial begin sq s = new; user u = new; $monitor("mon a=%0d", a); #1 a = 3; $strobe("strobe a=%0d", a); #1 $display("area=%0d", s.area()); $finish; end endmodule
