---
title: "JSWZL II: automation tools for javascript analysis"
tags:
  - Javascript
---

A **full, weapon-grade JSWZL cheat sheet** tailored specifically for:

* **Bug bounty hunters**
* **Pentesters**
* **Reverse-engineering obfuscated JavaScript**
* **Client-side endpoint discovery**
* **SPA (React/Angular/Vue) analysis**
* **Integrating JSWZL output into fuzzing / Burp / automation pipelines**

This will be **step-by-step**, low-level, and highly tactical.

---

# 🔥 JSWZL — The Ultimate Bug-Bounty & JavaScript Analysis Cheat Sheet

**Complete Workflow, Filters, Code Extractions, Payload Crafting, Automation**

---

# 1. What You Must Install

### (A) JSWZL (cloud-hosted or self-hosted instance)

* Create account → [https://jswzl.io](https://jswzl.io)
* Get the **API endpoint** + **token** (you’ll use it later for automation).

### (B) Burp Suite Plugin (“JSWZL Proxy Forwarder”)

* Lets JSWZL ingest:

  * `.js`
  * `.js.map` (source-maps)
  * HTML with inline `<script>`
  * Lazy-loaded chunks

### (C) VS Code Extension (“JSWZL”)

* Lets you explore descriptors:

  * Call expressions
  * Object schemas
  * String expressions
  * Fetch/XHR/GraphQL calls
  * LocalStorage/SessionStorage/cookie sinks
  * Event handlers
  * Message events
  * Crypto usage
  * Dangerous patterns

---

# 2. Perfect Setup (Bug Bounty)

Below is a **battle-tested configuration** for maximum JS capture.

### Burp → User Options → Misc → MIME types

Enable forwarding for:

```
text/javascript
application/javascript
application/x-javascript
application/json
text/html
application/octet-stream
```

### Burp → Proxy → Match/Replace

(Optional) Inject preloading JS to trigger Webpack chunk loads:

```
Match: </body>
Replace: <script>setTimeout(()=>window.scrollTo(999999,999999),2000);</script></body>
```

This forces **lazy-loaded chunks to fetch**, which JSWZL can then capture!

---

# 3. The Four JSWZL Descriptor Types and Why They Matter

JSWZL extracts descriptors — these are the **atomic units** you use for exploitation.

## (1) **String Expressions**

Extracts anything that looks like:

* API paths
* URLs
* Query strings
* Environment config
* Tokens / keys
* Feature flags
* GraphQL query bodies
* Regex validation patterns

Example hit you’ll see:

```
/api/user/delete
/v1/admin/auth/refresh
/graphql
eyJhbGciOi...
firebase-api-key-1234
```

🧨 **Use:** Identify hidden endpoints, API versions, GraphQL mutations, feature toggles, internal paths.

---

## (2) **Object Schemas**

Extracted from literal objects passed into:

* `fetch()`
* `axios()`
* `XMLHttpRequest`
* `postMessage`
* `localStorage.setItem`
* Redux/RTK action payloads
* React Query descriptors

Example:

```json
{
  "method": "POST",
  "headers": {
    "x-api-key": "abcd1234"
  },
  "body": {
    "userId": 123,
    "role": "admin"
  }
}
```

🧨 **Use:**

* Build exact fuzzing payloads
* Dump all client-side tokens
* Reverse engineer internal permission logic
* Build full API schemas without server docs

---

## (3) **Call Expressions**

JSWZL classifies calls to:

* `fetch()`, `axios()`, `XMLHttpRequest`
* DOM sinks (`innerHTML`, `document.write`)
* Storage sinks (`localStorage.setItem`)
* Crypto (`crypto.subtle.encrypt`)
* Messaging (`window.postMessage`)
* WebSocket connections
* Analytics SDK calls
* Feature toggles
* Event handlers

Example:

```
fetch("/internal/api/report/export", {...})

window.addEventListener("message", ...)

crypto.subtle.encrypt(...)
```

🧨 **Use:**

* Discover unlinked backend APIs
* Find XSS sinks
* Map client-side crypto/encryption
* Identify cross-origin message flows
* Detect internal admin functionality

---

## (4) **Behavioral Flows**

JSWZL identifies:

* Navigation patterns
* Access checks (`if (role !== 'admin')`)
* Hidden UI flows
* Multi-step processes
* Payment and transaction logic
* JWT/Tokens refresh cycles

🧨 **Use:**

* Identify privilege escalation
* Find bypassable client-side auth
* Reverse engineer SPA logic
* Spot insecure client-side access checks

---

# 4. The JSWZL → Attack Workflow (Full Pentest Pipeline)

Here’s the **canonical pipeline** JSWZL gives you:

---

## **STEP 1 — Inject and capture everything**

Browse:

* login
* dashboard
* all menus
* deep subpages
* admin-looking pages
* payment pages
* profile pages
* everything

Use forced scroll to load chunks:

```js
setInterval(() => window.scrollTo(999999, 999999), 1000);
```

---

## **STEP 2 — Open JSWZL → Filter by “String Expressions”**

Apply filters:

**Path-like strings**

```
/api/
/v1/
/internal/
/admin/
/graphql
/upload
/payment
/auth
/refresh
```

**Secrets-like patterns**

```
key
token
auth
jwt
secret
```

Extract EVERYTHING suspicious.

---

## **STEP 3 — Filter “CallExpressions → fetch / axios / graphql”**

Set filter:

```
descriptorType = CallExpression
and
callee includes "fetch" OR "axios" OR "graphql" OR "XMLHttpRequest"
```

This produces your **master API list**.

🎯 **Important:**
JSWZL links:

* endpoint
* payload schema
* originating source file
* variables used

So you get:

**Endpoint → Body → Headers → Auth → File → Code snippet**

This is >90% of your recon done.

---

## **STEP 4 — Filter “ObjectSchema → body / headers”**

Look for:

* roles
* feature flags
* toggles
* hidden parameters
* hidden admin flags

Examples found in real apps:

```
"role": "admin"
"isAdmin": false
"bypassOtp": true
"debug": true
"tier": "enterprise"
```

These lead to:

* privilege escalation
* feature unlocking
* admin panel discovery
* logic bypass

---

## **STEP 5 — Search for “JWT”, “token”, or storage sinks**

Filter:

```
CallExpression AND callee="localStorage.setItem"
```

You immediately find:

* session tokens
* refresh tokens
* impersonation tokens
* OAuth keys

This is critical for session hijacking.

---

## **STEP 6 — Search for hidden GraphQL queries**

Filter:

```
StringExpression contains "{"
and contains "query" OR "mutation"
```

You’ll uncover:

* hidden mutations
* admin-only queries
* unlinked operations

---

## **STEP 7 — Export EVERYTHING via GraphQL API**

JSWZL API supports descriptors query.

Example collector script:

```bash
curl -X POST https://your-jswzl/api/graphql \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "query": "query{
          descriptors{
            id
            type
            fileName
            snippet
            metadata
          }
        }"
      }' > jswzl_dump.json
```

You can then feed this into:

* Intruder
* ffuf
* Nuklear
* Your Burp extension
* Python fuzzer

---

# 5. Automate: Convert JSWZL → Fuzz Targets

### Extract only API endpoints:

```bash
jq -r '.data.descriptors[]
  | select(.type=="StringExpression")
  | .snippet
  | select(test("^/"))' jswzl_dump.json \
  > endpoints.txt
```

### Extract only POST bodies:

```bash
jq -r '.data.descriptors[]
  | select(.type=="ObjectSchema")
  | .snippet' jswzl_dump.json \
  > bodies.json
```

### Extract only storage leaks:

```bash
jq -r '.data.descriptors[]
  | select(.snippet|test("localStorage|sessionStorage"))' \
  jswzl_dump.json
```

### Extract all secrets:

```bash
jq -r '.data.descriptors[]
  | select(.snippet|test("key|token|secret|auth"))' \
  jswzl_dump.json
```

---

# 6. Exploit Mapping — What Each Descriptor Means for Vulnerability Types

| Descriptor Type                 | Typical Vulnerability          |
| ------------------------------- | ------------------------------ |
| StringExpression → hidden paths | IDOR, privilege escalation     |
| ObjectSchema → admin flags      | Feature bypass, admin takeover |
| CallExpression → cookie writes  | XSS, session fixation          |
| CallExpression → crypto         | Hard-coded keys, weak crypto   |
| Event handlers                  | UXSS, CSRF via postMessage     |
| Storage sinks                   | Token theft, impersonation     |
| Navigation flows                | Unauthorized page access       |
| GraphQL queries                 | Hidden mutations               |

---

# 7. Real-World Example (SPA / React / Admin Panel)

You might find:

```
fetch("/api/v3/admin/user/list", {...})
if(user.role !== "admin") redirect("/")
body: { plan:"enterprise", features:["unlock_admin"] }
"CanDisable2FA": true
localStorage.setItem("jwt", token)
ws://internal.company.com:8080/socket
```

This leads directly to:

* Admin API enumeration
* Feature unlock
* Role bypass
* 2FA bypass
* Token hijacking
* Internal WebSocket exploration

---

# 8. Final Add-ons: Modules You Should Always Enable

### ☑ Auto-source-map resolution

De-minifies, restores variable names.

### ☑ Auto-chunk fetching

Loads all hidden lazy chunks.

### ☑ Descriptor Extraction for:

* `fetch`
* `axios`
* `crypto.subtle`
* `postMessage`
* `localStorage`
* `eval`
* `Function()`
* `WebSocket`
* `navigator.sendBeacon`
* `BroadcastChannel`

---
