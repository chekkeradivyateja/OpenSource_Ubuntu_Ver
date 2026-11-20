# Coverage with Verilator 5.054, verilator_coverage and lcov

Step-by-step commands: [USER_GUIDE.md](USER_GUIDE.md) sections 5 (code coverage) and
6 (functional coverage). The Makefile templates do all of this with `make cov` and `make covhtml`.

## What is collected (build with `--coverage`)
| Type | Source |
|---|---|
| line, branch, expression, toggle | your RTL and testbench code |
| covergroup | `covergroup` / `coverpoint` / `bins` / `cross` (tested) |
| user | `cover property` |

## Steps
    ./obj_dir/Vtb_top +TEST=t1 +verilator+coverage+file+t1.dat      # one file per test
    verilator_coverage --write merged.dat t1.dat t2.dat               # merge
    grep -v verilated_std.sv merged.dat > design.dat                  # drop Verilator's std package
    verilator_coverage --report summary design.dat                    # all types in one table
    verilator_coverage --report hier design.dat                       # per instance / module
    verilator_coverage --annotate annotated design.dat                # sources with hit counts
    verilator_coverage --filter-type covergroup --annotate cg_bins --annotate-points design.dat
    verilator_coverage --write-info coverage.info design.dat
    genhtml coverage.info --output-directory cov_html                 # HTML (line coverage)

For UVM, switch coverage off for the UVM library with a `.vlt` file (USER_GUIDE section 8).

## Limits compared with VCS/Questa/Verdi
- The HTML report (lcov/genhtml) shows line coverage only; use the text report for
  toggle, branch, expression, covergroup and cover-property numbers.
- No coverage database such as UCDB or VDB, and no GUI coverage browser.
- `get_coverage()` works on a whole covergroup only, not on a single coverpoint or cross.
