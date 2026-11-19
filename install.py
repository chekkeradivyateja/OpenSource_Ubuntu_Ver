#!/usr/bin/env python3
"""Install the open-source verification flow on Ubuntu 24.04 LTS (x86-64).

Usage: python3 install.py [--check | --uninstall | --uvm-test]
  (no option)  check, install, self-test
  --check      only check the machine and the packages; changes nothing
  --uvm-test   also compile and run a small UVM test (about 4 min, 3 GB RAM)
  --uninstall  remove the installed tools and the ~/.bashrc block
"""
import argparse, getpass, grp, hashlib, os, platform, shutil, subprocess, sys
import tarfile, tempfile, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PKG = ROOT / "packages"
LOG = ROOT / "install.log"
DEST = Path("/opt/eda/open_ver_flow")
VERILATOR = DEST / "verilator-5.054"
UVM = DEST / "uvm-2020.3.1-vlt-656f20d-patched"
SURFER = DEST / "surfer-0.7.0"
ARCHIVES = {  # archive -> folder it creates
    "verilator-5.054-ubuntu24.04-x86_64.tar.gz": VERILATOR,
    "uvm-2020.3.1-vlt-656f20d-patched.tar.gz": UVM,
    "surfer_linux_v0.7.0.zip": SURFER,
}
APT = ["yosys", "z3", "lcov", "gtkwave", "g++", "make", "perl", "python3",
       "ccache", "zlib1g-dev", "liblz4-dev"]
BASHRC = Path.home() / ".bashrc"
BEGIN, END = "# >>> open_ver_flow >>>", "# <<< open_ver_flow <<<"
ENV = {
    "VERILATOR_ROOT": f"{VERILATOR}/share/verilator",
    "UVM_HOME": f"{UVM}/src",
    "PATH": f"{VERILATOR}/bin:{SURFER}:" + os.environ.get("PATH", ""),
}
UVM_TB = """import uvm_pkg::*;
`include "uvm_macros.svh"
class smoke_test extends uvm_test;
  `uvm_component_utils(smoke_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this); #10;
    `uvm_info("SMOKE", "UVM smoke test running", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
module tb; initial run_test("smoke_test"); endmodule
"""


def log(msg=""):
    print(msg, flush=True)
    with open(LOG, "a") as f:
        f.write(msg + "\n")


def run(cmd, cwd=None, env=None, timeout=None):
    """Run a command, copy its output to the log, return (exit code, output)."""
    try:
        p = subprocess.run(cmd, cwd=cwd, env=env, timeout=timeout, text=True,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        out, code = p.stdout, p.returncode
    except (OSError, subprocess.TimeoutExpired) as e:
        out, code = str(e), 1
    with open(LOG, "a") as f:
        f.write(f"$ {' '.join(map(str, cmd))}\n{out}\n[exit {code}]\n")
    return code, out


# ---------------------------------------------------------------- checks
def check():
    fails, warns = [], []
    osr = dict(l.rstrip().split("=", 1) for l in open("/etc/os-release") if "=" in l)
    if osr.get("ID") != "ubuntu" or not osr.get("VERSION_ID", "").strip('"').startswith("24.04"):
        fails.append(f"Ubuntu 24.04 required, your system is {osr.get('PRETTY_NAME', '?').strip(chr(34))}. "
                     "Fix: use Ubuntu 24.04 LTS.")
    if platform.machine() != "x86_64":
        fails.append(f"x86-64 required, found {platform.machine()}. Fix: use a 64-bit Intel/AMD machine.")
    ram = int(next(l.split()[1] for l in open("/proc/meminfo") if l.startswith("MemTotal"))) / 2**20
    if ram < 3.5:
        fails.append(f"RAM {ram:.1f} GB, at least 4 GB required. Fix: add RAM or give the VM more memory.")
    elif ram < 7.5:
        warns.append(f"RAM {ram:.1f} GB; 8 GB recommended (UVM compile needs about 3 GB).")
    base = next(p for p in [DEST, *DEST.parents] if p.exists())
    free = shutil.disk_usage(base).free / 2**30
    if free < 3:
        fails.append(f"Free disk {free:.1f} GB on {base}, at least 3 GB required. Fix: free disk space.")
    if os.geteuid() == 0:
        fails.append("Do not run with sudo. Fix: run 'python3 install.py' as your normal user.")
    if not shutil.which("sudo"):
        fails.append("sudo not found. Fix: ask your administrator to add your user to the sudo group.")
    if (run(["pgrep", "-x", "apt|apt-get|dpkg"])[0] == 0
            or run(["pgrep", "-f", "/usr/bin/unattended-upgrade( |$)"])[0] == 0):
        fails.append("apt/dpkg is busy (updates running). Fix: wait a few minutes and run again.")
    for name, line in (sums().items() if (PKG / "SHA256SUMS").exists() else [("SHA256SUMS", "")]):
        if not (PKG / name).exists():
            fails.append(f"Missing packages/{name}. Fix: clone the repository again.")
        elif sha256(PKG / name) != line:
            fails.append(f"Checksum mismatch for packages/{name}. Fix: clone the repository again.")
    for w in warns:
        log(f"WARN  {w}")
    for f in fails:
        log(f"FAIL  {f}")
    log("PASS  all checks" if not fails else f"{len(fails)} check(s) failed; nothing was changed.")
    return not fails


def sums():
    return {l.split()[1]: l.split()[0] for l in open(PKG / "SHA256SUMS") if l.strip()}


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------- install
def install():
    log("== apt packages (asks for your sudo password)")
    for cmd in (["sudo", "apt-get", "update"], ["sudo", "apt-get", "install", "-y", *APT]):
        if run(cmd)[0] != 0:
            sys.exit(f"FAIL  {' '.join(cmd)} failed; see {LOG}")
    user, group = getpass.getuser(), grp.getgrgid(os.getgid()).gr_name
    if run(["sudo", "install", "-d", "-o", user, "-g", group, str(DEST)])[0] != 0:
        sys.exit(f"FAIL  could not create {DEST}; see {LOG}")
    for name, folder in ARCHIVES.items():
        marker, digest = folder / ".installed", sums()[name]
        if marker.exists() and marker.read_text() == digest:
            log(f"==  {folder.name}: already installed")
            continue
        log(f"== unpacking {name}")
        shutil.rmtree(folder, ignore_errors=True)
        if name.endswith(".zip"):
            with zipfile.ZipFile(PKG / name) as z:
                z.extractall(folder)
            for exe in folder.iterdir():
                exe.chmod(0o755)
        else:
            with tarfile.open(PKG / name) as t:
                t.extractall(DEST, filter="data")
        marker.write_text(digest)
    block = "\n".join([BEGIN, f"export VERILATOR_ROOT={ENV['VERILATOR_ROOT']}",
                       f"export UVM_HOME={ENV['UVM_HOME']}",
                       f"export PATH={VERILATOR}/bin:{SURFER}:$PATH", END])
    BASHRC.write_text(strip_block(BASHRC.read_text() if BASHRC.exists() else "") + "\n" + block + "\n")
    log(f"== environment written to {BASHRC} (open a new terminal to use it)")


def strip_block(text):
    if BEGIN in text and END in text:
        text = text[:text.index(BEGIN)].rstrip("\n") + text[text.index(END) + len(END):]
    return text.rstrip("\n") + "\n"


# ---------------------------------------------------------------- self-test
def selftest(uvm):
    env = {**os.environ, **ENV}
    tmp = Path(tempfile.mkdtemp(prefix="open_ver_flow_selftest_"))
    shutil.copytree(ROOT / "examples" / "counter", tmp / "counter")
    sim, rtl = tmp / "counter" / "sim", ["../rtl/counter.sv", "../tb/tb_top.sv"]
    tests = [
        ("Verilator lint", ["make", "lint"], sim, None),
        ("Verilator simulation + assertions", ["make", "regress"], sim, "REGRESSION PASSED"),
        ("Coverage (verilator_coverage + lcov)", ["make", "covhtml"], sim, "lines"),
        ("FST waveform", ["verilator", "--binary", "--trace-fst", "-DDUMP_WAVES", "--Mdir", "obj_fst",
                          "--top-module", "tb_top", *rtl], sim, None),
        ("FST waveform run", ["./obj_fst/Vtb_top", "+TEST1"], sim, "PASS"),
        ("Yosys synthesis", ["yosys", "-p", "read_verilog -sv ../rtl/counter.sv; synth -top counter; stat"],
         sim, "Number of cells"),
    ]
    if uvm:
        (tmp / "uvm").mkdir()
        (tmp / "uvm" / "tb.sv").write_text(UVM_TB)
        u = ENV["UVM_HOME"]
        tests += [
            ("UVM compile", ["verilator", "--binary", "--vpi", "-j", "1", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                             "--top-module", "tb", f"+incdir+{u}", f"{u}/uvm_pkg.sv", "tb.sv",
                             f"{u}/dpi/uvm_dpi.cc"], tmp / "uvm", None),
            ("UVM run", ["./obj_dir/Vtb", "+UVM_TESTNAME=smoke_test"], tmp / "uvm", "UVM_FATAL :    0"),
        ]
    log("== self-test")
    ok = True
    for name, cmd, cwd, expect in tests:
        code, out = run(cmd, cwd=cwd, env=env, timeout=1800)
        good = code == 0 and (expect is None or expect in out)
        ok &= good
        log(f"{'PASS' if good else 'FAIL'}  {name}")
    log("== versions")
    for cmd in (["verilator", "--version"], ["yosys", "-V"], ["z3", "--version"], ["lcov", "--version"],
                ["gtkwave", "--version"], ["surfer", "--version"]):
        code, out = run(cmd, env=env)
        line = next((l for l in out.splitlines() if l.strip()), "")
        log(f"{'PASS' if code == 0 else 'FAIL'}  {cmd[0]}: {line.strip()}")
        ok &= code == 0
    if ok:
        shutil.rmtree(tmp)
    else:
        log(f"Self-test files kept in {tmp}")
    return ok


def uninstall():
    for folder in ARCHIVES.values():
        shutil.rmtree(folder, ignore_errors=True)
    if DEST.exists() and not any(DEST.iterdir()):
        DEST.rmdir()
    if BASHRC.exists():
        BASHRC.write_text(strip_block(BASHRC.read_text()))
    log(f"Removed {DEST} contents and the ~/.bashrc block. apt packages were kept.")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--check", action="store_true")
    g.add_argument("--uninstall", action="store_true")
    g.add_argument("--uvm-test", action="store_true")
    a = ap.parse_args()
    LOG.write_text("")
    if a.uninstall:
        return uninstall()
    log("== checks")
    if not check():
        sys.exit(1)
    if a.check:
        return
    install()
    if selftest(a.uvm_test):
        log("ALL PASSED. Open a new terminal, then try: cd examples/counter/sim && make regress")
    else:
        sys.exit(f"Some tests FAILED. Please open an Issue and attach {LOG}")


if __name__ == "__main__":
    main()
