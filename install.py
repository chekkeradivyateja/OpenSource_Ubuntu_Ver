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


def ask(question):
    """Ask on the terminal and log the question with the answer. No terminal input (EOF) means "n"."""
    try:
        answer = input(question).strip().lower()
        shown = answer or "(Enter)"
    except EOFError:
        answer, shown = "n", "(no input: n)"
    with open(LOG, "a") as f:
        f.write(f"{question}{shown}\n")
    return answer


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
def os_release():
    return {k: v.strip('"') for k, v in (l.rstrip().split("=", 1) for l in open("/etc/os-release") if "=" in l)}


def ubuntu_version():
    return os_release().get("VERSION", "?")


def check():
    """Print one line per check: status, item, what was found, what is needed, the fix."""
    rows = []  # (status, item, found, required, fix)
    def add(ok, item, found, required, fix, warn=False):
        rows.append(("PASS" if ok else "WARN" if warn else "FAIL", item, found, required, "" if ok else fix))

    osr = os_release()
    add(osr.get("ID") == "ubuntu" and osr.get("VERSION_ID", "").startswith("24.04"),
        "Ubuntu", osr.get("PRETTY_NAME", "?"), "Ubuntu 24.04.x LTS",
        "upgrade to Ubuntu 24.04 LTS (see 'How to fix' below)")
    add(platform.machine() == "x86_64", "CPU", platform.machine(), "x86_64",
        "use a 64-bit Intel/AMD machine or VM")
    add(sys.version_info >= (3, 12), "Python", platform.python_version(), "3.12 or newer",
        "Ubuntu 24.04 comes with Python 3.12; upgrading Ubuntu fixes this")
    ram = int(next(l.split()[1] for l in open("/proc/meminfo") if l.startswith("MemTotal"))) / 2**20
    add(ram >= 7.5, "RAM", f"{ram:.1f} GB", "8 GB recommended, 4 GB minimum",
        "add RAM or give the VM more memory (UVM compile needs about 3 GB)", warn=ram >= 3.5)
    base = next(p for p in [DEST, *DEST.parents] if p.exists())
    free = shutil.disk_usage(base).free / 2**30
    add(free >= 3, "Free disk", f"{free:.1f} GB on {base}", "3 GB", "free disk space on " + str(base))
    add(os.geteuid() != 0, "User", getpass.getuser(), "normal user (not sudo/root)",
        "run 'python3 install.py' without sudo")
    add(bool(shutil.which("sudo")), "sudo", shutil.which("sudo") or "not found",
        "sudo command (your password is checked when installing)",
        "ask your administrator to install sudo and give you sudo rights")
    busy = (run(["pgrep", "-x", "apt|apt-get|dpkg"])[0] == 0
            or run(["pgrep", "-f", "/usr/bin/unattended-upgrade( |$)"])[0] == 0)
    add(not busy, "apt", "busy (updates running)" if busy else "idle", "idle",
        "wait a few minutes for Ubuntu updates to finish, then run again")
    for name, digest in (sums().items() if (PKG / "SHA256SUMS").exists() else [("SHA256SUMS", "")]):
        found = "missing" if not (PKG / name).exists() else "OK" if sha256(PKG / name) == digest else "checksum mismatch"
        add(found == "OK", f"packages/{name}", found, "present, checksum OK", "clone the repository again")

    versions = {a: apt_version(a) for a in APT}
    MISSING_APT[:] = [a for a, v in versions.items() if not v]
    for a, v in versions.items():
        rows.append(("PASS" if v else "TODO", f"apt {a}", v or "not installed", "installed",
                     "" if v else "will be installed (you will be asked)"))
    if MISSING_APT:
        online = internet()
        add(online, "Internet", "reachable" if online else "no connection to archive.ubuntu.com",
            "needed to install missing apt packages", "connect to the internet, or install them manually")
    other = shutil.which("verilator")
    if other and not other.startswith(str(DEST)):
        # run it without our VERILATOR_ROOT, which belongs to the new install, not to this one
        env = {k: v for k, v in os.environ.items() if k != "VERILATOR_ROOT"}
        v = (run([other, "--version"], env=env)[1].strip().splitlines() or ["unknown version"])[0]
        rows.append(("INFO", "Other Verilator", f"{v} at {other}", None,
                     "it is kept; the new 5.054 comes first in PATH in new terminals"))

    for st, item, found, req, fix in rows:
        if req is None:
            log(f"{st:5} {item}: found {found}. Note: {fix}")
        else:
            log(f"{st:5} {item}: found {found}; required {req}" + (f". Fix: {fix}" if fix else ""))
    fails = sum(r[0] == "FAIL" for r in rows)
    log("PASS  all checks" if not fails else f"{fails} check(s) failed; nothing was changed.")
    UPGRADE[:] = [1] if rows[0][0] == "FAIL" and osr.get("ID") == "ubuntu" else []
    if UPGRADE:
        log("\nHow to fix: upgrade this machine to Ubuntu 24.04 LTS. The packaged tools need it\n"
            "(glibc 2.38+, Python 3.12); installing only a newer Python does not help.")
        log("Commands:\n  " + "\n  ".join(" ".join(c) for c in upgrade_steps()))
        log("Or install Ubuntu 24.04 LTS fresh: https://ubuntu.com/download/desktop")
    return not fails


MISSING_APT = []
UPGRADE = []  # non-empty when the Ubuntu release must be upgraded
RELEASE_CFG = Path("/etc/update-manager/release-upgrades")


def upgrade_steps():
    """Commands that upgrade Ubuntu to the next LTS release (22.04 -> 24.04)."""
    steps = [["sudo", "apt-get", "update"], ["sudo", "apt-get", "full-upgrade", "-y"]]
    if not shutil.which("do-release-upgrade"):
        steps.append(["sudo", "apt-get", "install", "-y", "update-manager-core"])
    if RELEASE_CFG.exists() and "Prompt=lts" not in RELEASE_CFG.read_text():
        steps.append(["sudo", "sed", "-i", "s/^Prompt=.*/Prompt=lts/", str(RELEASE_CFG)])
    return steps + [["sudo", "do-release-upgrade"]]


def offer_upgrade():
    """Ask the user, then run the upgrade commands one by one (default: No)."""
    log("\nThe installer can run these commands for you now. It takes 30-60 minutes, needs\n"
        "internet and a reboot. BACK UP YOUR FILES FIRST. On a shared/lab machine, ask\n"
        "your administrator before upgrading.")
    answer = ask("Upgrade Ubuntu to 24.04 now? [y/N] ")
    if answer not in ("y", "yes"):
        log("Not upgraded. Run the commands above yourself, reboot, then run install.py again.")
        return
    for cmd in upgrade_steps():
        log("$ " + " ".join(cmd))
        if cmd[-1] == "do-release-upgrade" and Path("/var/run/reboot-required").exists():
            log("A reboot is needed first. Run 'sudo reboot', then run install.py again to continue.")
            return
        code = subprocess.run(cmd).returncode  # interactive: the user answers the upgrade questions
        if code != 0:
            log(f"FAIL  '{' '.join(cmd)}' exited with {code}. Fix the problem shown above, then run install.py again.")
            return
    now = ubuntu_version()
    if now.startswith("24.04"):
        log(f"Upgrade finished (now Ubuntu {now}). Reboot if asked, then run: python3 install.py")
    else:
        log(f"Ubuntu is still {now}: the upgrade did not run. Read the messages from\n"
            "do-release-upgrade above, fix the problem, then run install.py again.")


def apt_version(pkg):
    code, out = run(["dpkg-query", "-W", "-f=${Status} ${Version}", pkg])
    return out.split()[-1] if code == 0 and out.startswith("install ok installed") else ""


def internet():
    import socket
    try:
        socket.create_connection(("archive.ubuntu.com", 80), timeout=5).close()
        return True
    except OSError:
        return False


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
    log("== sudo (asks for your password)")
    if subprocess.run(["sudo", "-v"]).returncode != 0:
        sys.exit(f"FAIL  sudo did not work for {getpass.getuser()}. Fix: ask your administrator for sudo rights, "
                 "or check your password.")
    if MISSING_APT:
        cmd = ["sudo", "apt-get", "install", "-y", *MISSING_APT]
        log(f"== {len(MISSING_APT)} apt package(s) missing: {' '.join(MISSING_APT)}")
        answer = ask("Install them now? [Y/n] ")
        if answer not in ("", "y", "yes"):
            sys.exit(f"Stopped. Install them yourself, then run again:\n  sudo apt-get update && {' '.join(cmd)}")
        for c in (["sudo", "apt-get", "update"], cmd):
            if run(c)[0] != 0:
                sys.exit(f"FAIL  {' '.join(c)} failed; see {LOG}")
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
        if UPGRADE and not a.check:
            offer_upgrade()
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
