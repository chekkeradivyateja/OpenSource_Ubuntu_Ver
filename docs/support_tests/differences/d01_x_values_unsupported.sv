// EXPECT: output a=0010 b=0 isunknown=0 eqx=0
// EXPECT: output x==0 is TRUE
// X and Z become 0 in Verilator (2-state). In VCS/Questa: a=x01z b=x isunknown=1 eqx=1.
module t;
  logic [3:0] a; logic b;
  initial begin
    a = 4'bx01z; b = 1'bx;
    $display("a=%b b=%b isunknown=%0d eqx=%0d", a, b, $isunknown(a), (b === 1'bx));
    if (b == 0) $display("x==0 is TRUE");
    $finish;
  end
endmodule
