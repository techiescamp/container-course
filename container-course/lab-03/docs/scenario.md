# Hands-On Guide: Linux Control Groups (cgroups)

In this lab, you’ll learn how **Linux Control Groups (cgroups)** work by creating a group, applying CPU and memory limits, and observing how processes behave under those restrictions.

By the end of this exercise, you’ll understand how cgroups form the foundation for container resource management in systems like Docker and Kubernetes.

---

## Step 1: Install Required Tools

On Ubuntu, install the cgroup utilities and a stress-testing tool:

```bash
sudo apt update
sudo apt install -y cgroup-tools
```{{copy}}  

- **cgroup-tools (libcgroup)** provides commands like `cgcreate`, `cgexec`, and `cgset` for managing cgroups.  
- **stress-ng** is useful for simulating CPU and memory load.  

---

## Step 2: Create a Cgroup  

```bash
sudo cgcreate -g cpu,memory:/labgroup
```{{copy}}  

This creates a new cgroup called **labgroup** with CPU and memory controllers enabled.  
A directory `/sys/fs/cgroup/labgroup/` will now exist to track and control resources.  

---

## Step 3: Apply CPU Limit  

```bash
sudo cgset -r cpu.max="20000 100000" labgroup
```{{copy}}  

- **PERIOD = 100000 µs (100 ms)**  
- **QUOTA = 20000 µs (20 ms)**  

This means processes inside `labgroup` can only run for **20 ms every 100 ms**, which is ~20% of a single CPU core.  

If a process tries to use more, the kernel **throttles** it until the next scheduling window.  

---

## Step 4: Apply Memory Limit  

```bash
sudo cgset -r memory.max=100M labgroup
```{{copy}}  

This restricts processes in `labgroup` to **100 MB of RAM**.  
If memory usage goes beyond this, the kernel’s **OOM (Out-of-Memory) killer** terminates the process.  

Verify the limits:  

```bash
cat /sys/fs/cgroup/labgroup/memory.max
cat /sys/fs/cgroup/labgroup/cpu.max
```{{copy}}  

---

## Step 5: Run a Test Process  

Let’s run a memory-hungry Python script inside the cgroup:  

```bash
sudo cgexec -g cpu,memory:labgroup python3 - <<'PY'
import time
chunks = [bytearray(1024*1024) for _ in range(200)]  # Allocate ~200 MB
time.sleep(20)
PY
```{{copy}}  

- Since we limited memory to **100 MB**, this script (200 MB allocation) should trigger the OOM killer.  
- You’ll likely see:  

```text
Killed
```

---

## Step 6: Observe Memory Usage

Check current memory consumption and events:

```bash
cat /sys/fs/cgroup/labgroup/memory.current
cat /sys/fs/cgroup/labgroup/memory.events
```{{copy}}  

---

## Step 7: Test CPU Throttling  

Run a CPU-intensive process inside the cgroup:  

```bash
sudo cgexec -g cpu,memory:labgroup bash -c 'timeout 10s sh -c "while :; do :; done"'
```{{copy}}  

This infinite loop tries to consume 100% CPU for 10 seconds.  
Because of the CPU limit (`20% of one core`), it will be throttled.  

Check stats:  

```bash
cat /sys/fs/cgroup/labgroup/cpu.stat
```{{copy}}  

Example output:  

```text
usage_usec 3100000
user_usec 3050000
system_usec 50000
nr_periods 100
nr_throttled 80
throttled_usec 8000000
```

* `nr_throttled`: How many times processes were throttled.
* `throttled_usec`: Total time processes spent waiting due to CPU limits.

---

You’ve now learned how to **create a cgroup, apply CPU and memory limits, and monitor their effects**.
This hands-on experiment shows exactly how Linux enforces resource controls—essential knowledge for understanding containers.


