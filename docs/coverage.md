# Coverage with Verilator, verilator_coverage and lcov

## Collect
Build with `--coverage` (line, toggle and user/`cover property` points).
Each simulation run writes `coverage.dat` in the run folder.

## Merge and report as text
    verilator_coverage --write merged.dat test1.dat test2.dat
    verilator_coverage --annotate cov_annot merged.dat

`cov_annot/` holds the source files annotated with hit counts.

## HTML report
    verilator_coverage --write-info coverage.info merged.dat
    genhtml coverage.info --output-directory cov_html

Open `cov_html/index.html` in a browser.

## Limits compared with VCS/Questa/Verdi
- The HTML report (lcov/genhtml) shows line coverage only; toggle and
  user coverage points are not shown as separate metrics.
- There is no combined coverage report (code + functional + assertion)
  and no coverage database such as UCDB or VDB.
- Functional coverage (`covergroup`) support depends on the Verilator
  version; check the manual and release notes for your version.
