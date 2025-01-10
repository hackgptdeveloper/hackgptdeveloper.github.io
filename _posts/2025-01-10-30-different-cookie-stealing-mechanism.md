---
title: "30 different stealing authentication tokens mechanism"
tags:
  - cookie stealing
---

Stealing authentication tokens inside HTTP cookies can occur in various scenarios due to improper security configurations, vulnerabilities, or malicious activities. Below is a list of 30 scenarios where this can happen:

### 1. **Cross-Site Scripting (XSS)**
   - Malicious script injected into a webpage reads cookies and sends them to an attacker’s server.

### 2. **Cookie Injection via HTTP Response Splitting**
   - Manipulating the HTTP response to include malicious cookies that overwrite existing session tokens.

### 3. **Insecure Transmission (No HTTPS)**
   - Tokens are sent over HTTP, making them vulnerable to network sniffing.

### 4. **Insecure Cookie Attributes**
   - Missing `Secure` attribute allows cookies to be sent over unsecured connections.

### 5. **Missing HttpOnly Flag**
   - Without `HttpOnly`, cookies are accessible to JavaScript, making them easier to steal with XSS.

### 6. **Cross-Site Request Forgery (CSRF)**
   - Exploiting a lack of proper CSRF tokens protection to perform unauthorized actions.

### 7. **Clickjacking**
   - Embedding the target website in an iframe to trick users into performing actions that expose cookies.

### 8. **Cookie Replay Attacks**
   - Reuse of stolen session cookies to impersonate users.

### 9. **Social Engineering**
   - Tricking users into sharing cookie data through phishing or other deceptive tactics.

### 10. **Man-in-the-Middle (MitM) Attacks**
   - Intercepting and reading cookies on unencrypted connections.

### 11. **Session Fixation**
   - Attacker sets a known session ID and forces the user to use it, gaining control when they log in.

### 12. **Weak Cookie Encryption**
   - Poor encryption practices allow attackers to decrypt cookie contents.

### 13. **Browser Vulnerabilities**
   - Exploiting flaws in the browser to access cookie data.

### 14. **Open Redirect Vulnerabilities**
   - Redirecting users to malicious domains to steal cookies.

### 15. **Reflected XSS**
   - Immediate execution of a script that reads cookies and transmits them.

### 16. **Stored XSS**
   - Persistent script injection that continuously steals cookies when a page is accessed.

### 17. **DNS Spoofing**
   - Redirecting traffic to a malicious server that mimics a legitimate site.

### 18. **Subdomain Takeover**
   - Controlling a subdomain of a target site and stealing cookies shared across subdomains.

### 19. **Insecure SameSite Attribute**
   - Misconfigured `SameSite` attribute, allowing CSRF or cookie theft.

### 20. **Cache Poisoning**
   - Poisoning cache to serve malicious pages that steal cookies.

### 21. **Malicious Browser Extensions**
   - Extensions with permissions to read cookies.

### 22. **Public Wi-Fi Attacks**
   - Intercepting cookies on unsecured Wi-Fi networks.

### 23. **Session Hijacking**
   - Taking control of an active session using stolen cookies.

### 24. **Cookie Domain Attribute Misconfiguration**
   - Sharing cookies across unintended domains.

### 25. **Cookie Path Attribute Misconfiguration**
   - Cookies accessible by unintended paths or subdirectories.

### 26. **Phishing Emails**
   - Redirecting users to a malicious page that reads cookies.

### 27. **Local File Inclusion (LFI)**
   - Including sensitive files that contain cookie data.

### 28. **Third-Party Script Inclusion**
   - Malicious third-party scripts injected into trusted domains.

### 29. **Cross-Origin Resource Sharing (CORS) Misconfiguration**
   - Allowing unauthorized domains to access cookies.

### 30. **Timing Attacks**
   - Using timing differences to infer cookie values or authentication tokens.

#### Preventative Measures
To mitigate these risks, implement best practices:
- Always use HTTPS.
- Set `Secure`, `HttpOnly`, and `SameSite` attributes on cookies.
- Use Content Security Policy (CSP) to prevent XSS.
- Implement proper CSRF protection.
- Avoid sharing sensitive tokens with third-party scripts or domains.

Each scenario represents a vector for potential token theft if appropriate countermeasures are not in place.

