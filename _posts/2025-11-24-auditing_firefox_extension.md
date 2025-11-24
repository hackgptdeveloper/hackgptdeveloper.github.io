---
title: "security-research–grade procedure to audit a Firefox extension"
tags:
  - Firefox extension
  - Javascript
  - Reverse engineering
---

This is a generic procedure you can audit to *any* .xpi extension.
Structured as static source review to dynamic runtime instrumentation to privilege boundary analysis to network forensics to permission modeling to supply chain verification.

---

# **1. Obtain the Real Source Code**

Firefox extensions are distributed as **XPI** (zip) archives.

### **Steps**

1. Download the `.xpi` file:

   * From AMO: click *download file* (→ ends with `.xpi`)
   * Or via local installation folder:

     * Linux: `~/.mozilla/firefox/<profile>/extensions/*.xpi`
2. Unzip:

   ```bash
   unzip addon.xpi -d addon_src/
   ```

### **Files to pay attention to**

* `manifest.json`
* `background.js`, `background.html`
* `content_scripts/*`
* `modules/*`
* `assets/*.js` or `.mjs`
* `browser_action/` or `sidebar/`
* `web_accessible_resources`
* Any `.wasm` or `.json` files

---

# **2. Manifest.json Analysis (Privilege, Surface, Entry Points)**

This is the highest-value file. Focus on:

### **A. Permissions Review**

Look at entries like:

* `"permissions": [...]`
* `"host_permissions": [...]`
* `"optional_permissions": [...]`

Flag any powerful permissions:

* `"<all_urls>"`
* `"tabs"`
* `"cookies"`
* `"webRequest"` or `"webRequestBlocking"`
* `"nativeMessaging"`
* `"proxy"`
* `"devtools"`

### **B. Background Operation**

Check:

* `"background": { "scripts": [...] }`
* `"background.service_worker"` in new MV3 extensions

These contain the core logic.

### **C. Web-Accessible Resources**

If present:

```json
"web_accessible_resources": [{
  "resources": ["*.js", "*.html"],
  "matches": ["<all_urls>"]
}]
```

This allows **web pages to read extension files**, enabling:

* Data exfiltration
* Keylogger injection
* Extension compromise

Red flag if any JS is exposed.

---

# **3. Static Code Review (JavaScript)**

Search for dangerous APIs and obfuscation.

### **A. Obfuscated Code Detection**

Look for:

* Random variable names (`_0x4d3eab`, etc.)
* eval chains:

  ```js
  eval(atob("..."))
  new Function(...)
  setTimeout("code()", 10)
  ```
* Extremely large arrays of hex/char codes

If obfuscated → treat as malicious until proven otherwise.

### **B. Dangerous WebExtension APIs**

Search in code:

* `browser.webRequest`
* `browser.cookies`
* `browser.proxy`
* `browser.tabs.executeScript`
* `browser.permissions.request`

Each implies security impact.

### **C. XHR/Fetch Exfiltration**

Look for unexpected domains:

```bash
grep -R "fetch(" -n addon_src/
grep -R "XMLHttpRequest" -n addon_src/
grep -R "http://" -n addon_src/
grep -R "https://" -n addon_src/
```

### **D. Keylogging & Page Injection**

Search for:

* `document.addEventListener("keydown")`
* `contentScript.sendMessage`
* `browser.tabs.executeScript({code: ...})`

### **E. Crypto / WebAssembly**

Suspicious if:

* WASM module loaded
* Crypto operations imported from unknown libraries

---

# **4. Dynamic Analysis (Runtime Behavior in Firefox)**

Create a separate audit profile:

```bash
firefox -CreateProfile audit
firefox -P audit
```

Install the extension manually:

* `about:addons` → install from file.

### **A. Inspect Background Script**

Open:

```
about:debugging#/runtime/this-firefox
```

→ inspect the extension
→ open devtools console

Watch real-time activity:

* Network panel
* Console logs
* Storage changes
* WebRequest activity

### **B. Monitor Network Traffic**

Use:

* Firefox DevTools
* Burp Suite (with system proxy)
* mitmproxy

Look for:

* Unexpected outbound domains
* POST requests with potentially sensitive data
* Hardcoded API keys
* Frequent polling

### **C. Check Storage APIs**

```
browser.storage.local
browser.storage.sync
```

See if anything sensitive is stored unencrypted.

---

# **5. Behavior Inspection Under Various Permissions**

Some extensions elevate permissions dynamically:

```
browser.permissions.request()
```

Test:

1. Install extension.
2. Use main features.
3. Observe if it asks for elevated permissions.
4. Compare new capabilities vs claimed functionality.

---

# **6. IPC and Message-Passing Analysis**

Look at:

* `browser.runtime.onMessage.addListener`
* Messages between:

  * content scripts
  * background scripts
* Any external message passing:

  * `"externally_connectable"` field

Check for:

* Data sent from pages → extension → remote server.
* Arbitrary code execution via message injection.

---

# **7. Supply-Chain Audit**

### **A. External Libraries**

Check all third-party JS:

* Look for minified files like `jquery.min.js`, `lib.js`
* Compute hash:

  ```bash
  shasum -a 256 file.js
  ```
* Compare with upstream project releases.

### **B. CDN Dependencies**

If the extension loads scripts from the Internet:

```html
<script src="https://cdn.example.com/script.js"></script>
```

→ Immediate supply-chain risk (CDN can inject malicious code).

### **C. Check Update URL**

In manifest:

```json
"update_url": "https://example.com/update.json"
```

Ensure:

* Uses HTTPS
* Domain belongs to developer
* No MITM vulnerabilities

---

# **8. Reverse Engineering (Optional but High Value)**

### **A. JavaScript Beautification**

```bash
npx js-beautify file.js -o pretty.js
```

### **B. Deobfuscation**

Using:

* `javascript-deobfuscator`
* `de4js`
* Node-based AST tools (acorn, esprima)

### **C. WASM Disassembly**

If `.wasm` found:

```bash
wasm2wat file.wasm
```

---

# **9. Permission-to-Behavior Matching**

Make a table:

| Permission           | Legitimate Need                        | Code Path | Red Flags                 |
| -------------------- | -------------------------------------- | --------- | ------------------------- |
| `<all_urls>`         | Should the extension access all sites? | Yes/No    | Danger if unjustified     |
| `tabs`               | Does UI rely on tabs?                  | Yes/No    | Overprivilege             |
| `webRequestBlocking` | Only needed for ad blockers            |           | Very suspicious otherwise |
| `nativeMessaging`    | Only enterprise apps                   |           | Massive privilege risk    |

If requested permission does *not* correspond to actual functionality → potential malicious activity.

---

# **10. Evaluate Against Known Malicious Patterns**

Malware families often display patterns:

* URL scanning / harvesting
* Affiliate link rewriting
* Hidden mining scripts
* Backdoor update channels
* Injecting ads into pages

Search for known indicators:

* `chrome-extension://`
* URL rewrites
* Canvas fingerprinting
* Browser fingerprint JS bundles

---

# **11. Final Reporting Checklist**

Produce a report containing:

### ✔ Manifest privileges and risk level

### ✔ Code quality (clear, minified, obfuscated)

### ✔ External domains contacted

### ✔ Unexpected data flows

### ✔ Storage of sensitive info

### ✔ Overprivileged permission set

### ✔ Deviations from functionality claims

### ✔ Potential malicious indicators

### ✔ Supply-chain anomalies

---
