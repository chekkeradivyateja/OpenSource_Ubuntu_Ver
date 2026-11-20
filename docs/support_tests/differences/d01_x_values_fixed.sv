// BUILD: --x-assign unique --x-initial unique
// RUN: +verilator+rand+reset+2 +verilator+seed+9
// EXPECT: output uninit r=54
// Fix: never rely on X. Reset every register. To find missing resets, build with
// --x-assign unique --x-initial unique and run with +verilator+rand+reset+2:
// uninitialized values become random (changed by +verilator+seed+<n>) instead of 0.
module t;
  logic [7:0] r;   // never assigned: a missing reset
  initial begin #1 $display("uninit r=%0d", r); $finish; end
endmodule
