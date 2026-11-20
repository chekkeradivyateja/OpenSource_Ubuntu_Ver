// EXPECT: output unique case, but none matched
// unique case with no matching item is an %Error that STOPS the simulation
// (here kept running by +verilator+error+limit). VCS/Questa only print a warning.
module t;
  logic [1:0] s = 2'd3;
  initial begin
    unique case (s) 2'd0: $display("0"); 2'd1: $display("1"); endcase
    $display("done"); $finish;
  end
endmodule
