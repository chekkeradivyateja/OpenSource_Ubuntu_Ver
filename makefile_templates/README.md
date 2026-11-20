# Makefile templates

| Template | Use it for | Tested with |
|---|---|---|
| [sv/Makefile](sv/Makefile) | SystemVerilog testbench: RTL, SVA (bind), covergroups, constrained random | `examples/sv_project` |
| [uvm/Makefile](uvm/Makefile) | UVM testbench with the installed UVM library (`$UVM_HOME`) | `examples/uvm_project` |
| [Makefile](Makefile) | smallest flow: one RTL folder, one testbench, tests selected by `+TESTn` | `examples/counter` |

How to use one:
1. In your project create `rtl/`, `tb/`, `sim/` (and `sva/` if you have assertions).
2. Copy the template into `sim/`.
3. Edit the block marked `EDIT HERE` at the top (top module names, folders, file order, tests).
4. Run `make help`, then for example `make lint`, `make regress`, `make cov`, `make covhtml`.

All targets are explained in `docs/USER_GUIDE.md` section 10.
