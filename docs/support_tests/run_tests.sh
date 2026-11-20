#!/bin/bash
# Re-runs every test in this folder and checks the result written in its header.
# Usage:  ./run_tests.sh              all SystemVerilog tests (about 2 minutes)
#         ./run_tests.sh --uvm        also the UVM test (about 3 more minutes)
#         ./run_tests.sh file.sv ...  only the given files
# Header lines in each test:
#   // EXPECT: error <text>     compile must fail and the log must contain <text>
#   // EXPECT: warning <text>   compile log must contain <text>
#   // EXPECT: output <text>    simulation output must contain <text>
#   // EXPECT: nooutput <text>  simulation output must NOT contain <text>
#   // BUILD: <options>         extra Verilator options      // RUN: <plusargs>
#   // EXTRA: <file>            extra C/C++ file             // UVM   compile with the UVM library
cd "$(dirname "$0")" || exit 1
HERE=$(pwd)
if [ "$1" = "--uvm" ]; then shift; FILES="differences/*.sv supported/*.sv uvm/*.sv"; fi
FILES=${*:-${FILES:-differences/*.sv supported/*.sv}}
pass=0; fail=0
for f in $FILES; do
  n=$(basename "$f" .sv); b=$HERE/build/$n; rm -rf "$b"; mkdir -p "$b"; cp "$f" "$b/"
  src=$HERE/$f
  hdr() { sed -n "s|^// $1: \{0,1\}||p" "$src"; }
  extra=$(hdr EXTRA); bopts=$(hdr BUILD); ropts=$(hdr RUN)
  [ -n "$extra" ] && cp "$(dirname "$src")/$extra" "$b/"
  top=t; uvm=""
  if grep -q '^// UVM' "$f"; then
    top=tb; uvm="--vpi --timescale 1ns/1ps -j 2 +incdir+$UVM_HOME $UVM_HOME/uvm_pkg.sv"
  fi
  ( cd "$b"
    verilator --binary --assert -Wno-fatal -Wno-lint -Wno-style $bopts --top-module $top \
      $uvm $n.sv $extra ${uvm:+$UVM_HOME/dpi/uvm_dpi.cc} > build.log 2>&1
    echo $? > build.rc
    if [ "$(cat build.rc)" = 0 ]; then
      timeout 120 ./obj_dir/V$top +verilator+error+limit+20 $ropts > run.log 2>&1
    else : > run.log; fi )
  ok=1; why=""
  while IFS= read -r e; do
    kind=${e%% *}; text=${e#* }
    case $kind in
      error)    [ "$(cat $b/build.rc)" != 0 ] && grep -qF -- "$text" $b/build.log || { ok=0; why="expected compile error: $text"; } ;;
      warning)  grep -qF -- "$text" $b/build.log || { ok=0; why="expected warning: $text"; } ;;
      output)   grep -qF -- "$text" $b/run.log || { ok=0; why="expected output: $text"; } ;;
      nooutput) ! grep -qF -- "$text" $b/run.log || { ok=0; why="unexpected output: $text"; } ;;
    esac
  done < <(hdr EXPECT)
  if [ $ok = 1 ]; then pass=$((pass+1)); printf "PASS  %s\n" "$f"
  else fail=$((fail+1)); printf "FAIL  %s  (%s; see build/%s/)\n" "$f" "$why" "$n"; fi
done
echo "$pass passed, $fail failed"
[ $fail = 0 ]
