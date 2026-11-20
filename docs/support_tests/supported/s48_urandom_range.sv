// EXPECT: output urandom_range
module t; initial begin int unsigned r1, r2; r1 = $urandom_range(10, 20); r2 = $urandom_range(10, 20); $display("urandom_range %0d %0d random=%0d", r1, r2, $random % 5); $finish; end endmodule
