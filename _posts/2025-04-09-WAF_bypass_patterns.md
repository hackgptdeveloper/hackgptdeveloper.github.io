---
title: "postMessage() usage"
tags:
  - javascript
---

How postMessage() appears across browser context.

---

Below is a list of 100 patterns that can be used at the Web Application Firewall (WAF) level to detect potential HTTP traffic attempting to bypass WAF protections. These patterns focus on common evasion techniques, unusual behaviors, and malicious payloads that attackers might use to circumvent standard WAF rules. Note that these patterns should be tailored to your specific WAF solution and environment, and some may require regex or custom logic for implementation.

### General Evasion Techniques
1. **Unusual HTTP Methods**: Detect non-standard HTTP methods (e.g., `TRACE`, `TRACK`, `OPTIONS`) not typically used by your application.
2. **Encoded Characters in URL**: Look for excessive URL encoding (e.g., `%25%32%35` for `%25`).
3. **Double Encoding**: Identify double-encoded characters (e.g., `%252F` instead of `/`).
4. **Null Bytes**: Detect null byte injections (e.g., `%00`) in URL or headers.
5. **Unicode Abuse**: Spot Unicode-encoded characters (e.g., `%u002f` for `/`).
6. **Mixed Case Headers**: Identify headers with unusual casing (e.g., `HoSt` instead of `Host`).
7. **Whitespace Variations**: Catch excessive or unusual whitespace in requests (e.g., `GET   /path`).
8. **Chunked Transfer Encoding**: Flag unexpected use of `Transfer-Encoding: chunked`.
9. **Multiple Content-Length Headers**: Detect requests with conflicting `Content-Length` values.
10. **Invalid Content-Length**: Spot mismatches between `Content-Length` and actual body size.

### Parameter and Payload Manipulation
11. **Parameter Pollution**: Identify duplicate parameters (e.g., `id=1&id=2`).
12. **Nested Parameters**: Detect attempts to nest parameters (e.g., `param[a][b]=malicious`).
13. **JSON in Unexpected Fields**: Catch JSON payloads in URL parameters or headers.
14. **Base64 Encoded Payloads**: Look for Base64 strings in parameters or cookies (e.g., `YWRtaW4=`).
15. **Hex Encoded Payloads**: Detect hex-encoded strings (e.g., `0x414141`).
16. **Long Parameter Values**: Flag unusually long parameter values (e.g., >1000 characters).
17. **SQL Injection Variants**: Catch SQL keywords with odd spacing (e.g., `S E L E C T`).
18. **SQL Comments**: Detect inline SQL comments (e.g., `--` or `/* */`) in parameters.
19. **Command Injection Variants**: Spot OS commands with separators (e.g., `;ls`, `||whoami`).
20. **Path Traversal Attempts**: Identify `../` or `..\` with variations (e.g., `%2e%2e%2f`).

### Header Manipulation
21. **Fake User-Agent**: Detect suspicious or malformed `User-Agent` strings (e.g., `<script>`).
22. **Missing User-Agent**: Flag requests with no `User-Agent` header.
23. **Custom Headers**: Catch unusual custom headers (e.g., `X-Forwarded-For: malicious`).
24. **Host Header Tampering**: Detect `Host` header mismatches with the target domain.
25. **Referrer Spoofing**: Spot suspicious `Referer` values (e.g., `<script>` or off-site URLs).
26. **Accept Header Abuse**: Identify malformed `Accept` headers (e.g., `Accept: */*;q=evil`).
27. **Cookie Tampering**: Detect oversized or malformed cookies (e.g., `cookie=evil;cookie2=evil`).
28. **Proxy Headers**: Catch unexpected proxy headers (e.g., `Via`, `X-Proxy-ID`).
29. **Multiple Host Headers**: Flag requests with more than one `Host` header.
30. **Invalid Protocol**: Detect requests with non-HTTP protocols in headers (e.g., `ftp://`).

### Request Body and File Uploads
31. **Malformed JSON**: Identify invalid JSON structures in POST requests.
32. **XML Injection**: Detect XML tags in non-XML contexts (e.g., `<tag>` in form data).
33. **File Upload Extensions**: Catch suspicious file extensions (e.g., `.php`, `.exe`).
34. **MIME Type Mismatch**: Flag mismatches between `Content-Type` and actual content.
35. **Binary Data in Text Fields**: Detect binary data in text-based parameters.
36. **Excessive POST Size**: Identify oversized POST requests beyond app limits.
37. **Multipart Form Abuse**: Spot malformed `multipart/form-data` boundaries.
38. **Serialized Data**: Catch PHP/Java serialized objects (e.g., `O:4:"Evil"`).
39. **Encoded File Content**: Detect Base64-encoded files in form fields.
40. **Null-terminated Strings**: Flag strings ending with `%00` in body.

### Behavioral Patterns
41. **High Request Rate**: Detect rapid requests from a single IP (e.g., >100 req/sec).
42. **Randomized Parameter Names**: Spot requests with gibberish parameter names (e.g., `xjdks=1`).
43. **Invalid HTTP Version**: Catch requests with odd HTTP versions (e.g., `HTTP/9.9`).
44. **Slow HTTP Attacks**: Identify requests with delayed headers or body (e.g., slowloris).
45. **Non-Standard Ports**: Flag requests targeting unusual ports (e.g., `:8080` if not allowed).
46. **Suspicious Query Strings**: Detect query strings with script tags (e.g., `?q=<script>`).
47. **Directory Brute Force**: Catch repeated requests to non-existent paths (e.g., `/admin1`, `/admin2`).
48. **Repeated 403/404 Responses**: Flag IPs triggering excessive errors.
49. **Geolocation Anomalies**: Detect requests from unexpected regions (if geo-filtering applies).
50. **Tor/Proxy Usage**: Identify traffic from known anonymizing services (e.g., Tor exit nodes).

### Implementation Notes
- These patterns should be implemented as rules or signatures in your WAF, often using regular expressions, anomaly scoring, or behavioral analysis.
- Combine these with allow/deny lists, rate limiting, and session tracking for better accuracy.
- Test rules in a staging environment to avoid false positives that might block legitimate traffic.
- Adjust thresholds (e.g., request rates, parameter lengths) based on your application's normal behavior.

### Advanced Evasion Techniques
1. **Percent Encoding Variants**: Detect alternate percent encodings (e.g., `%c0%af` for `/`).
2. **Overlong UTF-8**: Spot overlong UTF-8 sequences (e.g., `%c1%9c` instead of `<`).
3. **Backslash Instead of Slash**: Catch `\` instead of `/` in URLs (e.g., `domain\path`).
4. **URL Fragment Abuse**: Detect suspicious fragments (e.g., `#<script>`).
5. **Padded Requests**: Identify requests padded with junk data (e.g., `GET /?a=1&junk=xxx`).
6. **Non-ASCII Characters**: Flag non-ASCII characters in URLs or headers (e.g., `café`).
7. **HTTP/0.9 Requests**: Detect legacy HTTP/0.9-style requests (no headers).
8. **Invalid URL Schemes**: Catch requests with odd schemes (e.g., `data://`, `file://`).
9. **Mixed Slash Directions**: Spot URLs with mixed slashes (e.g., `/path\to/file`).
10. **Unusual Character Sets**: Detect charset mismatches (e.g., `charset=evil`).

### Header Manipulation (Continued)
11. **X-HTTP-Method-Override**: Flag misuse of `X-HTTP-Method-Override` to fake methods.
12. **Expect Header Abuse**: Detect `Expect: 100-continue` with malicious payloads.
13. **Malformed Range Header**: Catch invalid `Range` values (e.g., `Range: bytes=0-evil`).
14. **Connection Header Tricks**: Spot `Connection: keep-alive` with odd values.
15. **TE Header Abuse**: Detect `TE: trailers` with suspicious trailers.
16. **Upgrade Header**: Flag `Upgrade: websocket` on non-websocket endpoints.
17. **Accept-Encoding Tricks**: Catch `Accept-Encoding: gzip;q=evil`.
18. **If-Modified-Since Injection**: Detect script tags in `If-Modified-Since`.
19. **Pragma Header**: Spot unexpected `Pragma: no-cache` variations.
20. **Cache-Control Abuse**: Identify `Cache-Control: no-store;evil`.

### Payload and Parameter Manipulation (Continued)
21. **SQL Concatenation**: Detect concatenated SQL (e.g., `CONCAT('a','b')`).
22. **Hexadecimal SQL**: Catch hex-encoded SQL (e.g., `0x73656c656374` for `select`).
23. **Obfuscated XSS**: Spot script tags with obfuscation (e.g., `scr<script>ipt`).
24. **Polyglot Payloads**: Detect payloads valid in multiple contexts (e.g., JS+SQL).
25. **Eval Constructs**: Flag `eval()`, `exec()`, or similar in parameters.
26. **LDAP Injection**: Catch LDAP syntax (e.g., `*`, `)(` in parameters).
27. **NoSQL Injection**: Detect MongoDB/JSON operators (e.g., `$ne`, `$gt`).
28. **CRLF Injection**: Spot `%0d%0a` (CRLF) in parameters or headers.
29. **Parameter Name Injection**: Detect tags in parameter names (e.g., `<script>=1`).
30. **Boolean Blind SQL**: Catch `1=1`, `true`, or `false` in odd contexts.

### Request Body and File Uploads (Continued)
31. **Gzip Bomb**: Detect compressed payloads that expand excessively.
32. **Malformed XML Entities**: Catch `<!ENTITY` or XXE attempts (e.g., `<!DOCTYPE`).
33. **SOAP Injection**: Spot SOAP envelopes in non-SOAP endpoints.
34. **Hidden File Fields**: Detect unexpected `multipart/form-data` fields.
35. **Executable MIME Types**: Flag `application/x-executable` uploads.
36. **Double Extensions**: Catch files like `image.jpg.php`.
37. **Trailing Data**: Detect junk after file content in uploads.
38. **Empty File Names**: Spot uploads with blank `filename=""`.
39. **JSONP Abuse**: Catch `callback=evil` in JSON requests.
40. **CSV Injection**: Detect `=CMD` or `@SUM` in form data.

### Behavioral and Protocol Anomalies
41. **HEAD Flood**: Flag excessive `HEAD` requests to bypass logging.
42. **HTTP Pipelining**: Detect multiple requests in a single connection.
43. **Invalid Status Codes**: Catch requests specifying odd status (e.g., `HTTP/1.1 999`).
44. **Session ID Tampering**: Spot malformed or oversized session tokens.
45. **Cookie Overflow**: Detect cookies exceeding size limits (e.g., >4096 bytes).
46. **Rapid UA Switching**: Flag IPs changing `User-Agent` frequently.
47. **Suspicious Timing**: Catch requests with precise millisecond gaps.
48. **TLS Fingerprinting**: Detect odd SSL/TLS client hello patterns.
49. **HTTP/2 Abuse**: Spot HTTP/2-specific attacks (e.g., SETTINGS flood).
50. **WebDAV Methods**: Flag `PROPFIND`, `MOVE`, or `COPY` on non-DAV apps.

### Implementation Tips
- Use regex or pattern matching for string-based detections (e.g., `%0d%0a`).
- Leverage anomaly detection for behavioral patterns (e.g., rapid UA switching).
- Combine with IP reputation, rate limiting, and context-aware rules.
- Monitor logs for emerging patterns not yet codified here.
- Test extensively to minimize false positives, especially with encoded or behavioral rules.

Let me know if you’d like examples of regex for any of these or assistance integrating them into a specific WAF!


