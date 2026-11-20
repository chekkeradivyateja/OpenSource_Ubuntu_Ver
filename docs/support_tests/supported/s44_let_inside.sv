// EXPECT: output max=5 inside=1
module t; let max(a, b) = (a > b) ? a : b; int x = 5; initial begin $display("max=%0d inside=%0d", max(3, x), x inside {[1:6], 9}); $finish; end endmodule
