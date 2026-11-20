// EXPECT: output cnt=5
module t; logic [3:0] cnt = 4'd5; initial begin #1 $display("cnt=%0d", cnt); $finish; end endmodule
