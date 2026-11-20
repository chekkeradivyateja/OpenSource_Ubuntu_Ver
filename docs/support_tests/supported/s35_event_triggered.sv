// EXPECT: output triggered
module t; event e; initial begin fork begin #1 -> e; end begin wait (e.triggered); $display("triggered"); end join $finish; end endmodule
