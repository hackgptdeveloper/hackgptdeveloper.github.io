---
title: "100 differeny ways to test WordPress vulnerabilities"
tags:
  - Wordpress
---

Testing a WordPress URL or webpage for vulnerabilities involves a structured methodology, leveraging both automated tools and manual techniques. Below are **100 different ways** categorized into specific areas for comprehensive security testing:

---

### **1. General Information Gathering**
1. **WHOIS Lookup**: Gather information about the domain and registrar.
2. **Subdomain Enumeration**: Find subdomains using tools like `sublist3r` or `amass`.
3. **CMS Detection**: Confirm WordPress with tools like `whatweb` or `wpscan`.
4. **Identify Plugins**: Use `wpscan` or manual checks to enumerate plugins.
5. **Theme Identification**: Detect the active theme through source code inspection.
6. **WordPress Version Check**: Determine the WordPress version using `wpscan` or headers.
7. **Directory Enumeration**: Probe directories using tools like `dirb` or `gobuster`.
8. **Content Discovery**: Look for sensitive files like `.htaccess`, `wp-config.php`, or backup files.
9. **Identify Hosting Provider**: Use tools like `builtwith` to find hosting details.
10. **Google Dorking**: Search for indexed sensitive files (e.g., `"inurl:wp-content"`).

---

### **2. WordPress-Specific Vulnerabilities**
11. **Admin Panel Exposure**: Check if `/wp-admin` or `/wp-login.php` is accessible.
12. **Default Credentials**: Test for `admin:admin` or other weak/default passwords.
13. **XML-RPC Exploitation**: Test for XML-RPC brute force or pingback DDoS vulnerabilities.
14. **Unprotected REST API**: Test endpoints for unauthenticated data access.
15. **wp-config Backup**: Look for exposed `wp-config.php` backups (`wp-config.php.bak`).
16. **Version-Specific Exploits**: Check CVEs for the detected WordPress version.
17. **Debug Mode**: Verify if `WP_DEBUG` is enabled and exposing sensitive data.
18. **Directory Indexing**: Check `/wp-content/uploads` or other folders for open indexing.
19. **TimThumb Vulnerability**: Exploit outdated `timthumb.php` scripts.
20. **Exposed WP-Cron**: Look for exposed WP-Cron URLs.

---

### **3. User and Authentication Issues**
21. **Username Enumeration**: Use `?author=1` or REST API to enumerate usernames.
22. **Weak Password Policy**: Test for common passwords using brute-force tools.
23. **Session Hijacking**: Analyze cookies for secure/HTTP-only flags.
24. **Account Lockout**: Check if there’s a lockout mechanism for failed login attempts.
25. **Unnecessary Roles**: Check for users with excessive privileges.
26. **Login URL Exposure**: Check for `/login` or `/admin` redirects.
27. **Forgot Password Abuse**: Test the password reset mechanism for token reuse.

---

### **4. Plugin Vulnerabilities**
28. **Vulnerable Plugins**: Scan plugin versions against public CVEs (using `wpscan`).
29. **Plugin Enumeration**: Identify plugins through source code or tools.
30. **File Upload Abuse**: Exploit upload forms in plugins like Contact Form 7.
31. **Shortcode Abuse**: Test plugins allowing user input in shortcodes.
32. **Reflected XSS**: Look for unescaped plugin parameters in URLs.
33. **Stored XSS**: Test plugin forms for persistent XSS.
34. **SQL Injection**: Test plugin parameters for SQLi (e.g., `?id=1 OR 1=1`).
35. **CSRF in Plugins**: Test for lack of CSRF tokens in plugin functionalities.
36. **Unauthenticated Admin Access**: Check if plugins allow access without authentication.
37. **Known Exploits**: Exploit known plugin vulnerabilities using metasploit or exploit-db.

---

### **5. Theme Vulnerabilities**
38. **Outdated Themes**: Verify theme version and check for CVEs.
39. **Custom Theme Injection**: Test custom themes for poorly sanitized inputs.
40. **Insecure Functions**: Look for insecure `eval()` or `exec()` calls in themes.
41. **Hardcoded Credentials**: Search theme files for sensitive information.
42. **Exploitable Template Files**: Test files like `404.php` for code injection.
43. **File Inclusion**: Test for Local/Remote File Inclusion (LFI/RFI) in theme files.
44. **Script Injection**: Check for inline JavaScript or CSS injection vulnerabilities.

---

### **6. Web Server and Hosting Issues**
45. **HTTP Headers**: Test for missing security headers (`X-Frame-Options`, `CSP`, etc.).
46. **SSL Configuration**: Use `ssllabs.com` to test HTTPS implementation.
47. **Open Ports**: Perform a port scan using `nmap`.
48. **Server Version Disclosure**: Check server headers for version disclosure.
49. **Misconfigured Permissions**: Verify file permissions (`chmod 777` vulnerabilities).
50. **PHP Version**: Check for outdated or vulnerable PHP versions.
51. **Backup File Exposure**: Search for `.zip`, `.tar.gz`, or `.sql` files.

---

### **7. Injection Attacks**
52. **SQL Injection**: Test form inputs and URL parameters.
53. **Command Injection**: Test for `; ls` or `&& whoami` injection opportunities.
54. **XPath Injection**: Exploit XML inputs for unauthorized queries.
55. **LDAP Injection**: Test for injection vulnerabilities in LDAP queries.

---

### **8. Cross-Site Scripting (XSS)**
56. **Reflected XSS**: Use payloads like `<script>alert(1)</script>` in URL parameters.
57. **Stored XSS**: Test inputs stored in the database (e.g., comments, posts).
58. **DOM XSS**: Analyze JavaScript for insecure DOM-based input handling.
59. **POST XSS**: Test POST forms for input sanitization.

---

### **9. File Upload Vulnerabilities**
60. **PHP Shell Upload**: Attempt to upload `.php` shells.
61. **Double Extensions**: Test uploads like `shell.php.jpg`.
62. **Content-Type Bypass**: Use tools to manipulate headers for file uploads.
63. **Directory Traversal**: Exploit upload paths with `../` sequences.
64. **Malware Injection**: Test file upload paths for malicious file execution.

---

### **10. Cross-Site Request Forgery (CSRF)**
65. **CSRF Tokens**: Verify presence of anti-CSRF tokens in forms.
66. **CSRF in Forms**: Test actions like password changes or settings updates.

---

### **11. Broken Access Control**
67. **Admin Panel Access**: Check if non-admin users can access `/wp-admin`.
68. **Privileged Functionality**: Test if low-privilege users can perform admin actions.
69. **Direct File Access**: Check if unauthorized users can access `/wp-config.php`.

---

### **12. Security Misconfigurations**
70. **Indexing Sensitive Files**: Test for indexed backups or configuration files.
71. **Error Messages**: Verify if error messages disclose sensitive information.
72. **Debug Logs**: Look for exposed logs (`debug.log`).
73. **Default File Locations**: Check for `/readme.html` or `/license.txt`.

---

### **13. Cryptographic Issues**
74. **Weak Password Storage**: Analyze hash algorithms (e.g., MD5, SHA1).
75. **SSL/TLS Vulnerabilities**: Test for weak ciphers or protocols (e.g., SSLv3).
76. **Insecure Cookie Handling**: Check for missing `secure` and `httpOnly` flags.

---

### **14. Denial of Service (DoS)**
77. **Login Brute Force**: Test login page with repeated password attempts.
78. **XML-RPC DoS**: Abuse XML-RPC `pingback` for amplification attacks.
79. **REST API Abuse**: Exploit resource-intensive API calls.
80. **Search Form Abuse**: Flood search forms with large payloads.

---

### **15. Automated Tools for WordPress Security**
81. **WPScan**: Enumerate and test for common vulnerabilities.
82. **Nikto**: Scan for web server issues.
83. **Burp Suite**: Intercept and analyze HTTP requests.
84. **Nessus**: Perform vulnerability scans on the site.
85. **Acunetix**: Comprehensive web application scanner.
86. **OWASP ZAP**: Intercept and scan for vulnerabilities.

---

### **16. Post-Exploitation Checks**
87. **Backdoor Checks**: Scan uploaded files for malicious backdoors.
88. **Data Extraction**: Attempt to exfiltrate sensitive information.
89. **Privilege Escalation**: Exploit vulnerabilities to escalate privileges.
90. **Code Execution**: Execute arbitrary commands on the server.

---

### **17. Advanced Techniques**
91. **Timing Attacks**: Exploit delays in responses for information leaks.
92. **Blind SQL Injection**: Infer results using conditional responses.
93. **Content Injection**: Insert malicious content into poorly sanitized inputs.
94. **Cache Poisoning**: Manipulate cached responses for exploitation.

---

### **18. Social Engineering**
95. **Phishing for Admin Credentials**: Simulate phishing attacks.
96. **Weak CAPTCHA**: Bypass CAPTCHA if implemented poorly.

---

### **19. Log and Monitoring**
97. **Audit Logs**: Analyze logs for sensitive data exposure.
98. **Log Injection**: Insert malicious entries into logs.

---

### **20. Third-Party Services**
99. **CDN Vulnerabilities**: Test for issues in Cloudflare or similar setups.
100. **External API Abuse**: Test APIs integrated into WordPress.

---
