// EXPECT: error Syntax error
module t;
  initial begin $display("atoi=%0d", "42".atoi()); $finish; end
endmodule
