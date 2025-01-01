---
title: "common mistakes to avoid when using JSON Web Tokens (JWT) for authentication or authorization"

tags:
  - JWT
---

Here are 30 common mistakes to avoid when using JSON Web Tokens (JWT) for authentication or authorization:

---

### **1. Not Validating the Token's Signature**
Failing to validate the token's signature allows attackers to forge or tamper with tokens.

---

### **2. Using Symmetric Keys on Both Client and Server**
Sharing the symmetric key with the client compromises the security of the token, allowing anyone with the key to forge valid tokens.

---

### **3. Not Checking the `exp` Claim**
Ignoring the expiration claim (`exp`) allows expired tokens to remain valid indefinitely.

---

### **4. Hardcoding Secrets in Source Code**
Storing secrets or private keys in source code exposes them to potential leaks through version control or reverse engineering.

---

### **5. Using Weak or Guessable Signing Keys**
Using easily guessable keys (e.g., `1234` or `password`) makes tokens vulnerable to brute force attacks.

---

### **6. Ignoring the `aud` and `iss` Claims**
Failing to validate the audience (`aud`) or issuer (`iss`) claims can result in accepting tokens intended for other services or issued by untrusted entities.

---

### **7. Exposing JWTs in URLs**
Including JWTs in URLs (e.g., query parameters) makes them vulnerable to logging or leakage through browser history.

---

### **8. Not Using HTTPS**
Transmitting tokens over insecure HTTP connections exposes them to interception via man-in-the-middle (MITM) attacks.

---

### **9. Storing JWTs in Local Storage**
Local storage is vulnerable to cross-site scripting (XSS) attacks, exposing the token if malicious scripts gain access.

---

### **10. Using Weak Algorithms**
Using insecure algorithms like `none` or outdated ones like `HS256` (when `RS256` is more appropriate) weakens token security.

---

### **11. Relying on JWT for Sessions Without Revocation Mechanism**
Not having a way to revoke JWTs means users cannot log out effectively, and compromised tokens remain valid until they expire.

---

### **12. Failing to Implement Refresh Tokens Properly**
Not using refresh tokens correctly can lead to shorter-lived tokens being continually refreshed, negating their expiration.

---

### **13. Storing Sensitive Information in the Payload**
Embedding sensitive user data (e.g., passwords, PII) in the token payload risks data exposure if the token is intercepted or decoded.

---

### **14. Ignoring Token Size Limits**
Using excessively large payloads can lead to performance issues or failure when transmitting tokens via headers or cookies.

---

### **15. Allowing Unvalidated Token Sources**
Accepting tokens from any source (e.g., user input without validation) increases the risk of tampering or injection attacks.

---

### **16. Ignoring Clock Skew for `nbf` and `exp`**
Not accounting for clock skew may cause valid tokens to be prematurely rejected.

---

### **17. Overusing JWTs**
Using JWTs for scenarios where session cookies or simpler tokens would suffice can introduce unnecessary complexity and risk.

---

### **18. Not Rotating Signing Keys**
Failing to periodically rotate keys increases the risk of exposure and long-term compromise.

---

### **19. Mismanaging Blacklisted Tokens**
Not maintaining or verifying blacklisted tokens allows revoked tokens to remain valid.

---

### **20. Relying on Client-Side Validation Alone**
Performing all validation client-side without server-side checks allows bypassing of critical security measures.

---

### **21. Trusting Self-Signed JWTs**
Accepting tokens signed with self-generated or unverified keys undermines the authentication process.

---

### **22. Ignoring Claims Validation**
Not verifying claims like `sub`, `aud`, `iat`, or custom claims allows unauthorized access or misuse.

---

### **23. Using JWT for CSRF-Prone Actions**
JWTs do not inherently protect against cross-site request forgery (CSRF) attacks, especially if stored in cookies.

---

### **24. Not Securing Tokens in Cookies**
Storing tokens in cookies without enabling `HttpOnly` and `Secure` flags exposes them to XSS and MITM attacks.

---

### **25. Assuming JWTs are Fully Encrypted**
JWT payloads are only Base64URL-encoded, not encrypted, unless explicitly protected (e.g., with JWE).

---

### **26. Overlooking Rate Limiting**
Allowing unlimited token issuance or validation attempts facilitates brute force and abuse.

---

### **27. Using a Single Token for All Permissions**
Granting excessive permissions in a single token increases risk if the token is compromised.

---

### **28. Allowing Infinite Lifetimes**
Tokens without expiration (`exp`) claims can be used indefinitely if compromised.

---

### **29. Blindly Trusting Third-Party Tokens**
Accepting third-party tokens without proper validation or trust verification introduces significant risk.

---

### **30. Not Auditing Token Usage**
Failing to log and monitor token usage prevents detection of suspicious activity or abuse.

---

### Summary
Avoiding these mistakes ensures that JWT-based authentication and authorization systems remain secure, efficient, and resistant to common attack vectors.

