// EXPECT: output join_any at 5
// EXPECT: output wait fork done 10
// EXPECT: output disabled
module t; initial begin
fork #10 $display("A %0t", $time); #5 $display("B %0t", $time); join_any $display("join_any at %0t", $time);
fork #3 $display("C %0t", $time); join_none wait fork; $display("wait fork done %0t", $time);
fork begin #100 $display("never"); end join_none #1 disable fork; $display("disabled"); $finish; end endmodule
