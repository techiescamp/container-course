# Hands-On Guide: Linux Control Groups (cgroups)

To understand cgroups practically, we will create a process, limit its CPU and memory usage using cgroups, and observe the effects.

---

## Step 1: Install cgroup Tools (if not already installed)

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install cgroup-tools -y && apt install -y stress-ng
```{{copy}}

The `cgroup-tools` (or `libcgroup`) package provides commands like `cgcreate`, `cgexec`, and `cgset` that help us manage cgroups easily.

---

## Step 2: Create a cgroup

```bash
sudo cgcreate -g cpu,memory:/labgroup
```{{copy}}

This creates a new cgroup named `labgroup` that can control both **memory** and **CPU** usage. The path `/sys/fs/cgroup/` will now have a `labgroup` directory.

---

## Step 3: Set CPU Limit

```bash
sudo cgset -r cpu.max="20000 100000" labgroup   # ~20% of one CPU
```{{copy}}

- `cpu.shares` controls the relative CPU allocation.  
- Default is `1024`. Setting it to `256` means the process in this group gets **about 1/4 CPU share** compared to normal processes.

---

## Step 4: Set Memory Limit

```bash
sudo cgset -r memory.max=100M labgroup
```{{copy}}

This limits any process in the `labgroup` cgroup to **100 MB of RAM**. If it exceeds, the kernel’s OOM (Out-of-Memory) killer will terminate it.

Verify the values setup for both

```bash
cat /sys/fs/cgroup/labgroup/memory.max
cat /sys/fs/cgroup/labgroup/cpu.max
```{{copy}}

---

## Step 5: Run a test process inside the cgroup 

Let’s run a memory-hungry program (Python script) under this cgroup.

```bash
sudo cgexec -g cpu,memory:labgroup python3 - <<'PY'
import time
chunks = [bytearray(1024*1024) for _ in range(200)]  # ~200 MB
time.sleep(20)
PY
```{{copy}}

Runs a Python script inside the labgroup cgroup. It tries to allocate ~200 MB. If your memory.max is 100M, this should hit the memory limit and get OOM-killed.

If it hits the limit quickly, you may see:

```bash
Killed
```

## Watch the effect
```bash
cat /sys/fs/cgroup/labgroup/memory.current
cat /sys/fs/cgroup/labgroup/memory.events
```{{copy}}

## Test the CPU throttling

```bash
sudo cgexec -g cpu,memory:labgroup bash -c 'timeout 10s sh -c "while :; do :; done"'
```{{copy}}

## Watch the effect
```bash
cat /sys/fs/cgroup/labgroup/cpu.stat
```{{copy}}

Runs a tight loop for 10s inside the cgroup. With cpu.max="20000 100000" (20ms every 100ms → ~20% CPU of one core), the loop should get throttled.

Example output:

```bash
usage_usec 3100000
user_usec 3050000
system_usec 50000
nr_periods 100
nr_throttled 80
throttled_usec 8000000
```

---

 Now you’ve learned to **create, configure, and test cgroups in Linux**

