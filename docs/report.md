# Status Report

This report records what has been checked in the open-source flow and what has not.
Only results that were actually run are listed as tested.

## Tested (Verilator 5.054, one machine, Ubuntu 24.04 LTS x86-64)
- Lint (`--lint-only -Wall`)
- Simulation (`--binary`)
- Immediate and simple concurrent assertions (`--assert`)
- Coverage collection (`--coverage`, `verilator_coverage`)
- VCD waveforms (`--trace`)
- Makefile template (`makefile_templates/Makefile`): tested on 2026-11-19 with
  `examples/counter` (check, lint, TC1, regress, covtxt, covhtml, clean)
- FST waveforms (`--trace-fst`): tested on 2026-11-19; the file decodes with
  `fst2vcd`. (An earlier build with another version failed on a missing
  `include/gtkwave/fastlz.c`; this does not happen with 5.054.)
- UVM: tested on 2026-11-19 with a minimal test (one uvm_test, one objection,
  one message). Library: github.com/verilator/uvm commit 656f20d
  (UVM 2020.3.1) with two patches in `src/base/uvm_component.svh`:
  `bit clone;` -> `bit clone_flag;` and
  `wrapper.clone = clone;` -> `wrapper.clone_flag = clone;`.
  Compile with `--binary --vpi -j 1`: 4 min 30 s, peak RAM 2.9 GB,
  662 MB build folder. Run: under 1 s, UVM_ERROR 0, UVM_FATAL 0.
- 2026-11-20: Makefile templates `sv/` and `uvm/` with `examples/sv_project` and
  `examples/uvm_project`: all targets, including failure detection with injected bugs.
- 2026-11-20: every command in `USER_GUIDE.md`.
- 2026-11-20: `SV_UVM_SUPPORT.md`: 83 SystemVerilog tests and 1 UVM test in `support_tests/`
  (UVM: field macros, sequences, factory override, TLM FIFO, events, register model, report catcher).

## Not working or not tested yet
- Constructs listed in `SV_UVM_SUPPORT.md` sections 2-3 (with tested rewrites) and section 6 (not tested).
- UVM without the two patches: not tested.
- Installer: tested on one Ubuntu 24.04.5 machine; install on a fresh machine not tested yet.

## How to report a problem
Open an Issue on the repository and attach the installer log file.
