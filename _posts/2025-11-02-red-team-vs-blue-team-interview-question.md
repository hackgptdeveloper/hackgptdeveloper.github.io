---
title: "carefully structured list of **scenario-based** and **Red Team vs Blue Team** interview questions"
tags:
  - cybersecurity Interview Question
---

Each question is designed to test **critical thinking, tool choice, kill-chain mapping, detection logic, and remediation design** — not just memorization.

---

## 🔴 **Red Team Scenarios (Offensive / Adversarial Thinking)**

### 1. Initial Access & Recon

1. You’re targeting a web app behind Cloudflare. How do you identify its real origin IP?
2. During reconnaissance, you find an exposed `.git` directory. What’s your approach to exploit it safely?
3. A company uses a login portal with a CAPTCHA. How would you attempt password brute-forcing or bypassing CAPTCHA protection?
4. You discover a forgotten subdomain running an old CMS version. Describe how you’d perform fingerprinting and exploit development.
5. You found an S3 bucket with public read access. What are the next steps?

---

### 2. Exploitation & Payload Delivery

6. You have RCE on a web server with `www-data` privileges. What are your first three post-exploitation steps?
7. You compromise a developer’s workstation. How would you move laterally into the CI/CD environment?
8. Explain how you’d bypass antivirus and EDR using process injection or LOLBins.
9. You upload a PHP web shell, but it gets deleted after 10 seconds. What countermeasures could be removing it, and how do you persist?
10. You have access to a Kubernetes worker node. How do you attempt to escalate privileges to cluster admin?

---

### 3. Privilege Escalation & Lateral Movement

11. You gain a low-privileged Windows user shell. How would you enumerate for privilege escalation paths?
12. You find cached credentials in a Jenkins node. How do you extract and reuse them securely?
13. A Linux target runs Docker with `--privileged` flag. Explain how you can escape to the host.
14. You compromise a Windows box but find LSASS is protected. How else can you dump credentials?
15. The target network blocks SMB traffic. How else could you exfiltrate data stealthily?

---

### 4. Persistence & Evasion

16. You need to maintain persistence on a Linux web server without cron or rc.local. What other persistence mechanisms could you use?
17. Your reverse shell traffic is being blocked. How would you bypass egress filtering or use DNS tunneling?
18. What techniques could you use to evade a behavioral EDR system monitoring PowerShell?
19. You’re asked to simulate an APT group using fileless persistence. Describe your approach.
20. You need to persist in a Kubernetes cluster after pod restarts — how?

---

### 5. Exfiltration & Post-Exploitation

21. How would you exfiltrate 500MB of data without triggering DLP or SIEM alerts?
22. You find AWS CLI credentials on a compromised host. How do you escalate within AWS using those credentials?
23. You’re on a segmented network. How do you set up a covert C2 channel?
24. Describe a real scenario where you could chain SSRF → metadata API → AWS takeover.
25. What’s your strategy to remain stealthy while performing domain enumeration in Active Directory?

---

## 🔵 **Blue Team Scenarios (Defensive / Detection & Response)**

### 6. Threat Detection & Response

26. You receive an alert for multiple failed SSH logins from one IP. What steps would you take before blocking it?
27. How do you detect data exfiltration via DNS tunneling in network logs?
28. A user reports slow performance; how do you determine if malware or cryptomining is running?
29. How do you triage a suspected phishing email with an attachment?
30. You see `rundll32.exe` spawning PowerShell. What’s your investigation flow?

---

### 7. Log & SIEM Analysis

31. What specific log patterns indicate a brute-force attack vs a credential stuffing attack?
32. In your SIEM, you see traffic to `169.254.169.254`. Why is this important?
33. What key events would you monitor in Windows Event Logs for lateral movement detection?
34. How would you detect an attacker using `certutil` or `bitsadmin` for download?
35. What data sources would you correlate to confirm exfiltration activity?

---

### 8. Incident Response

36. You discover ransomware on one host — what are your immediate containment steps?
37. How would you preserve volatile memory for forensic analysis in Linux and Windows?
38. How do you ensure log integrity and chain of custody during incident handling?
39. What’s your method for scoping an incident across multiple endpoints?
40. After containment, how do you verify that persistence mechanisms are removed?

---

### 9. Threat Hunting

41. Describe how you would hunt for credential theft in Active Directory without waiting for alerts.
42. How do you use Sysmon data to identify process injection?
43. What are common indicators of PowerShell abuse in EDR telemetry?
44. How do you detect living-off-the-land (LOLBins) activity in your environment?
45. Explain how you would hunt for lateral movement via `WinRM` or `WMI`.

---

### 10. Cloud & Container Defense

46. How do you detect container breakout attempts in Kubernetes?
47. What are indicators of compromise in AWS CloudTrail logs?
48. How do you prevent IAM credential leakage from EC2 metadata services?
49. How do you detect cryptojacking in Kubernetes workloads?
50. A compromised Lambda function is making external requests — how do you investigate and mitigate?

---

## ⚙️ **Bonus: Deep-Dive Follow-Ups (used in advanced interviews)**

* **Map MITRE ATT&CK techniques** for any of the above scenarios.
* **Write detection logic (KQL, Sigma, or Splunk SPL)** for a given TTP.
* **Build an end-to-end kill chain** diagram showing how the attacker entered, moved laterally, and exfiltrated data.
* **Simulate detections** using tools like *Atomic Red Team*, *CALDERA*, or *PurpleSharp*.

---
