---
title: "CSP Lockdown: A Practical Guide to Hardening Your Policy Against All 10 Bypass Vectors"
tags:
  - security
  - CSP
  - XSS
  - mitigation
  - web-security
  - hardening
  - content-security-policy
  - defense-in-depth
---

**Challenge to the reader:** Run `curl -sI https://your-site.com | grep -i content-security-policy`. If the output is empty, your CSP hardening journey starts at zero — every bypass in the [attacker's playbook](/2026/07/12/csp-bypass-attacker-playbook.html) is available against your site right now. If you have a policy, copy it into Google's [CSP Evaluator](https://csp-evaluator.withgoogle.com/) — the result tells you exactly how much of this guide applies to you.

---

You've read about [what CSP blocks](/2026/07/12/ten-browser-features-csp-disables.html) and [how attackers bypass it](/2026/07/12/csp-bypass-attacker-playbook.html). This post is different — it's the hands-on implementation guide. No theory, no cataloging. Just concrete steps to lock down each bypass vector, test your policy, deploy it safely, and automate enforcement in CI/CD.

---

## 1. Phase 0: Audit Your Current Policy

Before touching anything, establish a baseline. Run these checks:

```bash
# 1. Does the site even have a CSP?
curl -sI https://your-site.com | grep -i content-security-policy

# 2. Is it enforced or Report-Only?
curl -sI https://your-site.com | grep -i content-security-policy-report-only

# 3. What does the CSP Evaluator say?
# Open https://csp-evaluator.withgoogle.com/ and paste your policy

# 4. Are there inline scripts that will break?
# In DevTools Console:
document.querySelectorAll('script:not([src]):not([nonce])').length
```

Record the results. This is your starting point. Every step below closes a gap you just identified.

**If you have no CSP at all:** Start with Phase 2 (Report-Only). Do NOT jump directly to enforcement — you will break your site.

**If you have a CSP with warnings:** Proceed to Phase 2 for each directive that the CSP Evaluator flagged.

---

## 2. Phase 1: The Non-Negotiable Directives

These directives should be present in every CSP, on every site, with zero exceptions. They have no legitimate use case in modern web applications:

### `object-src 'none'`

```http
Content-Security-Policy: object-src 'none';
```

There is no modern web application that needs `<object>`, `<embed>`, or `<applet>` for plugins. Set this to `'none'` and never think about it again. This closes bypass #4 (missing `object-src`).

### `base-uri 'none'` (or `'self'`)

```http
Content-Security-Policy: base-uri 'none';
```

This directive does NOT inherit from `default-src`. If you omit it, it's unrestricted regardless of how strict everything else is. Set it explicitly. Use `'self'` only if your application legitimately uses `<base>` tags — most don't. This closes bypass #8 (missing `base-uri`).

### `frame-ancestors 'none'` (or `'self'`)

```http
Content-Security-Policy: frame-ancestors 'none';
```

Prevents your page from being embedded in an iframe on an attacker's site. Use `'self'` if your application legitimately frames itself (e.g., a widget preview). This closes clickjacking.

### Verification

After adding these three directives, deploy in **Report-Only mode** and watch logs for 48 hours:

```http
Content-Security-Policy-Report-Only: object-src 'none'; base-uri 'none'; frame-ancestors 'none'; report-uri /csp-reports;
```

These directives almost never generate legitimate violation reports. If they do, investigate before enforcing.

---

## 3. Phase 2: Eliminate `'unsafe-inline'` and `'unsafe-eval'`

These are the two most dangerous keywords in CSP. If your policy contains either one, this phase is your highest priority.

### Step 1: Inventory every inline script

```javascript
// In DevTools Console, find all inline scripts
$$('script:not([src])').forEach((s, i) => {
  console.log(`Inline script #${i}:`, s.textContent.substring(0, 80));
});
```

### Step 2: Choose your migration path

| Scenario | Solution | Complexity |
|---|---|---|
| Few inline scripts (< 10) | Add per-request nonces | Low |
| Many inline scripts or dynamic | Use `strict-dynamic` + one nonced bootstrap | Medium |
| Framework-generated scripts (React, Vue) | Framework already handles this — just add nonce to the single entry `<script>` | Low |
| Cannot modify server for nonces | Use cryptographic hashes (`'sha256-...'`) | Low (but fragile — hashes break on ANY script change) |

### Step 3: Implement nonces

The nonce must be:
1. **Cryptographically random** — use `crypto.randomBytes(16).toString('base64')`, not `Math.random()`
2. **Unique per request** — never reuse a nonce across responses
3. **Unpredictable** — an attacker must not be able to guess it

**Express/Node.js example:**

```javascript
const crypto = require('crypto');

app.use((req, res, next) => {
  res.locals.nonce = crypto.randomBytes(16).toString('base64');
  next();
});

// In template:
// <script nonce="<%= nonce %>" src="/js/app.js"></script>

// Middleware to set header:
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    `script-src 'nonce-${res.locals.nonce}' 'strict-dynamic'; object-src 'none'; base-uri 'none'`
  );
  next();
});
```

**Django example:**

```python
import secrets
import base64

def csp_middleware(get_response):
    def middleware(request):
        nonce = base64.b64encode(secrets.token_bytes(16)).decode('ascii')
        request.csp_nonce = nonce
        response = get_response(request)
        response['Content-Security-Policy'] = (
            f"script-src 'nonce-{nonce}' 'strict-dynamic'; object-src 'none'; base-uri 'none'"
        )
        return response
    return middleware
```

**Nginx (if you can't modify application code):**

Nonces require server-side generation on every request. If you're behind Nginx and can't modify the application, use the `ngx_http_sub_module` or an OpenResty/Lua-based solution to inject nonces. If that's not feasible, fall back to hash-based CSP — but be aware that hashes break on every code change.

### Step 4: Replace `eval()` usage

Search your codebase:

```bash
grep -rn 'eval(' --include='*.js' .
grep -rn 'new Function(' --include='*.js' .
grep -rn "setTimeout.*'.*'" --include='*.js' .
grep -rn "setInterval.*'.*'" --include='*.js' .
```

Common replacements:

| Before | After |
|---|---|
| `eval(jsonStr)` | `JSON.parse(jsonStr)` |
| `new Function('return ' + expr)()` | Write a proper expression parser |
| `setTimeout('doThing()', 100)` | `setTimeout(() => doThing(), 100)` |
| Template engine using `eval` | Switch to a CSP-safe template engine |

---

## 4. Phase 3: Replace Domain Allow-Lists with `strict-dynamic`

Domain allow-lists are the root cause of bypasses 5 (JSONP), 7 (script gadgets), and 10 (open redirect). The fix is always the same: replace them with `'strict-dynamic'` + nonces.

**Before (vulnerable):**

```http
Content-Security-Policy: script-src 'self' https://cdn.jsdelivr.net https://accounts.google.com;
```

This policy is bypassed by JSONP on `accounts.google.com`, script gadgets on `cdn.jsdelivr.net`, and open redirects on any whitelisted domain.

**After (hardened):**

```http
Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic';
```

No domain whitelist. The nonced bootstrap script — which you control — loads all dependencies. `strict-dynamic` propagates trust from the nonced script to its dynamically-created children.

### What about third-party scripts?

For third-party scripts (analytics, monitoring, payment), use `strict-dynamic` with a **loader pattern**:

```html
<!-- Bootstrap: loaded with nonce, loads everything else dynamically -->
<script nonce="r4nd0m123">
  // This script is trusted because it has the nonce
  const s = document.createElement('script');
  s.src = 'https://cdn.jsdelivr.net/npm/some-library@1.0.0/dist/lib.min.js';
  document.head.appendChild(s);  // strict-dynamic propagates trust here
</script>
```

This works for any third-party script that doesn't itself need to create additional scripts. For analytics providers that inject their own scripts (Google Analytics, Datadog RUM), you may need to add specific origins alongside `strict-dynamic` — but use `'strict-dynamic'` as the primary mechanism and only add origins after testing.

---

## 5. Phase 4: Lock Down Remaining Directives

Once `script-src` is hardened, configure the exfiltration-prevention directives:

```http
Content-Security-Policy:
  default-src 'none';
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
  frame-ancestors 'none';
  frame-src 'none';
  connect-src 'self';
  img-src 'self' data:;
  style-src 'self';
  font-src 'self';
  form-action 'self';
  require-trusted-types-for 'script';
  upgrade-insecure-requests;
  report-uri /csp-reports;
```

| Directive | Value | What It Prevents |
|---|---|---|
| `default-src` | `'none'` | Blocks everything not explicitly allowed |
| `connect-src` | `'self'` | Prevents XHR/fetch/WebSocket exfiltration to external servers |
| `img-src` | `'self' data:` | Prevents `<img>` tracking pixel exfiltration |
| `form-action` | `'self'` | Prevents form-based data exfiltration to attacker servers |
| `frame-src` | `'none'` | Prevents iframe injection |
| `require-trusted-types-for` | `'script'` | Blocks `innerHTML`, `outerHTML`, `document.write` — DOM XSS sinks |

**Note on `require-trusted-types-for`:** This enforces the Trusted Types API. If your codebase uses `innerHTML`, `document.write`, or similar DOM sinks, you'll need to refactor to use Trusted Types objects or remove those sinks entirely. Deploy this in Report-Only mode first and collect violation reports for at least one week.

---

## 6. Phase 5: Deployment Strategy

Never deploy an enforced CSP directly to production. The failure mode is catastrophic — your site breaks for every user simultaneously.

### The Safe Deployment Pipeline

```
Week 1-2:  Report-Only mode → collect violations → fix legitimate breaks
Week 3:    Enforce on 10% traffic (canary)
Week 4:    Enforce on 100% traffic
Ongoing:   Monitor violation reports → refine policy
```

### Step 1: Deploy Report-Only

```http
Content-Security-Policy-Report-Only: default-src 'none'; script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; report-uri /csp-reports;
```

### Step 2: Collect and analyze violation reports

Set up a `/csp-reports` endpoint that logs all violation reports to your monitoring system. Each report contains:

```json
{
  "csp-report": {
    "document-uri": "https://your-site.com/page",
    "violated-directive": "script-src",
    "blocked-uri": "inline",
    "line-number": 42,
    "source-file": "https://your-site.com/js/app.js"
  }
}
```

Parse these for:
- **Legitimate breaks**: scripts/styles/resources your application actually needs → add to policy or refactor
- **Attack attempts**: scripts/styles from unexpected origins → investigate for XSS

### Step 3: Fix legitimate violations

Every violation from your own code is a bug in your CSP, not an attack. Fix each one:
- Add the nonce to the script tag
- Whitelist the resource origin (last resort)
- Refactor the code to be CSP-compatible

### Step 4: Canary enforcement

Once violations stabilize (no new legitimate violations for 48+ hours), enable enforcement on a subset of traffic:

```python
# Server-side canary logic
if random.random() < 0.10:  # 10% of requests
    response['Content-Security-Policy'] = policy  # enforce
else:
    response['Content-Security-Policy-Report-Only'] = policy  # report-only
```

Monitor error rates and user reports for 1-2 weeks at 10% before ramping.

### Step 5: Full enforcement

When the canary period is clean, deploy the enforced header to 100% of traffic and remove the report-only header.

---

## 7. Phase 6: CI/CD Integration

Your CSP should be version-controlled and tested like any other security control.

### Validate CSP Syntax

```bash
# Add to CI pipeline
npm install --save-dev csp-parse

# In CI:
echo "$CSP_POLICY" | npx csp-parse --validate
```

### Enforce Nonce Uniqueness

Write a test that verifies your server generates unique nonces per request:

```javascript
// test/csp.test.js
const crypto = require('crypto');

test('CSP nonces are unique across requests', async () => {
  const nonces = new Set();
  for (let i = 0; i < 100; i++) {
    const response = await fetch('/');
    const nonce = response.headers.get('content-security-policy').match(/'nonce-([^']+)'/)[1];
    expect(nonces.has(nonce)).toBe(false);
    nonces.add(nonce);
  }
});
```

### Test for Bypass Prevention

Maintain a test suite that verifies each bypass from the [attacker's playbook](/2026/07/12/csp-bypass-attacker-playbook.html) is blocked by your policy:

```javascript
test('unsafe-inline bypass is blocked', async () => {
  const page = await browser.newPage();
  await page.goto('https://staging.your-site.com');
  
  const result = await page.evaluate(() => {
    const script = document.createElement('script');
    script.textContent = 'window.__csp_test = 1;';
    document.head.appendChild(script);
    return window.__csp_test;
  });
  
  expect(result).toBeUndefined();  // Inline script was blocked
});
```

---

## 8. Quick Reference: Which Fixes Close Which Bypasses

| Bypass | Fix | Directive |
|---|---|---|
| `unsafe-inline` | Remove keyword, add nonces | `script-src` |
| `unsafe-eval` | Remove keyword | `script-src` |
| Wildcard | Remove `*` | `script-src` |
| Missing `object-src` | Set `object-src 'none'` | `object-src` |
| JSONP endpoints | Nonces + `strict-dynamic` | `script-src` |
| File upload bypass | Serve from different origin | `script-src`, server config |
| CDN script gadgets | Nonces + `strict-dynamic` | `script-src` |
| Missing `base-uri` | Set `base-uri 'none'` | `base-uri` |
| `data:` URI scripts | Remove `data:` | `script-src` |
| Open redirect chain | Nonces + `strict-dynamic` | `script-src` |

---

## 9. The Complete Hardened Policy

```http
Content-Security-Policy:
  default-src 'none';
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
  frame-ancestors 'none';
  frame-src 'none';
  connect-src 'self';
  img-src 'self' data:;
  style-src 'self';
  font-src 'self';
  form-action 'self';
  require-trusted-types-for 'script';
  upgrade-insecure-requests;
  report-uri /csp-reports;
```

Key properties of this policy:
- `default-src 'none'` — blocks everything not explicitly allowed
- `'nonce-{RANDOM}'` — only scripts with the per-request nonce execute
- `'strict-dynamic'` — trust propagates from nonced scripts to dynamically-loaded children; eliminates domain-allow-list bypasses
- `object-src 'none'` — blocks all plugin content
- `base-uri 'none'` — blocks `<base>` tag injection (crucial: not inherited from `default-src`)
- `require-trusted-types-for 'script'` — enforces Trusted Types, preventing DOM-based XSS via `innerHTML` and similar sinks
- `report-uri /csp-reports` — every violation is logged; you can detect both configuration errors and real attacks

---

**Final challenge:** Deploy the complete hardened policy above in Report-Only mode on your staging environment. Wait 24 hours. Collect the violation reports. Every report is either a bug in your code (fix it) or a false positive in this guide (I want to hear about it — contact me). Once you have zero violations for 48 consecutive hours, deploy to production enforcing on 10% traffic. This is not a thought experiment — it's your next sprint ticket.

The companion posts — [what CSP blocks by default](/2026/07/12/ten-browser-features-csp-disables.html) and the [attacker's bypass playbook](/2026/07/12/csp-bypass-attacker-playbook.html) — provide the context for why each directive in this guide exists. This guide is the *how*; those posts are the *what* and the *why*.

---

## References

- [CSP Evaluator — Google](https://csp-evaluator.withgoogle.com/)
- [CSP Level 3 Specification — W3C](https://www.w3.org/TR/CSP3/)
- [Trusted Types Specification — W3C](https://w3c.github.io/trusted-types/dist/spec/)
- [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
- [strict-dynamic explainer — web.dev](https://web.dev/strict-csp/)
