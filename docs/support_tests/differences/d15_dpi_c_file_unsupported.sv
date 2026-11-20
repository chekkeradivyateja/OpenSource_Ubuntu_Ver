// EXTRA: dpi_add.c
// EXPECT: error undefined reference to `c_add'
// A DPI function in a .c file is compiled as C++ by Verilator: its name is mangled and the link fails.
module t;
  import "DPI-C" function int c_add(int a, int b);
  initial begin $display("dpi %0d", c_add(2, 3)); $finish; end
endmodule
