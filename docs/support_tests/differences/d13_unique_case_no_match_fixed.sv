// EXPECT: output default
// EXPECT: nooutput %Error
// Fix: cover every value, or add a default item.
module t;
  logic [1:0] s = 2'd3;
  initial begin
    unique case (s) 2'd0: $display("0"); 2'd1: $display("1"); default: $display("default"); endcase
    $finish;
  end
endmodule
