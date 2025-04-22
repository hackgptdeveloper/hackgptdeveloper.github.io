---
title: "Rotating IP addresses using Squid and Docker"
tags:
  - Rotating IP
---

Great — here's a **low-level, reproducible setup** for rotating IPs using **Docker** and **Squid proxy**. This is particularly useful for scraping, automation, or anonymization.

We'll cover:

1. ✅ Architecture Overview  
2. ⚙️ Set Up Squid in Docker  
3. 🧠 IP Binding: Rotating Different Source IPs  
4. 🔄 Proxy Rotation Strategy  
5. 🧪 Testing the Setup

---

## ✅ 1. Architecture Overview

You’ll set up **Squid as a forward proxy**, bind it to **multiple source IP addresses (eth0:0, eth0:1, …)** on the host, then use **multiple containers or tools (like `proxychains`, curl, or requests)** to send traffic through Squid, rotating outbound IPs.

```
Client App → Docker (Squid Proxy) → Outbound Interface [Multiple Source IPs] → Internet
```

---

## ⚙️ 2. Set Up Squid in Docker

### **Step 1: Add Multiple IPs to Your Host**

> Replace with real IPs from your VPS provider. Requires you to have multiple public IPs bound.

```bash
ip addr add 192.0.2.101/32 dev eth0
ip addr add 192.0.2.102/32 dev eth0
```

Persist in `/etc/network/interfaces` or `netplan` configs depending on your distro.

---

### **Step 2: Create Squid Config with Multiple `tcp_outgoing_address`**

Here’s a **minimal `squid.conf`**:

```conf
http_port 3128

acl to_ip_1 myportname 3128
tcp_outgoing_address 192.0.2.101 to_ip_1

acl to_ip_2 myportname 3128
tcp_outgoing_address 192.0.2.102 to_ip_2

# Rotate per connection using round-robin or custom ACL
# You can switch based on client IPs, time, or round-robin with helper scripts

access_log /var/log/squid/access.log
cache deny all
```

---

### **Step 3: Dockerfile for Squid**

```Dockerfile
FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y squid net-tools iproute2 && \
    rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf

CMD ["squid", "-N", "-d1"]
```

---

### **Step 4: Build and Run Docker Container**

```bash
docker build -t squid-rotator .
docker run -d --name squid-proxy --net=host --cap-add=NET_ADMIN squid-rotator
```

> `--net=host` allows the container to bind to the host IPs.
> `--cap-add=NET_ADMIN` is required if you later want to manipulate routing inside the container.

---

## 🧠 3. IP Binding & Source IP Control (Low-level)

Squid uses `tcp_outgoing_address` to **bind to specific source IPs for outbound connections**.

Internally, Squid creates the connection socket with an explicit `bind()` to the source IP (visible in `src/client_side.c` or `comm_openex()` logic).

```c
// Simplified pseudo-path
fd = socket(...);
bind(fd, source_ip);  // The IP from tcp_outgoing_address
connect(fd, target_host);
```

Reference in Squid source:
- [`src/comm/Comm.cc`](https://github.com/squid-cache/squid/blob/master/src/comm/Comm.cc)
- [`tcp_outgoing_address`](http://www.squid-cache.org/Doc/config/tcp_outgoing_address/)

---

## 🔄 4. Proxy Rotation Strategies

### ✅ Option 1: **Manual Proxy Switching**

Clients switch between `http://proxy:3128` and `http://proxy2:3128` mapped to different Squid IPs.

### ✅ Option 2: **Multiple Squid Instances (easiest per-IP bind)**

- Start multiple Squid containers, each bound to a single IP:

```bash
docker run -d --name squid1 --net=host -e OUT_IP=192.0.2.101 squid-rotator
docker run -d --name squid2 --net=host -e OUT_IP=192.0.2.102 squid-rotator
```

Change `squid.conf` dynamically with env var replacement.

### ✅ Option 3: **Custom ACL-based Round-Robin**

This requires external ACL helpers or rotating NAT rules. More complex, but I can show this if you want to go deep.

---

## 🧪 5. Testing the Rotated Proxy

### From Client

```bash
curl -x http://host-ip:3128 http://ipinfo.io/ip
```

Or use Python:

```python
import requests

proxies = {
    'http': 'http://host-ip:3128',
    'https': 'http://host-ip:3128',
}

print(requests.get("https://api.ipify.org", proxies=proxies).text)
```

If setup is correct, the response should change depending on the chosen Squid proxy instance or outbound IP.

