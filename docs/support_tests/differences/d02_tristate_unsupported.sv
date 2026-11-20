// EXPECT: output floating bus=0 bufif1_off=0
// A floating net (z) reads as 0. In VCS/Questa: bus=z bufif1_off=z.
module t;
  wire bus, y; logic en = 0, a = 1;
  assign bus = en ? 1'b1 : 1'bz;
  bufif1 g(y, a, en);
  initial begin #1 $display("floating bus=%b bufif1_off=%b", bus, y); $finish; end
endmodule
