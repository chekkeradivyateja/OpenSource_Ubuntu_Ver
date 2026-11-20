// EXPECT: output in program
program p; initial begin #1 $display("in program"); end endprogram
module t; p u(); initial #5 $finish; endmodule
