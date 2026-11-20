# Assertions with Verilator 5.054

Assertions are checked only when the design is built with `--assert`.
Step-by-step commands: [USER_GUIDE.md](USER_GUIDE.md) section 4. Example: `examples/sv_project/sva/alu_sva.sv`.

## Tested and working (Verilator 5.054)
- Immediate assertions: `assert (expr) else $error(...)`.
- Concurrent assertions on a clock with `disable iff`.
- Implication `|->` and `|=>`, delays `##n` and `##[m:n]`.
- `$rose`, `$fell`, `$stable`, `$changed`, `$past`.
- Named `sequence` and `property`.
- `cover property` (reported as "user" coverage when built with `--coverage`).
- `bind` to attach an assertion module to a design without changing the RTL.

Other sequence operators were not tested; if Verilator reports `%Error-UNSUPPORTED`,
rewrite the property in simpler steps.

## Behaviour on failure
- The message looks like
  `[55000] %Error: alu_sva.sv:15: Assertion failed in tb_top.dut.u_alu_sva.a_valid_latency: ...`
- The simulation stops at the first failure with exit code 1 and does not write coverage.
- `+verilator+error+limit+<n>` keeps it running; the exit code is then 0, so search
  the log for `%Error`.

## Limits compared with VCS/Questa/Verdi
- Simulation is 2-state: X and Z are not modelled, so assertions that rely on
  detecting X (for example `$isunknown`) do not behave as in a 4-state simulator.
- Assertion pass/fail status is not shown in the waveform viewer.
- There is no assertion debug view or assertion database; failures are reported
  as messages in the simulation log.
