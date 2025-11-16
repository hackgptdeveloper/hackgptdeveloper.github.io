---
title: "Phishing attack internals"
tags:
  - phishing_attack
---

Phishing attack technically breakdown:

1. **How phishing attacks usually begin (initial vectors)**
2. **What they lead to (post-phishing kill-chain)**
3. **Which detection systems, logs, signals, and rules must exist to detect them**

This is written from the perspective of enterprise blue-team operations, SOC workflow, SIEM rule engineering, and endpoint/network telemetry.

---

# 1. HOW A PHISHING ATTACK USUALLY STARTS

### **Initial Delivery Vectors**

These are the most **statistically common, real-world entry points** seen by SOCs, DFIR teams, and threat intel feeds.

---

## **1.1 Email-Based Vectors**

### **(A) Malicious Link (URL Phishing)**

Attacker sends mails containing:

* Fake login pages (Microsoft 365, Gmail, Okta, Azure AD)
* Malicious Google Drive/Dropbox payloads
* fake “password expiry” or “new voicemail” links
* QR code phishing (“quishing”)

🔍 **How detection works**

* Secure Email Gateway (SEG) link-rewriting logs
* URL sandbox detonation logs
* SIEM rule: *“Unusual HTTP POST to new domain following email click event.”*
* DNS logs: new domains requested within minutes after receiving email
* Proxy logs showing page with *form-submission to external IP/domain*

---

## **1.2 Attachment-Based Vectors**

### **(A) Office Macros / Embedded Scripts**

* `.docm`, `.xlsm`, `.rtf` with malicious VBA, XLM, or DDE
* Lures requiring "Enable Editing" → "Enable Content"

### **(B) PDF Phishing**

* PDF containing URL redirection
* PDF with JavaScript to open malicious site

### **(C) Archive Phishing**

* `.zip/.rar/.7z` containing loaders (JS, VBS, BAT)
* ISO/IMG “mark of the web bypass”

🔍 **How detection works**

* EDR events: Script host execution (wscript, powershell.exe, mshta.exe)
* Email gateway attachment scanning logs
* Sysmon: Event 1 (Process Create) for suspicious children of `winword.exe` / `excel.exe`
* YARA rules on attachment detonation sandbox
* MITRE ATT&CK mapping: T1566 + T1204 + T1059 (.js/.vbs/.ps1)

---

## **1.3 SaaS Account Phishing**

Attackers impersonate:

* Microsoft Teams sharing notification
* Slack/Zoom invites
* Shared Google Docs activity

These redirect to credential-harvesting pages.

🔍 Detection:

* CASB / SSPM monitoring OAuth consent grants
* Azure AD: Impossible travel after authentication
* M365 Defender: “Suspicious login from unfamiliar location”
* Cloud proxy: New domain hosting look-alike login pages

---

## **1.4 SMS / WhatsApp / Mobile-Native Phishing (Smishing)**

Used heavily for:

* MFA fatigue attacks
* Fake delivery notifications (FedEx, DHL)
* Social engineering to install malicious APKs (Android malware)

🔍 Detection:

* MDM/Mobile EDR telemetry
* CASB login anomalies from mobile devices
* SMS gateway logs (if corporate devices)

---

## **1.5 Voice Phishing / Callback Phishing**

User calls a fake hotline → attacker instructs user to install:

* AnyDesk
* TeamViewer
* ScreenConnect
* Fake antivirus

This is currently **one of the top initial access vectors** for ransomware crews.

🔍 Detection:

* EDR alert on remote-desktop tool installation
* Proxy logs showing download of uncommon RMM software
* SIEM correlation: *“User downloads RMM app following inbound call event”*

---

# 2. WHAT PHISHING CAN LEAD TO (THE FULL KILL CHAIN)

Once the phishing attack succeeds (user clicks, downloads, or enters credentials), attackers proceed through stages. Here is the **full technical chain**:

---

## **Stage 1 — Credential Harvesting**

Outcome:

* Attacker steals Microsoft 365 / Google Workspace login
* Gains VPN/Web portal access
* Gains access to Okta → lateral identity takeover

Post-phish signals:

* Azure AD: new conditional access failures
* Okta: new IP/device binding
* MFA push approvals from new locations

---

## **Stage 2 — Session Hijacking / Token Theft**

Many modern phishing kits steal:

* session cookies
* bearer tokens
* refresh tokens

Allows:

* Bypassing MFA
* API access without login
* Silent mailbox access

---

## **Stage 3 — Malware / Loader Execution**

Phishing leads to downloading:

* initial loader (JS/VBS)
* PowerShell one-liner
* HTML smuggling (JS delivers EXE silently)

Leads to:

* Cobalt Strike Beacon
* AsyncRAT / Quasar
* Lumma / Raccoon Stealer
* Ransomware loader

EDR will show:

* Powershell → rundll32 → remote C2
* Office app → cmd.exe → powershell.exe
* Parent/child anomalies (excel.exe spawning powershell)

---

## **Stage 4 — Internal Reconnaissance**

Attacker enumerates:

* AD (LDAP queries)
* File shares
* VPN and internal web apps
* Cloud assets (Azure, AWS, GCP)

Detection:

* Sysmon Event 3, 4662, LDAP binding anomalies
* Windows Event 4768/4769 for AS-REQ/AS-REP spikes
* Azure AD Graph API excess querying

---

## **Stage 5 — Privilege Escalation**

Techniques:

* Password spray
* Kerberoasting
* Token impersonation
* OAuth grant attack
* Golden ticket / silver ticket

Detection:

* Kerberos TGS request anomaly (4769)
* Excessive LDAP queries from user workstation
* Azure AD: mass consent to OAuth risky apps

---

## **Stage 6 — Lateral Movement**

Examples:

* PsExec
* SMB remote service creation
* WinRM
* RDP lateral movement
* Cloud lateral movement via stolen API keys

Detection:

* Sysmon Event 3: connections to port 135/445
* EDR: PsExec execution or `psexesvc.exe` creation
* Windows Event 4624 Type 10 (remote login)
* CloudTrail anomalous API calls

---

## **Stage 7 — Data Theft (Exfiltration)**

Stealing:

* Files to MEGA, Dropbox, Telegram
* Source code (GitHub/GitLab)
* Cloud storage buckets (AWS S3, GCP buckets)

Detection:

* DLP rules: Increase in outbound data volume
* Proxy logs: encrypted uploads to external sites
* Cloud logs: LIST/GET/PUT spikes in S3 buckets

---

## **Stage 8 — Ransomware Deployment**

Final stage for financially motivated attackers:

* Shadow copy deletion
* Encrypting network drives
* Dropping ransom note

Detection:

* Sysmon 23: File deletion bursts
* EDR ransomware behavior heuristics
* Process: `vssadmin.exe delete shadows`
* Massive file renames/rewrites in short time

---

# 3. WHAT SYSTEMS SHOULD BE IN PLACE TO DETECT THESE EVENTS

Below are the **essential security controls**, organized by detection layer.

---

# **3.1 At the Email Layer**

### **Systems Required**

* Secure Email Gateway (Proofpoint, Mimecast, MS Defender)
* URL rewriting + sandbox detonation
* Anti-spoofing controls: SPF, DKIM, DMARC
* Attachment static scan + YARA engine
* QR-scan detectors (for quishing)

### **Detection Rules**

* “Email contains URL from new domain <7 days old”
* “Attachment detonated with high-risk behavior”
* “User reports phishing → correlate all recipients of same email”

---

# 3.2 **At the Identity Layer**

### **Systems Required**

* Identity Protection (Azure AD Identity Protection, Okta Risk Engine)
* CASB/SSPM (Netskope, Prisma Cloud, Microsoft Cloud App Security)
* MFA enforced (preferably phishing-resistant FIDO2/WebAuthn)

### **Detection Rules**

* Impossible travel
* Login from anonymizing VPN/TOR
* New OAuth app auto-grant
* Multiple MFA push rejects

---

# 3.3 **At the Endpoint Layer**

### **Systems Required**

* EDR/XDR: CrowdStrike, SentinelOne, MDE
* PowerShell logging (Script Block Logging, Module Logging)
* Sysmon with tuned config
* Application Control (AppLocker, WDAC)

### **Detection Rules**

* Office → cmd/powershell child process
* Droppers: `mshta.exe`, `wscript.exe`, `cscript.exe`, `rundll32.exe`
* LOLBins executing from user temp folder
* Suspicious network callbacks to C2 domain/IPs

---

# 3.4 **At the Network Layer**

### **Systems Required**

* DNS filtering (Cisco Umbrella, Quad9, Infoblox)
* Web proxy with SSL inspection
* Firewall with egress filtering
* NDR (Network Detection & Response)

### **Detection Rules**

* DNS request to domain less than 5 days old
* Unusual HTTP POST to non-standard port
* Large outbound data transfer
* DNS tunneling patterns (TXT record spikes)

---

# 3.5 **At the Cloud Layer**

### **Systems Required**

* CloudTrail (AWS), Azure Activity Logs, GCP Audit Logs
* Cloud posture management (CSPM)
* Cloud DLP
* Cloud SIEM ingestion

### **Detection Rules**

* API key creation from new IP
* Mass S3 object enumeration
* IAM privilege escalation attempt
* OAuth risky app consent

---

# 3.6 **SIEM Correlation Layer**

A modern SIEM (Elastic, Splunk, Sentinel, Chronicle) should correlate:

### **(A) Email → Click → DNS → Authentication**

Rules:

* User receives phishing email
* Within minutes they click malicious link
* DNS resolution to new domain
* Login attempt from same user/IP/device

### **(B) Attachment → Script Execution → C2 Traffic**

* Word opens → powershell.exe starts
* Outbound connection to rare IP
* EDR flags suspicious child process

### **(C) Cloud Account Phishing**

* Email reports “SharePoint doc shared”
* URL leads to fake login
* Cloud identity logs show password reset attempt

---

# FINAL SUMMARY (FOR BLUE TEAM)

### **How Phishing Starts**

* Malicious links
* Malicious attachments
* Cloud SaaS impersonation
* SMS/WhatsApp phishing
* Callback phishing
* Social engineering via phone

### **What It Leads To**

* Credential theft (password, tokens, sessions)
* Malware deployment
* Initial access broker foothold
* Lateral movement
* Data exfiltration
* Ransomware

### **Detection Systems Needed**

✔ Email protections
✔ Cloud identity protections
✔ CASB/SSPM
✔ EDR/XDR and Sysmon
✔ DNS filtering + NDR
✔ SIEM with correlation rules
✔ DLP for exfiltration

