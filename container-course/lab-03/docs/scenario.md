Got it 👍 — let’s build a **cgroups hands-on scenario** in the same style as the network namespace lab you liked. This will walk learners through how Linux control groups (cgroups) work, focusing on **CPU and memory limits**.

---

# Hands-On Guide: Linux Control Groups (cgroups)

To understand cgroups practically, we will create a process, limit its CPU and memory usage using cgroups, and observe the effects.

---

## Step 1: Install cgroup Tools (if not already installed)

On Ubuntu/Debian:

````bash
sudo apt update
sudo apt install cgroup-tools -y
```{{exec}}

On CentOS/RHEL:
```bash
sudo yum install libcgroup -y
```{{exec}}

**Explanation:**  
The `cgroup-tools` (or `libcgroup`) package provides commands like `cgcreate`, `cgexec`, and `cgset` that help us manage cgroups easily.

---

## Step 2: Create a cgroup

```bash
sudo cgcreate -g memory,cpu:/labgroup
```{{exec}}

**Explanation:**  
This creates a new cgroup named `labgroup` that can control both **memory** and **CPU** usage. The path `/sys/fs/cgroup/` will now have a `labgroup` directory.

---

## Step 3: Set CPU Limit

```bash
sudo cgset -r cpu.shares=256 labgroup
```{{exec}}

**Explanation:**  
- `cpu.shares` controls the relative CPU allocation.  
- Default is `1024`. Setting it to `256` means the process in this group gets **about 1/4 CPU share** compared to normal processes.

---

## Step 4: Set Memory Limit

```bash
sudo cgset -r memory.limit_in_bytes=100M labgroup
```{{exec}}

**Explanation:**  
This limits any process in the `labgroup` cgroup to **100 MB of RAM**. If it exceeds, the kernel’s OOM (Out-of-Memory) killer will terminate it.

---

## Step 5: Run a Process in the cgroup

Let’s run a memory-hungry program (Python script) under this cgroup.

```bash
sudo cgexec -g memory,cpu:labgroup stress --vm 1 --vm-bytes 200M --vm-hang 60
```{{exec}}

> Install `stress` if not available:
```bash
sudo apt install stress -y   # Debian/Ubuntu
sudo yum install stress -y   # RHEL/CentOS
```{{exec}}

**Explanation:**  
- `stress --vm 1 --vm-bytes 200M` tries to allocate **200 MB memory**.  
- Since our cgroup limit is **100 MB**, the kernel will kill this process.  

### Example Output
```text
stress: info: [2683] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
stress: FAIL: [2683] (415) <-- worker 2684 got signal 9
stress: WARN: [2683] (417) now reaping child worker processes
````

---

## Step 6: Run a CPU Test in the cgroup

````bash
sudo cgexec -g memory,cpu:labgroup stress --cpu 1 --timeout 20s
```{{exec}}

**Explanation:**  
This runs a CPU-intensive process for 20 seconds. Because `cpu.shares=256`, it gets less CPU compared to other processes on the system.

You can observe CPU usage with:

```bash
top
```{{exec}}

---

## Step 7: Inspect cgroup Stats

```bash
cat /sys/fs/cgroup/memory/labgroup/memory.max_usage_in_bytes
cat /sys/fs/cgroup/cpu/labgroup/cpu.shares
```{{exec}}

**Explanation:**  
These files show the **actual maximum memory used** and the **CPU share configuration**.

---

## Step 8: Clean Up

```bash
sudo cgdelete -g memory,cpu:/labgroup
```{{exec}}

**Explanation:**  
Removes the cgroup and frees system resources.

---

## Summary

- **cgroups** let you control how much CPU, memory, and other resources processes can use.  
- You created a `labgroup` cgroup, limited its CPU shares and memory.  
- Running stress tests showed how limits get enforced (OOM kill for memory, throttling for CPU).  

---

👉 Now you’ve learned to **create, configure, and test cgroups in Linux**!  

Would you like me to also prepare a **second cgroup lab** that focuses on **disk I/O limits** (using blkio cgroups), in the same Markdown course style?
````
