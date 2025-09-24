# Hands-On Guide: Linux Network Namespaces

To understand Linux network namespaces in a hands-on way, we will create namespaces, connect them using virtual Ethernet (veth) pairs, assign IPs, and test connectivity.

---

## Step 1: Create Two Network Namespaces

```bash
sudo ip netns add ns1
sudo ip netns add ns2
```{{copy}}

List the created Namespaces

```bash
ip netns list
```{{copy}}

### Example Output
```text
ns2
ns1
```

A **network namespace** is like a separate networking world inside your host. Each namespace has its own interfaces, routing table, and ARP table. Here we created `ns1` and `ns2`.

---

## Step 2: Create a Virtual Ethernet (veth) Pair

```bash
sudo ip link add veth1 type veth peer name veth2
```{{copy}}

Verify both interfaces are created

```bash
ip link show veth1
ip link show veth2
```{{copy}}

A **veth pair** works like a cable. Anything sent into one end comes out of the other. We will attach each end to a different namespace.

---

## Step 3: Assign veth Interfaces to Namespaces

```bash
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2
```{{copy}}

```bash
sudo ip netns exec ns1 ip link
sudo ip netns exec ns2 ip link
```{{copy}}

### Example Output
```text
3: veth1@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
3: veth2@if5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
```

Now, `veth1` is inside `ns1` and `veth2` is inside `ns2`. Each namespace has its own "network card."

---

## Step 4: Assign IP Addresses

```bash
sudo ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth1
sudo ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth2
```{{copy}}

Assigning IP addresses lets the namespaces talk over Layer 3 (IP). Both are placed in the same subnet `10.0.0.0/24`.

---

## Step 5: Bring Interfaces Up

```bash
sudo ip netns exec ns1 ip link set lo up
sudo ip netns exec ns1 ip link set veth1 up

sudo ip netns exec ns2 ip link set lo up
sudo ip netns exec ns2 ip link set veth2 up
```{{copy}}

Interfaces are down by default. Bringing them up is necessary for communication. Loopback (`lo`) is also enabled because many tools expect it.

---

## Step 6: Verify Routes

```bash
sudo ip netns exec ns1 ip route
sudo ip netns exec ns2 ip route
```{{copy}}

### Example Output
```text
10.0.0.0/24 dev veth1 proto kernel scope link src 10.0.0.1
10.0.0.0/24 dev veth2 proto kernel scope link src 10.0.0.2
```

The kernel automatically installs a route for each subnet when IPs are assigned. This shows both namespaces know how to reach each other.

---

## Step 7: Test Connectivity

```bash
sudo ip netns exec ns1 ping -c 3 10.0.0.2
```{{copy}}

### Example Output
```text
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.072 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.043 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=64 time=0.046 ms

--- 10.0.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2045ms
```

This confirms connectivity between the namespaces. The first ping also performs ARP resolution to learn the MAC address of the peer.

---

## Step 8 (Optional): Check ARP Table

```bash
sudo ip netns exec ns1 ip neigh
```{{copy}}

### Example Output
```text
10.0.0.2 dev veth1 lladdr 9a:02:88:4c:2f:3a REACHABLE
```

The ARP table shows how `10.0.0.2` is mapped to its MAC address over `veth1`.

---

**You have successfully created and managed Linux network namespaces, connected them with veth pairs, assigned IPs, and tested connectivity!**

---
