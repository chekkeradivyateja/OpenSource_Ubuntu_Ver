// EXPECT: output a=
// EXPECT: nooutput FAIL
typedef struct packed { bit [3:0] a; bit [3:0] b; } pair_t;
class c; rand pair_t p; constraint k { p.a > p.b; } endclass
module t; initial begin c o = new; if (!o.randomize()) $display("FAIL"); else $display("a=%0d b=%0d", o.p.a, o.p.b); $finish; end endmodule
