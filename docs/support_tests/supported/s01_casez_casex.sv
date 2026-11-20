// EXPECT: output casez match
// EXPECT: output casex match
module t; logic [3:0] s; initial begin s = 4'b1010; casez (s) 4'b1??0: $display("casez match"); default: $display("casez nomatch"); endcase
casex (s) 4'b1x1x: $display("casex match"); default: $display("casex nomatch"); endcase $finish; end endmodule
