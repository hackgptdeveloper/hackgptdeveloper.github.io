---
title: "20 command-line examples to enumerate SNMP (Simple Network Management Protocol) information"
tags:
  - SNMP
---

20 command-line examples to enumerate SNMP (Simple Network Management Protocol) information when provided with an IP address and UDP port 161:

---

### **Basic Enumeration**
1. **Check if SNMP is reachable**  
   ```bash
   snmpwalk -v2c -c public <IP> .1
   ```

2. **List all available OIDs using SNMPv2**  
   ```bash
   snmpbulkwalk -v2c -c public <IP>
   ```

3. **List all available OIDs using SNMPv1**  
   ```bash
   snmpwalk -v1 -c public <IP> .1
   ```

4. **Fetch the SNMP system information**  
   ```bash
   snmpwalk -v2c -c public <IP> system
   ```

---

### **Community Strings**
5. **Test a specific community string (replace 'community')**  
   ```bash
   snmpwalk -v2c -c community <IP> .1
   ```

6. **Brute force SNMP community strings with a dictionary**  
   ```bash
   onesixtyone -c community_list.txt <IP>
   ```

---

### **Device and Host Information**
7. **Retrieve device hostname**  
   ```bash
   snmpget -v2c -c public <IP> SNMPv2-MIB::sysName.0
   ```

8. **Fetch OS description and version**  
   ```bash
   snmpget -v2c -c public <IP> SNMPv2-MIB::sysDescr.0
   ```

9. **Get system uptime**  
   ```bash
   snmpget -v2c -c public <IP> SNMPv2-MIB::sysUpTime.0
   ```

10. **Find system contact details**  
    ```bash
    snmpget -v2c -c public <IP> SNMPv2-MIB::sysContact.0
    ```

11. **List SNMP interfaces**  
    ```bash
    snmpwalk -v2c -c public <IP> IF-MIB::ifDescr
    ```

---

### **Network Information**
12. **Retrieve IP addresses of interfaces**  
    ```bash
    snmpwalk -v2c -c public <IP> IP-MIB::ipAdEntAddr
    ```

13. **Get MAC addresses of interfaces**  
    ```bash
    snmpwalk -v2c -c public <IP> IF-MIB::ifPhysAddress
    ```

14. **Find routing table entries**  
    ```bash
    snmpwalk -v2c -c public <IP> IP-FORWARD-MIB::ipCidrRouteTable
    ```

---

### **Performance and Monitoring**
15. **Monitor interface traffic statistics**  
    ```bash
    snmpwalk -v2c -c public <IP> IF-MIB::ifInOctets
    ```

16. **Fetch CPU usage metrics**  
    ```bash
    snmpwalk -v2c -c public <IP> HOST-RESOURCES-MIB::hrProcessorLoad
    ```

17. **Fetch memory usage metrics**  
    ```bash
    snmpwalk -v2c -c public <IP> HOST-RESOURCES-MIB::hrMemorySize
    ```

18. **Get disk storage information**  
    ```bash
    snmpwalk -v2c -c public <IP> HOST-RESOURCES-MIB::hrStorageTable
    ```

---

### **SNMPv3 Specific Commands**
19. **Enumerate OIDs using SNMPv3 (user: 'admin', auth: 'MD5', priv: 'AES')**  
    ```bash
    snmpwalk -v3 -u admin -A auth_pass -a MD5 -X priv_pass -x AES <IP> .1
    ```

20. **Get system details with SNMPv3**  
    ```bash
    snmpget -v3 -u admin -A auth_pass -a MD5 -X priv_pass -x AES <IP> SNMPv2-MIB::sysDescr.0
    ```

---

### Notes
- Replace `<IP>` with the target's IP address.
- Replace `public` with the correct community string if known.
- For commands 19 and 20, adjust user credentials (`admin`, `auth_pass`, `priv_pass`) to match SNMPv3 configurations.
- Use a tool like Wireshark or tcpdump to observe the SNMP responses for troubleshooting or deeper inspection.

