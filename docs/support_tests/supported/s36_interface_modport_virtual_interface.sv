// EXPECT: output d=7
interface bus_if(input logic clk); logic [3:0] d; modport mp(input clk, output d); endinterface
class drv; virtual bus_if vif; function new(virtual bus_if v); vif = v; endfunction task go(); vif.d <= 4'd7; endtask endclass
module t; logic clk = 0; bus_if b(clk); initial begin drv dd = new(b); dd.go(); #1 $display("d=%0d", b.d); $finish; end endmodule
