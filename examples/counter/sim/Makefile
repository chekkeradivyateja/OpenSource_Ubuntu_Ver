# =============================================================================
#  Simple Verilator Makefile: one RTL folder, one testbench folder, tests TC1, TC2, ...
#  Tested with Verilator 5.054 on Ubuntu 24.04 using examples/counter.
#  Start here:   make help
#  For bigger projects use makefile_templates/sv/Makefile or uvm/Makefile.
# =============================================================================
#  Layout:  <project>/rtl/*.sv   <project>/tb/*.sv   <project>/sim/Makefile (this file)
#  Test TCn runs the simulator with the plusarg +TESTn; the testbench selects the test
#  with $test$plusargs("TEST1"), $test$plusargs("TEST2"), ...
#  WAVES=1 compiles with -DDUMP_WAVES; the testbench needs an `ifdef DUMP_WAVES block
#  that calls $dumpfile("waves.vcd") and $dumpvars (see examples/counter/tb/tb_top.sv).
# =============================================================================

# ============================== EDIT HERE ====================================
# 1. Top testbench module
TOP    ?= tb_top
# 2. Design and testbench files (packages must come before the files that import them)
RTL    ?= $(wildcard ../rtl/*.sv ../rtl/*.v)
TB     ?= $(wildcard ../tb/*.sv)
# 3. Tests run by 'make regress' (TCn -> plusarg +TESTn)
TESTS  ?= TC1 TC2
# =============================================================================
WAVES  ?= 0

VFLAGS := --binary --assert --coverage --trace -Wno-fatal --top-module $(TOP)
ifeq ($(WAVES),1)
VFLAGS += -DDUMP_WAVES
endif

.PHONY: help check lint build regress covtxt covhtml clean

help:
	@echo "Targets:"
	@echo "  make check          show tool versions and the source files found"
	@echo "  make lint           verilator --lint-only -Wall on all files"
	@echo "  make build          compile into obj_dir/"
	@echo "  make TC1            run test 1 (plusarg +TEST1) -> TC1.log, TC1_cov.dat"
	@echo "  make TC1 WAVES=1    same, and write waves.vcd"
	@echo "  make regress        run all tests in TESTS, print REGRESSION PASSED/FAILED"
	@echo "  make covtxt         merged coverage summary -> cov_summary.txt, cov_annot/"
	@echo "  make covhtml        HTML line-coverage report -> cov_html/index.html"
	@echo "  make clean          delete all generated files"
	@echo "Current settings: TOP=$(TOP) TESTS=\"$(TESTS)\""

check:
	@verilator --version
	@command -v verilator_coverage >/dev/null && echo "verilator_coverage: found" || echo "verilator_coverage: MISSING"
	@command -v genhtml >/dev/null && echo "genhtml (lcov): found" || echo "genhtml (lcov): MISSING (needed for covhtml)"
	@echo "RTL files: $(RTL)"
	@echo "TB files:  $(TB)"

lint:
	verilator --lint-only -Wall --timing --top-module $(TOP) $(RTL) $(TB)

build:
	verilator $(VFLAGS) $(RTL) $(TB)

# TCn runs the simulation with plusarg +TESTn and keeps its coverage file
TC%: build
	./obj_dir/V$(TOP) +TEST$* 2>&1 | tee TC$*.log
	mv coverage.dat TC$*_cov.dat

regress:
	@for t in $(TESTS); do $(MAKE) --no-print-directory $$t || { echo "REGRESSION FAILED ($$t)"; exit 1; }; done
	@if grep -l -E '%Error|Assertion failed' $(addsuffix .log,$(TESTS)); \
	  then echo "REGRESSION FAILED"; exit 1; else echo "REGRESSION PASSED"; fi

covtxt:
	verilator_coverage --write coverage.dat *_cov.dat
	verilator_coverage --annotate cov_annot coverage.dat | tee cov_summary.txt

covhtml: covtxt
	verilator_coverage --write-info coverage.info coverage.dat
	genhtml coverage.info --output-directory cov_html

clean:
	rm -rf obj_dir cov_annot cov_html *.log *.dat coverage.info cov_summary.txt waves.vcd
