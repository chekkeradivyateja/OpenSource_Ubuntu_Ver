// EXPECT: output x=
// EXPECT: nooutput FAIL
class c; rand int x; endclass
module t; initial begin c o = new; int y; if (!o.randomize() with { x inside {[10:20]}; }) $display("FAIL1");
if (!std::randomize(y) with { y > 5; y < 9; }) $display("FAIL2"); $display("x=%0d y=%0d", o.x, y); $finish; end endmodule
