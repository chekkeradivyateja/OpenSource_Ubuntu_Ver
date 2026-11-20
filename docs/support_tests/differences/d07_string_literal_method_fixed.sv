// EXPECT: output atoi=42 len=5 up=HELLO
// Fix: call string methods on a string variable.
module t;
  string n = "42", s = "Hello";
  initial begin $display("atoi=%0d len=%0d up=%s", n.atoi(), s.len(), s.toupper()); $finish; end
endmodule
