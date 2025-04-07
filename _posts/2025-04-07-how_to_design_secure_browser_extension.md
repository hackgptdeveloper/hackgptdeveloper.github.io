---
title: "Chrome browser extension for webapp security"
tags:
  - extension
---

Alright — you're asking **how to design a Chrome Extension** from the ground up with **full security discipline**, and you want it **chained all the way down** to **specs**, **source code**, and **browser internals**.  
Let's go **deep and detailed** like last time. 🧠⚙️

---

# **1. Threat Model for Chrome Extensions**

First, understand **how extensions are attacked**:

| Threat | Example |
|:---|:---|
| **Privilege Escalation** | Extension gets too much permission, used by attacker |
| **XSS in Extension Pages** | Popup.html vulnerable to script injection |
| **Message Forgery** | Untrusted websites sending forged `chrome.runtime.sendMessage()` |
| **Content Script Injection** | Content scripts leaking sensitive page data |
| **Manifest Spoofing / Typosquatting** | User installs malicious extension |
| **Supply Chain Attacks** | 3rd party libraries embedded insecurely |

---

# **2. Security Critical Features To Design Carefully**

---

## 2.1. **Minimal `manifest.json` Permissions**

**What**:  
Grant only the absolute minimum permissions.

**Origin**:  
- [Chrome Extension Manifest V3 Spec](https://developer.chrome.com/docs/extensions/mv3/manifest/)

**Example** (bad):
```json
{
  "permissions": ["tabs", "storage", "cookies", "webRequest", "*://*/"]
}
```
→ Huge attack surface!

**Example** (good):
```json
{
  "permissions": ["storage"],
  "host_permissions": ["https://your-site.example.com/*"]
}
```

**Chain to Source Code**:
- **Chromium**: [Permission Parsing](https://source.chromium.org/chromium/chromium/src/+/main:extensions/common/permissions/permissions_data.cc)

  ```cpp
  PermissionsData::HasAPIPermission()
  PermissionsData::HasHostPermission()
  ```
- Decides runtime access control for API calls.

---

## 2.2. **Isolate Content Scripts Properly**

**What**:  
- Content scripts run in the context of the target web page but are **isolated** via an *isolated world*.

**Risk**:
- Content script can leak secrets from page or be attacked by page scripts.

**Secure Handling**:
- Always treat DOM inputs as untrusted.
- Use messaging to background scripts to handle privileged actions.

**Spec Reference**:
- [Chrome Content Scripts Docs](https://developer.chrome.com/docs/extensions/mv3/content_scripts/)

**Chain to Source Code**:
- **Chromium**: [Content script injection mechanism](https://source.chromium.org/chromium/chromium/src/+/main:extensions/renderer/resources/web_accessible_resources.html)

  `content_scripts` injected through `UserScriptSet::InjectScripts()`.

---

## 2.3. **Use Strict CSP (Content Security Policy)**

**What**:  
- Extensions must enforce a strict **CSP** to prevent XSS inside their own pages (popup.html, options.html, etc.)

**Default MV3 CSP**:
```http
Content-Security-Policy: script-src 'self'; object-src 'self'
```

**Secure Customizations**:
- Avoid `unsafe-inline`
- Avoid remote script loads.

**Spec Reference**:
- [Extension CSP Spec](https://developer.chrome.com/docs/extensions/mv3/csp/)

**Chain to Source Code**:
- **Chromium**: [CSP header application](https://source.chromium.org/chromium/chromium/src/+/main:extensions/renderer/extension_frame_helper.cc)

  Applied automatically during extension frame navigation setup.

---

## 2.4. **Secure Messaging (chrome.runtime.sendMessage)**

**What**:  
- Extensions use `chrome.runtime.sendMessage` or `chrome.runtime.onMessage` to pass messages internally or from web pages.

**Risk**:
- External sites can spoof messages if listeners are poorly validated.

**Best Practices**:
- **Validate sender** inside `onMessage`.
- Use `chrome.runtime.connect` with ports if needed for more structured communications.

**Example**:
```javascript
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (sender.origin !== 'https://trusted.example.com') {
    return;
  }
  // process message safely
});
```

**Spec Reference**:
- [Messaging API](https://developer.chrome.com/docs/extensions/mv3/messaging/)

**Chain to Source Code**:
- **Chromium**: [chrome.runtime.onMessage dispatcher](https://source.chromium.org/chromium/chromium/src/+/main:extensions/browser/api/messaging/message_service.cc)

  `MessageService::DispatchMessage()` checks internal permissions.

---

## 2.5. **Background Scripts in MV3 (Service Workers)**

**What**:  
- MV3 replaces persistent background pages with **background service workers**.

**Security Benefit**:
- Service workers have no DOM access.
- Lifetime is limited — reduces long-term attack surface.

**Important**:
- Handle message passing asynchronously.
- Revalidate everything on fresh service worker startup.

**Spec Reference**:
- [Background Service Workers in MV3](https://developer.chrome.com/docs/extensions/mv3/service_workers/)

---

## 2.6. **Declarative Net Request API**

**What**:  
- MV3 extensions should use **declarativeNetRequest** instead of `webRequest` where possible.

**Security Win**:
- No access to raw network request data.
- Only declarative rules.
- Harder to leak data or manipulate unauthorizedly.

**Example**:
```json
"declarative_net_request": {
  "rule_resources": [{
    "id": "ruleset_1",
    "enabled": true,
    "path": "rules.json"
  }]
}
```

**Spec Reference**:
- [Declarative Net Request API](https://developer.chrome.com/docs/extensions/reference/declarativeNetRequest/)

---

## 2.7. **Web Accessible Resources Restrictions**

**What**:  
- Extensions can declare which internal files are visible to external websites.

**Secure Usage**:
- Avoid making sensitive resources (`popup.html`, `background.js`) web-accessible unless **absolutely necessary**.

**Example**:
```json
"web_accessible_resources": [
  {
    "resources": ["image1.png"],
    "matches": ["https://trusted.example.com/*"]
  }
]
```

**Chain to Source Code**:
- **Chromium**: [Web Accessible Resources enforcement](https://source.chromium.org/chromium/chromium/src/+/main:extensions/common/manifest_handlers/web_accessible_resources_info.cc)

---

## 2.8. **Extension Origin Isolation**

**What**:
- Extensions run under `chrome-extension://<uuid>/` origins.

**Risk**:
- If web pages link to extension resources improperly, data leaks can occur.

**Mitigations**:
- Use strict `CSP`.
- Limit `web_accessible_resources`.
- Validate extension ID origin inside communications.

---

# **3. Bonus: Browser Internal Security Protections**

| Protection | How It Works | Chromium Code Link |
|:---|:---|:---|
| Site Isolation | Extensions render separately from webpages | [//content/browser/site_per_process/](https://source.chromium.org/chromium/chromium/src/+/main:content/browser/site_per_process/) |
| Origin Trials | Control features via opt-ins | [//content/browser/origin_trials/](https://source.chromium.org/chromium/chromium/src/+/main:content/browser/origin_trials/) |
| Sandboxing Extension Processes | Each extension gets a low-privilege renderer | [//extensions/renderer/](https://source.chromium.org/chromium/chromium/src/+/main:extensions/renderer/) |

---

# **4. Full Security Checklist for Extension Development**

✅ Use MV3 Service Workers (no background page)  
✅ Minimal permissions in `manifest.json`  
✅ Strict CSP (`script-src 'self'`)  
✅ Content scripts isolated from page  
✅ Validate all `chrome.runtime` message origins  
✅ Limit web accessible resources  
✅ No remote code (no eval, no remote scripts)  
✅ Use `declarativeNetRequest` instead of `webRequest`  
✅ Audit and freeze external libraries (npm, etc.)  
✅ Follow defense-in-depth (assume compromise possible at every boundary)

---

# **5. Final Offer**

If you want, I can go **one level deeper**:

- **Trace real-world extension attacks** like *DataSpii*, *Augury* and show you where they failed on each of these points.
- **Show extension lifecycle internals** (extension loading → permission granting → renderer spawning flow inside Chromium).
- **Real examples of secure extension projects** you can reference.

---
  
Would you like me to dig into **real-world attack case studies** + **source code traces** too? 🔥🚀  
(We can go way deeper if you want.)  

