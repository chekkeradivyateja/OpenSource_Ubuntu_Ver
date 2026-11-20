# SystemVerilog and UVM support in Verilator 5.054

What works, what does not, and how to rewrite code that VCS/Questa accept but
Verilator 5.054 rejects or runs differently.

**How this was tested.** Every snippet below comes from a test file in
[`support_tests/`](support_tests/). Each file was compiled and run with Verilator 5.054
on Ubuntu 24.04 (2026-11-20) and its expected result is written in its header.
Re-run all of them on your machine:

    cd docs/support_tests
    ./run_tests.sh          # 83 SystemVerilog tests, about 2 minutes
    ./run_tests.sh --uvm    # plus the UVM test, about 3 more minutes

The "VCS/Questa" columns describe the behaviour defined by IEEE 1800; no commercial
simulator was run for this page.

Contents
1. Summary
2. Different behaviour (compiles, but the result is different)
3. Not supported (compile error) and how to rewrite
4. Supported and tested (SystemVerilog)
5. UVM
6. Not tested

---

## 1. Summary

| # | Item | Verilator 5.054 | Rewrite |
|---|---|---|---|
| d01 | X and Z values | become 0; `$isunknown` is 0; `x == 0` is true | reset everything; find missing resets with random init |
| d02 | floating nets (`z`), `bufif` off | read as 0 | pullup/pulldown, never test for z |
| d03 | two drivers on one net | no error, one value wins | one driver + select |
| d10 | goto repetition `b[->n]` | **compiles, never fails (silent)** | `##[1:N] (b ##1 c)` |
| d12 | `cover property` without `--coverage` | **ignored (silent)** | build with `--coverage` |
| d13 | `unique case` with no match | `%Error`, simulation stops | add `default` |
| d14 | two array-locator calls in one `$display` | second value printed wrong | store results in variables |
| d04 | `expect` | not supported | wait loop with timeout |
| d05 | `cg.cp.get_coverage()` (one coverpoint) | not supported | `cg.get_coverage()` / own covergroup |
| d06 | covergroup argument in a bins range | not supported | constant bins + `iff` |
| d07 | method on a string literal (`"42".atoi()`) | syntax error | method on a string variable |
| d08 | `##[m:n] b ##1 c` | not supported | `##[m:n] (b ##1 c)` |
| d09 | non-consecutive repetition `b[=n]` | not supported | counter + simple assertion |
| d11 | `sequence.triggered` | not supported | `cover property` with an action |
| d15 | DPI function in a `.c` file | link error | `.cpp` file with `extern "C"` |
| d16 | `specify`, `$setup`, `$hold`, path delays | ignored (warning) | no equivalent; use static timing analysis |

Most important: **d10 and d12 give no error at all**. A check written that way looks
fine but never reports a problem.

---

## 2. Different behaviour (compiles, but the result is different)

### d01 - X and Z values (2-state simulation)
Files: `differences/d01_x_values_unsupported.sv`, `d01_x_values_fixed.sv`

    logic [3:0] a; logic b;
    a = 4'bx01z; b = 1'bx;
    $display("a=%b b=%b isunknown=%0d eqx=%0d", a, b, $isunknown(a), (b === 1'bx));
    if (b == 0) $display("x==0 is TRUE");

| | Output |
|---|---|
| VCS/Questa | `a=x01z b=x isunknown=1 eqx=1` (and `b == 0` is not true) |
| Verilator 5.054 | `a=0010 b=0 isunknown=0 eqx=0` and `x==0 is TRUE` |

Uninitialized variables also start at 0, so a missing reset is not visible.
**Do this instead:** reset every register, and do not write checks that depend on X.
To find missing resets, let Verilator start every uninitialized bit with a random value:

    verilator --binary --x-assign unique --x-initial unique ... 
    ./obj_dir/Vtb_top +verilator+rand+reset+2 +verilator+seed+9

Tested: an unassigned `logic [7:0] r` then prints `uninit r=54` instead of 0
(another seed gives another value). If results change with the seed, something is not reset.

### d02 - Floating nets and tri-state
Files: `d02_tristate_unsupported.sv`, `d02_tristate_fixed.sv`

    assign bus = en ? 1'b1 : 1'bz;   // en = 0
    bufif1 g(y, a, en);              // en = 0

| | Output |
|---|---|
| VCS/Questa | `bus=z bufif1_off=z` |
| Verilator 5.054 | `bus=0 bufif1_off=0` |

**Do this instead:** give every shared net an idle value and never test for `z`:

    pullup(bus);                     // tested: all drivers off -> bus=1

### d03 - Two drivers on one net
Files: `d03_multidriver_unsupported.sv`, `d03_multidriver_fixed.sv`

    wire w;
    assign w = 1'b1;
    assign w = 1'b0;

| | Result |
|---|---|
| VCS/Questa | `w=x` (contention visible) |
| Verilator 5.054 | `w=1`, no error, and no multiple-driver warning even with `--lint-only -Wall` |

**Do this instead:** one driver per net, select the source:

    assign w = sel ? 1'b0 : 1'b1;

### d10 - Goto repetition `[->n]` (silent wrong result)
Files: `d10_goto_repeat_unsupported.sv`, `d10_goto_repeat_fixed.sv`

    a1: assert property (@(posedge clk) a |-> b[->1] ##1 c) else $error("FIRED goto");
    // a=1, later b=1, but c never comes

| | Result |
|---|---|
| VCS/Questa | assertion fails |
| Verilator 5.054 | **compiles, never fails**; the same sequence in a `cover property` is never hit |

**Do this instead:** a bounded window, with the rest of the sequence in parentheses:

    a1: assert property (@(posedge clk) a |-> ##[1:8] (b ##1 c)) else $error("...");

Tested both ways: correct signals give no error, missing `c` gives the error.

### d12 - `cover property` needs `--coverage` (silent)
Files: `d12_cover_without_coverage_unsupported.sv`, `d12_cover_without_coverage_fixed.sv`

    c0: cover property (@(posedge clk) a ##1 b) $display("COVER hit at %0t", $time);

Built without `--coverage`, the cover is not evaluated: no message, no count.
**Do this instead:** build with `--coverage` (the Makefile templates always do).
Tested: `COVER hit at 25`, and the hit is counted as "user" coverage.

### d13 - `unique case` with no matching item
Files: `d13_unique_case_no_match_unsupported.sv`, `d13_unique_case_no_match_fixed.sv`

    unique case (s) 2'd0: ...; 2'd1: ...; endcase      // s = 3

| | Result |
|---|---|
| VCS/Questa | warning, simulation continues |
| Verilator 5.054 | `%Error: ... unique case, but none matched for '2'h3'`, simulation stops |

**Do this instead:** cover every value or add `default: ...`.

### d14 - Two array-locator results in one `$display`
Files: `d14_two_locators_in_display_unsupported.sv`, `d14_two_locators_in_display_fixed.sv`

    $display("two=%p %p", q.find_index(x) with (x == 3), q.min());   // second value wrong

**Do this instead:** store the results first:

    idx = q.find_index(x) with (x == 3); mn = q.min();
    $display("idx=%p min=%p", idx, mn);        // idx='{'h2} min='{'h1}

### Deferred assertions (`assert #0`, `assert final`)
They work (`supported/s28_deferred_assertions.sv`), but one failure may be reported
several times in the same time step. Count failures per time, not per message.

---

## 3. Not supported (compile error) and how to rewrite

### d04 - `expect`
Error: `Unsupported: expect`

    expect (@(posedge clk) ##[1:3] b) $display("expect ok"); else $display("expect fail");

**Write instead:**

    bit ok = 0;
    repeat (3) begin @(posedge clk); if (b) begin ok = 1; break; end end
    if (ok) $display("expect ok"); else $error("b not seen within 3 clocks");

### d05 - `get_coverage()` of one coverpoint
Error: `Unsupported: 'get_coverage' of coverpoint or cross 'cp'`

    $display("cp cov=%0.1f", c.cp.get_coverage());

**Write instead:** `c.get_coverage()` for the whole covergroup (put a coverpoint in its own
covergroup if you need its number), or read every coverpoint and bin from the coverage file:

    verilator_coverage --report hier coverage.dat
    verilator_coverage --filter-type covergroup --annotate cg_bins --annotate-points coverage.dat

### d06 - Covergroup argument used in a bins range
Error: `Non-constant expression in array bins range`

    covergroup cg (int lim) with function sample(int x);
      cp: coverpoint x { bins b[] = {[0:lim]}; }
    endgroup

**Write instead:** constant bins, argument in an `iff`:

    covergroup cg (int lim) with function sample(int x);
      cp: coverpoint x iff (x <= lim) { bins b[] = {[0:7]}; }
    endgroup

### d07 - Method called on a string literal
Error: `Syntax error: Not expecting CONST under a DOT in dotted expression`

    $display("%0d", "42".atoi());

**Write instead:** `string n = "42"; ... n.atoi()`. All string methods tested on variables
(`len`, `toupper`, `substr`, `compare`, `atoi`) work.

### d08 - Ranged delay followed by more sequence
Error: `Unsupported: Bounded ranged cycle delay in a sequence prefix`

    a |-> ##[1:5] b ##1 c

**Write instead:** `a |-> ##[1:5] (b ##1 c)`. A range at the end (`a |-> ##[1:3] b`) works as written.

### d09 - Non-consecutive repetition `[=n]`
Error: `Usage of cycle delays requires default clocking` (with `default clocking` declared,
Verilator stops with an internal error).

    a |=> b[=2] ##1 c

**Write instead:** count the pulses and check with a simple assertion:

    always @(posedge clk) begin
      if (a) begin arm <= 1; nb <= 0; end
      else if (arm && b) nb <= nb + 1;
      if (arm && nb == 2) arm <= 0;
    end
    a1: assert property (@(posedge clk) (arm && b && nb == 1) |=> c) else $error("c missing after 2nd b");

### d11 - `sequence.triggered`
Error: `Can't find definition of variable/method: 'triggered'`

    sequence s_ab; @(posedge clk) a ##1 b; endsequence
    always @(posedge clk) if (s_ab.triggered) $display("a then b");

**Write instead** (build with `--coverage`):

    c_ab: cover property (@(posedge clk) a ##1 b) $display("a then b seen at %0t", $time);

`.triggered` on an **event** works (`supported/s35_event_triggered.sv`).

### d15 - DPI-C function in a `.c` file
Error at link time: `undefined reference to 'c_add'`. Verilator compiles the `.c` file as C++,
so the function name is changed (mangled).

    // dpi_add.c
    int c_add(int a, int b) { return a + b; }

**Write instead** a `.cpp` file:

    // dpi_add.cpp
    #include "svdpi.h"
    extern "C" int c_add(int a, int b) { return a + b; }

and pass it on the command line: `verilator --binary ... tb.sv dpi_add.cpp`.

### d16 - `specify` blocks and timing checks
Warning: `%Warning-SPECIFYIGN: Ignoring unsupported: specify block construct`.
Path delays and timing checks such as `$setup` are ignored; violations are not reported.
Verilator is a cycle/zero-delay simulator: there is no gate-level timing simulation in this
flow. Check timing with a static timing analysis tool instead.

---

## 4. Supported and tested (SystemVerilog)

Each line was compiled and run; for assertions, a **failing** case was used to prove that the
check really fires. Files are in `support_tests/supported/`.

| Area | Tested constructs (file) |
|---|---|
| Procedural | `casez`/`casex` (s01), `force`/`release` (s02), `fork`/`join_any`/`join_none`, `wait fork`, `disable fork` (s03), clocking block (s04), `program` (s05), `#`/`@ iff`/`wait`/intra-assignment delay (s40), variable initial values (s50), `generate` + parameters (s41), `let`, `inside` (s44), streaming `{<<{}}`/`{>>{}}` (s43), `real` math (s42) |
| Data types | associative/dynamic arrays, queues and their methods (s31), packed/unpacked `struct`, packed `union`, `enum` methods (s32), `string` methods on variables (s33) |
| Classes | virtual/pure virtual, static, `local`, `protected`, parameterized classes, `$cast` (s37), `interface class`/`implements`, `typedef class` (s38) |
| Randomization (z3) | `randcase`, `randsequence` (s06), `randc` (s07), `solve before`, `foreach`, `unique` (s08), `randomize() with`, `std::randomize()` (s09), dynamic array `size()` constraint (s10), `rand` packed struct (s11), `soft`, function in constraint, `pre_/post_randomize`, `constraint_mode`, `rand_mode` (s12), `$urandom_range` (s48) |
| Functional coverage | explicit/automatic bins, `ignore_bins`, `illegal_bins`, `wildcard bins` (s13), illegal bin hit = error (s14), transition bins `(0 => 1 => 2)` (s15), `cross` with `binsof ... intersect` (s16), `option.per_instance/goal/comment`, `get_inst_coverage()`, `sample()` with arguments (s17), covergroup in a class (UVM test) |
| SVA | `[*n]` (s18), `throughout` (s19), `within` (s20), `intersect` (s21), `s_eventually` (s22), `until` (s23), `first_match` (s24), local variables in properties (s25), `checker` (s26), `$past(x, n)`, properties with arguments (s27), `assert #0`/`assert final` (s28), `$assertoff`/`$asserton` (s29), `bind` (s30), `assume property` (s45), `$onehot`, `$onehot0`, `$countones` (s51), `$rose`, `$fell`, `$stable`, `$changed` (s52); also `|->`, `|=>`, `##n`, `##[m:n]` at the end, `disable iff`, `cover property` (USER_GUIDE section 4, `examples/sv_project`) |
| Inter-process | `mailbox`, `semaphore` (s34), event `.triggered`, `wait` (s35) |
| Interfaces | `interface`, `modport`, virtual interface in a class (s36) |
| System tasks | file I/O `$fopen/$fwrite/$fgets` (s39), `$monitor`, `$strobe` (s38), `$root` references (s47) |
| Gate level | UDP `primitive` tables (s46), gate primitives `and`, `or` (s49) |
| DPI | `import "DPI-C"` with a `.cpp` file (d15 fixed) |

---

## 5. UVM

Library: Verilator fork of UVM 2020.3.1 (commit 656f20d) with two patches, installed in `$UVM_HOME`.
Test: `support_tests/uvm/u01_uvm_features.sv` (run with `./run_tests.sh --uvm`) and
`examples/uvm_project`.

Tested and working:
- components, `uvm_config_db` (virtual interface and `int`), factory `type_id::create`, type override
- `uvm_sequence_item` with `uvm_field_*` macros: `print`, `sprint`, `clone`, `compare`
- sequences with `start_item`/`finish_item`, `` `uvm_do ``, `` `uvm_do_with `` (constraint respected), virtual sequence with `p_sequencer`
- driver, monitor, analysis ports, `uvm_subscriber` with a covergroup, `uvm_tlm_analysis_fifo`
- scoreboard, objections, drain time, `report_phase`, `uvm_report_server` counts
- `uvm_event_pool`, `uvm_report_catcher` (error demoted to info), `print_topology`
- register model: `uvm_reg_block`, `uvm_reg`, `uvm_reg_field`, map, `set`/`get` of the desired value
- `+UVM_TESTNAME`, `+UVM_VERBOSITY`, `+UVM_NO_RELNOTES`

No UVM feature in this list needed a rewrite. Things to know:
- Compile the UVM library with `--vpi`, `$UVM_HOME/dpi/uvm_dpi.cc`, `-Wno-lint -Wno-style` and
  `--timescale 1ns/1ps` (the library has no `` `timescale ``). See USER_GUIDE section 8.
- A full build takes about 2-4 minutes and up to about 3 GB RAM; ccache makes later builds faster.
- `uvm_config_db::set(this, "*", ...)` reaches only the children of `this`; use `""` for the component itself (standard UVM rule, same in every simulator).
- The SystemVerilog differences in sections 2-3 (2-state values, SVA limits) apply inside UVM too.

---

## 6. Not tested

Not covered by this page (may or may not work): UVM register front-door/back-door access
with an adapter and predictor, `uvm_hdl_*` back-door functions, sequence libraries, phase
jumping; assertions with several clocks; `config`/`library` blocks; `nettype`/`interconnect`;
SystemC; gate-level simulation with SDF. If you need one of them, write a small test like the
files in `support_tests/` and run it first.
