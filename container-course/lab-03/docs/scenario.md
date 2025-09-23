test -f /sys/fs/cgroup/cgroup.controllers && echo "cgroups v2" || echo "cgroups v1"
```{{copy}}

---

## Track A — Using `systemd-run` (recommended)

### A1) Install a load tool
```bash
sudo apt update
sudo apt install -y stress
```{{copy}}

### A2) Create a cgroup and set **memory limit**
Creates a transient cgroup (scope), runs a process, and caps memory.
```bash
sudo systemd-run --unit=lab-mem --scope \
  -p MemoryMax=100M \
  stress --vm 1 --vm-bytes 200M --vm-hang 60
```{{copy}}

**What happens:** process tries 200 MB; cgroup allows 100 MB → OOM kill (signal 9).  
**Verify logs:**
```bash
journalctl -u lab-mem.scope -n 50 --no-pager
```{{copy}}

**See raw cgroup files (paths may vary slightly):**
```bash
systemd-cgls --unit lab-mem.scope
cat /sys/fs/cgroup/system.slice/lab-mem.scope/memory.max
cat /sys/fs/cgroup/system.slice/lab-mem.scope/memory.current
```{{copy}}

---

### A3) Create a cgroup and set **CPU share (relative)**
```bash
sudo systemd-run --unit=lab-cpu --scope \
  -p CPUWeight=200 \
  stress --cpu 1 --timeout 20s
```{{copy}}

- Default weight is **100**. Higher = more share, lower = less.
- Check applied property:
```bash
systemctl show -p CPUWeight lab-cpu.scope
cat /sys/fs/cgroup/system.slice/lab-cpu.scope/cpu.weight
cat /sys/fs/cgroup/system.slice/lab-cpu.scope/cpu.stat
```{{copy}}

---

### A4) (Optional) **Hard CPU cap** (quota) instead of share  
`CPUQuota=` sets a percentage of one CPU.
```bash
sudo systemd-run --unit=lab-cap --scope \
  -p CPUQuota=50% \
  stress --cpu 1 --timeout 20s
```{{copy}}

Verify:
```bash
systemctl show -p CPUQuotaPerSecUSec lab-cap.scope
cat /sys/fs/cgroup/system.slice/lab-cap.scope/cpu.max
```{{copy}}

---

### A5) (Optional) **PIDs limit** (number of processes)
```bash
sudo systemd-run --unit=lab-pids --scope \
  -p TasksMax=10 \
  bash -c 'sleep 30'
```{{copy}}

Verify:
```bash
systemctl show -p TasksMax lab-pids.scope
cat /sys/fs/cgroup/system.slice/lab-pids.scope/pids.max
```{{copy}}

---

### A6) Stop anything left running
```bash
sudo systemctl stop lab-mem.scope lab-cpu.scope lab-cap.scope lab-pids.scope 2>/dev/null || true
```{{copy}}

---

## Track B — Low-level cgroup v2 (learn the internals)

> Note: On systemd distros, direct writes under `/sys/fs/cgroup` may be restricted. These steps usually work with `sudo`. If you get **Permission denied**, prefer **Track A**.

### B1) Create your own cgroup
```bash
sudo mkdir -p /sys/fs/cgroup/labgroup
```{{copy}}

**(If controllers are not enabled at parent, try enabling at root — may be blocked by systemd):**
```bash
# Enable controllers we’ll use (ignore if this errors)
echo "+memory +cpu +pids" | sudo tee -a /sys/fs/cgroup/cgroup.subtree_control
```{{copy}}

### B2) Set limits in that cgroup
- **Memory limit** (strict cap):
```bash
echo 100M | sudo tee /sys/fs/cgroup/labgroup/memory.max
```{{copy}}

- **CPU share** (relative weight, 1–10000; default 100):
```bash
echo 200 | sudo tee /sys/fs/cgroup/labgroup/cpu.weight
```{{copy}}

- **Hard CPU cap** (quota/period): format `max` or `<quota> <period>`
```bash
echo "50000 100000" | sudo tee /sys/fs/cgroup/labgroup/cpu.max   # = 50% of 1 CPU
```{{copy}}

- **PIDs limit** (max processes/threads):
```bash
echo 50 | sudo tee /sys/fs/cgroup/labgroup/pids.max
```{{copy}}

### B3) Run a process and **move it** into the cgroup
Start some workload, grab its PID, then attach:
```bash
stress --vm 1 --vm-bytes 200M --vm-hang 60 & pid=$!
echo $pid | sudo tee /sys/fs/cgroup/labgroup/cgroup.procs
wait $pid || true
```{{copy}}

**Expected:** it gets killed by OOM due to `memory.max=100M`.

### B4) Verify live stats
```bash
cat /sys/fs/cgroup/labgroup/memory.max
cat /sys/fs/cgroup/labgroup/memory.current
cat /sys/fs/cgroup/labgroup/cpu.weight
cat /sys/fs/cgroup/labgroup/cpu.stat
cat /sys/fs/cgroup/labgroup/pids.current
```{{copy}}

### B5) Clean up the cgroup
```bash
sudo rmdir /sys/fs/cgroup/labgroup
```{{copy}}

---

## Quick Reference (v2 keys you actually need)

- **CPU (relative share):** `cpu.weight` (1–10000, default 100)  
- **CPU (hard cap):** `cpu.max` (`max` or `<quota> <period>`; default period 100000 µs)  
- **Memory cap:** `memory.max` (bytes or `max` for unlimited)  
- **Current memory:** `memory.current`  
- **Processes limit:** `pids.max` / current `pids.current`  
- **I/O throttle (advanced):** `io.max` (e.g., `8:0 rbps=1048576 wbps=1048576`)

---

### What you learned
- **Create** a cgroup (scope via systemd or directory via cgroupfs)  
- **Set limits** (memory, CPU share, CPU quota, PIDs)  
- **Attach processes** and **verify** with the live counters/files

If you want, I can add an **I/O throttling mini-lab** (read/write bandwidth cap) in the same style.
