---
title: "**50 distinct CORS misconfiguration patterns**"
tags:
  - CORS
---

**50 distinct CORS misconfiguration patterns**, chaining each one to **specific headers**, **server behaviors**, and, where possible, **how the relevant source code or framework behavior leads to it**.

---

### 🚨 50 CORS Misconfiguration Patterns

| # | Pattern | Description & Source |
|:--|:--------|:----------------------|
| 1 | `Access-Control-Allow-Origin: *` | Wildcard allows any domain. (`MDN`, browser standards enforce it). |
| 2 | `Access-Control-Allow-Origin: null` | Accepts `null` origin (e.g., sandboxed iframes, file:// origins). Dangerous. |
| 3 | Reflection of `Origin` Header | Server echoes back any `Origin` without validation (`req.headers.origin`) |
| 4 | Regex Matching of Origin (`.*`) | Server uses unsafe regex like `/.*?/` in node.js/express CORS middleware. |
| 5 | Allowing `http://localhost` | Exposing CORS to localhost allows internal attacks (often hardcoded dev setting). |
| 6 | Allowing `127.0.0.1` | Same as above but with IP instead of hostname. |
| 7 | Allowing `.trusted.com` (leading dot) | Misparses subdomain checks, e.g., `.trusted.com` matches `evil.trusted.com.evil.com`. |
| 8 | EndsWith Match | Using `origin.endsWith('trusted.com')` (unsafe, easily bypassed with `attackertrusted.com`). |
| 9 | Wildcard + Credentials | `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true` (disallowed by spec but misconfigured servers may ignore). |
| 10 | Whitelisted Origins but without strict comparison | E.g., `allowedOrigins.includes(origin)` where list includes user-controlled entries. |
| 11 | Allowing wildcard subdomains without DNS control | Example: `*.example.com`, but subdomains are registerable (`anyonecanregister.example.com`). |
| 12 | Trusting `Referer` instead of `Origin` | Server checks `Referer` for CORS decisions instead of `Origin` (spoofable in some cases). |
| 13 | Case-insensitive matching | Lowercasing Origin and allowing e.g., `evil.Example.com` to bypass. |
| 14 | Misinterpretation of empty Origin | If `Origin` header is missing, allowing access instead of denying. |
| 15 | Accepting malformed Origins | Non-strict Origin parsing, e.g., `https:/example.com`. |
| 16 | Allowing blob:// and filesystem:// origins | Dangerous if app relies on CORS and trusts browser internal schemes. |
| 17 | Reflection of Origin inside JSON response body | Not CORS header misconfig but leads to CORS-confusion. |
| 18 | Wildcard in `Access-Control-Allow-Headers` | `Access-Control-Allow-Headers: *` (allowed in recent browsers but older servers misconfigured). |
| 19 | Wildcard in `Access-Control-Allow-Methods` | `Access-Control-Allow-Methods: *` (even unsupported methods allowed). |
| 20 | Over-permissive Preflight response | Allowing dangerous methods like `PUT`, `DELETE`, `PATCH` in CORS Preflight (`OPTIONS`) responses. |
| 21 | Dynamic Allow-Origin from non-trusted sources | Setting `Access-Control-Allow-Origin` based on a query parameter (e.g., `?origin=evil.com`). |
| 22 | CORS allowed on authentication endpoints | `/api/login` allows cross-origin authentication! |
| 23 | Allowing CORS on admin APIs | `/admin/config` responds to cross-origin requests. |
| 24 | Accepting multiple Origin headers | If multiple `Origin:` headers are sent, server uses first/last incorrectly. (non-standard behavior). |
| 25 | Wildcard IP ranges | Accepting all private IPs like `192.168.*.*`, often seen in Express CORS configuration. |
| 26 | Internal-only origins allowed | Allowing access from intranet domains (e.g., `http://internal.corp`). |
| 27 | Ignoring protocol (HTTP/HTTPS) | Only checking host in `Origin` not full protocol, enabling downgrade attacks. |
| 28 | Accepting wildcard TLDs | Accepting `*.com` or `*.net` via broken matching functions. |
| 29 | Broken S3 bucket CORS | Misconfigured AWS S3 bucket allowing anyone CORS access (`AllowedOrigin: *`). |
| 30 | Misconfigured CDN CORS headers | CDN edge caching unsafe CORS headers globally. |
| 31 | Non-origin CORS bypass with JSONP endpoint | JSONP endpoint + misconfigured CORS allows data leak. |
| 32 | Allowing iframe access with CORS misconfig | `X-Frame-Options` missing + bad CORS → combo attack. |
| 33 | OPTIONS response not secured | Preflight responses available everywhere. |
| 34 | Accepting OPTIONS from any origin without authentication | No token/cookie check for OPTIONS request. |
| 35 | CORS misconfig in microservices communication | Internal service trusts any origin, leaked externally. |
| 36 | Incorrectly handling IP address formats | Accepts `2130706433` (which is `127.0.0.1` decimal). |
| 37 | Unicode hostname confusion | Homograph attacks (`xn--evil-domain`). |
| 38 | Using deprecated `Access-Control-Allow-Origin: *` with non-simple headers | Browsers enforced recently; server-side still vulnerable. |
| 39 | `Origin` reflection in non-standard headers | Server sets e.g., `X-Access-Control-Allow-Origin: origin_header_value` |
| 40 | Fallback behavior for empty Origins to wildcard | If origin blank, fallback to `*` internally. |
| 41 | Allow CORS on static assets | JS files with `Access-Control-Allow-Origin: *` allow asset injection attacks. |
| 42 | Reverse Proxy CORS misconfiguration | Nginx/Apache proxies pass `Origin` unchecked to backend. |
| 43 | Allowing Protocol-relative URLs | `//example.com` accepted without parsing full scheme. |
| 44 | Accepting multiple comma-separated origins | Non-standard, misinterpreted by server if `Origin: a.com, b.com`. |
| 45 | Using Regex `.*\.example.com$` but missing anchors | Greedy matching in Node.js, Express, etc. |
| 46 | Allowing Origin based on request path | Different parts of app (path based) control origin policy differently, leading to bypass. |
| 47 | Fallback to hardcoded safe origin but with dynamic behavior | Partial mitigation, can be bypassed with path manipulation. |
| 48 | No Preflight check | CORS assumed simple requests, but attacker can escalate. |
| 49 | Accepting file:// origin on mobile apps | Hybrid apps exposing CORS to file:// origins. |
| 50 | Allowing websockets CORS unsafely | CORS not directly for WS, but fallback misconfigs allow WS hijacking.

---

# 📖 Source Code Examples (Linked to above patterns)

Let's chain into some frameworks:

- **Express.js (Node.js)** - common issue
  ```javascript
  app.use(cors({ origin: (origin, callback) => { callback(null, true); }})); // Pattern #3
  ```
  (No origin validation here, reflects any origin!)

- **Spring Boot (Java)**
  ```java
  @CrossOrigin(origins = "*")
  public class Controller {} // Pattern #1
  ```

- **Flask (Python)**
  ```python
  from flask_cors import CORS
  CORS(app, origins="*")  # Pattern #1
  ```

- **ASP.NET Core**
  ```csharp
  services.AddCors(options =>
  {
      options.AddPolicy("AllowAll", builder =>
          builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
  }); // Pattern #1
  ```

---

# 📚 Standard References
- [MDN Web Docs: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [OWASP CORS Misconfiguration Guide](https://owasp.org/www-community/attacks/CORS_OriginHeaderScrutiny)
- [W3C CORS Spec](https://www.w3.org/TR/cors/)

---
