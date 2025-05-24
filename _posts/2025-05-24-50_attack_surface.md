---
title: "50 attack surface for a webapp"
tags:
  - attacksurface
---

Here's a detailed list of the **Top 50 Attack Surfaces for a Website** along with **steps to identify each of them**. This list is tailored for deep technical audits and vulnerability assessments, including both frontend and backend exposures.

---

### 🔐 **TOP 50 WEBSITE ATTACK SURFACES & IDENTIFICATION METHODS**

---

#### **1. HTTP Methods**

* **Attack Surface:** Support for unsafe methods (PUT, DELETE, etc.)
* **Identification:**

  ```bash
  curl -X OPTIONS https://example.com -i
  ```

  Look for `Allow:` header.

---

#### **2. Unprotected Admin Panels**

* **Attack Surface:** Exposed `/admin`, `/dashboard`, etc.
* **Identification:**

  * Directory brute-forcing: `ffuf`, `dirsearch`, `gobuster`
  * DNS bruteforce for subdomains

---

#### **3. Login Portals**

* **Attack Surface:** Brute-force, credential stuffing, enumeration
* **Identification:**

  * Look for `/login`, `/signin`, etc.
  * Observe timing/oracles and error messages

---

#### **4. Public APIs (REST, GraphQL, gRPC)**

* **Attack Surface:** Broken Object Level Authorization (BOLA), injections
* **Identification:**

  * Use Swagger (`/swagger.json`), Postman collections
  * Discover GraphQL endpoints via `/graphql`, introspection queries

---

#### **5. File Upload Endpoints**

* **Attack Surface:** RCE, MIME confusion, polyglots
* **Identification:**

  * Look for forms or APIs accepting files
  * Intercept using Burp and test with crafted payloads

---

#### **6. JavaScript Files**

* **Attack Surface:** API keys, endpoints, logic
* **Identification:**

  * Use `waybackurls`, `gau`, `linkfinder`
  * Search for `.js` files in HTML

---

#### **7. Cookie Security**

* **Attack Surface:** Lack of `HttpOnly`, `Secure`, or `SameSite`
* **Identification:**

  * Inspect `Set-Cookie` headers in browser dev tools or Burp

---

#### **8. Session Management**

* **Attack Surface:** Predictable session tokens, fixation
* **Identification:**

  * Analyze token structure, reuse login tokens, logout behavior

---

#### **9. CORS Misconfigurations**

* **Attack Surface:** Unrestricted cross-origin access
* **Identification:**

  ```bash
  curl -H "Origin: http://evil.com" -I https://example.com
  ```

  Check `Access-Control-Allow-Origin`

---

#### **10. CSP (Content Security Policy)**

* **Attack Surface:** Absence leads to XSS
* **Identification:**

  * Check for `Content-Security-Policy` in headers
  * Use [csp-evaluator](https://csp-evaluator.withgoogle.com/)

---

#### **11. Source Map Files**

* **Attack Surface:** `.map` files reveal original source
* **Identification:**

  * Check for `<script src="app.js">` → Try `app.js.map`

---

#### **12. Open Redirects**

* **Attack Surface:** `?next=https://evil.com`
* **Identification:**

  * Look for redirect parameters in URLs
  * Fuzz with tools like `qsreplace`, `ffuf`

---

#### **13. SSRF (Server-Side Request Forgery)**

* **Attack Surface:** User-controlled URLs in request parameters
* **Identification:**

  * Look for `url=`, `redirect=`, `site=`
  * Test internal endpoints: `http://127.0.0.1:80`

---

#### **14. DOM-based XSS**

* **Attack Surface:** JavaScript reads user input and inserts into DOM
* **Identification:**

  * Use `DOM Invader` in Burp
  * Grep `.js` for `document.write`, `innerHTML`, `location.hash`

---

#### **15. API Rate Limiting**

* **Attack Surface:** Lack of throttling = brute-force
* **Identification:**

  * Send repetitive requests with same token/IP

---

#### **16. Sensitive Data in URLs**

* **Attack Surface:** Tokens, credentials in GET requests
* **Identification:**

  * Inspect browser/network logs
  * Analyze `Referer` header

---

#### **17. WebSocket Endpoints**

* **Attack Surface:** Real-time protocol bypasses CSRF, insecure auth
* **Identification:**

  * Use browser dev tools → Network → WS
  * Tools: `wss://`, `socket.io`, `signalr`

---

#### **18. JWT Implementation**

* **Attack Surface:** None/weak signature verification
* **Identification:**

  * Decode JWTs (e.g. [jwt.io](https://jwt.io))
  * Change algorithm to `none`, test key confusion

---

#### **19. Forgotten Debug Endpoints**

* **Attack Surface:** `/debug`, `/__debug__`, `/actuator`
* **Identification:**

  * Directory fuzzing
  * Common endpoint brute-force

---

#### **20. HTML Comments / Hidden Fields**

* **Attack Surface:** Credential leaks, environment info
* **Identification:**

  * `<!-- TODO: admin password is xyz -->`

---

#### **21. Email and Password Resets**

* **Attack Surface:** Token predictability, leakage, lack of expiry
* **Identification:**

  * Trigger reset, observe token in email/link

---

#### **22. JavaScript Framework Vulnerabilities**

* **Attack Surface:** Outdated React/Angular/Vue
* **Identification:**

  * Use Wappalyzer, builtwith
  * Look for version-specific CVEs

---

#### **23. Third-party Dependencies**

* **Attack Surface:** CDN, NPM, or JS libraries with known CVEs
* **Identification:**

  * Tools: `retire.js`, `npm audit`, `OWASP Dependency Check`

---

#### **24. Exposed Git / SVN Repositories**

* **Attack Surface:** `.git/config`, `.svn/entries`
* **Identification:**

  ```bash
  curl https://example.com/.git/config
  ```

---

#### **25. Web Server Misconfigurations**

* **Attack Surface:** Directory listing, error messages
* **Identification:**

  * Access `/`, `/backup`, etc.
  * Tools: `nikto`, `nmap`, `httprint`

---

#### **26. XML Parsing (XXE)**

* **Attack Surface:** XML inputs to parsers
* **Identification:**

  * Look for XML input
  * Test payloads like `<!DOCTYPE foo SYSTEM "file:///etc/passwd">`

---

#### **27. Insecure Deserialization**

* **Attack Surface:** Java, PHP, .NET serialization
* **Identification:**

  * Look for serialized objects in parameters/cookies
  * Use `ysoserial`, `marshalsec`

---

#### **28. CSRF**

* **Attack Surface:** Unsafe state-changing GET/POST
* **Identification:**

  * Analyze request origin validation
  * Use `csrf-poc-generator`

---

#### **29. Weak Password Policies**

* **Attack Surface:** Accepts short/guessable passwords
* **Identification:**

  * Try weak passwords during signup

---

#### **30. IDOR (Insecure Direct Object References)**

* **Attack Surface:** `/user/1234`
* **Identification:**

  * Change IDs in URL, cookies, params

---

#### **31. Third-party Integrations**

* **Attack Surface:** Slack bots, Zapier, etc.
* **Identification:**

  * Analyze outgoing webhooks
  * Review embedded integrations

---

#### **32. CDN Caching / Cache Poisoning**

* **Attack Surface:** Serving attacker-controlled cached responses
* **Identification:**

  * Manipulate headers: `X-Forwarded-Host`, `Host`

---

#### **33. Logging Endpoints**

* **Attack Surface:** Leak sensitive headers/tokens
* **Identification:**

  * Check for verbose error logs
  * Burp → Analyze response body for log traces

---

#### **34. Test/Staging Environments**

* **Attack Surface:** Deployed with weak auth or dummy data
* **Identification:**

  * Subdomain brute-forcing
  * `/staging`, `/test`, `beta.`

---

#### **35. Reverse Proxies**

* **Attack Surface:** Misconfiguration may expose internal services
* **Identification:**

  * SSRF + HTTP request smuggling
  * Tools: `smuggler`, `burp`

---

#### **36. Client-Side Routing**

* **Attack Surface:** Single Page Apps may route insecurely
* **Identification:**

  * Deep linking to restricted content
  * Use browser devtools and navigation tracing

---

#### **37. Insecure CSP Reporting Endpoints**

* **Attack Surface:** Leak sensitive paths via `report-uri`
* **Identification:**

  * Analyze CSP header
  * Send malformed reports

---

#### **38. Dependency Confusion**

* **Attack Surface:** Privately scoped packages resolved publicly
* **Identification:**

  * Analyze package manifests (`package.json`)
  * Register malicious packages in NPM/PyPi

---

#### **39. Subdomain Takeover**

* **Attack Surface:** DNS points to deprovisioned service
* **Identification:**

  * Tools: `subjack`, `nuclei`, `tko-subs`

---

#### **40. Outdated TLS / Insecure Cipher Suites**

* **Attack Surface:** Weak encryption
* **Identification:**

  * Use `sslyze`, `testssl.sh`

---

#### **41. Broken Access Controls**

* **Attack Surface:** Privilege escalation
* **Identification:**

  * Login as low-priv user
  * Try accessing admin-level URLs

---

#### **42. Insecure Webhooks**

* **Attack Surface:** Forged requests
* **Identification:**

  * Analyze webhook endpoints
  * Replay requests with modified headers

---

#### **43. JavaScript Event Handlers**

* **Attack Surface:** Clickjacking, XSS, JS logic flaws
* **Identification:**

  * Grep for `onClick`, `onLoad`, `eval`

---

#### **44. Misconfigured Reverse Proxies**

* **Attack Surface:** Host header injection
* **Identification:**

  * Fuzz `Host:` header, test open redirects / SSRF

---

#### **45. Misconfigured S3 Buckets / Object Storage**

* **Attack Surface:** Publicly readable/writable
* **Identification:**

  * Tools: `AWSBucketDump`, `s3scanner`, `truffleHog`

---

#### **46. Unused/Legacy APIs**

* **Attack Surface:** Old versions with no auth
* **Identification:**

  * `/v1/`, `/api_old/`, `/rest/`
  * Use Burp/ffuf to enumerate versions

---

#### **47. Caching with Credentials**

* **Attack Surface:** Sensitive data cached and exposed to other users
* **Identification:**

  * Set `Cache-Control: no-store` headers
  * Test caching behavior across accounts

---

#### **48. JavaScript Prototypes Pollution**

* **Attack Surface:** `__proto__`, `constructor.prototype` override
* **Identification:**

  * Fuzz nested objects in JSON
  * Look for merging logic (`lodash`, `jquery`)

---

#### **49. Clickjacking**

* **Attack Surface:** No `X-Frame-Options`
* **Identification:**

  ```bash
  curl -I https://example.com | grep -i x-frame-options
  ```

---

#### **50. Service Workers**

* **Attack Surface:** Intercept and manipulate requests
* **Identification:**

  * Look for `navigator.serviceWorker.register` in JS
  * Analyze cached routes

---
