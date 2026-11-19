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

## Not working or not tested yet
- FST waveforms (`--trace-fst`): an earlier build failed on a missing
  `include/gtkwave/fastlz.c`; not re-tested with 5.054.
- UVM with the Verilator UVM library: not tested yet.
- Installer and tool bundle: in progress.

## How to report a problem
Open an Issue on the repository and attach the installer log file.
