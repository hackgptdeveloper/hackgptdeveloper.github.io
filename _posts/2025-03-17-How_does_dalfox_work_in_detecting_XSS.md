---
title: "How does Dalfox detect XSS internally"
tags:
  - XSS, Dalfox
---

The motivation for this question is when I tested my payload at http://testphp.vulnweb.com/guestbook.php manually and it worked, but when I passed to dalfox to scan and detect it did not work.

First attempt at ChatGPT gave totally wrong answer - the file never even exists. 

So let's try Grok.

To explain the reflected XSS detection logic in DalFox, I'll break down the key components of its source code based on its open-source repository on GitHub (`hahwul/dalfox`). Since I don’t have direct access to the code here, I'll describe the general structure and logic based on the publicly available documentation, typical XSS detection patterns, and the behavior outlined in DalFox's features. For precise line numbers, you'd need to refer to the latest version of the source code (e.g., `v2.9` or later as of March 2025) in the repository, but I’ll guide you through the conceptual flow and key files involved.

DalFox, written in Go, is a fast parameter analysis and XSS scanning tool that identifies reflected XSS by analyzing HTTP responses for injected payloads. Its reflected XSS detection logic primarily revolves around sending crafted payloads, checking if they are reflected in the response, and verifying if they can execute in a browser-like context (often via DOM parsing). Here's how this works, step-by-step, with references to the likely locations in the source code:

---

### Key Files Involved
1. **`pkg/scanning/scan.go`**  
   - This file contains the core scanning logic, including the process of sending requests and analyzing responses.
   - The `Scan` function orchestrates the scanning process, calling subroutines for parameter analysis and payload testing.

2. **`pkg/scanning/payload.go`**  
   - This file defines the payload generation logic, including the creation of test strings for reflected XSS detection.

3. **`pkg/verification/verify.go`** (or similar)  
   - This file handles the verification of reflected payloads, often using DOM-based analysis to confirm XSS executability.

4. **`lib/`** (e.g., `lib/request.go` or similar)  
   - Contains utility functions for making HTTP requests and handling responses.

---

### Reflected XSS Detection Logic Breakdown

#### 1. **Parameter Discovery and Injection**
   - **Where**: `pkg/scanning/scan.go` (likely in the `Scan` function or a related method like `ParameterAnalysis`).
   - **What Happens**: DalFox starts by identifying parameters in the target URL (e.g., `?cat=123&artist=123`). It then injects test payloads into these parameters to check for reflection. This is part of the "parameter analysis" phase, where it finds "reflected params" (as noted in the GitHub README).
   - **Logic**: 
     - It iterates over URL query parameters, headers, or POST data (configurable via flags like `-p` or `-d`).
     - For each parameter, it injects a unique, identifiable string (e.g., `dalfox-test`) or a basic XSS payload (e.g., `"><test>`).
     - Example: For `http://example.com/?cat=123`, it might test `http://example.com/?cat=123dalfox-test`.

#### 2. **Sending Requests**
   - **Where**: `lib/request.go` or a helper function in `pkg/scanning/scan.go` (e.g., `SendReq`).
   - **What Happens**: DalFox sends HTTP requests with the modified parameters using Go’s `net/http` package. It supports customization (e.g., headers via `-H`, cookies via `-C`, or method override via `-X`).
   - **Logic**: 
     - Constructs an HTTP request with the injected payload.
     - Records the response body, headers, and status code.
     - Example call might resemble:
       ```go
       resp, err := SendReq("GET", "http://example.com/?cat=123dalfox-test", options)
       if err != nil { /* handle error */ }
       ```

#### 3. **Checking for Reflection**
   - **Where**: `pkg/scanning/scan.go` (possibly in a function like `CheckReflection` or within `Scan`’s response handling).
   - **What Happens**: After receiving the response, DalFox checks if the injected payload appears unchanged in the response body. This indicates potential reflection, a prerequisite for reflected XSS.
   - **Logic**: 
     - Searches the response body for the exact string injected (e.g., `dalfox-test` or `"><test>`).
     - Uses string matching or regex to confirm reflection (e.g., `strings.Contains(resp.Body, payload)`).
     - If reflected, it flags the parameter as vulnerable and proceeds to verification.
     - Example:
       ```go
       if strings.Contains(resp.Body, payload) {
           fmt.Println("[W] Reflected Payload in HTML:", payload)
           // Proceed to verification
       }
       ```

#### 4. **Payload Generation for XSS Testing**
   - **Where**: `pkg/scanning/payload.go` (likely in a function like `GeneratePayloads` or `GetXSSPayloads`).
   - **What Happens**: Once reflection is confirmed, DalFox generates a set of XSS payloads tailored to the context (e.g., HTML, attributes, JavaScript). These payloads are drawn from built-in lists, custom files (`--custom-payload`), or remote sources (`--remote-payloadbox`).
   - **Logic**: 
     - Constructs payloads like `"><svg onload=alert(45)>` or `"><img src=x onerror=alert(1)>`.
     - Encodes payloads if needed (e.g., double URL encoding via `--encoder-url`).
     - Example payloads from the README:
       - `"><svg/class="dalfox"onLoad=alert(45)>`
       - `'><img/src/onerror=.1|alert``>`

#### 5. **Verification of Executability**
   - **Where**: `pkg/verification/verify.go` or integrated into `pkg/scanning/scan.go`.
   - **What Happens**: DalFox doesn’t just stop at reflection—it verifies if the reflected payload can execute. It uses DOM-based verification (via a Go-based DOM parser) or headless browser simulation to check if the payload triggers an XSS condition (e.g., an `alert()`).
   - **Logic**: 
     - Parses the response HTML using a DOM library (e.g., `github.com/PuerkitoBio/goquery` or similar).
     - Checks the context of the reflection (e.g., in HTML, attribute, or JS) and whether the payload breaks out of that context.
     - For example, if `"><svg onload=alert(45)>` is reflected in `<div>USER_INPUT</div>`, it becomes `<div>"><svg onload=alert(45)></div>`, which is executable.
     - Marks it as `[V]` (verified) if successful:
       ```go
       if VerifyXSS(resp.Body, payload) {
           fmt.Println("[V] Triggered XSS Payload:", urlWithPayload)
       }
       ```

#### 6. **Optimization and Filtering**
   - **Where**: `pkg/scanning/scan.go` or a helper like `OptimizePayloads`.
   - **What Happens**: DalFox eliminates unnecessary payloads based on "bad characters" or context (e.g., if `"` is filtered, it skips payloads relying on it). It also runs tests in parallel for speed.
   - **Logic**: 
     - Analyzes the response for filtering patterns (e.g., WAF detection via `--waf-evasion`).
     - Adjusts payloads dynamically to fit the injection point.

---

### Example Flow in Code
Here’s a simplified pseudo-code representation of how this might look in `pkg/scanning/scan.go`:
```go
func Scan(target string, options Options) {
    params := ExtractParams(target) // Step 1: Find parameters
    for _, param := range params {
        testPayload := "dalfox-test"
        url := InjectPayload(target, param, testPayload)
        resp, err := SendReq("GET", url, options) // Step 2: Send request
        if err != nil { continue }

        if strings.Contains(resp.Body, testPayload) { // Step 3: Check reflection
            xssPayloads := GeneratePayloads() // Step 4: Generate XSS payloads
            for _, payload := range xssPayloads {
                urlWithXSS := InjectPayload(target, param, payload)
                resp, _ := SendReq("GET", urlWithXSS, options)
                if VerifyXSS(resp.Body, payload) { // Step 5: Verify executability
                    fmt.Println("[V] Verified XSS:", urlWithXSS)
                }
            }
        }
    }
}
```

---

### Specific Lines (Hypothetical)
Since exact line numbers depend on the version, here’s where to look in the latest `hahwul/dalfox` repository:
- **Reflection Check**: `pkg/scanning/scan.go`, likely around lines 200–300 in a function like `Scan` or `CheckReflection`.
- **Payload Generation**: `pkg/scanning/payload.go`, around lines 20–100 where payloads are defined or generated.
- **Verification**: `pkg/verification/verify.go` (or similar), possibly lines 50–150 where DOM parsing occurs.

For precise lines, clone the repository (`git clone https://github.com/hahwul/dalfox`), navigate to these files, and search for terms like `reflect`, `payload`, or `verify`. The README and wiki also provide example outputs (e.g., `[POC][R][GET]`) that hint at the logic’s implementation.

---

### Conclusion
DalFox’s reflected XSS detection combines parameter injection, response analysis, payload crafting, and DOM-based verification. Its efficiency comes from parallel testing and context-aware payload optimization. To dive deeper, explore the `pkg/scanning` and `pkg/verification` directories in the source code, focusing on the interplay between `scan.go` and `payload.go`. This modular design makes it both powerful and extensible for XSS hunting!

