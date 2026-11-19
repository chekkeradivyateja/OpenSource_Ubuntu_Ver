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
Ubuntu 24.04 LTS (any 24.04.x), x86-64. 8 GB RAM recommended (4 GB minimum), 3 GB free disk.
Ubuntu 22.04 is not supported (the tools need glibc 2.38 or newer).

## Install
    git clone https://github.com/chekkeradivyateja/OpenSource_Ubuntu_Ver.git
    cd OpenSource_Ubuntu_Ver
    python3 install.py

It asks for your sudo password once, installs into /opt/eda/open_ver_flow,
and ends with a PASS/FAIL self-test. Open a new terminal afterwards.
Options: `--check` (check only), `--uvm-test` (add a UVM test), `--uninstall`.

## Status
| Item | Status |
|---|---|
| Verilator 5.054: lint, simulation, assertions, coverage, VCD | tested on one machine |
| Verilator 5.054: FST waveforms, UVM | tested on 2026-11-19 with Verilator 5.054, one machine (minimal UVM test only) |
| Installer (install.py) | --check, unpack, self-test, second run and --uninstall tested on 2026-11-19 on one machine with apt/sudo steps skipped; full install on a fresh Ubuntu 24.04 not tested yet |
| Makefile template | tested on 2026-11-19 with Verilator 5.054, one machine |

## Folders
- install.py  one-command installer (Python standard library only)
- installer/  installer notes
- packages/  prebuilt Verilator 5.054, patched UVM library, Surfer v0.7.0
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
