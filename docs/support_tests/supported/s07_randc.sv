// EXPECT: output 0 2 1 3
class c; randc bit [1:0] v; endclass
module t; initial begin c o = new; repeat (4) begin void'(o.randomize()); $write("%0d ", o.v); end $display(""); $finish; end endmodule
