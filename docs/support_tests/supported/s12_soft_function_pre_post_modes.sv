// EXPECT: output pre=1 post=1
// EXPECT: output override x=7
// EXPECT: output modes y=100
class c; rand int x; rand int y; int pre = 0, post = 0;
constraint c1 { soft x == 5; } constraint c2 { y inside {[0:9]}; y == dbl(x) % 10; }
function int dbl(int v); return v * 2; endfunction
function void pre_randomize(); pre++; endfunction function void post_randomize(); post++; endfunction endclass
module t; initial begin c o = new; void'(o.randomize()); $display("x=%0d y=%0d pre=%0d post=%0d", o.x, o.y, o.pre, o.post);
void'(o.randomize() with { x == 7; }); $display("override x=%0d", o.x);
o.c2.constraint_mode(0); o.y.rand_mode(0); o.y = 100; void'(o.randomize()); $display("modes y=%0d", o.y); $finish; end endmodule
