---
title: "Identifying Access Control Bugs"
tags:
  - AccessControl
---

Access control bugs can be critical in exposing sensitive data or allowing unauthorized actions. Here are **30 methods** to detect access control bugs systematically:

---

### **General Reconnaissance and Analysis**
1. **Role-Based Access Review**  
   Compare permissions of different roles to ensure access is restricted based on the principle of least privilege.

2. **Horizontal Privilege Escalation Testing**  
   Attempt to access resources of another user at the same privilege level (e.g., user accessing another user’s data).

3. **Vertical Privilege Escalation Testing**  
   Test actions or resources intended only for higher-privileged users (e.g., accessing admin functionality as a regular user).

4. **Session Token Manipulation**  
   Modify session tokens or cookies to simulate another user or higher privilege level.

5. **Parameter Tampering**  
   Change resource IDs, user IDs, or object references in API requests or URLs to test if they’re validated on the server side.

---

### **Backend and API-Focused Techniques**
6. **Direct Object Reference Testing**  
   Test insecure direct object references (IDOR) by accessing objects using sequential or guessable identifiers.

7. **API Endpoint Enumeration**  
   Identify and test undocumented or hidden API endpoints for improper access controls.

8. **Missing Function-Level Access Control**  
   Call high-privilege API methods without appropriate privilege levels.

9. **Mass Assignment Exploitation**  
   Submit additional fields in API requests (e.g., `isAdmin=true`) and test if unauthorized fields are processed.

10. **Testing Default Endpoints**  
    Check for default, unprotected endpoints in frameworks like `/admin`, `/graphql`, or `/debug`.

---

### **Authentication and Session Hijacking**
11. **Privilege Changes Post Authentication**  
    Observe if session attributes change after privilege escalation or de-escalation, like moving from user to admin.

12. **Session Fixation**  
    Check if session tokens remain the same after privilege escalation, allowing attackers to hijack elevated sessions.

13. **Multi-Step Authorization Testing**  
    Verify that every step of a multi-step process enforces access control (e.g., checkout flows).

14. **Cross-Account Session Reuse**  
    Attempt to reuse session data across different accounts to verify isolation.

15. **Test Forgotten Password Workflow**  
    Check if users can reset passwords for other accounts or escalate privileges.

---

### **Input and Payload Manipulation**
16. **Force Browsing**  
    Attempt direct access to resources by guessing or constructing URLs without proper authorization.

17. **Header Tampering**  
    Modify headers like `X-Forwarded-For`, `Referer`, or `Authorization` to spoof requests.

18. **Replay Attacks**  
    Replay captured requests with modified parameters to verify if authorization is properly implemented.

19. **Testing HTTP Methods**  
    Test different HTTP methods (e.g., `PUT`, `DELETE`) on resources intended for read-only access.

20. **Bypassing Access Control via CORS**  
    Identify misconfigured CORS headers that allow unauthorized domains to access sensitive APIs.

---

### **UI and Frontend Testing**
21. **Hidden Elements and Features**  
    Inspect hidden form fields or UI elements that may expose higher privilege functionality.

22. **JavaScript Analysis**  
    Analyze client-side JavaScript for exposed endpoints or access control logic.

23. **Disabling Client-Side Checks**  
    Bypass client-side access control checks by tampering with the DOM or JavaScript.

24. **Forced Parameter Injection**  
    Append additional GET/POST parameters in URLs or forms to test for unhandled access control.

25. **Testing Input Constraints**  
    Bypass UI restrictions by sending raw API requests outside the intended input constraints.

---

### **Edge Case and Environmental Testing**
26. **Testing Default Roles and Users**  
    Test for default or forgotten roles/users (e.g., admin/admin, test/test).

27. **Rate Limiting and Bulk Access**  
    Check if bulk operations like scraping or downloading data bypass access controls.

28. **Privilege Creep**  
    Identify scenarios where roles or permissions are not revoked after privilege de-escalation.

29. **Misconfigured ACLs**  
    Analyze Access Control Lists (ACLs) for improper wildcard or overly permissive rules.

30. **Time-Limited Token Exploitation**  
    Test for issues with tokens or links that should expire but don’t (e.g., password reset links).

---

### **Systematic Testing Practices**
- **Automation**: Tools like Burp Suite, OWASP ZAP, and custom scripts for automating common access control tests.
- **Manual Review**: Critical in identifying logic flaws or assumptions in access control implementations.
- **Code Analysis**: Analyze source code to verify role checks, middleware enforcement, and privilege restrictions.

