// EXPECT: output idx='{'h2} min='{'h1}
// Fix: store locator results in queue variables first.
module t;
  int q[$] = '{4, 1, 3}; int idx[$], mn[$];
  initial begin
    idx = q.find_index(x) with (x == 3); mn = q.min();
    $display("idx=%p min=%p", idx, mn); $finish;
  end
endmodule
