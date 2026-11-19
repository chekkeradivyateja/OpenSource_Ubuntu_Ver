# Tool packages (Ubuntu 24.04 LTS, x86-64)

| File | Contents | Source |
|---|---|---|
| `verilator-5.054-ubuntu24.04-x86_64.tar.gz` | Verilator 5.054, prebuilt, without debug binaries | https://github.com/verilator/verilator/tree/v5.054 |
| `uvm-2020.3.1-vlt-656f20d-patched.tar.gz` | Verilator UVM library, commit 656f20d, with two patches (below) | https://github.com/verilator/uvm |
| `surfer_linux_v0.7.0.zip` | Surfer v0.7.0, official release file, unchanged | https://gitlab.com/surfer-project/surfer/-/releases/v0.7.0 |

Check the files with `sha256sum -c SHA256SUMS`.
Licenses are in `../licenses/`.

## Changes from the original sources
- Verilator: the built-in default `VERILATOR_ROOT` in `bin/verilator_bin` and
  the `prefix` in `share/pkgconfig/verilator.pc` are set to
  `/opt/eda/open_ver_flow/verilator-5.054`, where `install.py` installs it.
- UVM, `src/base/uvm_component.svh`:
  `bit clone;` -> `bit clone_flag;` and
  `wrapper.clone = clone;` -> `wrapper.clone_flag = clone;`.

Yosys, z3, lcov and GTKWave are installed from the Ubuntu 24.04 packages (apt).
