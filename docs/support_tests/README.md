# Support tests

Test files behind `../SV_UVM_SUPPORT.md`. Each file states its expected result in its header
(`// EXPECT: ...`).

| Folder | Contents |
|---|---|
| `differences/` | pairs: `*_unsupported.sv` (rejected or different in Verilator 5.054) and `*_fixed.sv` (the rewrite that works) |
| `supported/` | constructs that work; assertion tests fail on purpose to prove the check runs |
| `uvm/` | one UVM test covering many UVM features |

    ./run_tests.sh          # all SystemVerilog tests (about 2 minutes)
    ./run_tests.sh --uvm    # also the UVM test (about 3 more minutes)
    ./run_tests.sh supported/s04_clocking_block.sv     # one test

Build files go to `build/` (ignored by git). Run in a terminal opened after `install.py`.
