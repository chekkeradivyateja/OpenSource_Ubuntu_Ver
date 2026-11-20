// EXPECT: output o0=f o1=ff
module leaf #(parameter int W = 4) (output logic [W-1:0] o); assign o = '1; endmodule
module t; genvar i; logic [3:0] o0; logic [7:0] o1; generate for (i = 0; i < 2; i++) begin : g if (i == 0) leaf #(4) u(o0); else leaf #(.W(8)) u(o1); end endgenerate
initial begin #1 $display("o0=%h o1=%h", o0, o1); $finish; end endmodule
