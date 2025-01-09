---
title: "Top 100 Content Security Policy (CSP) features"
tags:
  - CSP
---

Content Security Policy (CSP) is an HTTP header that provides a robust mechanism to mitigate certain types of attacks, such as Cross-Site Scripting (XSS) and data injection. Here are the **top 50 features** and directives supported by CSP:

### 1-10: Basic Content Control Directives
1. **default-src**: Sets a default policy for all resource types not explicitly mentioned in other directives.
2. **script-src**: Specifies allowed sources for JavaScript.
3. **style-src**: Specifies allowed sources for stylesheets.
4. **img-src**: Defines valid sources for images.
5. **connect-src**: Controls URLs that can be loaded using script interfaces (e.g., `fetch`, `XMLHttpRequest`).
6. **font-src**: Defines valid sources for font resources.
7. **object-src**: Specifies valid sources for the `<object>`, `<embed>`, and `<applet>` elements.
8. **media-src**: Defines sources for `<audio>` and `<video>` elements.
9. **frame-src**: Specifies valid sources for embedding `<frame>` and `<iframe>` content.
10. **worker-src**: Specifies valid sources for Worker and SharedWorker scripts.

### 11-20: Advanced and Control Directives
11. **child-src**: Controls resources for nested browsing contexts, like `<frame>` and `<iframe>`.
12. **form-action**: Restricts the URLs to which forms can be submitted.
13. **frame-ancestors**: Specifies valid parents that may embed the current page using `<frame>`, `<iframe>`, or `<object>`.
14. **sandbox**: Applies restrictions to a page or frame, similar to the `sandbox` attribute on an `<iframe>`.
15. **plugin-types**: Restricts the MIME types of plugins that can be loaded.
16. **base-uri**: Restricts the URLs to which a document’s `<base>` element can point.
17. **manifest-src**: Specifies allowed sources for manifest files.
18. **prefetch-src**: Specifies valid sources for prefetching or prerendering.
19. **navigate-to**: Limits the URLs the page can navigate to using links or redirects.
20. **require-trusted-types-for**: Enforces the use of `Trusted Types` to prevent XSS.

### 21-30: Subresource Integrity and Input Restrictions
21. **block-all-mixed-content**: Blocks all mixed content requests.
22. **upgrade-insecure-requests**: Automatically upgrades HTTP requests to HTTPS.
23. **trusted-types**: Defines policies that control which functions can create DOM objects from strings.
24. **report-uri**: Specifies where violation reports are sent.
25. **report-to**: Sends violation reports to a `Reporting API` endpoint.
26. **nonce-attribute**: Allows the use of a nonce (`'nonce-xxxx'`) to whitelist scripts or styles.
27. **strict-dynamic**: Works with `'unsafe-inline'` and nonces to allow only dynamically created scripts.
28. **unsafe-inline**: Allows inline JavaScript and CSS (should be avoided in strict CSP).
29. **unsafe-eval**: Allows the use of `eval()` and similar functions (should be avoided in strict CSP).
30. **self**: A source keyword that allows loading from the same origin.

### 31-40: Source Control Keywords
31. **none**: Disallows all content for the directive.
32. **unsafe-hashes**: Allows the use of specific hashes for inline scripts.
33. **strict-origin**: Restricts requests to the same origin, with a strict scheme.
34. **strict-origin-when-cross-origin**: Allows restricted cross-origin requests while protecting sensitive data.
35. **data:**: Allows inline data URIs (e.g., `data:image/png`).
36. **blob:**: Allows `blob:` URLs.
37. **filesystem:**: Allows `filesystem:` URLs.
38. **https:**: Restricts resources to HTTPS sources.
39. **http:**: (not recommended) Allows resources from insecure HTTP.
40. **'unsafe-inline-hashes'**: Allows using hashes with inline code.

### 41-50: Reporting and Miscellaneous
41. **report-sample**: Allows the browser to include sample code in reports.
42. **script-src-attr**: Specifies valid sources for inline event handlers and script attributes.
43. **style-src-attr**: Specifies valid sources for inline `style` attributes.
44. **style-src-elem**: Specifies valid sources for `<style>` and `<link>` elements.
45. **script-src-elem**: Specifies valid sources for external scripts.
46. **cross-origin-embedder-policy**: Used for embedding security and cross-origin isolation.
47. **cross-origin-opener-policy**: Prevents cross-origin communication between windows.
48. **cross-origin-resource-policy**: Controls the sharing of resources with cross-origin requests.
49. **unsafe-hashes-with-fallback**: Allows fallback behavior when using unsafe hashes.
50. **worker-src-attr**: Allows customization of inline worker scripts.

### Summary
These directives and features offer fine-grained control over the resources a web page can load. A well-implemented CSP reduces attack surfaces significantly, improving security against content-based attacks. Use tools like [CSP Evaluator](https://csp-evaluator.withgoogle.com/) to analyze and optimize your CSP policies.
