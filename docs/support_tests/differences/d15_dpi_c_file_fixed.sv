// EXTRA: dpi_add.cpp
// EXPECT: output dpi 5
// Fix: write the DPI code in a .cpp file and declare the function extern "C" (see dpi_add.cpp).
module t;
  import "DPI-C" function int c_add(int a, int b);
  initial begin $display("dpi %0d", c_add(2, 3)); $finish; end
endmodule
