Installer notes. The installer is `../install.py`; run it from the repository folder.

What it does:
1. Checks Ubuntu 24.04, x86-64, RAM, free disk, sudo, apt not busy, package checksums.
2. Installs from apt: yosys z3 lcov gtkwave g++ make perl python3 ccache zlib1g-dev liblz4-dev.
3. Unpacks Verilator 5.054, the patched UVM library and Surfer v0.7.0 from `../packages/`
   into /opt/eda/open_ver_flow.
4. Adds a marked block to ~/.bashrc (PATH, VERILATOR_ROOT, UVM_HOME).
5. Self-test: lint, simulation, assertions, coverage, FST, Yosys, versions (UVM with --uvm-test).

The log is written to install.log in the repository folder. Attach it to an Issue if something fails.
