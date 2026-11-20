// EXPECT: output rev=10000011
module t; logic [7:0] a = 8'b1100_0001, b; byte q[$]; initial begin b = {<<{a}}; q = {>>8{16'hABCD}}; $display("rev=%b q=%p", b, q); $finish; end endmodule
