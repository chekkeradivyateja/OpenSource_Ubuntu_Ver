---
name: Problem report
about: The installer, a Makefile target or a tool does not work
title: "[problem] "
labels: bug
---

**What did you run?** (the exact command)

**What happened?** (paste the last lines of the output)

**What did you expect?**

**Your machine** (paste the output of these commands)

    lsb_release -d
    uname -m
    free -h | head -2
    verilator --version
    echo $UVM_HOME

**Log file:** attach `install.log` (installer problems) or the log of the failing command
(for example `sim/logs/<test>.log`).
