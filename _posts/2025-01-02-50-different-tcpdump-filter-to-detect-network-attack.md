---
title: "**50 different Wireshark or TCPDump filters** for network anomalies detection"
tags:
  - Network Anomaly Detection
---

Here’s a list of **50 different Wireshark or TCPDump filters** that can help detect a variety of network attacks or anomalies. Filters are categorized for convenience.

---

### **1. General Malicious Traffic**
1. Capture non-standard ports:  
   `tcp.port != 80 and tcp.port != 443`
2. Detect empty or malformed packets:  
   `frame.len <= 64`
3. Identify high-volume traffic from a single source:  
   `ip.src == <specific IP> and frame.pkt_len > 1000`

---

### **2. DDoS/DoS Detection**
4. Detect ICMP flood attacks:  
   `icmp`
5. Identify SYN flood:  
   `tcp.flags.syn == 1 and tcp.flags.ack == 0`
6. Detect fragmented packets:  
   `ip.flags.mf == 1`
7. UDP flood detection:  
   `udp`
8. Abnormal ICMP echo size (large pings):  
   `icmp and frame.len > 1024`
9. Amplification attack (source port 53, large UDP packets):  
   `udp.port == 53 and frame.len > 512`

---

### **3. ARP Spoofing**
10. Detect duplicate ARP replies:  
    `arp.opcode == 2`
11. Identify ARP with conflicting MACs:  
    `arp.src.hw_mac != eth.src`

---

### **4. DNS Attacks**
12. Detect DNS tunneling:  
    `udp.port == 53 and dns.qry.name contains "<suspicious domain>"`
13. Identify unusual DNS responses:  
    `dns.flags.rcode != 0`
14. Look for DNS amplification:  
    `udp.port == 53 and frame.len > 512`

---

### **5. HTTP/HTTPS Attacks**
15. Detect HTTP POST flood:  
    `http.request.method == "POST"`
16. Look for HTTP request anomalies:  
    `http.request.uri contains "<specific string>"`
17. Identify HTTPS brute force attempts:  
    `ssl.handshake.type == 1`

---

### **6. SQL Injection**
18. Detect SQLi keywords in HTTP payload:  
    `http contains "UNION SELECT"`
19. Identify suspicious query patterns:  
    `http.request.uri matches "(SELECT|INSERT|DELETE)"`

---

### **7. FTP Attacks**
20. Detect FTP brute force attempts:  
    `ftp.request.command == "USER"`
21. Look for suspicious FTP commands:  
    `ftp contains "<suspicious command>"`

---

### **8. Email/SMTP Attacks**
22. Identify spam:  
    `tcp.port == 25 and frame.len > 1000`
23. Detect SMTP relay attempts:  
    `smtp and frame.len > 1500`

---

### **9. SSH Attacks**
24. Detect SSH brute force attempts:  
    `tcp.port == 22 and tcp.flags.syn == 1`
25. Look for unexpected SSH connections:  
    `tcp.port == 22 and ip.dst == <specific server IP>`

---

### **10. Malware Detection**
26. Detect communication with known C&C servers:  
    `ip.addr == <C&C IP>`
27. Identify beaconing behavior:  
    `frame.time_delta < 1 and ip.src == <specific IP>`
28. Detect suspicious file downloads:  
    `http contains ".exe"`

---

### **11. File Transfer/Exfiltration**
29. Detect large outbound data transfers:  
    `ip.dst == <external IP> and frame.len > 1500`
30. Identify potential sensitive file transfers:  
    `http contains ".zip"`

---

### **12. MITM Attacks**
31. Look for unusual certificate exchanges:  
    `ssl.handshake.type == 11`
32. Detect unexpected ARP traffic:  
    `arp.opcode == 1 and eth.src != <expected MAC>`

---

### **13. Port Scanning**
33. Identify SYN scans:  
    `tcp.flags.syn == 1 and tcp.flags.ack == 0`
34. Look for FIN scans:  
    `tcp.flags.fin == 1 and tcp.flags.ack == 0`
35. Detect NULL scans:  
    `tcp.flags == 0x00`

---

### **14. SMB/NetBIOS Attacks**
36. Detect SMB brute force:  
    `tcp.port == 445 and smb.cmd == 0x73`
37. Look for suspicious NetBIOS traffic:  
    `nbns`

---

### **15. Wireless Network Attacks**
38. Detect deauthentication frames:  
    `wlan.fc.type_subtype == 12`
39. Look for probe request flooding:  
    `wlan.fc.type_subtype == 4`
40. Identify suspicious EAPOL packets:  
    `eapol`

---

### **16. VoIP/SIP Attacks**
41. Detect SIP brute force attempts:  
    `sip and frame.len > 1000`
42. Look for RTP flooding:  
    `rtp`

---

### **17. IPv6 Specific Attacks**
43. Detect Router Advertisement spoofing:  
    `icmpv6.type == 134`
44. Identify unusual Neighbor Discovery messages:  
    `icmpv6.type == 135 or icmpv6.type == 136`

---

### **18. Tor/VPN Usage**
45. Identify Tor traffic:  
    `tcp.port == 9001`
46. Detect OpenVPN traffic:  
    `udp.port == 1194`

---

### **19. IoT Device Attacks**
47. Detect unusual IoT traffic:  
    `ip.src == <IoT Device IP> and tcp.port != <expected port>`
48. Look for unexpected DNS lookups:  
    `dns.qry.name contains "<IoT Device domain>"`

---

### **20. Miscellaneous**
49. Detect IPv4 packets with invalid headers:  
    `ip.version != 4`
50. Identify TCP packets with mismatched flags:  
    `tcp.flags.urg == 1 and tcp.flags.psh == 0`

---

These filters are starting points; they often need adjustment based on the network environment and traffic characteristics. For best results, combine with **threat intelligence** and **anomaly detection tools**.

