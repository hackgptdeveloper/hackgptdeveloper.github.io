---
title: "**top 30 CSP bypass techniques**"
tags:
  - CSP
---

The **top 30 CSP bypass techniques** known in the CTF and bug bounty hunting communities, along with their explanations and use cases:

### 1-10: Inline Script and Style Bypasses
1. **Nonce Reuse**: If a `nonce` is reused across multiple responses or can be guessed, attackers can inject content with the known nonce.
2. **Dynamic Script Injection via `strict-dynamic`**: Using `script-src 'strict-dynamic'` allows dynamically created scripts (e.g., using `eval()`) which can lead to bypass if combined with a trusted script.
3. **Whitelisted JSONP Endpoints**: Exploiting `script-src` that allows external JSONP endpoints to execute arbitrary JavaScript.
4. **Data URI Whitelisting**: Using `data:` URIs in `script-src` or `style-src` may allow execution of inline scripts if enabled.
5. **Blob URI Whitelisting**: If `blob:` is allowed, attackers can create blob URLs containing malicious content.
6. **Self Whitelisting with User-Controlled Content**: When `script-src 'self'` is used and the site reflects user input without sanitization.
7. **Inline Event Handlers with `'unsafe-inline'`**: Allows using event handlers directly in HTML (`onclick`, etc.), exploitable in lenient CSPs.
8. **Bypass via `innerHTML`**: Using DOM manipulation functions that insert unsanitized HTML (e.g., `innerHTML`, `document.write`).
9. **Base Tag Injection**: Injecting `<base>` tags to manipulate relative paths if `default-src` is too permissive.
10. **Bypass using `unsafe-eval`**: CSP that allows `unsafe-eval` permits functions like `eval()`, `setTimeout()`, and `setInterval()`.

### 11-20: Source and Fetch Policy Bypasses
11. **Permissive Wildcard for Script Sources**: Using `script-src *` allows loading scripts from any domain.
12. **Third-party Libraries with XSS Vulnerabilities**: Libraries allowed by CSP may have vulnerabilities that allow script injection.
13. **Compromised CDN Whitelist**: Whitelisted CDNs that host user-controlled content.
14. **Content-Type Mismatch**: Allowing non-JS content (e.g., images) to be served with `application/javascript` MIME type.
15. **MIME Sniffing Bypass**: Improper MIME-type checks may allow arbitrary script injection.
16. **URL Parameter Injection**: Fetching scripts using user-controllable parameters (e.g., `example.com/script.js?payload=...`).
17. **Redirection to Malicious Domains**: If a whitelisted domain redirects to a malicious site.
18. **JSON Hijacking via `img-src` or `connect-src`**: If CSP allows loading JSON or data from external sources.
19. **Subresource Integrity (SRI) Misconfiguration**: Incorrect or missing integrity attributes for scripts.
20. **Allowing `filesystem:` URIs**: Can lead to arbitrary file reads and writes in some contexts.

### 21-30: Policy and Reporting Mechanism Bypasses
21. **Policy Parsing Errors**: Exploiting browser-specific quirks or bugs in CSP parsing logic.
22. **Case-sensitivity Bypass**: Using case-insensitive variations of directives in some browsers (`sCrIpT-sRc`).
23. **Misconfigured Frame Ancestors**: Weak `frame-ancestors` allowing clickjacking.
24. **Policy Injection via Meta Tags**: Injecting new CSP directives through `<meta http-equiv="Content-Security-Policy">`.
25. **Weak Default-src with Fallback**: Using lenient `default-src` when specific directives are missing.
26. **Cross-origin Redirection Chains**: Using chained redirects to bypass origin restrictions.
27. **Bypassing Wildcards in Subdomains**: Exploiting `*.example.com` when sensitive subdomains should be excluded.
28. **Improper Nonce Scope Management**: Using nonces outside of intended scope (e.g., on subresources).
29. **Report URI Manipulation**: Poisoning reports sent to `report-uri` for information leakage.
30. **Abusing CSP Report-only Mode**: CSP in `report-only` does not block execution, only reports violations.

### Summary
CSP bypasses are possible due to misconfigurations, overly permissive policies, browser quirks, and untrusted third-party resources. Properly auditing and refining CSP configurations while following best practices helps mitigate these risks. Always test CSP headers using tools like `csp-evaluator` and browser developer tools to identify potential weaknesses.
