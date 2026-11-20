// EXPECT: output udp y=1
primitive my_and(output y, input a, input b); table 0 ? : 0; ? 0 : 0; 1 1 : 1; endtable endprimitive
module t; logic a = 1, b = 1; wire y; my_and u(y, a, b); initial begin #1 $display("udp y=%b", y); $finish; end endmodule
