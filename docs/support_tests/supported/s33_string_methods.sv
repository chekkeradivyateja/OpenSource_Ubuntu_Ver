// EXPECT: output atoi=42
module t; string s = "Hello", n = "42"; initial begin $display("%s len=%0d up=%s sub=%s cmp=%0d atoi=%0d itoa=%s", s, s.len(), s.toupper(), s.substr(1,3), s.compare("Hello"), n.atoi(), $sformatf("%0d", 7)); $finish; end endmodule
