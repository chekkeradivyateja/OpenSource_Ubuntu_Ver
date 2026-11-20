// EXPECT: output got 5
// EXPECT: output sem ok
module t; mailbox #(int) mb = new(); semaphore sm = new(1); int r;
initial begin fork begin #1 mb.put(5); end begin mb.get(r); $display("got %0d", r); end join
sm.get(1); $display("sem ok try=%0d", sm.try_get(1)); sm.put(1); $display("num=%0d", mb.num()); $finish; end endmodule
