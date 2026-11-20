// EXPECT: output released bus=1
// Fix: give every shared net a defined idle value (pullup/pulldown), and do not test for z.
module drv(inout wire b, input logic en, input logic v); assign b = en ? v : 1'bz; endmodule
module t;
  wire bus; logic e1 = 1, e2 = 0;
  drv d1(bus, e1, 1'b0); drv d2(bus, e2, 1'b0);
  pullup(bus);
  initial begin #1 e1 = 0; #1 $display("released bus=%b", bus); $finish; end
endmodule
