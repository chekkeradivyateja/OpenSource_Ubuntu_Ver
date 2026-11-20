// EXPECT: nooutput two='{'h2} '{'h1}
// EXPECT: output two='{'h2}
// Two array-locator results in one $display: the second one prints a wrong number.
module t;
  int q[$] = '{4, 1, 3};
  initial begin $display("two=%p %p", q.find_index(x) with (x == 3), q.min()); $finish; end
endmodule
