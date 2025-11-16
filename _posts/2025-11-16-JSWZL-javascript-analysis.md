---
title: "JSWZL: automation tools for javascript analysis"
tags:
  - Javascript
---

## JSWZL (a.k.a “JS Weasel”)

![Image](https://cdn.prod.website-files.com/62eba6b8d1f478779b13391c/64aeb15b0c61eb6dcea9a3d7_6481a9a95c7d7eb7727a9cfe_screenshot2-p-1080.png)

![Image](https://cdn.prod.website-files.com/62eba6b7d1f478205413390e/6481a9a95c7d7eb7727a9cfe_screenshot2.png)

![Image](https://raw.githubusercontent.com/kufii/CodeSnap/master/examples/material_operator-mono.png)

Here’s a deep technical breakdown of JSWZL — what it is, how it works under the hood, how it fits into a web-app security/pentesting workflow (which I know you’re into), the strengths & limitations, and practical steps to integrate it into your setup (Spring Boot / React / microservices stack or bug-bounty work).

---

### What is JSWZL

* JSWZL (“Weasel” / “JS Weasel”) is a tool aimed at **static analysis of JavaScript code** within web applications, specifically targeted at web‐app security testers and pentesters. ([Jswzl][1])
* It supports:

  * Ingestion of JS/HTML via a proxy plugin (e.g., for Burp Suite) so the tool can capture JS code served to a browser and perform analysis. ([Jswzl][1])
  * A VS Code extension for browsing the analysed output (source tree, descriptors, endpoints, etc.). ([Jswzl][2])
* The blog post by the founder describes it as “the next stage in the evolution of tooling for penetration testers, web application security testers … anyone who spends time testing web applications.” ([Jswzl][1])
* The features list: discovery of relevant string expressions (paths, secrets, GraphQL queries), object schemas (HTTP request payloads etc), call patterns (AJAX/XHR/fetch, sinks like localStorage/cookie) and client-behavior (event handlers, message passing) in one overview. ([Jswzl][2])

---

### Why it matters for your context (web app pentesting, bug-bounty, JS analysis)

Given that you have interest in reverse-engineering obfuscated JS, analyzing SPAs, client-side behavior, this tool addresses those pain points:

* Many modern apps deliver large bundles (SPA frameworks like React/Angular) with code-splitting, dynamic chunk loading, minification, source‐maps; manual JS analysis is tedious. JSWZL automates:

  * detection & application of source‐maps to recover original source. ([Jswzl][1])
  * detection & pre-fetching of lazy-loaded chunks (i.e., Webpack splitted modules). ([Jswzl][1])
  * unpacking of packed/minified code and re-structuring the code for easier reading (“Prettify”). ([Jswzl][2])
* It then uses AST analysis / static analysis passes (String Expression → Object Schema → Call Expression) to extract “descriptors” (interesting code constructs) to help you target endpoints / payloads / sinks more quickly. ([Jswzl][1])
* For a bug-bounty hunter (your domain) this means: faster enumeration of endpoints, payload shapes, client behavior that might yield injection/authorization/logic flaws. For example extracting array of path-looking strings to feed into intruder/fuzzer. ([Jswzl][1])

---

### How it works: Internals & stages

Drilling into the technical pipeline (from blog post + docs):

1. **Pre‐analysis stage**

   * Detects whether a source map (`.js.map`) exists for a served JS file and applies the map to recover original variable/function names where possible. ([Jswzl][1])
   * Detects chunk‐loader patterns (e.g., Webpack’s `import()` or `__webpack_require__.e(...)`) via heuristics or a lightweight sandbox/runtime, then fetches the lazy chunks. This is important because many code paths are hidden behind lazy load. ([Jswzl][1])

2. **Optimization stage**

   * Takes minified/obfuscated code and rewrites/normalizes it: e.g., rewriting common patterns of useless indirection, variable aliasing, self-invoking packaging functions. Example given in blog: a convoluted code snippet is simplified to a more direct form. ([Jswzl][1])
   * Prettifies code (formatting, correct indentation) to ease human review. ([Jswzl][2])
   * Attempt to dereference variables via a simple interpreter (so variable aliasing doesn’t hide the usage). Eg: `var a=1; var b=a; call(b)` → tool resolves call to `call(1)`. ([Jswzl][1])

3. **Analysis / descriptor extraction**

   * AST passes that interpret code semantics:

     * *String Expressions* → look for literal strings that “look like” paths, secrets, GraphQL query strings. ([Jswzl][1])
     * *Object Schemas* → find object literals that conform to a pattern (for example HTTP request options: `{ method:'POST', headers:{…}, body:… }`) inside the code. ([Jswzl][1])
     * *Call Expressions* → locate calls to functions or methods that may be interesting (e.g., `fetch`, `XMLHttpRequest`, `localStorage.setItem`, `window.addEventListener('message', …)`) and refer back to object schemas/strings to contextualize. ([Jswzl][2])
   * The result is a structured output: for each descriptor you get metadata (source file, line/column, code snippet, type of descriptor) and an interactive UI for exploration.

4. **Integration & consumption**

   * Web plugin / proxy (for Burp) ingests JS/HTML traffic, sends to analysis engine. ([Jswzl][1])
   * VS Code extension presents results: shows code tree, descriptors, request history. You can click into descriptor and jump to source. ([Jswzl][2])
   * GraphQL API to pull results programmatically (so you could hook it into your own scripts). ([Jswzl][2])

---

### Strengths (from your vantage)

* Big time‐saver when handling large SPA bundles: automated chunk fetching and map resolution reduce manual overhead.
* Helps expose client‐side endpoints / payloads which often drive API/injection vectors in bug-bounty tests.
* Framework-agnostic: specifically mentions supporting React, Angular, ExtJS but not tied to them. ([Jswzl][2])
* Good for readability: minified & packed code is recovered into something more analyzable.
* Because you’re doing reverse engineering / obfuscated JS, you’ll appreciate the interpreter step for variable dereferencing.
* The fact you can hook it into existing tools (Burp, VS Code) means less disruption to your workflow.

---

### Limitations / caveats (important for a deep user)

* It’s still a **static analysis** tool (though with some dynamic‐style preprocessing). It will not execute arbitrary JS in full context (e.g., if the code relies heavily on runtime DOM/browser environment, heavy dynamic evals, or obfuscated runtime code that mutates at runtime). So certain behaviors may still evade detection.
* Obfuscation/resolution limits: Though it handles many packers and source-maps, extremely aggressive obfuscation (e.g., dynamic code generation, runtime eval chains) may still require manual analysis.
* Cost/licensing: From the site it appears Commercial/Trial rather than fully open‐source. You’ll need to check pricing if you want full features. ([Jswzl][2])
* Integration work: For best results, you’ll need to ensure the JS files/requests are correctly captured via proxy or instrumented, chunks are correctly fetched. In a complex microservice/React build with code‐splitting and runtime loading, you may need to adjust.
* False positives/negatives: As with any heuristic tool, the descriptor extraction may pick up many “noise” items (e.g., many string expressions that look like endpoints but are not exploitable) so you’ll still need to validate manually.
* It may not substitute full dynamic instrumentation (e.g., for runtime behaviors like WebSocket communication, encryption/decryption flows).

---

### Practical Integration Steps (for your stack / bug‐bounty workflow)

Here’s a step-by-step plan to integrate JSWZL into your pentesting / security-analysis workflow (you can adapt to your Spring Boot/React microservice context):

#### Step 1: Install/setup

* Get access to JSWZL: sign up for trial/licensing on [https://jswzl.io](https://jswzl.io). ([Jswzl][2])
* Install the VS Code extension (search “JSWZL” in VS Code marketplace) so you can view results locally.
* Install the Burp Suite plugin/extension: configure Burp to send JS/HTML responses to JSWZL for analysis. (The blog mentions this integration under “1.1 Burp Suite”.) ([Jswzl][1])

  * In Burp Proxy “Intercept” or “Proxy history”, for JS responses, enable forwarding to JSWZL endpoint (as plugin).
  * Configure the plugin to send `.js`, `.map` files, `.html` with embedded `<script>` as required.

#### Step 2: Capture and feed JS/HTML

* While browsing the target web-app (or running your crawler) capture all JS files and HTML pages (especially SPAs).
* Ensure code-splitting lazy loads are triggered (by interacting with the UI) so JSWZL can fetch chunks.
* Configure JSWZL (via plugin) to download source-maps if present.

#### Step 3: Analysis & review

* After ingestion, open VS Code extension: you will see a file tree of JS files + extracted descriptors.
* Review descriptor categories:

  * **String Expressions**: look for unusual paths, GraphQL endpoints, secret keys, localStorage keys.
  * **Object Schemas**: inspect HTTP request payload shapes (e.g., `body: { userId: ..., role: ... }`).
  * **Call Expressions / Sinks**: find interesting API calls, event handlers, or client-side storage manipulation.
* Use the output to prioritise manual testing: e.g., endpoints to fuzz, API payloads to tamper with, client logic flows for injection/privilege issues.

#### Step 4: Integration into your workflow

* Hook the GraphQL API of JSWZL (if permitted) to export descriptors into your own tooling: e.g., feed paths into your intruder scripts, or import object schemas into your fuzzing automation.
* Combine JSWZL output with your typical workflow: for example:

  * Use the extracted endpoints as input for your automated API enumeration (e.g., run Burp Intruder or a custom Python script for that endpoint list).
  * Use the extracted object schemas to craft payload fuzzing (e.g., tamper fields with injection strings).
  * Combine with your knowledge of WebSocket/GraphQL etc (you mentioned you look into modern web apps) and map client-side logic flows to server-side vulnerabilities.

#### Step 5: Feedback loop & refinement

* When you discover a vulnerability (e.g., client side injection, broken authentication), feed that knowledge into your analysis: tag descriptors accordingly, refine your filters in JSWZL so future runs highlight similar patterns.
* Routinely update/trigger JSWZL during deep testing of a large app: e.g., after SPA build changes, or when a new feature is loaded (so chunks new to you are captured).

---

### Use-cases in your context (specialised)

Given your interest in analyzing obfuscated JS, binary analysis, containerization, here are specific angles:

* **Obfuscated/minified SPA code**: Use JSWZL to automatically unwind minification and packaging, reducing manual “beauty-ify + variable rename” steps.
* **Client → API endpoint discovery**: For microservices with heavy JS front-ends, client logic may call many hidden APIs; JSWZL helps map them.
* **GraphQL enumeration**: If the front-end uses GraphQL, JSWZL’s string expression extraction may pick up query strings and schema shapes which can feed into enumeration/fuzzing.
* **Supply-chain analysis / embedded code**: If you are analysing third-party JS libraries in a containerized or cloud environment, JSWZL can help extract interesting calls/behaviors (though dynamic behaviours still may need manual trampolining).
* **Bug-bounty rapid reconnaissance**: Use JSWZL early in a target’s scope to build endpoint lists, object‐term dictionaries, client‐side logic flows, before heavy manual testing.

---

### Comparison / relation with other tools

* Traditional lint/static analysis tools (ESLint, JSHint) focus on code quality/style rather than security‐centric descriptor extraction. (See e.g. ESLint description) ([Wikipedia][3])
* JSWZL is more akin to a *security enumeration-oriented static analysis + enrichment* tool (rather than lint).
* Other research tools (see academic papers) focus on dynamic analysis or fuzzing of JS engines (e.g., FV8, Fakeium) which is more heavy-weight; JSWZL focuses on front‐end JS code in web apps for security testers. ([arXiv][4])

---

### Limitations & what you still must do manually

* Deep runtime behaviours: Client logic may fetch remote code/eval things at runtime, or rely on heavy WebAssembly; static analysis may miss runtime code execution paths.
* Obfuscation using runtime generation or anti-analysis tricks might still hide flows; you may need to complement with dynamic instrumentation or debugging.
* Just because an endpoint / object schema is extracted doesn’t mean it’s vulnerable — you still must validate: e.g., authentication, authorization, business logic, injection vectors.
* For server-side code (e.g., your Spring Boot backend) you’ll still need to analyze code/config there; JSWZL is front-end-centric.
* Over‐reliance on automated extraction can lead to information overload (many false positives); you’ll need to filter and prioritise.

---

### Quick Try-out Guide (CLI/Hands-on)

Here’s a quick minimal workflow to try JSWZL in your test lab:

```bash
# Suppose you have Burp Suite installed and JSWZL plugin (configure via Burp UI)
# 1. Browse your target web app in browser, intercept traffic via Burp
# 2. Ensure JS files / HTML responses go through proxy and plugin sends them to JSWZL
# 3. In VS Code:
#    - Install “JSWZL” extension
#    - Connect to your JSWZL analysis server (host/port as configured)
#    - View the “Descriptors” tab → filter by “Call Expression”
#    - Example: sort by descriptor type “Call Expression” → look for `fetch(` or `document.cookie` or `localStorage.setItem`
# 4. Extract interesting endpoints or payload shapes and export via GraphQL endpoint. For example:
   # (Pseudo-curl)
   curl -X POST https://your-jswzl-server/api/graphql \
     -H "Content-Type: application/json" \
     -d '{"query": "query { descriptors(filter:{type:\"CallExpression\"}) { fileName, line, snippet } }"}'
# 5. Feed fileName/line info into your automated intruder/fuzzer list for further testing
```

---

### Recommendations for you (given your profile)

* Since you do bug‐bounty/web‐app security and JS reverse engineering: adopt JSWZL as part of your **recon/enumeration** phase. Early in a target you can spin up JSWZL to harvest front-end logic, build endpoint lists etc, then feed into deeper exploitation phase (you pick up dynamic instrumentation, manual code review, event hooking).
* Integrate with your containerized/test‐lab setup: e.g., spin up a local copy of the target (React + Spring Boot), intercept JS bundles via Burp + JSWZL plugin to learn how code is structured before going live.
* Combine with your knowledge of obfuscation — when JSWZL flags a code chunk as “packed / requires processing”, you can examine it manually to identify anti‐analysis patterns, then maybe script unpacking/var renaming.
* Given your interest in advanced tooling (ActiveScan++, Kubernetes, microservices): you might script the GraphQL API of JSWZL into your CI/CD pipeline: after each build of a front-end, run JSWZL, flag new descriptors, compare with baseline to detect new endpoints/payloads introduced, and feed into your bug-hunting dashboards.
* Don’t neglect **dynamic behaviour**: use JSWZL to surface what to focus on statically, then pair it with runtime instrumentation (e.g., Chrome DevTools, proxy-based JS instrumentation) for full coverage.

---

[1]: https://www.jswzl.io/post/introducing-jswzl-in-depth-js-analysis-for-web-security-testers?utm_source=chatgpt.com "In-depth JavaScript analysis for web security testers"
[2]: https://www.jswzl.io/?utm_source=chatgpt.com "jswzl"
[3]: https://en.wikipedia.org/wiki/ESLint?utm_source=chatgpt.com "ESLint"
[4]: https://arxiv.org/abs/2405.13175?utm_source=chatgpt.com "FV8: A Forced Execution JavaScript Engine for Detecting Evasive Techniques"


