// EXPECT: output sqrt=1.581139
module t; real r = 2.5; shortreal s = 1.5; initial begin $display("r=%f sqrt=%f pow=%f int=%0d s=%f", r, $sqrt(r), $pow(2.0, 3.0), $rtoi(r), s); $finish; end endmodule
