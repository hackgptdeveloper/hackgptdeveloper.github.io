---
title: "100 ways of API Hacking"
tags:
  - APIHacking
---

100 ways of API Hacking

Below are 100 approaches for **API hacking**, categorized for better understanding. Each method delves into testing for security issues, misconfigurations, or vulnerabilities in APIs:

---

### **1–20: Authentication and Authorization Flaws**
1. Test for **insecure direct object references (IDOR)**.
2. Attempt **brute-forcing API keys**.
3. Check for **missing authentication headers**.
4. Bypass authentication via **parameter manipulation**.
5. Use **default credentials** (e.g., `admin:admin`).
6. Explore **JWT misconfigurations** (e.g., using `none` algorithm).
7. Manipulate **OAuth tokens** (e.g., swapping `aud` or `iss` fields).
8. Reuse **expired or stolen tokens**.
9. Test **rate-limiting flaws** for account takeover.
10. Enumerate users via API responses.
11. Escalate privileges by altering **roles or user IDs**.
12. Bypass 2FA mechanisms via API flaws.
13. Exploit misconfigured **CORS policies**.
14. Send requests from **untrusted origins**.
15. Test **HTTP Basic authentication** for weaknesses.
16. Use **dictionary attacks** on API endpoints with weak passwords.
17. Check for **weak session management** (e.g., predictable tokens).
18. Exploit **token leakage** via logs or error messages.
19. Use APIs to bypass **frontend restrictions**.
20. Bypass **IP-based restrictions** by using proxies.

---

### **21–40: Input Validation Flaws**
21. Test for **SQL injection** in parameters.
22. Check for **NoSQL injection** vulnerabilities.
23. Inject **command injections** via payloads.
24. Test for **XML External Entity (XXE)** attacks.
25. Exploit **insecure deserialization** vulnerabilities.
26. Perform **path traversal** attacks (e.g., `../../etc/passwd`).
27. Use **cross-site scripting (XSS)** in JSON/XML responses.
28. Try **LDAP injections** in user directory APIs.
29. Manipulate **graph queries** (e.g., GraphQL injections).
30. Send **malformed JSON/XML payloads**.
31. Use oversized requests to test for **DoS vulnerabilities**.
32. Inject **unicode characters** to bypass filters.
33. Fuzz with **unexpected inputs** like negative numbers or long strings.
34. Test for **regular expression DoS (ReDoS)** vulnerabilities.
35. Send **double-encoded payloads** to bypass validation.
36. Manipulate API queries with **SQL wildcards**.
37. Inject **JavaScript Object Notation Hijacking (JSON Hijacking)**.
38. Test for **HTTP parameter pollution**.
39. Experiment with **incomplete request bodies**.
40. Use **nested or recursive payloads** to crash parsers.

---

### **41–60: Business Logic Testing**
41. Test for **improper rate limits** (e.g., brute force).
42. Abuse API workflows for **free or unauthorized access**.
43. Manipulate **payment APIs** to bypass charges.
44. Exploit **currency conversion discrepancies**.
45. Modify **shipping calculations** in e-commerce APIs.
46. Bypass API rules for **promo codes**.
47. Duplicate **transaction requests** to double-charge or refund.
48. Exploit **logical flaws in subscription APIs**.
49. Test **state management flaws** in multi-step processes.
50. Exploit APIs to access **internal admin functions**.
51. Use **incomplete or delayed responses** to probe data leakage.
52. Attempt to modify **immutable objects**.
53. Test for **skipping steps** in multi-stage workflows.
54. Exploit **sequence-breaking vulnerabilities**.
55. Abuse **caching mechanisms** to expose stale data.
56. Attempt **double-spending attacks** via concurrent requests.
57. Test for **missing cleanup mechanisms** in transaction APIs.
58. Check for unintended **rate-limited actions** (e.g., skipping approvals).
59. Abuse **cross-tenant isolation issues** in SaaS APIs.
60. Manipulate timestamps to exploit **time-dependent logic**.

---

### **61–80: Misconfiguration Issues**
61. Exploit APIs with **default configurations**.
62. Test for **verbose error messages** leaking sensitive info.
63. Check for **API debugging tools** exposed in production.
64. Look for **unsecured admin endpoints**.
65. Scan for **open API schemas** (`swagger.json`, `api-docs`).
66. Exploit **unfiltered log outputs**.
67. Abuse **hard-coded secrets** in API code.
68. Access **unsecured database connections**.
69. Test for **overly permissive access controls**.
70. Look for exposed APIs via **search engines** (e.g., Google Dorks).
71. Test for weak or missing **TLS configurations**.
72. Exploit **insecure redirects** in API responses.
73. Abuse **API versioning** to access deprecated features.
74. Check for **unpatched software vulnerabilities**.
75. Enumerate hidden endpoints using **robots.txt** or **sitemap.xml**.
76. Exploit **HTTP method misconfigurations** (e.g., PUT instead of GET).
77. Abuse misconfigured **rate limits** to perform DoS.
78. Scan for open **debugging ports** (e.g., gRPC APIs).
79. Exploit APIs on **default ports** (e.g., 8080).
80. Identify **proxy misconfigurations** leading to request tampering.

---

### **81–100: Advanced Techniques**
81. Exploit **side-channel leaks** (e.g., timing attacks).
82. Perform **subdomain takeovers** to compromise API endpoints.
83. Exploit **API chaining** to combine vulnerabilities.
84. Test for **unauthorized file uploads**.
85. Abuse **GraphQL introspection** to gather sensitive details.
86. Exploit **metadata endpoints** on cloud services (e.g., AWS).
87. Analyze **mobile app traffic** to find hidden APIs.
88. Use **reverse engineering** tools to extract API keys.
89. Test **middleware vulnerabilities** (e.g., API gateways).
90. Intercept API traffic with **MITM attacks**.
91. Perform **SSTI attacks** (Server-Side Template Injection).
92. Exploit **functionality exposed via third-party integrations**.
93. Abuse **public API keys** in repositories.
94. Automate scans with **Burp Suite** or **OWASP ZAP**.
95. Use fuzzing tools like **FFUF** or **Atheris**.
96. Exploit **delayed rate limits** (e.g., per minute vs. per request).
97. Perform **JWT replay attacks**.
98. Inject **API hooks** into client applications.
99. Use tools like **Postman**, **Insomnia**, or **cURL** for manual testing.
100. Cross-reference APIs with **CVE databases** to find public exploits.

---

These methods cover a broad spectrum of **API security testing**. Always ensure you have proper **legal authorization** to test APIs to comply with ethical and legal boundaries.

