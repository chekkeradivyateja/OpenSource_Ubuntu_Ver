// EXPECT: output and=0 or=1
module t; logic a = 1, b = 0; wire y1, y2, y3; and g1(y1, a, b); or g2(y2, a, b); bufif1 g3(y3, a, b);
initial begin #1 $display("and=%b or=%b bufif1(en=0)=%b", y1, y2, y3); $finish; end endmodule
