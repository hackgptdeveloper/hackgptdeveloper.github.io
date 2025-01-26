---
title: "10 different ways of using proxychains"
tags:
  - Proxychains
---

`proxychains` is a powerful tool for routing application traffic through a chain of proxies. Below are 10 different ways to use it, with examples:

---

### **1. Run a Web Browser Through Proxies**
Use `proxychains` to route your browser traffic through a proxy.

```bash
proxychains firefox
```

This will open Firefox and route all its traffic through the configured proxies in `/etc/proxychains.conf`.

---

### **2. Test Connectivity Using `curl`**
Use `proxychains` to send requests using `curl`.

```bash
proxychains curl https://example.com
```

This is useful for testing how the request appears when routed through the proxies.

---

### **3. Perform DNS Lookups**
Run `dig` or `nslookup` to check how DNS queries behave when routed through proxies.

```bash
proxychains dig example.com
```

This routes DNS resolution through the proxy chain.

---

### **4. Run Network Scans Using `nmap`**
Route `nmap` scans through proxies for anonymity.

```bash
proxychains nmap -sT -Pn -p 80 example.com
```

`-sT` ensures a TCP connect scan, as SYN scans (`-sS`) typically don’t work over proxies.

---

### **5. Use `proxychains` with `wget`**
Download files anonymously using `wget`.

```bash
proxychains wget https://example.com/file.zip
```

This downloads the file through the configured proxy chain.

---

### **6. Bypass Firewalls for SSH**
Use `proxychains` to establish SSH connections through a proxy.

```bash
proxychains ssh user@remote-server.com
```

This is handy for connecting to SSH servers behind firewalls or geographical restrictions.

---

### **7. Run Tor Browser with Proxychains**
Chain `proxychains` with `tor` for additional anonymity.

```bash
proxychains tor
```

This routes `tor` itself through the configured proxy chain.

---

### **8. Use Proxychains with `git`**
Clone repositories or interact with Git servers through proxies.

```bash
proxychains git clone https://github.com/user/repository.git
```

This allows Git traffic to be anonymized.

---

### **9. Test APIs or Services Using `python`**
Run Python scripts with `proxychains` to proxy API requests or other scripts.

```bash
proxychains python my_script.py
```

This is particularly useful for developers testing applications or APIs through proxies.

---

### **10. Automate Proxychains with Shell Scripts**
Combine `proxychains` with a shell script for batch tasks.

Example shell script `proxy_download.sh`:
```bash
#!/bin/bash
for url in $(cat urls.txt); do
  proxychains wget $url
done
```

Run it:
```bash
chmod +x proxy_download.sh
./proxy_download.sh
```

This automates tasks like downloading files anonymously in bulk.

---

### Key Configurations for Proxychains
Before using `proxychains`, configure `/etc/proxychains.conf` or `~/.proxychains/proxychains.conf`. For example:
```plaintext
# Dynamic mode for proxy chaining
dynamic_chain

# Proxy list
socks5 127.0.0.1 9050
http 192.168.1.100 8080
```

Modes:
- **dynamic_chain**: Skips unavailable proxies in the chain.
- **strict_chain**: Ensures all proxies are used, failing if one is down.
- **random_chain**: Randomizes the order of proxies.

---

