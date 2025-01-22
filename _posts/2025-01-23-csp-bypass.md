---
title: "Client Side CSP Bypass"
tags:
  - CSPBypass
---

Here’s a detailed list of 30 ways client-side Content Security Policy (CSP) bypasses are possible, with explanations and references to potential vulnerabilities:

### 1. **Inline Script Execution via `nonce` or `hash` Injection**
   - **Description**: Attacker gains control over `nonce` or `hash` values used to whitelist inline scripts.
   - **Exploit**: Injecting matching `nonce` or `hash` in malicious scripts.

### 2. **JSONP Abuse**
   - **Description**: Exploiting JSONP endpoints to deliver JavaScript payloads.
   - **Exploit**: Using JSONP callbacks to execute script responses.

### 3. **DOM-based Script Injections**
   - **Description**: Manipulating DOM properties like `innerHTML`, `outerHTML`, or `document.write`.
   - **Exploit**: Injecting scripts into the DOM structure where CSP rules do not apply effectively.

### 4. **Overly Permissive `script-src` Directive**
   - **Description**: Allowing unsafe domains or `*` in `script-src`.
   - **Exploit**: Loading scripts from attacker-controlled domains.

### 5. **Bypass via `data:` URI**
   - **Description**: CSP not restricting `data:` URIs in `script-src`.
   - **Exploit**: Encoding malicious scripts in `data:` URLs.

### 6. **Missing or Misconfigured `base-uri`**
   - **Description**: Lack of `base-uri` restriction allows redirection abuse.
   - **Exploit**: Malicious base URI redirection to attacker-controlled resources.

### 7. **MIME Type Sniffing**
   - **Description**: Misconfigured server allowing MIME type sniffing for scripts.
   - **Exploit**: Content with incorrect MIME types being executed as JavaScript.

### 8. **Script Gadget Inclusion**
   - **Description**: Reuse of existing trusted scripts to construct malicious payloads.
   - **Exploit**: Combining benign script fragments to perform malicious actions.

### 9. **`object-src` or `embed-src` Weakness**
   - **Description**: Allowing `object` or `embed` elements from non-trusted origins.
   - **Exploit**: Embedding scripts via Flash or legacy plugins.

### 10. **Using `javascript:` URLs**
   - **Description**: CSP allows `javascript:` URLs if improperly restricted.
   - **Exploit**: `javascript:alert(1)` type payloads.

### 11. **Form Action CSP Bypass**
   - **Description**: Misconfiguring `form-action` directive.
   - **Exploit**: Redirecting form actions to malicious endpoints.

### 12. **Event Handlers and Inline JavaScript**
   - **Description**: Inline event handlers (`onclick`, `onmouseover`) without restrictions.
   - **Exploit**: Inline handler executing attacker’s JavaScript.

### 13. **CSS Injection for Script Execution**
   - **Description**: Exploiting CSS for JavaScript-like behaviors.
   - **Exploit**: Leveraging `expression()` or `@import` for malicious content (deprecated but still a risk in legacy contexts).

### 14. **Redirect Chains and CSP**
   - **Description**: Redirecting to exploit allowed sources.
   - **Exploit**: Chaining redirects to bypass `script-src`.

### 15. **Bypassing with `meta` CSP**
   - **Description**: Using inline `<meta http-equiv="Content-Security-Policy">`.
   - **Exploit**: Overwriting effective CSP with a weaker one.

### 16. **Use of Worker Scripts (`Worker`, `SharedWorker`)**
   - **Description**: Allowing `worker-src` from insecure origins.
   - **Exploit**: Running scripts in isolated worker contexts.

### 17. **WebAssembly Abuse**
   - **Description**: Loading WebAssembly from less restricted sources.
   - **Exploit**: Malicious WASM binaries circumventing `script-src`.

### 18. **Service Workers and CSP**
   - **Description**: Service workers executing cached or offline scripts.
   - **Exploit**: Using service worker manipulation to bypass CSP.

### 19. **SVG Animation for Script Injection**
   - **Description**: Embedding scripts in SVG files.
   - **Exploit**: `<script>` tags or `animate` elements in SVG.

### 20. **CSP Header Injection**
   - **Description**: Manipulating HTTP headers to inject a custom CSP.
   - **Exploit**: Setting a weak or no-op CSP.

### 21. **Mixed Content Vulnerability**
   - **Description**: Loading mixed content despite CSP.
   - **Exploit**: HTTP content injected into HTTPS contexts.

### 22. **XSS Reflected Payload with CSP Gaps**
   - **Description**: Reflecting user input in CSP-ignored contexts.
   - **Exploit**: CSP misconfigurations allowing script injection.

### 23. **Misuse of `trusted-types`**
   - **Description**: Misconfiguring `TrustedTypes` policy.
   - **Exploit**: Bypassing protections with non-strict policies.

### 24. **Weak `default-src` Directive**
   - **Description**: Insufficient restrictions in `default-src`.
   - **Exploit**: Implicitly allowing script execution.

### 25. **File Scheme Privilege**
   - **Description**: Allowing `file://` in CSP rules.
   - **Exploit**: Loading local files.

### 26. **Browser-Specific CSP Bugs**
   - **Description**: Exploiting implementation bugs.
   - **Exploit**: Using browser quirks for bypasses.

### 27. **Using Blob or Object URLs**
   - **Description**: CSP allowing `blob:` or `filesystem:` URLs.
   - **Exploit**: Loading JavaScript via Blob URLs.

### 28. **Clickjacking and CSP**
   - **Description**: Poor frame-ancestor configurations.
   - **Exploit**: Framing pages for clickjacking.

### 29. **Cross-Origin Resource Sharing (CORS) Misconfiguration**
   - **Description**: Combining CORS issues with CSP bypass.
   - **Exploit**: Script access from cross-origin resources.

### 30. **Resource Exhaustion or Policy Parsing Bugs**
   - **Description**: Exploiting parser limits or errors.
   - **Exploit**: Malformed CSP headers causing fallback to unsafe defaults.

---

By understanding these bypasses, you can better assess CSP configurations and ensure robust client-side security. These scenarios are context-dependent, so thorough testing and secure defaults are essential.

