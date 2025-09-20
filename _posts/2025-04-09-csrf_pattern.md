---
title: "list of 50 different patterns resulting in CSRF"
tags:
  - csrf
---

CSRF patterns and their explanation to fundamental web behaviors and, when applicable, show how they would appear in real codebases (PHP, Java, Node.js, etc.).  

---

### 📜 50 CSRF-Prone Patterns (Low-Level View)

---

### 1. **HTTP Method Confusion**
   - Server accepts **GET** requests for **state-changing operations** (e.g., delete, update).
   - 🔗 **Source:** HTTP 1.1 RFC - "GET should be safe and idempotent" (RFC 7231).

---

### 2. **No CSRF Token in Forms**
   - Forms perform state changes without a per-user token.
   - 🔗 **Example:**
     ```html
     <form action="/change-email" method="POST">
       <input name="email" value="hacker@example.com" />
       <input type="submit" />
     </form>
     ```

---

### 3. **CSRF Token Not Tied to Session**
   - Token is static, not regenerated or tied to session/user.

---

### 4. **Static Hidden Inputs for Critical Actions**
   - Static hidden input fields for actions without any unpredictable content.

---

### 5. **Absence of SameSite Cookies**
   - Session cookies set without `SameSite=Lax` or `Strict`.
   - 🔗 **Source:** [RFC 6265bis - HTTP State Management Mechanism](https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-09).

---

### 6. **CSRF Token in URL Parameters**
   - Token exposed in URLs, can be logged or leaked via referrer headers.

---

### 7. **No Origin or Referer Header Validation**
   - Backend doesn't validate `Origin` or `Referer` headers on state-changing requests.

---

### 8. **Misusing CORS (Cross-Origin Resource Sharing)**
   - Allowing cross-origin requests with `Access-Control-Allow-Origin: *` **and** sensitive endpoints.

---

### 9. **HTML Forms without Anti-CSRF Validation on POST Endpoints**
   - Forms missing any backend CSRF checks despite POST usage.

---

### 10. **Unsafe PUT/PATCH/DELETE without Token**
   - Sensitive PUT/PATCH/DELETE APIs exposed without anti-CSRF protections.

---

### 11. **Using GET to Change Passwords**
   - Password changes via simple URL access.

---

### 12. **WebSocket Actions Without Auth Handshake**
   - Sensitive WebSocket actions that don't require explicit authentication on connect.

---

### 13. **Legacy Systems Relying on IP Address for Authentication**
   - IPs can be spoofed in certain networks (e.g., NATs).

---

### 14. **Session Fixation Flaws**
   - If attacker can fix a session identifier, CSRF becomes easier.

---

### 15. **Embedded JS Widgets Performing State Changes**
   - Third-party embeddable widgets can alter state without user consent.

---

### 16. **Using XMLHttpRequest without Credentials Check**
   - Forgetting `xhr.withCredentials = true;` leads to unsafe cross-origin leakage.

---

### 17. **Sensitive GET endpoints usable in `<img src="">`**
   - E.g., making requests like `<img src="https://bank.com/delete-account?id=1">`.

---

### 18. **CSRF Token Predictability**
   - Poor randomness generation for tokens.
   - 🔗 **Source:** `Math.random()` (in JS) is **not cryptographically secure**.

---

### 19. **Static CSRF Token Across Sessions**
   - Same token for every user session.

---

### 20. **Authentication By Only Checking Cookie Without Additional Validation**
   - Trusting cookie presence as the sole proof of authentication.

---

### 21. **Login CSRF**
   - CSRF-able login endpoints where attacker forces victim to log in as attacker.

---

### 22. **Missing Double Submit Cookie Pattern**
   - If relying on double submit CSRF defense, but failing to implement correctly.

---

### 23. **Multi-Page Forms Without Token Revalidation**
   - Multi-step forms where only the first step checks for a CSRF token.

---

### 24. **Subdomain Misconfigurations**
   - Allowing cookies for `.example.com` where attacker controls `evil.example.com`.

---

### 25. **Open Redirects Assisting CSRF**
   - Redirects after state changes, assisting in login CSRF attacks.

---

### 26. **Mixed Content HTTP/HTTPS Issues**
   - HTTP pages leaking session tokens used for HTTPS sites.

---

### 27. **CSRF on Logout**
   - Allowing attackers to force users to log out (Session Fixation + Hijacking possible).

---

### 28. **PUT/PATCH APIs Not Validating Request Content-Type**
   - Accepting any content type, including `application/x-www-form-urlencoded`.

---

### 29. **Allowing Legacy Flash Content**
   - Flash ignores CORS restrictions unless crossdomain.xml is used.

---

### 30. **Non-Verifying API Gateways/Proxies**
   - API gateways forwarding sensitive requests without header validation.

---

### 31. **CSRF Bypass via 307 Redirect**
   - 307 preserves original method and body; attackers exploit it.

---

### 32. **Cross-Origin POST Accepting `application/x-www-form-urlencoded`**
   - Default HTML POST behavior is exploited without triggering CORS preflight.

---

### 33. **Multi-Tenant APIs Without Tenant ID Validation**
   - APIs do not verify user is part of tenant; CSRF leads to data leakage.

---

### 34. **CSP Bypasses Allowing Form Submissions**
   - Weak CSP allows forms from attacker domains.

---

### 35. **Iframe-able Sensitive Pages**
   - No `X-Frame-Options: DENY` allowing hidden iframes to automate clicks (Clickjacking + CSRF).

---

### 36. **Session Not Bound to User-Agent**
   - Session reuse attacks easier when not tied to user-specific metadata.

---

### 37. **"Remember Me" Tokens Without Fresh Authentication for Sensitive Changes**
   - Tokens used for sensitive actions without revalidating the user's identity.

---

### 38. **Automatic Action Endpoints on Page Load**
   - Pages that auto-trigger critical actions once loaded (`onload` JavaScript).

---

### 39. **Handling of JSON CSRF (JSON Hijacking)**
   - JSON GET endpoints leaking sensitive data to attacker domains.

---

### 40. **OAuth Misuse (Implicit Flow Leakage)**
   - Attacker can steal tokens via a forged redirect.

---

### 41. **Content-Type Confusion on Server-Side Parsers**
   - E.g., Express.js automatically parsing forms even if not expected.

---

### 42. **Login Cross-Site Request Forgery via Federated Logins**
   - Misconfigured SSO or OAuth providers causing CSRF at login time.

---

### 43. **Logout Cross-Site Request Forgery**
   - Attacker forces victim to logout to cause disruption or session confusion.

---

### 44. **Password Reset via CSRF**
   - Password resets triggered by attacker without user's consent.

---

### 45. **Admin Action CSRF**
   - Admins having higher privileges and exposed endpoints vulnerable to CSRF.

---

### 46. **Unkeyed HMAC Tokens**
   - Token generated without secret key → predictable if algorithm is known.

---

### 47. **CSRF in Mobile APIs via WebViews**
   - Apps using WebViews incorrectly inherit cookies from mobile browser sessions.

---

### 48. **SSO Auto-Provisioning Abuse**
   - SSO endpoints automatically create accounts upon first login without user validation.

---

### 49. **Missing CAPTCHA on Sensitive Actions**
   - CAPTCHA absence can turn otherwise "protected" flows into CSRF-prone flows.

---

### 50. **Incorrect Assumptions about CORS 'Safe Methods'**
   - Thinking `OPTIONS` preflight always happens — it doesn't for simple POSTs.

---

---

### 🛠️ Real Examples:  
(Direct from major codebases where CSRF issues were discovered historically)

- **Django <1.2** — [CSRF token predictable, leading to bypass](https://www.djangoproject.com/weblog/2011/mar/28/security-releases/)
- **Ruby on Rails <3.2.6** — `protect_from_forgery` improperly configured.
- **Express.js (Node.js)** — default body parsers (`body-parser`) made certain attacks feasible if validation was missing.

---
