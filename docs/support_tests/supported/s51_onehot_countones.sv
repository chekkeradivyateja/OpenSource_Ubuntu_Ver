// EXPECT: output countones=3 onehot=1 onehot0=1 isunknown=0
module t;
  initial begin
    $display("countones=%0d onehot=%0d onehot0=%0d isunknown=%0d",
             $countones(4'b1011), $onehot(4'b0100), $onehot0(4'b0000), $isunknown(4'b0101));
    $finish;
  end
endmodule
