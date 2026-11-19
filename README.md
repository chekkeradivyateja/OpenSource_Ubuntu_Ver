# Open-Source Verification Flow

A free replacement for the paid verification flow (VCS, Questa, Verdi), for training.

## What is covered
- Simulation, lint, assertions: Verilator
- UVM testbenches: Verilator UVM library (patched)
- Code and functional coverage: verilator_coverage, lcov
- Synthesis: Yosys
- Waveforms: Surfer, GTKWave
- Constraint randomization: z3

## Supported system
Ubuntu 24.04 LTS, x86-64.

## Status
| Item | Status |
|---|---|
| Verilator 5.054: lint, simulation, assertions, coverage, VCD | tested on one machine |
| Verilator 5.054: FST waveforms, UVM | not working or not tested yet |
| Installer and tool bundle | in progress |
| Makefile template | not tested yet |

## Folders
- installer/  one-command installer (in progress)
- makefile_templates/  generic Makefile for a Verilator project
- examples/  small demo projects
- docs/  tools, limitations, assertions, coverage, troubleshooting
- licenses/  license files of the tools

## Limits compared with VCS/Questa/Verdi
2-state simulation (no X/Z), no assertion status in waveforms, HTML coverage
shows line coverage only, no combined coverage report or database.
See docs/ for details.

## Problems
Open an Issue and attach the installer log file.
