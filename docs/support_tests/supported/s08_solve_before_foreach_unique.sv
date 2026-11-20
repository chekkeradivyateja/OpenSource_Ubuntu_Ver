// EXPECT: output arr=
// EXPECT: nooutput FAIL
class c; rand bit m; rand bit [3:0] v; rand bit [3:0] arr[4];
constraint c1 { m -> v == 0; solve m before v; }
constraint c2 { foreach (arr[i]) arr[i] < 8; unique {arr}; } endclass
module t; initial begin c o = new; if (!o.randomize()) $display("FAIL"); else $display("m=%0d v=%0d arr=%p", o.m, o.v, o.arr); $finish; end endmodule
