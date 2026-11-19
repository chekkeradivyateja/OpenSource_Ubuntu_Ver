# Generic Verilator Makefile. Layout: ../rtl/*.sv  ../tb/*.sv  (this file in sim/)
# Usage: make check | lint | TC1 | regress | covtxt | covhtml | clean
#        add WAVES=1 to dump waves.vcd (testbench needs an `ifdef DUMP_WAVES block)

TOP    ?= tb_top
RTL    ?= $(wildcard ../rtl/*.sv ../rtl/*.v)
TB     ?= $(wildcard ../tb/*.sv)
TESTS  ?= TC1 TC2
WAVES  ?= 0

VFLAGS := --binary --assert --coverage --trace -Wno-fatal --top-module $(TOP)
ifeq ($(WAVES),1)
VFLAGS += -DDUMP_WAVES
endif

.PHONY: check lint build regress covtxt covhtml clean

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
	@for t in $(TESTS); do $(MAKE) --no-print-directory $$t || exit 1; done
	@grep -l -E '%Error|Assertion failed' $(addsuffix .log,$(TESTS)) && echo "REGRESSION FAILED" || echo "REGRESSION PASSED"

covtxt:
	verilator_coverage --write coverage.dat *_cov.dat
	verilator_coverage --annotate cov_annot coverage.dat | tee cov_summary.txt

covhtml: covtxt
	verilator_coverage --write-info coverage.info coverage.dat
	genhtml coverage.info --output-directory cov_html

clean:
	rm -rf obj_dir cov_annot cov_html *.log *.dat coverage.info cov_summary.txt waves.vcd
