# Assertions with Verilator

Assertions are checked only when the design is built with `--assert`.

## What to expect
- Immediate assertions (`assert (expr) else $error(...)`) are supported.
- Concurrent assertions on a clock are supported for common forms:
  `assert property (@(posedge clk) disable iff (rst) a |-> b);`,
  `|=>`, fixed delays `##n`, and `$rose`, `$fell`, `$stable`, `$past`.
- Complex sequence operators may be unsupported or partly supported,
  depending on the Verilator version. Check the Verilator manual and
  release notes for your version, and keep properties simple.
- `cover property` results go into the coverage file when built with
  `--coverage`.

## Limits compared with VCS/Questa/Verdi
- Simulation is 2-state: X and Z are not modelled, so assertions that
  rely on detecting X (for example `$isunknown`) do not behave as in a
  4-state simulator.
- Assertion pass/fail status is not shown in the waveform viewer.
- There is no assertion debug view or assertion database; failures are
  reported as messages in the simulation log.

## Tip
Search the simulation log for `Assertion failed` or `%Error` to find failures.
